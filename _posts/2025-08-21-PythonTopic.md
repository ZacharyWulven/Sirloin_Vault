---
layout: post
title: PythonTopic-01
date: 2025-08-21 16:45:30.000000000 +09:00
categories: [Python]
tags: [Python]
---


## TypedDict
* TypedDict 是 Python 类型系统中的一个特殊工具，用于为字典对象提供具名的、固定的键（key）和对应的值类型（value type）。
* 它来自于 typing 模块，主要目的是让静态类型检查器（如 mypy, Pyright, PyCharm 的内置检查器等）能够理解一个字典预期拥有哪些键，以及每个键对应的值是什么类型。


> 简单来说，它让你可以像定义一个`类`一样去定义一个字典的结构，从而获得更好的类型提示和代码检查
{: .prompt-info }


### 主要有两种定义方式：
* 1 类语法（推荐）


```python
from typing import TypedDict

# 定义一个名为 `User` 的 TypedDict，描述用户信息
class User(TypedDict):
    # 声明必需的键及其类型
    name: str
    age: int
    is_active: bool

# 使用这个类型来注解变量
user_data: User = {
    "name": "Bob",
    "age": 25,
    "is_active": False
}

# 类型检查器知道这些键是存在的，并且值是对应的类型
user_name: str = user_data["name"]  # OK
user_age: int = user_data["age"]    # OK

# 类型检查器会捕获拼写错误！
wrong_key = user_data["name"]       # 错误： TypedDict "User" 没有 key "name"

# 类型检查器会捕获类型错误！
user_data["age"] = "not_a_number"   # 错误： 期望 `int`，找到了 `str`

# 缺少必需的键也会被捕获
incomplete_user: User = {
    "name": "Charlie",
    # 错误：缺少 `age` 和 `is_active` 键
}
```

* 2 函数语法


```python
from typing import TypedDict

# 使用函数语法定义相同的 `User` 类型
User = TypedDict('User', {
    'name': str,
    'age': int,
    'is_active': bool
})

# 用法与类语法完全相同
user_data: User = {'name': 'Bob', 'age': 25, 'is_active': False}
```


### 高级用法
* 1 可选键 (Optional Keys)
  - 不是所有键都是必须的。你可以使用 typing.NotRequired 或 total=False 来声明可选键。

```python
from typing import TypedDict, NotRequired

class UserWithOptional(TypedDict):
    name: str          # 必需键
    age: int           # 必需键
    
    # 使用 NotRequired 声明可选键
    phone_number: NotRequired[str] 
    nickname: NotRequired[str]

# 这样创建是合法的
user1: UserWithOptional = {"name": "Alice", "age": 30} # 没有可选键
user2: UserWithOptional = {"name": "Bob", "age": 25, "phone_number": "123-4567"} # 提供一个可选键
```

* 2 全部可选 

```python
from typing import TypedDict

# 将 `total` 参数设为 False，意味着所有键都是可选的
class PartialUser(TypedDict, total=False):
    name: str
    age: int
    is_active: bool

# 可以创建空字典或包含任意键的字典
partial_user: PartialUser = {}
partial_user = {"name": "Dave"}
partial_user = {"age": 40}
```

### 继承

```python
from typing import TypedDict, NotRequired

class BaseUser(TypedDict):
    name: str
    email: str

class AdminUser(BaseUser):
    # 继承 BaseUser 的所有键 (name, email)
    # 并添加新的键
    permissions: list[str]
    # 以及一个可选键
    security_level: NotRequired[int]

# AdminUser 类型现在要求 name, email, permissions，security_level 是可选的
admin: AdminUser = {
    "name": "Superuser",
    "email": "admin@company.com",
    "permissions": ["read", "write", "delete"]
}
```

### Sample


```python
from typing import TypedDict, NotRequired, List

# 1. 定义 API 返回的文章数据的结构
class Article(TypedDict):
    id: int
    title: str
    content: str
    tags: List[str]  # 值是一个字符串列表
    view_count: NotRequired[int]  # 老文章可能没有这个字段

# 2. 模拟一个从数据库或API获取数据的函数
# 返回类型注解为 Article，让调用者知道返回的结构
def fetch_article(article_id: int) -> Article:
    # 模拟数据
    return {
        "id": article_id,
        "title": "Python 3.10 Features",
        "content": "Here are the new features...",
        "tags": ["python", "programming"],
        # "view_count": 1500  # 这个字段是可选的，所以不返回也可以
    }

# 3. 使用函数
article_data = fetch_article(123)

# 类型检查器和IDE都知道这些操作是安全的
print(f"Title: {article_data['title']}") # IDE 会提示 `title` 是有效的键
title_length = len(article_data['title']) # 也知道 title 是 str，所以有 len()

# 安全地访问可选键，因为可能不存在，使用 .get() 是好的做法
view_count = article_data.get('view_count', 0) # 如果不存在，默认为 0
print(f"Viewed {view_count} times")

# 遍历 tags，也知道它是 List[str]
print("Tags:", ", ".join(article_data['tags']))

# 4. 类型检查器会阻止你犯错误
# article_data["nonexistent_key"] # 错误：Article 没有 key 'nonexistent_key'
# article_data["tags"].lower()    # 错误：List[str] 没有 lower() 方法，应该是 article_data['title'].lower()
```


### tips

```python
# state 是 TypedDict 对象
 return {
            **state, // 即把 state 字典打平放入当前 dict
            "error": f"感知阶段出错: {str(e)}",
            "current_phase": "perception"  # 保持在当前阶段
        }

```


### 重要注意事项
* 运行时行为：TypedDict 主要服务于静态类型检查器
  - 在 Python 运行时，它基本上就是一个普通的 dict。它不会在运行时进行任何额外的类型验证或强制约束

* 性能：使用 TypedDict 没有任何运行时性能开销，因为它只在代码静态分析阶段起作用

* 工具支持：要充分发挥 TypedDict 的优势，你必须使用支持它的静态类型检查器（如 mypy）或智能 IDE（如 PyCharm, VS Code with Pylance）

> 总而言之，TypedDict 是编写类型安全、结构清晰的字典驱动代码（例如处理 JSON API 响应）的强大工具，可以极大地提高代码的可维护性和可靠性。
{: .prompt-info }


