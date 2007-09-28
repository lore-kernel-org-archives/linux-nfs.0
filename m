From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 06/33] svc: Add transport specific xpo_release	function
Date: Fri, 28 Sep 2007 11:06:04 -0500
Message-ID: <1190995564.10604.44.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050147.12677.85535.stgit@dell3.ogc.int>
	<18172.28133.761225.855135@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIN9-0003gm-8s
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:07:23 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbINB-0006a2-Vr
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:07:28 -0700
In-Reply-To: <18172.28133.761225.855135@notabene.brown>
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

On Fri, 2007-09-28 at 12:58 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > 
> > The svc_sock_release function releases pages allocated to a thread. For
> > UDP, this also returns the receive skb to the stack. For RDMA it will 
> > post a receive WR and bump the client credit count. 
> > 
> ..
> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> > index 37f7448..cfb2652 100644
> > --- a/include/linux/sunrpc/svc.h
> > +++ b/include/linux/sunrpc/svc.h
> > @@ -217,7 +217,7 @@ struct svc_rqst {
> >  	struct auth_ops *	rq_authop;	/* authentication flavour */
> >  	u32			rq_flavor;	/* pseudoflavor */
> >  	struct svc_cred		rq_cred;	/* auth info */
> > -	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
> > +	void *			rq_xprt_ctxt;	/* transport specific context ptr */
> >  	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
> >  
> >  	struct xdr_buf		rq_arg;
> ..
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index cc8c7ce..e7d203a 100644
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
> > +	struct sk_buff *skb = (struct sk_buff *)rqstp->rq_xprt_ctxt;
> 
> Minor style point: We don't cast void* in the kernel.

Oops, no we don't.

> 
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
> 
> These are somewhat ugly, aren't they?
> What would you think of giving rqstp a pointer directly to xpt_ops to
> avoid the double indirection?
> 

Maybe I'm missing something, but does it actually save anything? The
xpt_ops structure is copied into the transport instance. I think you'd
end up with this:

	rqstp->rq_ops->xpo_release(rqstp)

More aesthetically pleasing perhaps, but you'd still have "double
indirection". I think this is the same as we have today actually for the
sk_release/sk_sendto functions.

> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
