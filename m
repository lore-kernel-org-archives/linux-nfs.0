From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: remove svc_create_thread()
Date: Mon, 7 Apr 2008 16:53:38 -0400
Message-ID: <20080407205338.GF11219@fieldses.org>
References: <1207601137-6099-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, hch@infradead.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37098 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbYDGUxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2008 16:53:39 -0400
In-Reply-To: <1207601137-6099-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2008 at 04:45:37PM -0400, Jeff Layton wrote:
> Now that the nfs4 callback thread uses the kthread API, there are no
> more users of svc_create_thread(). Remove it.

Thanks; applied.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/sunrpc/svc.h |    1 -
>  net/sunrpc/svc.c           |   10 ----------
>  2 files changed, 0 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 64c9755..4b54c5f 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -386,7 +386,6 @@ struct svc_serv *  svc_create(struct svc_program *, unsigned int,
>  			      void (*shutdown)(struct svc_serv*));
>  struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
>  					struct svc_pool *pool);
> -int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
>  void		   svc_exit_thread(struct svc_rqst *);
>  struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
>  			void (*shutdown)(struct svc_serv*),
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 60c9e92..71023c7 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -613,16 +613,6 @@ out_thread:
>  }
>  
>  /*
> - * Create a thread in the default pool.  Caller must hold BKL.
> - */
> -int
> -svc_create_thread(svc_thread_fn func, struct svc_serv *serv)
> -{
> -	return __svc_create_thread(func, serv, &serv->sv_pools[0]);
> -}
> -EXPORT_SYMBOL(svc_create_thread);
> -
> -/*
>   * Choose a pool in which to create a new thread, for svc_set_num_threads
>   */
>  static inline struct svc_pool *
> -- 
> 1.5.3.6
> 
