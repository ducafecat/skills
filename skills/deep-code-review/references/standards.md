# Standards 检查要求

## 仓库标准

- 只读取 manifest 的 standardSources；该列表来自 Git 跟踪文件及 changed path 对应层级，不扫描 ignored 目录。
- 仓库明确记录的标准优先。跳过 lint、formatter、typecheck 等工具已经强制执行的内容。
- 标准违反可以作为确定 finding；必须指出具体标准来源。

## Fowler code smells baseline

以下仅作启发式判断，finding 必须标注为主观代码异味：

- **Mysterious Name**：名称不能揭示行为或数据含义。
- **Duplicated Code**：变更的多个 hunk 重复同一逻辑结构。
- **Feature Envy**：代码主要操作另一个对象的数据。
- **Data Clumps**：相同字段或参数组合反复一起传递。
- **Primitive Obsession**：primitive/string 代替明确的领域概念。
- **Repeated Switches**：同一类型判断 cascade 重复出现。
- **Shotgun Surgery**：一项逻辑修改被迫分散到许多文件。
- **Divergent Change**：一个模块混入多个不相关的变化原因。
- **Speculative Generality**：为当前不需要的场景增加抽象或 hook。
- **Message Chains**：调用方依赖过长的内部访问链。
- **Middle Man**：函数或类型主要做无价值转发。
- **Refused Bequest**：实现者忽略大部分继承契约。

不报告只凭个人偏好的命名或结构意见，也不要求为消除异味进行与当前变更不成比例的重构。
