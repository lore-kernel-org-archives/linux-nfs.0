From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 06/35] svc: Add transport specific xpo_release function
Date: Tue, 2 Oct 2007 11:18:53 -0400
Message-ID: <D6D83B86-2A07-44F2-A729-9BF9DD74A6D4@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192742.3250.93576.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcjZ6-0003WX-FT
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 08:21:40 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcjZ5-0005bP-P2
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 08:21:40 -0700
In-Reply-To: <20071001192742.3250.93576.stgit@dell3.ogc.int>
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

On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
>
> The svc_sock_release function releases pages allocated to a thread.  
> For
> UDP, this also returns the receive skb to the stack. For RDMA it will
> post a receive WR and bump the client credit count.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  include/linux/sunrpc/svc.h      |    2 +-
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  net/sunrpc/svcsock.c            |   16 +++++++++-------
>  3 files changed, 11 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 37f7448..cfb2652 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -217,7 +217,7 @@ struct svc_rqst {
>  	struct auth_ops *	rq_authop;	/* authentication flavour */
>  	u32			rq_flavor;	/* pseudoflavor */
>  	struct svc_cred		rq_cred;	/* auth info */
> -	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
> +	void *			rq_xprt_ctxt;	/* transport specific context ptr */
>  	struct svc_deferred_req*rq_deferred;	/* deferred request we are  
> replaying */
>
>  	struct xdr_buf		rq_arg;
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> svc_xprt.h
> index f0ba052..5871faa 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -12,6 +12,7 @@ #include <linux/sunrpc/svc.h>
>  struct svc_xprt_ops {
>  	int		(*xpo_recvfrom)(struct svc_rqst *);
>  	int		(*xpo_sendto)(struct svc_rqst *);
> +	void		(*xpo_release)(struct svc_rqst *);
>  };
>
>  struct svc_xprt_class {

You intend to add xpo_detach and xpo_free in a later patch.  The  
method names suggest all of these operate on the svc_xprt.   
xpo_release, however appears to operate on a request, not on a svc_xprt.

Perhaps you might name this method xpo_release_rqst or some other  
name that indicates that this operates on a request.  The name  
xpo_release could easily refer to closing the underlying socket.  As  
an example, the client-side transport uses ->release_request.

The client side also appears to treat the transport as handling  
requests, instead of socket reads and writes.  The use of the method  
names recvfrom and sendto suggest we are talking about bytes on a  
socket here, not transmitting and receiving whole RPC requests.  I  
think that's a useful abstraction.

While I'm whining aloud... I don't prefer the method names detach or  
free, either.  On the client side we used close and destroy, which  
(to me, anyway) makes more sense.

> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 150531f..2d5731c 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -184,14 +184,14 @@ svc_thread_dequeue(struct svc_pool *pool
>  /*
>   * Release an skbuff after use
>   */
> -static inline void
> +static void
>  svc_release_skb(struct svc_rqst *rqstp)
>  {
> -	struct sk_buff *skb = rqstp->rq_skbuff;
> +	struct sk_buff *skb = rqstp->rq_xprt_ctxt;
>  	struct svc_deferred_req *dr = rqstp->rq_deferred;
>
>  	if (skb) {
> -		rqstp->rq_skbuff = NULL;
> +		rqstp->rq_xprt_ctxt = NULL;
>
>  		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
>  		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
> @@ -394,7 +394,7 @@ svc_sock_release(struct svc_rqst *rqstp)
>  {
>  	struct svc_sock	*svsk = rqstp->rq_sock;
>
> -	svc_release_skb(rqstp);
> +	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
>
>  	svc_free_res_pages(rqstp);
>  	rqstp->rq_res.page_len = 0;
> @@ -866,7 +866,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  			skb_free_datagram(svsk->sk_sk, skb);
>  			return 0;
>  		}
> -		rqstp->rq_skbuff = skb;
> +		rqstp->rq_xprt_ctxt = skb;
>  	}
>
>  	rqstp->rq_arg.page_base = 0;
> @@ -902,6 +902,7 @@ svc_udp_sendto(struct svc_rqst *rqstp)
>  static struct svc_xprt_ops svc_udp_ops = {
>  	.xpo_recvfrom = svc_udp_recvfrom,
>  	.xpo_sendto = svc_udp_sendto,
> +	.xpo_release = svc_release_skb,
>  };
>
>  static struct svc_xprt_class svc_udp_class = {
> @@ -1290,7 +1291,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
>  	}
>
> -	rqstp->rq_skbuff      = NULL;
> +	rqstp->rq_xprt_ctxt   = NULL;
>  	rqstp->rq_prot	      = IPPROTO_TCP;
>
>  	/* Reset TCP read info */
> @@ -1356,6 +1357,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
>  static struct svc_xprt_ops svc_tcp_ops = {
>  	.xpo_recvfrom = svc_tcp_recvfrom,
>  	.xpo_sendto = svc_tcp_sendto,
> +	.xpo_release = svc_release_skb,
>  };
>
>  static struct svc_xprt_class svc_tcp_class = {
> @@ -1577,7 +1579,7 @@ svc_send(struct svc_rqst *rqstp)
>  	}
>
>  	/* release the receive skb before sending the reply */
> -	svc_release_skb(rqstp);
> +	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
>
>  	/* calculate over-all length */
>  	xb = & rqstp->rq_res;

Chuck Lever
chuck.lever@oracle.com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
