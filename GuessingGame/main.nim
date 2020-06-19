import random
import strutils

randomize()

# 答え
var ans = rand(1..100)

echo "数字当てゲーム\n\n"

while true:

  echo "1から100までの数字を入力。end でギブアップ。"

  var input = readLine(stdin)

  if input == "end":
    break

  var inputInt: int
  try:
    # strutils.parseInt
    inputInt = parseInt(input)
  except:
    echo "数字を入力してください"
    continue

  if ans == inputInt:
    echo "正解"
    break
  elif ans > inputInt:
    echo "小さすぎます"
  elif ans < inputInt:
    echo "大きすぎます"


echo "終了"
