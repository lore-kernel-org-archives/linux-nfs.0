Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43760 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752099AbeCHRFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 12:05:11 -0500
Date: Thu, 8 Mar 2018 12:05:11 -0500
To: Olga Kornievskaia <kolga@netapp.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v7 10/10] NFSD stop queued async copies on client shutdown
Message-ID: <20180308170511.GF10782@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-11-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180220164229.65404-11-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 20, 2018 at 11:42:29AM -0500, Olga Kornievskaia wrote:
> If client is shutting down and there are still async copies going
> on, then stop queued async copies.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c  | 13 +++++++++++++
>  fs/nfsd/nfs4state.c |  1 +
>  fs/nfsd/state.h     |  1 +
>  3 files changed, 15 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 57d0daa..54039e4 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1096,6 +1096,19 @@ static void nfs4_put_copy(struct nfsd4_copy *copy)
>  	kfree(copy);
>  }
>  
> +void nfsd4_shutdown_copy(struct nfs4_client *clp)
> +{
> +	struct nfsd4_copy *copy;
> +
> +	spin_lock(&clp->async_lock);
> +	list_for_each_entry(copy, &clp->async_copies, copies) {
> +		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
> +		kthread_stop(copy->copy_task);
> +		nfs4_put_copy(copy);

Those three lines could go in a common helper to be called here and from
nfsd4_offload_cancel().

--b.

> +	}
> +	spin_unlock(&clp->async_lock);
> +}
> +
>  static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
>  {
>  	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bd76bd1..f9f2383 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1965,6 +1965,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
>  		release_openowner(oo);
>  	}
>  	nfsd4_return_all_client_layouts(clp);
> +	nfsd4_shutdown_copy(clp);
>  	nfsd4_shutdown_callback(clp);
>  	if (clp->cl_cb_conn.cb_xprt)
>  		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 49709d1..131aefa 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -646,6 +646,7 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
>  extern int nfsd4_create_callback_queue(void);
>  extern void nfsd4_destroy_callback_queue(void);
>  extern void nfsd4_shutdown_callback(struct nfs4_client *);
> +extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
>  extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
>  extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
>  							struct nfsd_net *nn);
> -- 
> 1.8.3.1
