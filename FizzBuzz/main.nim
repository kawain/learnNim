for i in 1..100:
  if i mod 15 == 0:
    echo $i & " FizzBuzz"
  elif i mod 5 == 0:
    echo $i & " Buzz"
  elif i mod 3 == 0:
    echo $i & " Fizz"
  else:
    echo $i
