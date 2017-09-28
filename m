Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60150 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750759AbdI1TVu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 15:21:50 -0400
Date: Thu, 28 Sep 2017 15:21:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] NFSD stop queued async copies on client shutdown
Message-ID: <20170928192148.GM10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-11-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170928172945.50780-11-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 01:29:45PM -0400, Olga Kornievskaia wrote:
> If client is shutting down and there are still async copies going
> on, then stop queued async copies.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c  | 9 +++++++++
>  fs/nfsd/nfs4state.c | 1 +
>  fs/nfsd/state.h     | 2 ++
>  3 files changed, 12 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 74bfa4b..8d0c87f 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -91,6 +91,12 @@ void nfsd4_destroy_copy_queue(void)
>  	destroy_workqueue(copy_wq);
>  }
>  
> +void nfsd4_shutdown_copy(struct nfs4_client *clp)
> +{
> +	set_bit(NFSD4_CLIENT_COPY_KILL, &clp->cl_flags);
> +	flush_workqueue(copy_wq);

Looks like that will just stop new copies and wait on any ongoing ones.
That could be a long wait.

A signal should help there too.

If you still need a "this client is dying" bit in cl_flags, you could
probably just use CB_KILL instead of this new one.

--b.

> +}
> +
>  #define NFSDDBG_FACILITY		NFSDDBG_PROC
>  
>  static u32 nfsd_attrmask[] = {
> @@ -1205,6 +1211,9 @@ static void nfsd4_do_async_copy(struct work_struct *work)
>  		container_of(work, struct nfsd4_copy, cp_work);
>  	struct nfsd4_copy *cb_copy;
>  
> +	if (test_bit(NFSD4_CLIENT_COPY_KILL, &copy->cp_clp->cl_flags))
> +		goto out;
> +
>  	copy->nfserr = nfsd4_do_copy(copy, 0);
>  
>  	if (copy->cps->cp_cancelled)
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 97ab3f8..f4b193e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1961,6 +1961,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
>  	}
>  	nfsd4_return_all_client_layouts(clp);
>  	nfsd4_shutdown_callback(clp);
> +	nfsd4_shutdown_copy(clp);
>  	if (clp->cl_cb_conn.cb_xprt)
>  		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
>  	free_client(clp);
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index c31025c..55f09a9 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -336,6 +336,7 @@ struct nfs4_client {
>  #define NFSD4_CLIENT_RECLAIM_COMPLETE	(3)	/* reclaim_complete done */
>  #define NFSD4_CLIENT_CONFIRMED		(4)	/* client is confirmed */
>  #define NFSD4_CLIENT_UPCALL_LOCK	(5)	/* upcall serialization */
> +#define NFSD4_CLIENT_COPY_KILL		(6)	/* stop copy workqueue */
>  #define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
>  					 1 << NFSD4_CLIENT_CB_KILL)
>  	unsigned long		cl_flags;
> @@ -644,6 +645,7 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
>  extern int nfsd4_create_callback_queue(void);
>  extern void nfsd4_destroy_callback_queue(void);
>  extern void nfsd4_shutdown_callback(struct nfs4_client *);
> +extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
>  extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
>  extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
>  							struct nfsd_net *nn);
> -- 
> 1.8.3.1
> 
