Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995AbaEHRGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 13:06:07 -0400
Date: Thu, 8 May 2014 13:06:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Get rid of empty function nfs4_state_init
Message-ID: <20140508170606.GH20976@fieldses.org>
References: <534383D4.50504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <534383D4.50504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Tue, Apr 08, 2014 at 01:06:28PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 7 -------
>  fs/nfsd/nfsctl.c    | 1 -
>  fs/nfsd/nfsd.h      | 2 --
>  3 files changed, 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5a9588e..6e786a8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4969,13 +4969,6 @@ struct nfs4_client *nfsd_find_client(struct
> sockaddr_storage *addr, size_t addr_
> 
>  #endif /* CONFIG_NFSD_FAULT_INJECTION */
> 
> -/* initialization to perform at module load time: */
> -
> -void
> -nfs4_state_init(void)
> -{
> -}
> -
>  /*
>   * Since the lifetime of a delegation isn't limited to that of an open, a
>   * client may quite reasonably hang on to a delegation as long as it has
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7f55517..493f3d4 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1174,7 +1174,6 @@ static int __init init_nfsd(void)
>  	retval = nfsd4_init_slabs();
>  	if (retval)
>  		goto out_unregister_pernet;
> -	nfs4_state_init();
>  	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
>  	if (retval)
>  		goto out_free_slabs;
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 30f34ab..22259f8 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -106,7 +106,6 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
>   */
>  #ifdef CONFIG_NFSD_V4
>  extern unsigned long max_delegations;
> -void nfs4_state_init(void);
>  int nfsd4_init_slabs(void);
>  void nfsd4_free_slabs(void);
>  int nfs4_state_start(void);
> @@ -117,7 +116,6 @@ void nfs4_reset_lease(time_t leasetime);
>  int nfs4_reset_recoverydir(char *recdir);
>  char * nfs4_recoverydir(void);
>  #else
> -static inline void nfs4_state_init(void) { }
>  static inline int nfsd4_init_slabs(void) { return 0; }
>  static inline void nfsd4_free_slabs(void) { }
>  static inline int nfs4_state_start(void) { return 0; }
> -- 
> 1.9.0
> 
