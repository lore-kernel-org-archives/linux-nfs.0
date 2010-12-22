Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60143 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394Ab0LVWY0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Dec 2010 17:24:26 -0500
Date: Wed, 22 Dec 2010 17:24:14 -0500
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V5 03/11] SUNRPC new transport for the NFSv4.1 shared
 back channel
Message-ID: <20101222222414.GD13243@fieldses.org>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <1292879088-7821-3-git-send-email-andros@netapp.com>
 <1292879088-7821-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292879088-7821-4-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 20, 2010 at 04:04:40PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Move the current sock create and destroy routines into the new transport ops.
> Back channel socket will be destroyed by the svc_closs_all call in svc_destroy.

Also note you're adding UDP check?

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/sunrpc/svcsock.h |    1 +
>  net/sunrpc/svc.c               |    4 --
>  net/sunrpc/svcsock.c           |  118 +++++++++++++++++++++++++++++++++-------
>  3 files changed, 99 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 1b353a7..3a45a80 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -45,6 +45,7 @@ int		svc_sock_names(struct svc_serv *serv, char *buf,
>  int		svc_addsock(struct svc_serv *serv, const int fd,
>  					char *name_return, const size_t len);
>  void		svc_init_xprt_sock(void);
> +void		svc_init_bc_xprt_sock(void);
>  void		svc_cleanup_xprt_sock(void);
>  struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot);
>  void		svc_sock_destroy(struct svc_xprt *);
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 606d182..261e2d1 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -488,10 +488,6 @@ svc_destroy(struct svc_serv *serv)
>  	if (svc_serv_is_pooled(serv))
>  		svc_pool_map_put();
>  
> -#if defined(CONFIG_NFS_V4_1)
> -	svc_sock_destroy(serv->bc_xprt);
> -#endif /* CONFIG_NFS_V4_1 */
> -
>  	svc_unregister(serv);
>  	kfree(serv->sv_pools);
>  	kfree(serv);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 07919e1..d2db384 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -66,6 +66,13 @@ static void		svc_sock_free(struct svc_xprt *);
>  static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
>  					  struct net *, struct sockaddr *,
>  					  int, int);
> +#if defined(CONFIG_NFS_V4_1)
> +static struct svc_xprt *svc_bc_create_socket(struct svc_serv *, int,
> +					     struct net *, struct sockaddr *,
> +					     int, int);
> +static void svc_bc_sock_free(struct svc_xprt *xprt);
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  #ifdef CONFIG_DEBUG_LOCK_ALLOC
>  static struct lock_class_key svc_key[2];
>  static struct lock_class_key svc_slock_key[2];
> @@ -1184,6 +1191,75 @@ static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
>  	return svc_create_socket(serv, IPPROTO_TCP, net, sa, salen, flags);
>  }
>  
> +#if defined(CONFIG_NFS_V4_1)
> +static struct svc_xprt *svc_bc_create_socket(struct svc_serv *, int,
> +					     struct net *, struct sockaddr *,
> +					     int, int);
> +static void svc_bc_sock_free(struct svc_xprt *xprt);
> +
> +static struct svc_xprt *svc_bc_tcp_create(struct svc_serv *serv,
> +				       struct net *net,
> +				       struct sockaddr *sa, int salen,
> +				       int flags)
> +{
> +	return svc_bc_create_socket(serv, IPPROTO_TCP, net, sa, salen, flags);
> +}
> +
> +static void svc_bc_tcp_sock_detach(struct svc_xprt *xprt)
> +{
> +}
> +
> +/* These bc ops are never called. The shared fore channel is used instead */
> +static int svc_bc_tcp_recvfrom(struct svc_rqst *rqstp)
> +{
> +	return 0;
> +}
> +
> +static int svc_bc_tcp_sendto(struct svc_rqst *rqstp)
> +{
> +	return 0;
> +}
> +
> +static void svc_bc_release_skb(struct svc_rqst *rqstp)
> +{
> +}
> +
> +static int svc_bc_tcp_has_wspace(struct svc_xprt *xprt)
> +{
> +	return 0;
> +}
> +
> +static struct svc_xprt *svc_bc_tcp_accept(struct svc_xprt *xprt)
> +{
> +	return NULL;
> +}
> +
> +static struct svc_xprt_ops svc_tcp_bc_ops = {
> +	.xpo_create = svc_bc_tcp_create,
> +	.xpo_recvfrom = svc_bc_tcp_recvfrom,
> +	.xpo_sendto = svc_bc_tcp_sendto,
> +	.xpo_release_rqst = svc_bc_release_skb,
> +	.xpo_detach = svc_bc_tcp_sock_detach,
> +	.xpo_free = svc_bc_sock_free,
> +	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
> +	.xpo_has_wspace = svc_bc_tcp_has_wspace,
> +	.xpo_accept = svc_bc_tcp_accept,
> +};
> +
> +static struct svc_xprt_class svc_tcp_bc_class = {
> +	.xcl_name = "tcp-bc",
> +	.xcl_owner = THIS_MODULE,
> +	.xcl_ops = &svc_tcp_bc_ops,
> +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
> +};
> +
> +void svc_init_bc_xprt_sock(void)
> +{
> +	svc_reg_xprt_class(&svc_tcp_bc_class);
> +}
> +EXPORT_SYMBOL_GPL(svc_init_bc_xprt_sock);
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  static struct svc_xprt_ops svc_tcp_ops = {
>  	.xpo_create = svc_tcp_create,
>  	.xpo_recvfrom = svc_tcp_recvfrom,
> @@ -1509,41 +1585,43 @@ static void svc_sock_free(struct svc_xprt *xprt)
>  	kfree(svsk);
>  }
>  
> +#if defined(CONFIG_NFS_V4_1)
>  /*
> - * Create a svc_xprt.
> - *
> - * For internal use only (e.g. nfsv4.1 backchannel).
> - * Callers should typically use the xpo_create() method.
> + * Create a back channel svc_xprt which shares the fore channel socket.
>   */
> -struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot)
> +static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
> +					     int protocol,
> +					     struct net *net,
> +					     struct sockaddr *sin, int len,
> +					     int flags)
>  {
>  	struct svc_sock *svsk;
> -	struct svc_xprt *xprt = NULL;
> +	struct svc_xprt *xprt;
> +
> +	if (protocol != IPPROTO_TCP) {
> +		printk(KERN_WARNING "svc: only and TCP sockets"
> +			" supported on shared back channel\n");
> +		return ERR_PTR(-EINVAL);
> +	}
>  
> -	dprintk("svc: %s\n", __func__);
>  	svsk = kzalloc(sizeof(*svsk), GFP_KERNEL);
>  	if (!svsk)
> -		goto out;
> +		return ERR_PTR(-ENOMEM);
>  
>  	xprt = &svsk->sk_xprt;
> -	if (prot == IPPROTO_TCP)
> -		svc_xprt_init(&svc_tcp_class, xprt, serv);
> -	else if (prot == IPPROTO_UDP)
> -		svc_xprt_init(&svc_udp_class, xprt, serv);
> -	else
> -		BUG();
> -out:
> -	dprintk("svc: %s return %p\n", __func__, xprt);
> +	svc_xprt_init(&svc_tcp_bc_class, xprt, serv);
> +
> +	serv->bc_xprt = xprt;
> +
>  	return xprt;
>  }
> -EXPORT_SYMBOL_GPL(svc_sock_create);
>  
>  /*
> - * Destroy a svc_sock.
> + * Free a back channel svc_sock.
>   */
> -void svc_sock_destroy(struct svc_xprt *xprt)
> +static void svc_bc_sock_free(struct svc_xprt *xprt)
>  {
>  	if (xprt)
>  		kfree(container_of(xprt, struct svc_sock, sk_xprt));
>  }
> -EXPORT_SYMBOL_GPL(svc_sock_destroy);
> +#endif /* CONFIG_NFS_V4_1 */
> -- 
> 1.6.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
