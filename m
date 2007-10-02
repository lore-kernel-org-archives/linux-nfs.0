From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
Date: Tue, 2 Oct 2007 11:04:16 -0400
Message-ID: <CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcjKL-0000OG-97
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 08:06:25 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcjKP-0001q9-1f
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 08:06:30 -0700
In-Reply-To: <20071001192740.3250.73564.stgit@dell3.ogc.int>
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
> The sk_sendto and sk_recvfrom are function pointers that allow  
> svc_sock
> to be used for both UDP and TCP. Move these function pointers to the
> svc_xprt_ops structure.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  include/linux/sunrpc/svc_xprt.h |    2 ++
>  include/linux/sunrpc/svcsock.h  |    3 ---
>  net/sunrpc/svcsock.c            |   12 ++++++------
>  3 files changed, 8 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> svc_xprt.h
> index 827f0fe..f0ba052 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -10,6 +10,8 @@ #define SUNRPC_SVC_XPRT_H
>  #include <linux/sunrpc/svc.h>
>
>  struct svc_xprt_ops {
> +	int		(*xpo_recvfrom)(struct svc_rqst *);
> +	int		(*xpo_sendto)(struct svc_rqst *);
>  };
>
>  struct svc_xprt_class {
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/ 
> svcsock.h
> index 1878cbe..08e78d0 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -45,9 +45,6 @@ #define	SK_DETACHED	10			/* detached fro
>  						 * be revisted */
>  	struct mutex		sk_mutex;	/* to serialize sending data */
>
> -	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
> -	int			(*sk_sendto)(struct svc_rqst *rqstp);
> -
>  	/* We keep the old state_change and data_ready CB's here */
>  	void			(*sk_ostate)(struct sock *);
>  	void			(*sk_odata)(struct sock *, int bytes);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index d84b5c8..150531f 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -900,6 +900,8 @@ svc_udp_sendto(struct svc_rqst *rqstp)
>  }
>
>  static struct svc_xprt_ops svc_udp_ops = {
> +	.xpo_recvfrom = svc_udp_recvfrom,
> +	.xpo_sendto = svc_udp_sendto,
>  };
>
>  static struct svc_xprt_class svc_udp_class = {
> @@ -917,8 +919,6 @@ svc_udp_init(struct svc_sock *svsk)
>  	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt);
>  	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
>  	svsk->sk_sk->sk_write_space = svc_write_space;
> -	svsk->sk_recvfrom = svc_udp_recvfrom;
> -	svsk->sk_sendto = svc_udp_sendto;
>
>  	/* initialise setting must have enough space to
>  	 * receive and respond to one request.
> @@ -1354,6 +1354,8 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
>  }
>
>  static struct svc_xprt_ops svc_tcp_ops = {
> +	.xpo_recvfrom = svc_tcp_recvfrom,
> +	.xpo_sendto = svc_tcp_sendto,
>  };
>
>  static struct svc_xprt_class svc_tcp_class = {
> @@ -1381,8 +1383,6 @@ svc_tcp_init(struct svc_sock *svsk)
>  	struct tcp_sock *tp = tcp_sk(sk);
>
>  	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt);
> -	svsk->sk_recvfrom = svc_tcp_recvfrom;
> -	svsk->sk_sendto = svc_tcp_sendto;
>
>  	if (sk->sk_state == TCP_LISTEN) {
>  		dprintk("setting up TCP socket for listening\n");
> @@ -1530,7 +1530,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
>
>  	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
>  		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
> -	len = svsk->sk_recvfrom(rqstp);
> +	len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
>  	dprintk("svc: got len=%d\n", len);
>
>  	/* No data, incomplete (TCP) read, or accept() */
> @@ -1590,7 +1590,7 @@ svc_send(struct svc_rqst *rqstp)
>  	if (test_bit(SK_DEAD, &svsk->sk_flags))
>  		len = -ENOTCONN;
>  	else
> -		len = svsk->sk_sendto(rqstp);
> +		len = svsk->sk_xprt.xpt_ops.xpo_sendto(rqstp);
>  	mutex_unlock(&svsk->sk_mutex);
>  	svc_sock_release(rqstp);

Again, here you have copied a pointer from the class structure to the  
instance structure -- the address of the transport ops structure  
never changes during the lifetime of the xprt instance, does it?  You  
could just as easily use the class's ops pointer instead.

It looks like on the client side, I didn't put the ops vector or the  
payload maximum in the class structure at all... 6 of one, half dozen  
of the other.  Using the class's value of the ops and payload maximum  
would save some space in the svc_xprt, though, come to think of it.

Also, to address Neil's concern about the appearance of the  
expression which dereferences these methods, why not use a macro,  
similar to VOP_GETATTR() in the old BSD kernels, that replaces this  
long chain of indirections with a simple to recognize macro call?

Chuck Lever
chuck.lever@oracle.com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
