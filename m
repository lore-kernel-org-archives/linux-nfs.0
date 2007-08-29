From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 08/20] svc: centralise accept handling
Date: Wed, 29 Aug 2007 18:56:45 -0500
Message-ID: <1188431805.7502.75.camel@trinity.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162338.15224.14674.stgit@dell3.ogc.int>
	<46D5BD8A.5090509@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQXQA-0005ZD-DK
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 16:58:02 -0700
Received: from ms-smtp-06.texas.rr.com ([24.93.47.45])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQXQE-0006DV-Mx
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 16:58:07 -0700
In-Reply-To: <46D5BD8A.5090509@oracle.com>
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

On Wed, 2007-08-29 at 14:40 -0400, Chuck Lever wrote:
> Tom Tucker wrote:
> > Centralise the handling of the SK_CONN bit so that future
> > server transport implementations will be easier to
> > write correctly.  Also, the xpt_recvfrom method does not 
> > need to check for SK_CONN anymore, that's handled in core 
> > code which calls a new xpt_accept method.
> > 
> > Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> > Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  include/linux/sunrpc/svcsock.h |    4 ++++
> >  net/sunrpc/svcsock.c           |   24 +++++++++++-------------
> >  2 files changed, 15 insertions(+), 13 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> > index 0145057..7663578 100644
> > --- a/include/linux/sunrpc/svcsock.h
> > +++ b/include/linux/sunrpc/svcsock.h
> > @@ -41,6 +41,10 @@ struct svc_xprt {
> >  	 * svc_sock.
> >  	 */
> >  	u32			xpt_max_payload;
> > +	/*
> > +	 * Accept a pending connection, for connection-oriented transports
> > +	 */
> > +	int			(*xpt_accept)(struct svc_sock *svsk);
> >  };
> >  
> >  /*
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 5c3a794..94eb921 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1012,7 +1012,7 @@ static inline int svc_port_is_privileged
> >  /*
> >   * Accept a TCP connection
> >   */
> > -static void
> > +static int
> >  svc_tcp_accept(struct svc_sock *svsk)
> >  {
> >  	struct sockaddr_storage addr;
> > @@ -1021,12 +1021,12 @@ svc_tcp_accept(struct svc_sock *svsk)
> >  	struct socket	*sock = svsk->sk_sock;
> >  	struct socket	*newsock;
> >  	struct svc_sock	*newsvsk;
> > -	int		err, slen;
> > +	int		err = 0, slen;
> >  	char		buf[RPC_MAX_ADDRBUFLEN];
> >  
> >  	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
> >  	if (!sock)
> > -		return;
> > +		return -EINVAL;
> >  
> >  	clear_bit(SK_CONN, &svsk->sk_flags);
> >  	err = kernel_accept(sock, &newsock, O_NONBLOCK);
> > @@ -1037,9 +1037,8 @@ svc_tcp_accept(struct svc_sock *svsk)
> >  		else if (err != -EAGAIN && net_ratelimit())
> >  			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
> >  				   serv->sv_name, -err);
> > -		return;
> > +		return err;
> >  	}
> > -
> >  	set_bit(SK_CONN, &svsk->sk_flags);
> >  	svc_sock_enqueue(svsk);
> >  
> > @@ -1124,11 +1123,11 @@ svc_tcp_accept(struct svc_sock *svsk)
> >  	if (serv->sv_stats)
> >  		serv->sv_stats->nettcpconn++;
> >  
> > -	return;
> > +	return 0;
> >  
> >  failed:
> >  	sock_release(newsock);
> > -	return;
> > +	return err;
> >  }
> >  
> >  /*
> > @@ -1153,12 +1152,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
> >  		return svc_deferred_recv(rqstp);
> >  	}
> >  
> > -	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
> > -		svc_tcp_accept(svsk);
> > -		svc_sock_received(svsk);
> > -		return 0;
> > -	}
> > -
> >  	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
> >  		/* sndbuf needs to have room for one request
> >  		 * per thread, otherwise we can stall even when the
> > @@ -1361,6 +1354,7 @@ static const struct svc_xprt svc_tcp_xpr
> >  	.xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
> >  	.xpt_has_wspace = svc_tcp_has_wspace,
> >  	.xpt_max_payload = RPCSVC_MAXPAYLOAD_TCP,
> > +	.xpt_accept = svc_tcp_accept,
> >  };
> >  
> >  static void
> > @@ -1521,6 +1515,9 @@ svc_recv(struct svc_rqst *rqstp, long ti
> >  	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
> >  		dprintk("svc_recv: found SK_CLOSE\n");
> >  		svc_delete_socket(svsk);
> > +	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
> 
> This checks a flag in a "struct sock" in the middle of a "generic" 
> function.  Seems like a step backwards to me.

I need to reverse the order of patch 8 and 9. 

> 
> > +		svsk->sk_xprt->xpt_accept(svsk);
> 
> Why aren't you using the return value you just added to svc_tcp_accept?

Oversight. I'll fix it.

> 
> > +		svc_sock_received(svsk);
> >  	} else {
> >  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
> >  			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
> > @@ -1660,6 +1657,7 @@ static struct svc_sock *svc_setup_socket
> >  	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
> >  
> >  	dprintk("svc: svc_setup_socket %p\n", sock);
> > +	*errp = 0;
> 
> Hrm, if this is a genuine omission not related to the other changes in 
> this patch, you should perhaps send this as a separate patch.

It may not a "genuine" ommission since errp is probably only defined
when the return value is NULL. It may be just an unnecessary code change
that I should drop.

> 
> >  	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
> >  		*errp = -ENOMEM;
> >  		return NULL;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
