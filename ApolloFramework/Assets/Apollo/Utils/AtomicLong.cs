using System;
using System.Threading;

namespace Apollo.Share
{
    public class AtomicLong
    {
        private long value;

        public AtomicLong(long initialValue)
        {
            value = initialValue;
        }

        public AtomicLong()
            : this(0)
        {
        }

        public long Get()
        {
            return value;
        }

        public void Set(long newValue)
        {
            value = newValue;
        }

        public long GetAndSet(long newValue)
        {
            for (; ; )
            {
                long current = Get();
                if (CompareAndSet(current, newValue))
                    return current;
            }
        }

        public bool CompareAndSet(long expect, long update)
        {
            return Interlocked.CompareExchange(ref value, update, expect) == expect;
        }

        public long GetAndIncrement()
        {
            for (; ; )
            {
                long current = Get();
                long next = current + 1;
                if (CompareAndSet(current, next))
                    return current;
            }
        }

        public long GetAndDecrement()
        {
            for (; ; )
            {
                long current = Get();
                long next = current - 1;
                if (CompareAndSet(current, next))
                    return current;
            }
        }

        public long GetAndAdd(long delta)
        {
            for (; ; )
            {
                long current = Get();
                long next = current + delta;
                if (CompareAndSet(current, next))
                    return current;
            }
        }

        public long IncrementAndGet()
        {
            for (; ; )
            {
                long current = Get();
                long next = current + 1;
                if (CompareAndSet(current, next))
                    return next;
            }
        }

        public long DecrementAndGet()
        {
            for (; ; )
            {
                long current = Get();
                long next = current - 1;
                if (CompareAndSet(current, next))
                    return next;
            }
        }

        public long AddAndGet(long delta)
        {
            for (; ; )
            {
                long current = Get();
                long next = current + delta;
                if (CompareAndSet(current, next))
                    return next;
            }
        }

        public override String ToString()
        {
            return Convert.ToString(Get());
        }
    }
}
