From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 7/7] SUNRPC: Rename xprt_disconnect()
Date: Wed, 07 Nov 2007 19:01:10 -0500
Message-ID: <1194480070.7962.11.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107004011.13713.39834.stgit@heimdal.trondhjem.org>
	<47324751.9050603@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Tom Talpey <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpunJ-0007uy-GY
	for nfs@lists.sourceforge.net; Wed, 07 Nov 2007 15:58:49 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpunP-0007kU-3N
	for nfs@lists.sourceforge.net; Wed, 07 Nov 2007 15:58:55 -0800
In-Reply-To: <47324751.9050603@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Wed, 2007-11-07 at 18:16 -0500, Chuck Lever wrote:
> Oops.  Looks like you did the rename in xs_tcp_read_fraghdr in this patch.

I agree. That really should be part of patch 6. I'll respin these 2
patches...


> Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > xprt_disconnect() should really only be called when the transport shutdown
> > is completed, and it is time to wake up any pending tasks. Rename it to
> > xprt_disconnect_done() in order to reflect the semantical change.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  include/linux/sunrpc/xprt.h     |    2 +-
> >  net/sunrpc/xprt.c               |    6 +++---
> >  net/sunrpc/xprtrdma/transport.c |    4 ++--
> >  net/sunrpc/xprtsock.c           |    6 +++---
> >  4 files changed, 9 insertions(+), 9 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index afb9e6a..2554cd2 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -245,7 +245,7 @@ void			xprt_adjust_cwnd(struct rpc_task *task, int result);
> >  struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
> >  void			xprt_complete_rqst(struct rpc_task *task, int copied);
> >  void			xprt_release_rqst_cong(struct rpc_task *task);
> > -void			xprt_disconnect(struct rpc_xprt *xprt);
> > +void			xprt_disconnect_done(struct rpc_xprt *xprt);
> >  void			xprt_force_disconnect(struct rpc_xprt *xprt);
> >  
> >  /*
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index fcdc4b8..4d71152 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -574,11 +574,11 @@ static void xprt_autoclose(struct work_struct *work)
> >  }
> >  
> >  /**
> > - * xprt_disconnect - mark a transport as disconnected
> > + * xprt_disconnect_done - mark a transport as disconnected
> >   * @xprt: transport to flag for disconnect
> >   *
> >   */
> > -void xprt_disconnect(struct rpc_xprt *xprt)
> > +void xprt_disconnect_done(struct rpc_xprt *xprt)
> >  {
> >  	dprintk("RPC:       disconnected transport %p\n", xprt);
> >  	spin_lock_bh(&xprt->transport_lock);
> > @@ -586,7 +586,7 @@ void xprt_disconnect(struct rpc_xprt *xprt)
> >  	xprt_wake_pending_tasks(xprt, -ENOTCONN);
> >  	spin_unlock_bh(&xprt->transport_lock);
> >  }
> > -EXPORT_SYMBOL_GPL(xprt_disconnect);
> > +EXPORT_SYMBOL_GPL(xprt_disconnect_done);
> >  
> >  /**
> >   * xprt_force_disconnect - force a transport to disconnect
> > diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> > index dc55cc9..06e8b50 100644
> > --- a/net/sunrpc/xprtrdma/transport.c
> > +++ b/net/sunrpc/xprtrdma/transport.c
> > @@ -449,7 +449,7 @@ xprt_rdma_close(struct rpc_xprt *xprt)
> >  	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
> >  
> >  	dprintk("RPC:       %s: closing\n", __func__);
> > -	xprt_disconnect(xprt);
> > +	xprt_disconnect_done(xprt);
> >  	(void) rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
> >  }
> >  
> > @@ -682,7 +682,7 @@ xprt_rdma_send_request(struct rpc_task *task)
> >  	}
> >  
> >  	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req)) {
> > -		xprt_disconnect(xprt);
> > +		xprt_disconnect_done(xprt);
> >  		return -ENOTCONN;	/* implies disconnect */
> >  	}
> >  
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index c0aa2b4..a7d53d1 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -789,7 +789,7 @@ clear_close_wait:
> >  	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> >  	clear_bit(XPRT_CLOSING, &xprt->state);
> >  	smp_mb__after_clear_bit();
> > -	xprt_disconnect(xprt);
> > +	xprt_disconnect_done(xprt);
> >  }
> >  
> >  /**
> > @@ -911,7 +911,7 @@ static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_rea
> >  	/* Sanity check of the record length */
> >  	if (unlikely(transport->tcp_reclen < 4)) {
> >  		dprintk("RPC:       invalid TCP record fragment length\n");
> > -		xprt_disconnect(xprt);
> > +		xprt_force_disconnect(xprt);
> >  		return;
> >  	}
> >  	dprintk("RPC:       reading TCP record fragment of length %d\n",
> > @@ -1160,7 +1160,7 @@ static void xs_tcp_state_change(struct sock *sk)
> >  		break;
> >  	case TCP_CLOSE:
> >  		/* Mark transport as closed and wake up all pending tasks */
> > -		xprt_disconnect(xprt);
> > +		xprt_disconnect_done(xprt);
> >  		clear_bit(XPRT_CLOSING, &xprt->state);
> >  	}
> >   out:
> > 
> > 
> > -------------------------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc.
> > Still grepping through log files to find problems?  Stop.
> > Now Search log events and configuration files using AJAX and a browser.
> > Download your FREE copy of Splunk now >> http://get.splunk.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
