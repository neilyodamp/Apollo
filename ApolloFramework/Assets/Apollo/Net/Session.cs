using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net.Sockets;
using Apollo.Share;
using System;

namespace Apollo.Net
{
    public sealed class Session
    {
        private static readonly AtomicLong nextId = new AtomicLong();

        public readonly long id = nextId.GetAndAdd(1);

        private readonly Socket socket;
        private readonly Manager manager;
        private readonly AtomicInteger closed = new AtomicInteger(0);

        public Session(Manager manager,Socket socket)
        {

        }

        public Manager Manager
        {
            get { return manager; }
        }

        public void Connect(string host,int port)
        {
            this.socket.BeginConnect(host, port, new AsyncCallback(OnConnectResult), null);
        }

        public void Send(Message message)
        {

        }

        public void Close()
        {

        }

        private void Decode()
        {

        }

        private void OnConnectResult(IAsyncResult result)
        {
            
        }

        private void OnReceiveResult(IAsyncResult result)
        {

        }

        private void OnSendResult(IAsyncResult result)
        {

        }
    }
}
