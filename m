From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 18/20] svc: Add xpt_defer transport function
Date: Wed, 29 Aug 2007 16:34:13 -0500
Message-ID: <1188423253.7502.70.camel@trinity.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162359.15224.74970.stgit@dell3.ogc.int>
	<46D5C932.20505@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQVCi-0000ye-Hc
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:36:01 -0700
Received: from ms-smtp-06.texas.rr.com ([24.93.47.45])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQVCk-0005tY-Lq
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:36:05 -0700
In-Reply-To: <46D5C932.20505@oracle.com>
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

On Wed, 2007-08-29 at 15:29 -0400, Chuck Lever wrote:
> Tom Tucker wrote:
> > The RDMA transport includes an ONCRDMA header that precedes the RPC 
> > message. This header needs to be saved in addition to the RPC message 
> > itself. The RPC transport uses page swapping to implement copy avoidance.
>                ^^^

Oops. I'll fix that comment if this function survives the review.

> I assume you mean the "RDMA" transport here.
> 

Yes

> Not having looked closely at the RDMA transport, it may be naive to ask
> if any of the RDMA page swapping implementation would be useful for the 
> socket transport implementation?
> 

The only one I can think of is for NFSv4 on RDMA w/ sessions. Today, the
defer implementation drops anything but simple header-only (no pagelist)
RPC. Concern had been expressed about the negative performance
implications for NFSv4 with sessions and whether this could trigger all
kinds of hideous replay scenarios. I honestly don't know and I also
don't know all the conditions under which an RPC can be deferred. 

I do know that this made writing my transport driver easier because it
gave me a way to squirrel away data that was otherwise hidden from the
svc core code. Trond had mentioned adding a 'reserve' field that could
be used by any transport for this purpose. The function clearly gives us
more flexibility, but I think the jury is still out on whether or not
the flexibility is needed. All that said, I don't see it as a huge issue
one way or the other.

> > These transport dependencies are hidden in the xpt_defer routine allowing
> > the bulk of the deferral processing to remain in transport independent 
> > code.
> 
> You may have two separate patches here: one that exports svc_revisit and 
> one that adds an xpt_defer method.
> 



> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  include/linux/sunrpc/svcsock.h |    5 +++++
> >  net/sunrpc/svcsock.c           |    5 +++--
> >  2 files changed, 8 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> > index a920e9b..145c82b 100644
> > --- a/include/linux/sunrpc/svcsock.h
> > +++ b/include/linux/sunrpc/svcsock.h
> > @@ -51,6 +51,10 @@ struct svc_xprt {
> >  	 * Accept a pending connection, for connection-oriented transports
> >  	 */
> >  	int			(*xpt_accept)(struct svc_sock *svsk);
> > +
> > +	/* RPC defer routine. */
> > +	struct cache_deferred_req *(*xpt_defer)(struct cache_req *req);
> > +
> >  	/* Transport list link */
> >  	struct list_head	xpt_list;
> >  };
> > @@ -138,6 +142,7 @@ void		svc_sock_add_connection(struct svc
> >  void		svc_sock_add_listener(struct svc_sock *);
> >  /* Add an initialised connectionless svc_sock to the server */
> >  void		svc_sock_add_connectionless(struct svc_sock *);
> > +void 		svc_revisit(struct cache_deferred_req *dreq, int too_many);
> >  
> >  /*
> >   * svc_makesock socket characteristics
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 03ce7e9..b89c577 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1651,7 +1651,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
> >  	clear_bit(SK_OLD, &svsk->sk_flags);
> >  
> >  	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
> > -	rqstp->rq_chandle.defer = svc_defer;
> > +	rqstp->rq_chandle.defer = svsk->sk_xprt->xpt_defer;
> 
> Where is xpt_defer set?  Are we calling a NULL pointer here?
> 

Merge error. Good catch. The RDMA transport does it right.


> >  	if (serv->sv_stats)
> >  		serv->sv_stats->netcnt++;
> > @@ -2116,7 +2116,7 @@ EXPORT_SYMBOL_GPL(svc_create_svcsock);
> >   * Handle defer and revisit of requests
> >   */
> >  
> > -static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
> > +void svc_revisit(struct cache_deferred_req *dreq, int too_many)
> >  {
> >  	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
> >  	struct svc_sock *svsk;
> > @@ -2136,6 +2136,7 @@ static void svc_revisit(struct cache_def
> >  	svc_sock_enqueue(svsk);
> >  	svc_sock_put(svsk);
> >  }
> > +EXPORT_SYMBOL_GPL(svc_revisit);
> >  
> >  static struct cache_deferred_req *
> >  svc_defer(struct cache_req *req)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
