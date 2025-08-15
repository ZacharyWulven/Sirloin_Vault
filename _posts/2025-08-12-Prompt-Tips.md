---
layout: post
title: Prompt-Tips
date: 2025-08-12 16:45:30.000000000 +09:00
categories: [AI, AIStarted]
tags: [AI, AIStarted]
---


## Prompt-Tips
* 提示词工程是我们与语言模型交流的方式，让它按照我们的要求执行。这就需要编写清晰指令，为模型提供完成任务所需的`背景信息`。


## Prompt structure
* 要先明确任务描述
    - 告诉 AI 你的角色是什么？
    - 你要完成什么任务？

1. 1-2 sentences to establish role and high level task `背景信息`
2. Dynamic / retrieved content
3. Detailed task instructions
4. Examples/n-shot（optional）
5. Repeat critical instructions(particularly useful for very long prompts)


## 10 points of Prompt structure
1. Task context:
    - 背景信息、上下文
    - 例如：你提供的 input 都是干什么的
2. Tone context:
    - 调整语气，基于事实
3. Background data/documents/images:
    - 背景、细节、数据、文档、图片等
    
4. Detail task description & rules
    - `<tasks><task id=1></task id=1></tasks>`

5. Examples

6. Conversation history 对话历史
    - 与 Examples 类似确保有足够上下文信息给到大语言模型

7. Immediate task description or request

8. Thinking step by step / take a deep breath

9. Output formatting 输出格式
    - JSON OR XML
10. Prefilled response（if only）


    
    
## how to organize Infomation in your Prompts
* Claude 非常重视标准结构
* disorganized prompts are hard for Claude to comprehend
* Use delimiters like XML tags to organize
    - Just like section titles and header help humans better follow information，
        - using XML tags `<></>` helps Claude understand the prompt's structure
* Claude understands all types of delimiters
    - we just prefer XML becasuse its boundaries are clear and it's token efficient
    - also using markdown，but XML is better    

* 你也可以使用 markdown 但 XML 更好因为它明确了标签内容


## Preventing hallucinations
### Try the following to troubleshoot or minimize hallucinations:
1. Have Claude say `I don't know` if it doesn't know
    - 希望 Claude 不要凭空捏造哪些不在 Prompt 中也不在数据中的细节
    - 如果它不知道选哪个，不希望 Claude 靠猜测来下结论
2. Tell Claude to `answer only if it is very confident` in its response
    - 提醒它只有非常有把握时才回答
3. Have Claude `think before answering`
4. Ask Claude to `find relevant quotes` from long documents then answer using the quotes
    - give it guidance



    
