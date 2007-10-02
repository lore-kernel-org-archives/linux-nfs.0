From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 06/35] svc: Add transport specific xpo_release	function
Date: Tue, 02 Oct 2007 11:35:37 -0500
Message-ID: <1191342937.1565.16.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192742.3250.93576.stgit@dell3.ogc.int>
	<D6D83B86-2A07-44F2-A729-9BF9DD74A6D4@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ickjr-0005Te-GN
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:36:51 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ickjw-0004wo-BZ
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:36:56 -0700
In-Reply-To: <D6D83B86-2A07-44F2-A729-9BF9DD74A6D4@oracle.com>
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

On Tue, 2007-10-02 at 11:18 -0400, Chuck Lever wrote:
> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> >

[...snip...]

> >
> >  struct svc_xprt_class {
> 
> You intend to add xpo_detach and xpo_free in a later patch.  The  
> method names suggest all of these operate on the svc_xprt.   
> xpo_release, however appears to operate on a request, not on a svc_xprt.

It's a little of both. It allows a transport to handle
transport-specific context information that is cached in the rqstp
structure. 

> 
> Perhaps you might name this method xpo_release_rqst or some other  
> name that indicates that this operates on a request.  The name  
> xpo_release could easily refer to closing the underlying socket.  As  
> an example, the client-side transport uses ->release_request.

Yes, I like your name better.

> 
> The client side also appears to treat the transport as handling  
> requests, instead of socket reads and writes.  The use of the method  
> names recvfrom and sendto suggest we are talking about bytes on a  
> socket here, not transmitting and receiving whole RPC requests.  I  
> think that's a useful abstraction.
> 
> While I'm whining aloud... I don't prefer the method names detach or  
> free, either.  On the client side we used close and destroy, which  
> (to me, anyway) makes more sense.
> 

Perhaps, but these names match what is actually done: detach disconnects
the transport from asynchronous I/O events, and free -- well frees.

> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 150531f..2d5731c 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -184,14 +184,14 @@ svc_thread_dequeue(struct svc_pool *pool
> >  /*
> >   * Release an skbuff after use
> >   */
> > -static inline void
> > +static void
> >  svc_release_skb(struct svc_rqst *rqstp)
> >  {
> > -	struct sk_buff *skb = rqstp->rq_skbuff;
> > +	struct sk_buff *skb = rqstp->rq_xprt_ctxt;
> >  	struct svc_deferred_req *dr = rqstp->rq_deferred;
> >
> >  	if (skb) {
> > -		rqstp->rq_skbuff = NULL;
> > +		rqstp->rq_xprt_ctxt = NULL;
> >
> >  		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
> >  		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
> > @@ -394,7 +394,7 @@ svc_sock_release(struct svc_rqst *rqstp)
> >  {
> >  	struct svc_sock	*svsk = rqstp->rq_sock;
> >
> > -	svc_release_skb(rqstp);
> > +	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
> >
> >  	svc_free_res_pages(rqstp);
> >  	rqstp->rq_res.page_len = 0;
> > @@ -866,7 +866,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
> >  			skb_free_datagram(svsk->sk_sk, skb);
> >  			return 0;
> >  		}
> > -		rqstp->rq_skbuff = skb;
> > +		rqstp->rq_xprt_ctxt = skb;
> >  	}
> >
> >  	rqstp->rq_arg.page_base = 0;
> > @@ -902,6 +902,7 @@ svc_udp_sendto(struct svc_rqst *rqstp)
> >  static struct svc_xprt_ops svc_udp_ops = {
> >  	.xpo_recvfrom = svc_udp_recvfrom,
> >  	.xpo_sendto = svc_udp_sendto,
> > +	.xpo_release = svc_release_skb,
> >  };
> >
> >  static struct svc_xprt_class svc_udp_class = {
> > @@ -1290,7 +1291,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
> >  		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
> >  	}
> >
> > -	rqstp->rq_skbuff      = NULL;
> > +	rqstp->rq_xprt_ctxt   = NULL;
> >  	rqstp->rq_prot	      = IPPROTO_TCP;
> >
> >  	/* Reset TCP read info */
> > @@ -1356,6 +1357,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
> >  static struct svc_xprt_ops svc_tcp_ops = {
> >  	.xpo_recvfrom = svc_tcp_recvfrom,
> >  	.xpo_sendto = svc_tcp_sendto,
> > +	.xpo_release = svc_release_skb,
> >  };
> >
> >  static struct svc_xprt_class svc_tcp_class = {
> > @@ -1577,7 +1579,7 @@ svc_send(struct svc_rqst *rqstp)
> >  	}
> >
> >  	/* release the receive skb before sending the reply */
> > -	svc_release_skb(rqstp);
> > +	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
> >
> >  	/* calculate over-all length */
> >  	xb = & rqstp->rq_res;
> 
> Chuck Lever
> chuck.lever@oracle.com
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
