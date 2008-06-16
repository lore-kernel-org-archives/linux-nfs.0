From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/11] svcrdma: Add a type for keeping NFS RPC mapping
Date: Mon, 16 Jun 2008 15:48:58 -0400
Message-ID: <20080616194858.GA29446@fieldses.org>
References: <12120836962076-git-send-email-tom@opengridcomputing.com> <12120836962324-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42244 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbYFPTtA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 15:49:00 -0400
In-Reply-To: <12120836962324-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 29, 2008 at 12:54:46PM -0500, Tom Tucker wrote:
> Create a new data structure to hold the remote client address space
> to local server address space mapping.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  include/linux/sunrpc/svc_rdma.h          |   27 +++++++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma.c           |   23 +++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   26 ++++++++++++++++++++++++++
>  3 files changed, 76 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 05eb466..bd8749c 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -86,6 +86,31 @@ struct svc_rdma_op_ctxt {
>  	struct page *pages[RPCSVC_MAXPAGES];
>  };
>  
> +/*
> + * NFS_ requests are mapped on the client side by the chunk lists in
> + * the RPCRDMA header. During the fetching of the RPC from the client
> + * and the writing of the reply to the client, the memory in the
> + * client and the memory in the server must be mapped as contiguous
> + * vaddr/len for access by the hardware. These data strucures keep
> + * these mappings.
> + *
> + * For an RDMA_WRITE, the 'sge' maps the RPC REPLY. For RDMA_READ, the
> + * 'sge' in the svc_rdma_req_map maps the server side RPC reply and the
> + * 'ch' field maps the read-list of the RPCRDMA header to the 'sge'
> + * mapping of the reply.
> + */
> +struct svc_rdma_chunk_sge {
> +	int start;		/* sge no for this chunk */
> +	int count;		/* sge count for this chunk */
> +};
> +struct svc_rdma_req_map {
> +	unsigned long count;
> +	union {
> +		struct kvec sge[RPCSVC_MAXPAGES];
> +		struct svc_rdma_chunk_sge ch[RPCSVC_MAXPAGES];
> +	};
> +};
> +
>  #define RDMACTXT_F_LAST_CTXT	2
>  
>  struct svcxprt_rdma {
> @@ -173,6 +198,8 @@ extern int svc_rdma_post_recv(struct svcxprt_rdma *);
>  extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
>  extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
>  extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
> +extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
> +extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
>  extern void svc_sq_reap(struct svcxprt_rdma *);
>  extern void svc_rq_reap(struct svcxprt_rdma *);
>  extern struct svc_xprt_class svc_rdma_class;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
> index 88c0ca2..545ea72 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> @@ -69,6 +69,9 @@ atomic_t rdma_stat_rq_prod;
>  atomic_t rdma_stat_sq_poll;
>  atomic_t rdma_stat_sq_prod;
>  
> +/* Temporary NFS request map cache */
> +struct kmem_cache *svc_rdma_map_cachep = NULL;

No need to initialize globals to NULL.

> +
>  /*
>   * This function implements reading and resetting an atomic_t stat
>   * variable through read/write to a proc file. Any write to the file
> @@ -241,6 +244,8 @@ void svc_rdma_cleanup(void)
>  		svcrdma_table_header = NULL;
>  	}
>  	svc_unreg_xprt_class(&svc_rdma_class);
> +	if (svc_rdma_map_cachep)
> +		kmem_cache_destroy(svc_rdma_map_cachep);

By design this can't be NULL (and the code presumably would have oopsed
much earlier if it were mistakenly allowed to be) so I'm inclined not to
bother checking....

>  }
>  
>  int svc_rdma_init(void)
> @@ -255,9 +260,27 @@ int svc_rdma_init(void)
>  		svcrdma_table_header =
>  			register_sysctl_table(svcrdma_root_table);
>  
> +	/* Create the temporary map cache */
> +	svc_rdma_map_cachep = kmem_cache_create("svc_rdma_map_cache",
> +						sizeof(struct svc_rdma_req_map),
> +						0,
> +						SLAB_HWCACHE_ALIGN,
> +						NULL);
> +	if (!svc_rdma_map_cachep) {
> +		printk(KERN_INFO "Could not allocate map cache.\n");
> +		goto err;
> +	}
> +
>  	/* Register RDMA with the SVC transport switch */
>  	svc_reg_xprt_class(&svc_rdma_class);
>  	return 0;
> +
> + err:
> +	if (svcrdma_table_header) {
> +		unregister_sysctl_table(svcrdma_table_header);

unregister_sysctl_table() already handles the NULL case, so you could
skip the if (svcrdma_table_header).

--b.

> +		svcrdma_table_header = NULL;
> +	}
> +	return -ENOMEM;
>  }
>  MODULE_AUTHOR("Tom Tucker <tom@opengridcomputing.com>");
>  MODULE_DESCRIPTION("SVC RDMA Transport");
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index e132509..ae90758 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -173,6 +173,32 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
>  	atomic_dec(&xprt->sc_ctxt_used);
>  }
>  
> +/* Temporary NFS request map cache. Created in svc_rdma.c  */
> +extern struct kmem_cache *svc_rdma_map_cachep;
> +
> +/*
> + * Temporary NFS req mappings are shared across all transport
> + * instances. These are short lived and should be bounded by the number
> + * of concurrent server threads * depth of the SQ.
> + */
> +struct svc_rdma_req_map *svc_rdma_get_req_map(void)
> +{
> +	struct svc_rdma_req_map *map;
> +	while (1) {
> +		map = kmem_cache_alloc(svc_rdma_map_cachep, GFP_KERNEL);
> +		if (map)
> +			break;
> +		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
> +	}
> +	map->count = 0;
> +	return map;
> +}
> +
> +void svc_rdma_put_req_map(struct svc_rdma_req_map *map)
> +{
> +	kmem_cache_free(svc_rdma_map_cachep, map);
> +}
> +
>  /* ib_cq event handler */
>  static void cq_event_handler(struct ib_event *event, void *context)
>  {
