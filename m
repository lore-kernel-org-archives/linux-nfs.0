Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab1KDVgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 17:36:00 -0400
Date: Fri, 4 Nov 2011 17:36:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Call nfsd4_init_slabs() from init_nfsd()
Message-ID: <20111104213559.GI721@fieldses.org>
References: <1320171487-13966-1-git-send-email-bjschuma@netapp.com>
 <20111101190523.GA1891@fieldses.org>
 <4EB0478B.7060100@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EB0478B.7060100@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 01, 2011 at 03:24:59PM -0400, Bryan Schumaker wrote:
> On Tue 01 Nov 2011 03:05:23 PM EDT, J. Bruce Fields wrote:
> > On Tue, Nov 01, 2011 at 02:18:07PM -0400, bjschuma@netapp.com wrote:
> >> From: Bryan Schumaker <bjschuma@netapp.com>
> >>
> >> init_nfsd() was calling free_slabs() during cleanup code, but the call
> >> to init_slabs() was hidden in nfsd4_state_init().  This could be
> >> confusing to people unfamiliar with the code.
> >
> > Good idea.  But: while you're at it, since you just removed the only
> > possible error return from nfs4_state_init(), how about going ahead and
> > making that a void return.  Probably in the same patch.--b.
> 
> Sure.  How about this?

Works for me; thanks!

--b.

> 
> init_nfsd() was calling free_slabs() during cleanup code, but the call
> to init_slabs() was hidden in nfsd4_state_init().  This could be
> confusing to people unfamiliar with the code.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |   10 +++-------
>  fs/nfsd/nfsctl.c    |    3 ++-
>  fs/nfsd/nfsd.h      |    6 ++++--
>  3 files changed, 9 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 47e94e3..5d6b2b1 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2301,7 +2301,7 @@ nfsd4_free_slabs(void)
>  	nfsd4_free_slab(&deleg_slab);
>  }
>  
> -static int
> +int
>  nfsd4_init_slabs(void)
>  {
>  	openowner_slab = kmem_cache_create("nfsd4_openowners",
> @@ -4396,14 +4396,11 @@ nfs4_check_open_reclaim(clientid_t *clid)
>  
>  /* initialization to perform at module load time: */
>  
> -int
> +void
>  nfs4_state_init(void)
>  {
> -	int i, status;
> +	int i;
>  
> -	status = nfsd4_init_slabs();
> -	if (status)
> -		return status;
>  	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
>  		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
>  		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
> @@ -4427,7 +4424,6 @@ nfs4_state_init(void)
>  	INIT_LIST_HEAD(&client_lru);
>  	INIT_LIST_HEAD(&del_recall_lru);
>  	reclaim_str_hashtbl_size = 0;
> -	return 0;
>  }
>  
>  static void
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index db34a58..912b17e 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1127,9 +1127,10 @@ static int __init init_nfsd(void)
>  	int retval;
>  	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 
> okir@monad.swb.de).\n");
>  
> -	retval = nfs4_state_init(); /* nfs4 locking state */
> +	retval = nfsd4_init_slabs();
>  	if (retval)
>  		return retval;
> +	nfs4_state_init();
>  	nfsd_stat_init();	/* Statistics */
>  	retval = nfsd_reply_cache_init();
>  	if (retval)
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 58134a2..4e2ee29 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -104,14 +104,16 @@ static inline int nfsd_v4client(struct svc_rqst 
> *rq)
>   */
>  #ifdef CONFIG_NFSD_V4
>  extern unsigned int max_delegations;
> -int nfs4_state_init(void);
> +void nfs4_state_init(void);
> +int nfsd4_init_slabs(void);
>  void nfsd4_free_slabs(void);
>  int nfs4_state_start(void);
>  void nfs4_state_shutdown(void);
>  void nfs4_reset_lease(time_t leasetime);
>  int nfs4_reset_recoverydir(char *recdir);
>  #else
> -static inline int nfs4_state_init(void) { return 0; }
> +static inline void nfs4_state_init(void) { }
> +static inline int nfsd4_init_slabs(void) { return 0; }
>  static inline void nfsd4_free_slabs(void) { }
>  static inline int nfs4_state_start(void) { return 0; }
>  static inline void nfs4_state_shutdown(void) { }
> -- 
> 1.7.7
> >
> >>
> >> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> >> ---
> >>  fs/nfsd/nfs4state.c |    5 +----
> >>  fs/nfsd/nfsctl.c    |    6 +++++-
> >>  fs/nfsd/nfsd.h      |    2 ++
> >>  3 files changed, 8 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 47e94e3..765b292 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -2301,7 +2301,7 @@ nfsd4_free_slabs(void)
> >>  	nfsd4_free_slab(&deleg_slab);
> >>  }
> >>  
> >> -static int
> >> +int
> >>  nfsd4_init_slabs(void)
> >>  {
> >>  	openowner_slab = kmem_cache_create("nfsd4_openowners",
> >> @@ -4401,9 +4401,6 @@ nfs4_state_init(void)
> >>  {
> >>  	int i, status;
> >>  
> >> -	status = nfsd4_init_slabs();
> >> -	if (status)
> >> -		return status;
> >>  	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
> >>  		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
> >>  		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
> >> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> >> index db34a58..883ea54 100644
> >> --- a/fs/nfsd/nfsctl.c
> >> +++ b/fs/nfsd/nfsctl.c
> >> @@ -1127,9 +1127,12 @@ static int __init init_nfsd(void)
> >>  	int retval;
> >>  	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
> >>  
> >> -	retval = nfs4_state_init(); /* nfs4 locking state */
> >> +	retval = nfsd4_init_slabs();
> >>  	if (retval)
> >>  		return retval;
> >> +	retval = nfs4_state_init(); /* nfs4 locking state */
> >> +	if (retval)
> >> +		goto out_free_slabs;
> >>  	nfsd_stat_init();	/* Statistics */
> >>  	retval = nfsd_reply_cache_init();
> >>  	if (retval)
> >> @@ -1160,6 +1163,7 @@ out_free_cache:
> >>  	nfsd_reply_cache_shutdown();
> >>  out_free_stat:
> >>  	nfsd_stat_shutdown();
> >> +out_free_slabs:
> >>  	nfsd4_free_slabs();
> >>  	return retval;
> >>  }
> >> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> >> index 58134a2..46f97ba 100644
> >> --- a/fs/nfsd/nfsd.h
> >> +++ b/fs/nfsd/nfsd.h
> >> @@ -105,6 +105,7 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
> >>  #ifdef CONFIG_NFSD_V4
> >>  extern unsigned int max_delegations;
> >>  int nfs4_state_init(void);
> >> +int nfsd4_init_slabs(void);
> >>  void nfsd4_free_slabs(void);
> >>  int nfs4_state_start(void);
> >>  void nfs4_state_shutdown(void);
> >> @@ -112,6 +113,7 @@ void nfs4_reset_lease(time_t leasetime);
> >>  int nfs4_reset_recoverydir(char *recdir);
> >>  #else
> >>  static inline int nfs4_state_init(void) { return 0; }
> >> +static inline int nfsd4_init_slabs(void) { return 0; }
> >>  static inline void nfsd4_free_slabs(void) { }
> >>  static inline int nfs4_state_start(void) { return 0; }
> >>  static inline void nfs4_state_shutdown(void) { }
> >> -- 
> >> 1.7.7
> >>
> 
> 
