def fib(n)
  return n if n < 2
  fib(n - 1) + fib(n - 2)
end

2.times.map { Ractor.new { fib(40) } }.map(&:take)

r = Ractor.new do
  Ractor.receive
end

r.send(:ok)
p r.take

r = Ractor.new do
  Ractor.receive_if do |msg|
    case msg
    when 100
      break msg * 2
    when 200
      break msg * 4
    end
  end
end

r.send 100
p r.take
