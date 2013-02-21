Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3644 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752786Ab3BUUCz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 15:02:55 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "simo@redhat.com" <simo@redhat.com>
Subject: Re: [PATCH 1/6] SUNRPC: make AF_LOCAL connect synchronous
Date: Thu, 21 Feb 2013 20:02:30 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA946@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
	 <1361464705-12340-2-git-send-email-bfields@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA5F3@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130221194804.GC3531@pad.fieldses.org>
In-Reply-To: <20130221194804.GC3531@pad.fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-02-21 at 14:48 -0500, J. Bruce Fields wrote:
> On Thu, Feb 21, 2013 at 06:17:47PM +0000, Myklebust, Trond wrote:
> > On Thu, 2013-02-21 at 11:38 -0500, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > It doesn't appear that anyone actually needs to connect asynchronously.
> > > 
> > > Also, using a workqueue for the connect means we lose the namespace
> > > information from the original process.  This is a problem since there's
> > > no way to explicitly pass in a filesystem namespace for resolution of an
> > > AF_LOCAL address.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  net/sunrpc/xprtsock.c |   35 +++++++++++++++++++++++++++--------
> > >  1 file changed, 27 insertions(+), 8 deletions(-)
> > > 
> > > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > > index bbc0915..b1df874 100644
> > > --- a/net/sunrpc/xprtsock.c
> > > +++ b/net/sunrpc/xprtsock.c
> > > @@ -1866,13 +1866,9 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
> > >   * @xprt: RPC transport to connect
> > >   * @transport: socket transport to connect
> > >   * @create_sock: function to create a socket of the correct type
> > > - *
> > > - * Invoked by a work queue tasklet.
> > >   */
> > > -static void xs_local_setup_socket(struct work_struct *work)
> > > +static void xs_local_setup_socket(struct sock_xprt *transport)
> > >  {
> > > -	struct sock_xprt *transport =
> > > -		container_of(work, struct sock_xprt, connect_worker.work);
> > >  	struct rpc_xprt *xprt = &transport->xprt;
> > >  	struct socket *sock;
> > >  	int status = -EIO;
> > > @@ -1919,6 +1915,31 @@ out:
> > >  	current->flags &= ~PF_FSTRANS;
> > >  }
> > >  
> > > +static void xs_local_connect(struct rpc_task *task)
> > > +{
> > > +	struct rpc_xprt *xprt = task->tk_xprt;
> > > +	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> > > +	unsigned long timeout;
> > > +
> > > +	 if (RPC_IS_ASYNC(task))
> > > +	 	rpc_exit(task, -ENOTCONN);
> > 
> > Needs a "return"...
> 
> Fixed, thanks.
> 
> > 
> > 
> > > +
> > > +	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
> > > +		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
> > > +				"seconds\n",
> > > +				xprt, xprt->reestablish_timeout / HZ);
> > > +		timeout = xprt->reestablish_timeout;
> > > +		xprt->reestablish_timeout <<= 1;
> > > +		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
> > > +			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> > > +		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
> > > +			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
> > > +		rpc_delay(task, timeout);
> > 
> > This too needs to exit in order to sleep.
> 
> Oops, so maybe simplest would be just to connect first and then delay if
> there's a failure.
> 
> (Or is there any problem just making that rpc_delay() an msleep() since
> we know we're in the synchronous case?)

A 5 minute msleep() is probably a bit excessive. Making it interruptible
might help, but ...
That does however raise the issue of why we need exponential back off
here? An AF_LOCAL connect call is pretty efficient.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
