using System;
using Apollo.Share;

namespace Apollo.Net
{
    public abstract class Message
    {
        protected Session session = null;

        public void SendResponse(Message msg)
        {
            if (this.session == null)
                throw new Exception("not associate with a session");

            this.session.Send(msg);
        }

        public void SetSession(Session session)
        {
            this.session = session;
        }

        public Session GetSession()
        {
            return this.session;
        }

        public void Dispatch()
        {
            this.session.Manager.DispatchMessage(this.session, this);
        }

        public abstract int Type();

        public abstract void Handle();


    }
}
