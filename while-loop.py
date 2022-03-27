# # while Loop
# x=0
# while (x<5):
#     print(x)
#     x=x+1



# # For Loop
#  days=["Mon","Tues","Wed","Thu","Fri","Sat","Sun"]

#  for d in days:
#      print(d)
 
#  fruits=[f"apple", "banana", "cherry"]
 
#  for x in fruits:
#      print(x)

#print("HelloWorld")
#==========================================================
# convert a camel case string to a snake case string.

# def camelToSnake(paramString):

#                 """camelCase > camel_case"""

#   for index, letter in enumerate(paramString):

#       if letter.isupper():

#         # insert "_" in prev... 

#          paramString = paramString.insert(index - 1, "_")

#          paramString = paramString.replace(letter, lower(letter))

#                 else:

#          pass

#                 return paramString

import re


def camel_to_snake(paramString):
    '''camelCase > camel_case'''
    pattern = re.compile(r'(?<!^)(?=[A-Z])')
    paramString = pattern.sub('_', paramString).lower()
    return paramString
