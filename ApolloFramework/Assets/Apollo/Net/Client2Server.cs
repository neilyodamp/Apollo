using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Apollo.Net
{
    public class Client2Server : Manager
    {
        public static Client2Server Instance = new Client2Server();

        private string _host;
        private int _port;
        private Session _session;
        private int _serverTime;
        private readonly MessageQueue<Message> _queue = new MessageQueue<Message>();
        private readonly BetterList<Action> _funcs = new BetterList<Action>();


        private Client2Server()
        {
            //foreach(Message msg in A)
            //添加所有消息类型
        }
        
        public void Init()
        {

        }

        public void SetHost(string host,int port)
        {
            this._host = host;
            this._port = port;
        }

        public string GetHost()
        {
            return this._host;
        }

        public int GetPort()
        {
            return _port;
        }

        public void Connect()
        {
            if (string.IsNullOrEmpty(_host))
                return;

            CreateClientSession(_host, _port);
        }

        public void Close()
        {
            if(_session != null)
            {
                _session.Close();
                _session = null;
            }
        }

        public void Send(Message msg)
        {
            if(_session != null)
            {
                _session.Send(msg);
            }
        }

        public void Update()
        {
            if(_funcs.size > 0)
            {
                lock(_funcs)
                {
                    for(int i = 0,size = _funcs.size;i<size;++i)
                    {
                        Action func = _funcs[i];
                        try
                        {
                            func();
                        }catch(Exception e)
                        {
                            Debug.LogException(e);
                        }
                    }

                    _funcs.Clear();
                }
            }

            while(true)
            {
                Message msg = _queue.Dequeue();
                if (msg == null)
                    break;

                try
                {
                    msg.Handle();
                }catch(Exception e)
                {
                    Debug.LogException(e);
                }
            }
        }

        private void OnConnected()
        {
            //FIXED:Connected Event;
        }
        
        private void OnDisConnected()
        {
            if(_session != null)
            {
                _session = null;

                //FIXED: DisConnected Event.

            }
        }

        private void AddMainThreadFunc(Action func)
        {
            lock(_funcs)
            {
                _funcs.Add(func);
            }
        }

        protected override void OnAddSession(Session session)
        {
            _session = session;
            AddMainThreadFunc(OnConnected);
        }

        protected override void OnDelSession(Session session)
        {
            AddMainThreadFunc(OnDisConnected);
        }

        public override void DispatchMessage(Session session, Message msg)
        {
            _queue.Enqueue(msg);
        }

        public int ServerTime
        {
            get { return ServerTime; }
        }
        
    }

}
