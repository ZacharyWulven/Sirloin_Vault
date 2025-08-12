---
layout: post
title: 06-Text2SQL 自助式数据报表开发
date: 2025-08-08 16:45:30.000000000 +09:00
categories: [AI, AIStarted]
tags: [AI, AIStarted]
---


## Text2SQL：自助式数据报表开发

## 数据格式
* 非结构化数据：PDF，Word，图片
* 结构化数据：Excel，SQL


## 自助式数据报表开发方式
1. LangChain 中的 SQL Agent
2. 自己编写（LLM + Prompt）


## Text to SQL 技术
* 将自然语言问题自动转换为结构化的 SQL 查询语句，可以让用户更直观的与数据库进行交互。

### Text-to-SQL 的技术演变经历了 3 个阶段：（了解）
* 早期阶段：依赖于人工编写的规则模板来匹配自然语言和 SQL 语句之间的对应关系
* 机器学习阶段（sequence to sequence）: 采用序列到序列模型等机器学习方法来学习自然语言和 SQL 之间的映射关系
* LLM 阶段: 借助 LLM 强大的语言理解和代码生成能力，利用提示工程、微调等方法将 Text-to-SQL 性能提升到新的高度


### 我们目前已处于 LLM 阶段，基于 LLM 的 Text-to-SQL 系统会包含以下几个步骤：
* 自然语言理解: 分析用户输入的自然语言问题，`理解其意图和语义`
* 模式链接: 将问题中的`实体与数据库模式`中的表和列进行链接
* SQL 生成: 根据理解的语义和模式链接结果，生成相应的 SQL 查询语句
* SQL 执行: 在数据库上执行 SQL 查询，将结果返回给用户


### LLM 模型选择
* 闭源模型
    - GPT-o1/o3: o1 模型开启了新的 Scaling Law，更专注于推理阶段，在编程和 Text to SQL 中能力优于 gpt-4o，同时 mini 模型速度更快，价格更低
    - Claude 3.7-sonnet: Anthropic 公司于 2025 年 2 月发布，号称迄今为止最智能的模型，首款混合推理模型 Claude 3.7-sonnet 实现了两种思考方式的结合，既能提供接近即时的响应，也能展示分步骤的详细思考过程
    - Claude 3.5-sonnet：2024 年推出的模型，支持 20 万 tokens 上下文，性能超过 GPT-4o，在 Cursor 中使用非常顺滑
    - Gemini 2.0：性能强悍，支持 100 万 token 上下文
    - Qwen-Turbo：支持 100 万 token 上下文，速度快，价格非常便宜


* 开源模型
    - DeepSeek-V3: 在代码生成任务中表现出色，能够快速生成高质量的代码片段。它通过从 DeepSeek-R1 中蒸馏推理能力，显著提升了代码生成的准确性和效率
    - DeepSeek-R1: R1 在代码生成和复杂逻辑推理方面表现卓越，特别是在处理复杂的编程任务和数学问题时，准确率更高。例如，在 Codeforces Elo 评分中，R1 达到 2029 分，超越 96.3% 的人类参赛者
    - Qwen：Qwen 系列从 0.5B，1.5B，3B，7B，14B，32B，72B 等多种尺寸，性能优于 Llama3.1。

* 代码大模型
    - Qwen-Coder：能力强，接近闭源一线大模型，其中 Qwen2.5-Coder-32B 能力与 GPT-4o 持平
    - CodeGeeX：智谱开源的代码大模型，基于 GLM 底座，性能卓越，在 vscode 等编辑器中可以找到对应的插件。
    - SQLCoder：专为 SQL 生成而设计的开源模型，但是维护更新慢。所以不建议使用
    - DeepSeek-Coder：在多种编程语言中与开源代码模型中实现了先进的性能




## 搭建 SQL Copilot
### 方法 1：SQLDatabase
* 采用 LangChain 框架，提供了 sql chain，prompt，retriever，tools, agent，让用户通过自然语言，执行 SQL 查询
* 优点：使用方便，自动通过数据库连接，获取数据库的 metadata
* 不足：执行不灵活，需要多次判断哪个表适合复杂查询很难胜任，对于复杂查询通过率低，多次调用 LLM

* SQL Agent (来自 Langchain) 封装了一些工具
    - step1：sql_db_list_tables 对所有的数据表进行筛选，例如 heros 表
    - step2：sql_db_schema 查看具体的数据表，参数 heros 
    - step3：sql_db_query 撰写 SQL 进行查询，得到查询结果


### 方法 2：自己编写 SQL + 向量数据库 + LLM
* 本质是：LLM + RAG 选择适合的 LLM，比如：ChatModel: DeepSeek-V3，CodeModel: Qwen2.5-Coder, CodeGeeX2-6B RAG，可以分成：向量数据库检索 + 固定文件（比如本地数据表说明等）
* 优点：重心在于 RAG 的提供上，准确性高，配置灵活
* 不足：需要设置的条件规则多

* 向量数据库可以提供领域知识，当用户检索某个问题的时候 => 从向量数据库中找到相关的内容，放到 prompt中 => 提升 SQL 查询的相关性
    - 历史回答问题都写过哪些 SQL，向量数据库中存储之前写好的 SQL 语句


#### Thinking：除了对用户 query，补充领域知识外，针对专门名词（用户可以拼写错误的），也可以进行纠正
* 向量数据库的作用：
    - 给 Prompt 提供更多的 context，用于 LLM 进行决策


#### Thinking：使用向量数据库的时候，有哪些可以优化的地方？
1. 使用 similarity threshold，来决定 retrieved examples 的质量（有些 example 和用户 query 关系不大）
    - 例如，如果 similarity threshold 大于多少才使用
2. 优化 few-show examples 的多样性，让尽可能多的情况展示给 prompt





#### SQL Prompt Best Practice

```python
prompt = f"""-- language: SQL
### Question: {query}
### Input: {create_sql}
### Response:
Here is the SQL query I have generated to
answer the question `{query}`:
```sql
"""
```


### Prompt 写法很重要，解释：
1. 说明语言类型，-- language: SQL
2. 将 SQL 建表语句放到 SQL prompt 中，因为 LLM 是通过 SQL 建表语句进行识别的
3. SQL 编写用 ```sql（是 markdown 语法，上边意思补全 sql），放到 prompt 最后 Prompt 中的首尾很重要



> `create_sql` 是数据表的建表语句(建表语句可以写一个注释或值的范围)，`query` 是用户查询的问题。
把 metadata 数据表的定义，一些术语的定义，给到大模型，能让结果更准确
{: .prompt-info }


### 方法 3 Vanna



## [Vanna](https://github.com/vanna-ai/vanna)
* Vanna 是开源的 RAG 框架，专注于将自然语言转换为 SQL 查询（Text-to-SQL），并支出与数据库的交互
* Result correct 的会放到对题本里；错的会放到错题本里；都是放到向量数据库


![image](/assets/img/ai/start/vanna.jpg)


### Vanna 特点：
* 开源与可定制化：Vanna 提供完整的 Python 库，支持本地化部署，允许用户自定义大语言模型（LLM）、向量数据库（VectorDB）和关系型数据库（如 MySQL、PostgreSQL 等）。
* RAG 增强的准确性：通过检索增强生成技术，结合数据库的元数据（如 DDL 语句、表注释、示例 SQL 等）训练模型，显著提升复杂查询的准确率。
* 多场景支持：适用于企业数据分析、智能客服、电商搜索、金融报告生成等场景，非技术人员可通过自然语言直接查询数据库。
* 灵活的基础设施：支持多种 LLM（如 OpenAI、本地部署的 Ollama）、向量数据库（如 ChromaDB），并可扩展至非默认支持的数据库。




### Vanna 工作原理
1. 训练 RAG 模型：即源数据存储到向量数据库中
    - 输入数据库的元数据（如 INFORMATION_SCHEMA）、DDL 语句、文档或示例 SQL
    - 模型将这些信息转换为向量并存储到向量库中，用于后续检索
2. 生成 SQL
    - `用户提问时，系统从向量库中检索相关上下文，组装成 Prompt 发送给 LLM`
    - LLM 生成 SQL 后，自动执行并返回结果（表格或图表）

### 使用步骤
* 安装: pip install vanna，可选扩展如 vanna[chromadb,ollama,mysql] 支持本地化部署

```shell
$ pip install "vanna[chromadb,ollama,mysql]"
```

* 连接数据库
    - 自定义 run_sql 方法（如 MySQL 需通过 mysql.connector 返回 Pandas DataFrame）
    
* 训练模型
    - 通过 DDL、文档或 SQL 示例训练，例如：vn.train(ddl="CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100))")

* 提问与查询
    - 调用 vn.ask("查询销售额最高的产品")，生成并执行 SQL



### ask 函数
* 作用：用户通过自然语言提问时调用此函数，它是查询的核心入口，会依次调用 generate_sql、run_sql、
generate_plotly_code、get_plotly_figure 四个函数来完成整个查询及可视化的过程
* 工作流程：
    - 首先将用户的问题转换成向量表示，然后在向量数据库中检索与问题语义最相似的 DDL 语句、文档和 SQL 查询
    - 将检索到的信息和用户的问题一起提供给 LLM，生成对应的SQL查询
    - 执行生成的 SQL 查询，并将查询结果以表格和 Plotly 图表的形式返回给用户
    - 比如：vn.ask("查询 heros 表中 英雄攻击力前 5 名的英雄")



### generate_sql 函数
* 作用：根据用户输入的自然语言问题，生成对应的SQL语句。
* 工作流程：
    - 调用 get_similar_question_sql 函数，在向量数据库中检索与问题相似的 sql/question对
    - 调用 get_related_ddl 函数，在向量数据库中检索与问题相似的建表语句 ddl
    - 调用 get_related_documentation 函数，在向量数据库中检索与问题相似的文档
    - 调用 get_sql_prompt 函数，结合上述检索到的信息生成 prompt，然后将 prompt 提供给 LLM，生成 SQL 语句



### run_sql 函数
* 作用：执行 generate_sql 函数生成的 SQL 语句，并返回查询结果
* 工作流程：将生成的 SQL 语句发送到连接的数据库中执行，获取并返回查询结果
    - 例如：sql=vn.generate_sql("查询heros表中 英雄攻击力前5名的英雄")



### Vanna 优势：
1. 向量数据库的管理（DDL、文档、错题本）
2. 数据生画图，并且支持多种图表样式





## Q&A
### 1 自助式报表时 BI 吗？
* 主要是 Text2SQL，自然语言撰写 SQL，进行数据表的查询


### 2 PDF 里复杂表格不好提取内容
* 是的，表格可能有复杂的情况，比如跨页，合并单元格的
* Step 1：PDF 识别提取表格信息，可以用第三方工具 MinerU 对 PDF 中的图表、图片、公式进行解析
* Step 2：将提取的 .md 中的表格 => 写入 .csv（可以让 LLM 来）
* Step 3：让 LLM 撰写 SQL，获取 access 数据内容
* Step 4：进行对比


### 3 PDF 种类
* 一种是 word 转的，一种是图片扫的
* 图片扫描需要用到 OCR


### 4 百炼 VS modelscope （都是阿里云的）
* 百炼提供的是 API，直接可以使用
* modelscope 提供私有化的下载，可以下载到本地，用 GPU 进行部署和推理


### 5 知识库喂给大模型，思考过程正确，但是答案不正确
1. 换模型，比如 Qwen3 系列
2. 思考准确，可以提取 `<think></think>` 部分，作为上下文，然后再用普通模型进行推理


> Note：deepseek-v3 版本有时候不能调用 function call
{: .prompt-info }


### 6 小 trick：Text2SQL 让 LLM 自己写 SQL
* 方法一：text2SQL function call：就是让大模型写 SQL，比如给它 LLM Prompt，然后使用 qwen-turbo 进行撰写 SQL，解析 SQL
* 方法二： 跳过单独写 text2SQL 函数，直接写一个 exec_sql 函数


### 7 自定义 LLM + RAG + Text2SQL 流程

```
prompt = """
以下是用户问题: {query}
数据库的数据表的定义: {create_sql}

之前类似问题回答: {RAG-qa}
"""
```

> docs(RAG-qa) = knowledgeBase.similarity_search(query,k=2), 执行相似度搜索，找到与查询相关的文档
{: .prompt-info }
