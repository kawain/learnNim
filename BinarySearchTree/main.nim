import options
import strutils
import sequtils
import random
import strformat


type Node = ref object
  id: int
  num: int
  left, right: Option[Node]


proc maketree(n: var Node, i, v: int) =
  var n2 = Node(id: i+1, num: v, left: none(Node), right: none(Node))
  if n.num < v:
    if n.right.isNone:
      n.right = some(n2)
    else:
      maketree(n.right.get, i, v)
  else:
    if n.left.isNone:
      n.left = some(n2)
    else:
      maketree(n.left.get, i, v)


proc search(n: var Node) =
  echo "探索する値を入力"
  var input = readLine(stdin).parseInt
  while true:
    if n.num == input:
      echo input, "は", n.id, "番目に見つかりました"
      break
    elif n.num < input and n.right.isSome:
      n = n.right.get
    elif n.num > input and n.left.isSome:
      n = n.left.get
    else:
      echo input, "は見つかりません"
      break


proc main() =
  randomize()

  var data: seq[int] = toSeq(1..20)

  shuffle(data)

  for i, v in data:
    echo fmt"{i+1:>4}:{v:>4}"

  # 先頭初期化
  var node = Node(id: 1, num: data[0], left: none(Node), right: none(Node))

  for i, v in data:
    if i > 0:
      maketree(node, i, v)

  echo node[]
  echo node.right.get[]
  echo node.right.get.right.get[]
  echo node.right.get.right.get.right.get[]
  echo "---"
  echo node.left.get[]
  echo node.left.get.left.get[]
  echo node.left.get.left.get.left.get[]

  search(node)


when isMainModule:
  main()
