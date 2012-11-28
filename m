Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34876 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754443Ab2K1SB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 13:01:59 -0500
Date: Wed, 28 Nov 2012 13:01:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 01/10] NFSD: Fold fault_inject.h into state.h
Message-ID: <20121128180156.GA16707@fieldses.org>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
 <1354026919-13313-2-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1354026919-13313-2-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2012 at 09:35:10AM -0500, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> There were only a small number of functions in this file and since they
> all affect stored state I think it makes sense to put them in state.h
> instead.  I also dropped most static inline declarations since there are
> no callers when fault injection is not enabled.

Went ahead and applied this one, just for fun.

--b.

> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfsd/fault_inject.c |  1 -
>  fs/nfsd/fault_inject.h | 28 ----------------------------
>  fs/nfsd/nfs4state.c    |  1 -
>  fs/nfsd/nfsctl.c       |  2 +-
>  fs/nfsd/state.h        | 15 +++++++++++++++
>  5 files changed, 16 insertions(+), 31 deletions(-)
>  delete mode 100644 fs/nfsd/fault_inject.h
> 
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> index e6c3815..0278112 100644
> --- a/fs/nfsd/fault_inject.c
> +++ b/fs/nfsd/fault_inject.c
> @@ -10,7 +10,6 @@
>  #include <linux/module.h>
>  
>  #include "state.h"
> -#include "fault_inject.h"
>  
>  struct nfsd_fault_inject_op {
>  	char *file;
> diff --git a/fs/nfsd/fault_inject.h b/fs/nfsd/fault_inject.h
> deleted file mode 100644
> index 90bd057..0000000
> --- a/fs/nfsd/fault_inject.h
> +++ /dev/null
> @@ -1,28 +0,0 @@
> -/*
> - * Copyright (c) 2011 Bryan Schumaker <bjschuma@netapp.com>
> - *
> - * Function definitions for fault injection
> - */
> -
> -#ifndef LINUX_NFSD_FAULT_INJECT_H
> -#define LINUX_NFSD_FAULT_INJECT_H
> -
> -#ifdef CONFIG_NFSD_FAULT_INJECTION
> -int nfsd_fault_inject_init(void);
> -void nfsd_fault_inject_cleanup(void);
> -void nfsd_forget_clients(u64);
> -void nfsd_forget_locks(u64);
> -void nfsd_forget_openowners(u64);
> -void nfsd_forget_delegations(u64);
> -void nfsd_recall_delegations(u64);
> -#else /* CONFIG_NFSD_FAULT_INJECTION */
> -static inline int nfsd_fault_inject_init(void) { return 0; }
> -static inline void nfsd_fault_inject_cleanup(void) {}
> -static inline void nfsd_forget_clients(u64 num) {}
> -static inline void nfsd_forget_locks(u64 num) {}
> -static inline void nfsd_forget_openowners(u64 num) {}
> -static inline void nfsd_forget_delegations(u64 num) {}
> -static inline void nfsd_recall_delegations(u64 num) {}
> -#endif /* CONFIG_NFSD_FAULT_INJECTION */
> -
> -#endif /* LINUX_NFSD_FAULT_INJECT_H */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7e5dfa1..2d6386f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -44,7 +44,6 @@
>  #include "xdr4.h"
>  #include "vfs.h"
>  #include "current_stateid.h"
> -#include "fault_inject.h"
>  
>  #include "netns.h"
>  
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index dab350d..7e0d6db 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -19,7 +19,7 @@
>  #include "idmap.h"
>  #include "nfsd.h"
>  #include "cache.h"
> -#include "fault_inject.h"
> +#include "state.h"
>  #include "netns.h"
>  
>  /*
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 2deb6a8..b542bf2 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -496,4 +496,19 @@ extern void nfsd4_client_record_create(struct nfs4_client *clp);
>  extern void nfsd4_client_record_remove(struct nfs4_client *clp);
>  extern int nfsd4_client_record_check(struct nfs4_client *clp);
>  extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
> +
> +/* nfs fault injection functions */
> +#ifdef CONFIG_NFSD_FAULT_INJECTION
> +int nfsd_fault_inject_init(void);
> +void nfsd_fault_inject_cleanup(void);
> +void nfsd_forget_clients(u64);
> +void nfsd_forget_locks(u64);
> +void nfsd_forget_openowners(u64);
> +void nfsd_forget_delegations(u64);
> +void nfsd_recall_delegations(u64);
> +#else /* CONFIG_NFSD_FAULT_INJECTION */
> +static inline int nfsd_fault_inject_init(void) { return 0; }
> +static inline void nfsd_fault_inject_cleanup(void) {}
> +#endif /* CONFIG_NFSD_FAULT_INJECTION */
> +
>  #endif   /* NFSD4_STATE_H */
> -- 
> 1.8.0.1
> 
