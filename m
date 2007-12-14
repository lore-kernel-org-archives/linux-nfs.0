From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 14/38] svc: Change sk_inuse to a kref
Date: Fri, 14 Dec 2007 15:52:26 -0500
Message-ID: <20071214205226.GG23121@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233224.15718.91339.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44381 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899AbXLNUwa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2007 15:52:30 -0500
In-Reply-To: <20071211233224.15718.91339.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2007 at 05:32:25PM -0600, Tom Tucker wrote:
> 
> Change the atomic_t reference count to a kref and move it to the 
> transport indepenent svc_xprt structure. Change the reference count
> wrapper names to be generic.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svc_xprt.h |    8 ++++++
>  include/linux/sunrpc/svcsock.h  |    1 -
>  net/sunrpc/svc_xprt.c           |   17 ++++++++++++
>  net/sunrpc/svcsock.c            |   54 +++++++++++++++------------------------
>  4 files changed, 46 insertions(+), 34 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index 3f4a1df..eb801ad 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -8,6 +8,7 @@
>  #define SUNRPC_SVC_XPRT_H
>  
>  #include <linux/sunrpc/svc.h>
> +#include <linux/module.h>
>  
>  struct svc_xprt_ops {
>  	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
> @@ -34,11 +35,18 @@ struct svc_xprt_class {
>  struct svc_xprt {
>  	struct svc_xprt_class	*xpt_class;
>  	struct svc_xprt_ops	*xpt_ops;
> +	struct kref		xpt_ref;
>  };
>  
>  int	svc_reg_xprt_class(struct svc_xprt_class *);
>  int	svc_unreg_xprt_class(struct svc_xprt_class *);
>  void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
>  int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
> +void	svc_xprt_put(struct svc_xprt *xprt);
> +
> +static inline void svc_xprt_get(struct svc_xprt *xprt)
> +{
> +	kref_get(&xprt->xpt_ref);
> +}
>  
>  #endif /* SUNRPC_SVC_XPRT_H */
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 3181d9d..ba07d50 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -24,7 +24,6 @@ struct svc_sock {
>  
>  	struct svc_pool *	sk_pool;	/* current pool iff queued */
>  	struct svc_serv *	sk_server;	/* service for this socket */
> -	atomic_t		sk_inuse;	/* use count */
>  	unsigned long		sk_flags;
>  #define	SK_BUSY		0			/* enqueued/receiving */
>  #define	SK_CONN		1			/* conn pending */
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 9136da4..43418cf 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -82,6 +82,22 @@ int svc_unreg_xprt_class(struct svc_xprt_class *xcl)
>  }
>  EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
>  
> +static void svc_xprt_free(struct kref *kref)
> +{
> +	struct svc_xprt *xprt =
> +		container_of(kref, struct svc_xprt, xpt_ref);
> +	struct module *owner = xprt->xpt_class->xcl_owner;
> +	BUG_ON(atomic_read(&kref->refcount));

All this BUG_ON() is doing is checking for what looks like a bizarrely
unlikely bug in kref_put().  The BUG_ON from the original code is:

	BUG_ON(!test_bit(SK_DEAD, &svsk->sk_flags));

But I don't have any strong feelings as to whether that's necessary.

--b.
