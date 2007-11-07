From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH 1/7] SUNRPC: Fix a race in xs_tcp_state_change()
Date: Wed, 07 Nov 2007 17:32:43 -0500
Message-ID: <1194474763.7504.57.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003940.13713.65472.stgit@heimdal.trondhjem.org>
	<47323A62.9000803@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47323A62.9000803@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>


On Wed, 2007-11-07 at 17:21 -0500, Chuck Lever wrote:
> Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > When scheduling the autoclose RPC call, we want to ensure that we don't
> > race against the test_bit() call in xprt_clear_locked().
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  include/linux/sunrpc/xprt.h |    1 +
> >  net/sunrpc/xprt.c           |   20 ++++++++++++++++++++
> >  net/sunrpc/xprtsock.c       |    5 +----
> >  3 files changed, 22 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 30b17b3..6f524a9 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -246,6 +246,7 @@ struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
> >  void			xprt_complete_rqst(struct rpc_task *task, int copied);
> >  void			xprt_release_rqst_cong(struct rpc_task *task);
> >  void			xprt_disconnect(struct rpc_xprt *xprt);
> > +void			xprt_force_disconnect(struct rpc_xprt *xprt);
> >  
> >  /*
> >   * Reserved bit positions in xprt->state
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index 282a9a2..48c5a8b 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -570,6 +570,7 @@ static void xprt_autoclose(struct work_struct *work)
> >  
> >  	xprt_disconnect(xprt);
> >  	xprt->ops->close(xprt);
> > +	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> 
> xs_close already clears the CLOSE_WAIT bit, and so does xs_tcp_shutdown 
> (added in a later patch).  So this hunk appears to be unnecessary.
> 
> But xprt_rdma_close doesn't clear CLOSE_WAIT, it appears.  Do we want to 
> copy (some of) the logic from the end of xs_close into xprt_rdma_close?

Nah. I'd like to move the XPRT_CLOSE_WAIT stuff into xprt.c in order to
convert it into a generic way of telling the transport layer that we
want it to shut down. It is already in the xprt_clear_locked() logic, so
this is really just a cleanup of the current hack.

> >  	xprt_release_write(xprt, NULL);
> >  }
> >  
> > @@ -588,6 +589,25 @@ void xprt_disconnect(struct rpc_xprt *xprt)
> >  }
> >  EXPORT_SYMBOL_GPL(xprt_disconnect);
> >  
> > +/**
> > + * xprt_force_disconnect - force a transport to disconnect
> > + * @xprt: transport to disconnect
> > + *
> > + */
> > +void xprt_force_disconnect(struct rpc_xprt *xprt)
> > +{
> > +	/* Don't race with the test_bit() in xprt_clear_locked() */
> > +	spin_lock_bh(&xprt->transport_lock);
> > +	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
> > +	/* Try to schedule an autoclose RPC call */
> > +	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
> > +		queue_work(rpciod_workqueue, &xprt->task_cleanup);
> 
> > +	else if (xprt->snd_task != NULL)
> > +		rpc_wake_up_task(xprt->snd_task);
> 
> What's this new bit of logic for?

It ensures that if the current holder of the XPRT_LOCKED bit is
sleeping, then we want it to wake up so that we can disconnect. The only
reason why the current holder might be sleeping would be if it is
waiting for buffer space to transmit (or possibly it might be trying to
reconnect - we might want to add a test for XPRT_CONNECTED too).

> > +	spin_unlock_bh(&xprt->transport_lock);
> > +}
> > +EXPORT_SYMBOL_GPL(xprt_force_disconnect);
> > +
> >  static void
> >  xprt_init_autodisconnect(unsigned long data)
> >  {
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 02298f5..322e4e2 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1118,10 +1118,7 @@ static void xs_tcp_state_change(struct sock *sk)
> >  	case TCP_SYN_RECV:
> >  		break;
> >  	case TCP_CLOSE_WAIT:
> > -		/* Try to schedule an autoclose RPC calls */
> > -		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
> > -		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
> > -			queue_work(rpciod_workqueue, &xprt->task_cleanup);
> > +		xprt_force_disconnect(xprt);
> >  	default:
> >  		xprt_disconnect(xprt);
> >  	}
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________ NFS maillist - NFS@lists.sourceforge.net https://lists.sourceforge.net/lists/listinfo/nfs
