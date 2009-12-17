From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: null dereference in nfs4_begin_drain_session
Date: Thu, 17 Dec 2009 17:54:29 -0500
Message-ID: <20091217225429.GK21454@fieldses.org>
References: <20091215222449.GD8686@fieldses.org> <1260917540.3219.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58088 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbZLQWyW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 17:54:22 -0500
In-Reply-To: <1260917540.3219.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 15, 2009 at 05:52:20PM -0500, Trond Myklebust wrote:
> On Tue, 2009-12-15 at 17:24 -0500, J. Bruce Fields wrote: 
> The following patch should suffice to fix this...

Yup, not seeing this any more, thanks!

(Sorry for the slow confirmation--my test hosts stopped booting.  Argh!
Looks like it was something temporarily broken upstream...).

--b.

> 
> Cheers
>   Trond
> ----------------------------------------------------------------------------------------------------- 
> commit 380454126f1357db9270f9d1ca05dfe1a6e4ad47
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Dec 15 17:36:57 2009 -0500
> 
>     NFSv4: Fix a regression in the NFSv4 state manager
>     
>     Commit 5601a00d671fe89f9b087513244abcd08ad67e7d (nfs: run state manager
>     in privileged mode) introduces a regression in the NFSv4 code when
>     compiled with CONFIG_NFS_V4_1. The calls to nfs4_end_drain_session()
>     from the main loop in nfs4_state_manager() Oops due to the lack of an
>     NFSv4.1 session when running NFSv4.0.
>     
>     The fix is to move those two calls back into nfs41_init_clientid() and
>     nfs4_reset_session().
>     
>     The calls to nfs4_end_drain_session() that remain inside
>     nfs4_state_manager() are safe, since the NFSv4.0 code will never set the
>     NFS4CLNT_SESSION_DRAINING bit.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 18e8b26..6d263ed 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -176,6 +176,7 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  {
>  	int status;
>  
> +	nfs4_begin_drain_session(clp);
>  	status = nfs4_proc_exchange_id(clp, cred);
>  	if (status != 0)
>  		goto out;
> @@ -1274,6 +1275,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
>  {
>  	int status;
>  
> +	nfs4_begin_drain_session(clp);
>  	status = nfs4_proc_destroy_session(clp->cl_session);
>  	if (status && status != -NFS4ERR_BADSESSION &&
>  	    status != -NFS4ERR_DEADSESSION) {
> @@ -1299,7 +1301,6 @@ out:
>  
>  #else /* CONFIG_NFS_V4_1 */
>  static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
> -static int nfs4_begin_drain_session(struct nfs_client *clp) { return 0; }
>  static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
>  #endif /* CONFIG_NFS_V4_1 */
>  
> @@ -1332,7 +1333,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  	for(;;) {
>  		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
>  			/* We're going to have to re-establish a clientid */
> -			nfs4_begin_drain_session(clp);
>  			status = nfs4_reclaim_lease(clp);
>  			if (status) {
>  				nfs4_set_lease_expired(clp, status);
> @@ -1359,7 +1359,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  		/* Initialize or reset the session */
>  		if (test_and_clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)
>  		   && nfs4_has_session(clp)) {
> -			nfs4_begin_drain_session(clp);
>  			status = nfs4_reset_session(clp);
>  			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
>  				continue;
> 
