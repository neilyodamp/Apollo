using System.Collections;
using System.Collections.Generic;
using System.Net.Sockets;
using System;
using UnityEngine;

namespace Apollo.Net
{
    public abstract class Manager
    {
        private readonly int iBufferCapacity;
        protected Dictionary<int, Message> messages;
        protected Dictionary<long, Session> sessions = new Dictionary<long, Session>();

        protected Manager():this(1048576)
        {

        }

        protected Manager(int iBufferCapacity)
        {
            this.iBufferCapacity = iBufferCapacity;
            this.messages = new Dictionary<int, Message>();
        }

        public int IBufferCapacity
        {
            get { return iBufferCapacity; }
        }

        public bool Send(long sessionID,Message msg)
        {
            Session session;
            lock(sessions)
            {
                if (!sessions.TryGetValue(sessionID, out session))
                    return false;
            }

            session.Send(msg);
            return true;
        }

        public void SendAll(Message msg)
        {
            lock(sessions)
            {
                foreach(Session session in sessions.Values)
                {
                    session.Send(msg);
                }
            }
        }

        public Session GetSession(long sessionID)
        {
            Session session;

            lock(sessions)
            {
                sessions.TryGetValue(sessionID, out session);
            }
            return session;
        }

        public void CloseSession(long sessionID)
        {
            Session session;
            lock(sessions)
            {
                if (!sessions.TryGetValue(sessionID, out session))
                    return;
            }

            session.Close();
        }

        public void AddSession(Session session)
        {

            lock(sessions)
            {
                sessions[session.id] = session;
            }

            try
            {

                OnAddSession(session);

            }catch
            {

            }
        }

        public Session CreateClientSession(string host,int port)
        {
            Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

            Session session = new Session(this, socket);
            session.Connect(host, port);
            return session;
        }

        public virtual void DispatchMessage(Session session,Message msg)
        {
            try
            {
                msg.Handle();
            }
            catch
            {

            }
        }

        public virtual void OnUnknownMessage(Session session,int type,int size)
        {
            throw new Exception("unknown message type: " + type);
        }

        public virtual Message CreateMessage(int type)
        {
            try
            {
                Message msg = messages[type];
                return msg == null ? null : (Message)Activator.CreateInstance(msg.GetType());
            }
            catch(Exception e)
            {
                return null;
            }
        }

        public void AddMessageType(Message msg)
        {
            if(messages.ContainsKey(msg.Type()))
            {
                throw new Exception("duplicate message type: " + msg.Type());
            }
            else
            {
                messages[msg.Type()] = msg;
            }
        }

        public void DelSession(Session session)
        {
            try
            {
                OnDelSession(session);
            }
            catch
            {

            }

            lock(sessions)
            {
                sessions.Remove(session.id);
            }
        }

        protected abstract void OnAddSession(Session session);
        protected abstract void OnDelSession(Session session);
    }
}
