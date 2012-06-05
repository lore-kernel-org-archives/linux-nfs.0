Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39320 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784Ab2FEUTL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 16:19:11 -0400
Date: Tue, 5 Jun 2012 16:19:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: add fault injection for CB_PATH_DOWN
Message-ID: <20120605201909.GA27061@fieldses.org>
References: <1337888537-21754-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337888537-21754-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 24, 2012 at 03:42:16PM -0400, Weston Andros Adamson wrote:
> This fault injection hook causes all SEQUENCE operation replies to have the
> SEQ4_STATUS_CB_PATH_DOWN flag set until the client calls BIND_CONN_TO_SESSION
> or creates a new session.

I'm not necessarily opposed, but why do you need this?  In what
"real-life" situation could a client see the CB_PATH_DOWN flag
unexpectedly set?

--b.

> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfsd/fault_inject.c |    4 ++++
>  fs/nfsd/fault_inject.h |    2 ++
>  fs/nfsd/nfs4state.c    |   20 ++++++++++++++++++++
>  3 files changed, 26 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> index e6c3815..ab81144 100644
> --- a/fs/nfsd/fault_inject.c
> +++ b/fs/nfsd/fault_inject.c
> @@ -38,6 +38,10 @@ static struct nfsd_fault_inject_op inject_ops[] = {
>  		.file   = "recall_delegations",
>  		.func   = nfsd_recall_delegations,
>  	},
> +	{
> +		.file   = "kill_backchannel",
> +		.func   = nfsd_kill_backchannel,
> +	},
>  };
>  
>  static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
> diff --git a/fs/nfsd/fault_inject.h b/fs/nfsd/fault_inject.h
> index 90bd057..b058e03 100644
> --- a/fs/nfsd/fault_inject.h
> +++ b/fs/nfsd/fault_inject.h
> @@ -15,6 +15,7 @@ void nfsd_forget_locks(u64);
>  void nfsd_forget_openowners(u64);
>  void nfsd_forget_delegations(u64);
>  void nfsd_recall_delegations(u64);
> +void nfsd_kill_backchannel(u64);
>  #else /* CONFIG_NFSD_FAULT_INJECTION */
>  static inline int nfsd_fault_inject_init(void) { return 0; }
>  static inline void nfsd_fault_inject_cleanup(void) {}
> @@ -23,6 +24,7 @@ static inline void nfsd_forget_locks(u64 num) {}
>  static inline void nfsd_forget_openowners(u64 num) {}
>  static inline void nfsd_forget_delegations(u64 num) {}
>  static inline void nfsd_recall_delegations(u64 num) {}
> +static inline void nfsd_kill_backchannel(u64 num) {}
>  #endif /* CONFIG_NFSD_FAULT_INJECTION */
>  
>  #endif /* LINUX_NFSD_FAULT_INJECT_H */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 21266c7..9afc902 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4737,6 +4737,26 @@ void nfsd_recall_delegations(u64 num)
>  	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
>  }
>  
> +/*
> + * Force SEQUENCE operations to have SEQ4_STATUS_CB_PATH_DOWN flag set
> + * until backchannel is reestablished by BIND_CONN_TO_SESSION or
> + * DESTROY_SESSION/CREATE_SESSION with SP4_NONE.
> + *
> + * The argument 'num' is ignored, any value will trigger the fault on
> + * all clients.
> + */
> +void nfsd_kill_backchannel(u64 num)
> +{
> +	struct nfs4_client *clp, *next;
> +
> +	nfs4_lock_state();
> +	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
> +		clp->cl_cb_state = NFSD4_CB_DOWN;
> +	}
> +	nfs4_unlock_state();
> +
> +	printk(KERN_INFO "NFSD: killed backchannel");
> +}
>  #endif /* CONFIG_NFSD_FAULT_INJECTION */
>  
>  /* initialization to perform at module load time: */
> -- 
> 1.7.4.4
> 
