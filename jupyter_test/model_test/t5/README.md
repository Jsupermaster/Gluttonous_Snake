---
language:
- ru
- zh
- en
tags:
- translation
license: apache-2.0
datasets:
- ccmatrix
metrics:
- sacrebleu
widget:
  - example_title: translate zh-ru
    text: >
      translate to ru: 开发的目的是为用户提供个人同步翻译。
  - example_title: translate ru-en
    text: >
      translate to en: Цель разработки — предоставить пользователям личного синхронного переводчика.
  - example_title: translate en-ru
    text: >
      translate to ru: The purpose of the development is to provide users with a personal synchronized interpreter.
  - example_title: translate en-zh
    text: >
      translate to zh: The purpose of the development is to provide users with a personal synchronized interpreter.
  - example_title: translate zh-en
    text: >
      translate to en: 开发的目的是为用户提供个人同步解释器。
  - example_title: translate ru-zh
    text: >
      translate to zh: Цель разработки — предоставить пользователям личного синхронного переводчика.
---

# T5 English, Russian and Chinese multilingual machine translation

This model represents a conventional T5 transformer in multitasking mode for translation into the required language, precisely configured for machine translation for pairs: ru-zh, zh-ru, en-zh, zh-en, en-ru, ru-en.

The model can perform direct translation between any pair of Russian, Chinese or English languages. For translation into the target language, the target language identifier is specified as a prefix 'translate to <lang>:'. In this case, the source language may not be specified, in addition, the source text may be multilingual.

Example translate Russian to Chinese

```python
from transformers import T5ForConditionalGeneration, T5Tokenizer

device = 'cuda' #or 'cpu' for translate on cpu

model_name = 'utrobinmv/t5_translate_en_ru_zh_small_1024'
model = T5ForConditionalGeneration.from_pretrained(model_name)
model.to(device)
tokenizer = T5Tokenizer.from_pretrained(model_name)

prefix = 'translate to zh: '
src_text = prefix + "Цель разработки — предоставить пользователям личного синхронного переводчика."

# translate Russian to Chinese
input_ids = tokenizer(src_text, return_tensors="pt")

generated_tokens = model.generate(**input_ids.to(device))

result = tokenizer.batch_decode(generated_tokens, skip_special_tokens=True)
print(result)
#开发的目的就是向用户提供个性化的同步翻译。
```



and Example translate Chinese to Russian

```python
from transformers import T5ForConditionalGeneration, T5Tokenizer

device = 'cuda' #or 'cpu' for translate on cpu

model_name = 'utrobinmv/t5_translate_en_ru_zh_small_1024'
model = T5ForConditionalGeneration.from_pretrained(model_name)
model.to(device)
tokenizer = T5Tokenizer.from_pretrained(model_name)

prefix = 'translate to ru: '
src_text = prefix + "开发的目的就是向用户提供个性化的同步翻译。"

# translate Russian to Chinese
input_ids = tokenizer(src_text, return_tensors="pt")

generated_tokens = model.generate(**input_ids.to(device))

result = tokenizer.batch_decode(generated_tokens, skip_special_tokens=True)
print(result)
#Цель разработки - предоставить персонализированный синхронный перевод для пользователей.
```



##  



## Languages covered

Russian (ru_RU), Chinese (zh_CN), English (en_US)
