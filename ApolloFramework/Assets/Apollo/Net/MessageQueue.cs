using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Apollo.Net
{
    public class MessageQueue<T>
    {
        private readonly Queue<T> m_queue = new Queue<T>();

        public void Enqueue(T message)
        {
            lock (m_queue)
            {
                m_queue.Enqueue(message);
            }
        }

        public T Dequeue()
        {
            lock (m_queue)
            {
                if (m_queue.Count == 0)
                {
                    return default(T);
                }
                else
                {
                    return m_queue.Dequeue();
                }
            }
        }
    }
}
