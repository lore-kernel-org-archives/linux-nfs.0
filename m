From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 09/38] svc: Add a transport function that checks for write space
Date: Fri, 30 Nov 2007 15:46:20 -0500
Message-ID: <2F76C3FF-923D-4C36-ADBE-E3F9F645F20E@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224012.14563.23130.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38791 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbXK3Uqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 15:46:47 -0500
In-Reply-To: <20071129224012.14563.23130.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 29, 2007, at 5:40 PM, Tom Tucker wrote:
> In order to avoid blocking a service thread, the receive side checks
> to see if there is sufficient write space to reply to the request.
> Each transport has a different mechanism for determining if there is
> enough write space to reply.
>
> The code that checked for white space was coupled with code that

s/white space/write space/

> checked for CLOSE and CONN. These checks have been broken out into
> separate statements to make the code easier to read.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  net/sunrpc/svcsock.c            |   60 ++++++++++++++++++++++++++++ 
> +++++------
>  2 files changed, 51 insertions(+), 10 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> svc_xprt.h
> index 8501115..3adc8f3 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -10,6 +10,7 @@
>  #include <linux/sunrpc/svc.h>
>
>  struct svc_xprt_ops {
> +	int		(*xpo_has_wspace)(struct svc_xprt *);
>  	int		(*xpo_recvfrom)(struct svc_rqst *);
>  	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
>  	int		(*xpo_sendto)(struct svc_rqst *);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 510ad45..b796244 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -269,22 +269,24 @@ svc_sock_enqueue(struct svc_sock *svsk)
>  	BUG_ON(svsk->sk_pool != NULL);
>  	svsk->sk_pool = pool;
>
> -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
> -	     > svc_sock_wspace(svsk))
> -	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
> -	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
> +	/* Handle pending connection */
> +	if (test_bit(SK_CONN, &svsk->sk_flags))
> +		goto process;
> +
> +	/* Handle close in-progress */
> +	if (test_bit(SK_CLOSE, &svsk->sk_flags))
> +		goto process;
> +
> +	/* Check if we have space to reply to a request */
> +	if (!svsk->sk_xprt.xpt_ops->xpo_has_wspace(&svsk->sk_xprt)) {
>  		/* Don't enqueue while not enough space for reply */
> -		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
> -			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
> -			svc_sock_wspace(svsk));
> +		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);

Since you remove the only callers of svc_sock_wspace here, you can  
probably safely delete that function in this patch as well.

>  		svsk->sk_pool = NULL;
>  		clear_bit(SK_BUSY, &svsk->sk_flags);
>  		goto out_unlock;
>  	}
> -	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -
>
> + process:
>  	if (!list_empty(&pool->sp_threads)) {
>  		rqstp = list_entry(pool->sp_threads.next,
>  				   struct svc_rqst,
> @@ -897,6 +899,24 @@ static void svc_udp_prep_reply_hdr(struct  
> svc_rqst *rqstp)
>  {
>  }
>
> +static int svc_udp_has_wspace(struct svc_xprt *xprt)
> +{
> +	struct svc_sock *svsk = container_of(xprt, struct svc_sock,  
> sk_xprt);
> +	struct svc_serv	*serv = svsk->sk_server;
> +	int required;
> +
> +	/*
> +	 * Set the SOCK_NOSPACE flag before checking the available
> +	 * sock space.
> +	 */
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;

The result of the sum is unsigned, but then we stuff it into a signed  
integer...

> +	if (required*2 > sock_wspace(svsk->sk_sk))
> +		return 0;

...and then this introduces a mixed sign comparison (harmless  
AFAICT).  Perhaps "required" should be an unsigned long.

Also, some may prefer "<< 1" to "* 2".  I'm not sure it makes much  
difference here.  Arguably, it might be slightly better documentation  
to double "required" before the if statement.

> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 1;
> +}
> +
>  static struct svc_xprt_ops svc_udp_ops = {
>  	.xpo_recvfrom = svc_udp_recvfrom,
>  	.xpo_sendto = svc_udp_sendto,
> @@ -904,6 +924,7 @@ static struct svc_xprt_ops svc_udp_ops = {
>  	.xpo_detach = svc_sock_detach,
>  	.xpo_free = svc_sock_free,
>  	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
> +	.xpo_has_wspace = svc_udp_has_wspace,
>  };
>
>  static struct svc_xprt_class svc_udp_class = {
> @@ -1366,6 +1387,24 @@ static void svc_tcp_prep_reply_hdr(struct  
> svc_rqst *rqstp)
>  	svc_putnl(resv, 0);
>  }
>
> +static int svc_tcp_has_wspace(struct svc_xprt *xprt)
> +{
> +	struct svc_sock *svsk = container_of(xprt, struct svc_sock,  
> sk_xprt);
> +	struct svc_serv	*serv = svsk->sk_server;
> +	int required;
> +
> +	/*
> +	 * Set the SOCK_NOSPACE flag before checking the available
> +	 * sock space.
> +	 */
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;

Ibid.

> +	if (required*2 > sk_stream_wspace(svsk->sk_sk))
> +		return 0;

Oddly sk_stream_wspace() returns an int, but sock_space() returns an  
unsigned long.  Sigh...

> +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 1;
> +}
> +
>  static struct svc_xprt_ops svc_tcp_ops = {
>  	.xpo_recvfrom = svc_tcp_recvfrom,
>  	.xpo_sendto = svc_tcp_sendto,
> @@ -1373,6 +1412,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
>  	.xpo_detach = svc_sock_detach,
>  	.xpo_free = svc_sock_free,
>  	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
> +	.xpo_has_wspace = svc_tcp_has_wspace,
>  };
>
>  static struct svc_xprt_class svc_tcp_class = {

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
