From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 22/33] svc: Move sk_lastrecv to svc_xprt
Date: Fri, 28 Sep 2007 11:16:17 -0500
Message-ID: <1190996177.10604.54.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050220.12677.62957.stgit@dell3.ogc.int>
	<18172.33312.649312.820488@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIWy-0004pC-NC
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:17:32 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbIX3-0004lK-FS
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:17:37 -0700
In-Reply-To: <18172.33312.649312.820488@notabene.brown>
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

On Fri, 2007-09-28 at 14:25 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > 
> > This functionally trivial change moves the tranpsort independent sk_lastrecv 
> > field to the svc_xprt structure. 
> 
> It would seem that sk_lastrecv is entirely unused (Well, a dprintk
> prints it, but that isn't very interesting).

agreed.

> I think it used to be used to time out idle connections, but Greg's
> mark/sweep does a better job without needing this field.  Shall we
> just remove it?

I think so. Greg?

> 
> NeilBrown
> 
> 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  include/linux/sunrpc/svc_xprt.h |    1 +
> >  include/linux/sunrpc/svcsock.h  |    1 -
> >  net/sunrpc/svcsock.c            |    6 +++---
> >  3 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> > index 5b2aef4..edb7ad2 100644
> > --- a/include/linux/sunrpc/svc_xprt.h
> > +++ b/include/linux/sunrpc/svc_xprt.h
> > @@ -56,6 +56,7 @@ #define XPT_LISTENER	11			/* listening e
> >  	struct svc_serv *	xpt_server;	/* service for this transport */
> >  	atomic_t    	    	xpt_reserved;	/* space on outq that is reserved */
> >  	struct mutex		xpt_mutex;	/* to serialize sending data */
> > +	time_t			xpt_lastrecv;	/* time of last received request */
> >  };
> >  
> >  int	svc_reg_xprt_class(struct svc_xprt_class *);
> > diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> > index 41c2dfa..406d003 100644
> > --- a/include/linux/sunrpc/svcsock.h
> > +++ b/include/linux/sunrpc/svcsock.h
> > @@ -33,7 +33,6 @@ struct svc_sock {
> >  	/* private TCP part */
> >  	int			sk_reclen;	/* length of record */
> >  	int			sk_tcplen;	/* current read length */
> > -	time_t			sk_lastrecv;	/* time of last received request */
> >  
> >  	/* cache of various info for TCP sockets */
> >  	void			*sk_info_authunix;
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 71b7f86..04155aa 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1622,7 +1622,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
> >  		svc_sock_release(rqstp);
> >  		return -EAGAIN;
> >  	}
> > -	svsk->sk_lastrecv = get_seconds();
> > +	svsk->sk_xprt.xpt_lastrecv = get_seconds();
> >  	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
> >  
> >  	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
> > @@ -1725,7 +1725,7 @@ svc_age_temp_sockets(unsigned long closu
> >  		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
> >  
> >  		dprintk("queuing svsk %p for closing, %lu seconds old\n",
> > -			svsk, get_seconds() - svsk->sk_lastrecv);
> > +			svsk, get_seconds() - svsk->sk_xprt.xpt_lastrecv);
> >  
> >  		/* a thread will dequeue and close it soon */
> >  		svc_xprt_enqueue(&svsk->sk_xprt);
> > @@ -1773,7 +1773,7 @@ static struct svc_sock *svc_setup_socket
> >  	svsk->sk_ostate = inet->sk_state_change;
> >  	svsk->sk_odata = inet->sk_data_ready;
> >  	svsk->sk_owspace = inet->sk_write_space;
> > -	svsk->sk_lastrecv = get_seconds();
> > +	svsk->sk_xprt.xpt_lastrecv = get_seconds();
> >  	spin_lock_init(&svsk->sk_lock);
> >  	INIT_LIST_HEAD(&svsk->sk_deferred);
> >  


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
