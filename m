Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61135 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab0HBDgN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 23:36:13 -0400
Message-ID: <4C563CE5.1010101@cn.fujitsu.com>
Date: Mon, 02 Aug 2010 11:35:01 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "nfsd4: distinguish expired from stale stateids"
References: <20100518233746.GC26911@fieldses.org>
In-Reply-To: <20100518233746.GC26911@fieldses.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> This reverts commit 78155ed75f470710f2aecb3e75e3d97107ba8374.
> 
> We're depending here on the boot time that we use to generate the
> stateid being monotonic, but get_seconds() is not necessarily.
> 
> We still depend at least on boot_time being different every time, but
> that is a safer bet.
> 
> We have a few reports of errors that might be explained by this problem,
> though we haven't been able to confirm any of them.
> 
> But the minor gain of distinguishing expired from stale errors seems not
> worth the risk.
> 

  Hi bruce, if remove this patch, some my test will fail. So what's your opinion
  for those test case.

    STEP1: open the file, and get a open stateid (STATEID).
    STEP2: shutdown the network between client and server
    STEP3: keep the network partition lease_time(90s by default) seconds
    STEP4: recovery network
    STEP5: do some IO operation, such as LOCK.

  If i use the patch 78155ed75f470710f2aecb3e75e3d97107ba8374, this case will OK
  at STEP5,  however, it's will fail when remove this patch.

  So i think it's no good for the network recovery, what do you think about it, 
  or give me some suggestions, thanks very much.


> Conflicts:
> 
> 	fs/nfsd/nfs4state.c
> 
> Cc: Bian Naimeng <biannm@cn.fujitsu.com>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4state.c |   56 ++++++++++-----------------------------------------
>  1 files changed, 11 insertions(+), 45 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 296eded..12f7109 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -190,7 +190,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
>  	dp->dl_vfs_file = stp->st_vfs_file;
>  	dp->dl_type = type;
>  	dp->dl_ident = cb->cb_ident;
> -	dp->dl_stateid.si_boot = get_seconds();
> +	dp->dl_stateid.si_boot = boot_time;
>  	dp->dl_stateid.si_stateownerid = current_delegid++;
>  	dp->dl_stateid.si_fileid = 0;
>  	dp->dl_stateid.si_generation = 0;
> @@ -1884,7 +1884,7 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
>  	stp->st_stateowner = sop;
>  	get_nfs4_file(fp);
>  	stp->st_file = fp;
> -	stp->st_stateid.si_boot = get_seconds();
> +	stp->st_stateid.si_boot = boot_time;
>  	stp->st_stateid.si_stateownerid = sop->so_id;
>  	stp->st_stateid.si_fileid = fp->fi_id;
>  	stp->st_stateid.si_generation = 0;
> @@ -2733,39 +2733,11 @@ nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
>  static int
>  STALE_STATEID(stateid_t *stateid)
>  {
> -	if (time_after((unsigned long)boot_time,
> -			(unsigned long)stateid->si_boot)) {
> -		dprintk("NFSD: stale stateid " STATEID_FMT "!\n",
> -			STATEID_VAL(stateid));
> -		return 1;
> -	}
> -	return 0;
> -}
> -
> -static int
> -EXPIRED_STATEID(stateid_t *stateid)
> -{
> -	if (time_before((unsigned long)boot_time,
> -			((unsigned long)stateid->si_boot)) &&
> -	    time_before((unsigned long)(stateid->si_boot + nfsd4_lease), get_seconds())) {
> -		dprintk("NFSD: expired stateid " STATEID_FMT "!\n",
> -			STATEID_VAL(stateid));
> -		return 1;
> -	}
> -	return 0;
> -}
> -
> -static __be32
> -stateid_error_map(stateid_t *stateid)
> -{
> -	if (STALE_STATEID(stateid))
> -		return nfserr_stale_stateid;
> -	if (EXPIRED_STATEID(stateid))
> -		return nfserr_expired;
> -
> -	dprintk("NFSD: bad stateid " STATEID_FMT "!\n",
> +	if (stateid->si_boot == boot_time)
> +		return 0;
> +	dprintk("NFSD: stale stateid " STATEID_FMT "!\n",
>  		STATEID_VAL(stateid));
> -	return nfserr_bad_stateid;
> +	return 1;
>  }
>  
>  static inline int
> @@ -2889,10 +2861,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
>  	status = nfserr_bad_stateid;
>  	if (is_delegation_stateid(stateid)) {
>  		dp = find_delegation_stateid(ino, stateid);
> -		if (!dp) {
> -			status = stateid_error_map(stateid);
> +		if (!dp)
>  			goto out;
> -		}
>  		status = check_stateid_generation(stateid, &dp->dl_stateid,
>  						  flags);
>  		if (status)
> @@ -2905,10 +2875,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
>  			*filpp = dp->dl_vfs_file;
>  	} else { /* open or lock stateid */
>  		stp = find_stateid(stateid, flags);
> -		if (!stp) {
> -			status = stateid_error_map(stateid);
> +		if (!stp)
>  			goto out;
> -		}
>  		if (nfs4_check_fh(current_fh, stp))
>  			goto out;
>  		if (!stp->st_stateowner->so_confirmed)
> @@ -2980,7 +2948,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>  		 */
>  		sop = search_close_lru(stateid->si_stateownerid, flags);
>  		if (sop == NULL)
> -			return stateid_error_map(stateid);
> +			return nfserr_bad_stateid;
>  		*sopp = sop;
>  		goto check_replay;
>  	}
> @@ -3247,10 +3215,8 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (!is_delegation_stateid(stateid))
>  		goto out;
>  	dp = find_delegation_stateid(inode, stateid);
> -	if (!dp) {
> -		status = stateid_error_map(stateid);
> +	if (!dp)
>  		goto out;
> -	}
>  	status = check_stateid_generation(stateid, &dp->dl_stateid, flags);
>  	if (status)
>  		goto out;
> @@ -3476,7 +3442,7 @@ alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struc
>  	stp->st_stateowner = sop;
>  	get_nfs4_file(fp);
>  	stp->st_file = fp;
> -	stp->st_stateid.si_boot = get_seconds();
> +	stp->st_stateid.si_boot = boot_time;
>  	stp->st_stateid.si_stateownerid = sop->so_id;
>  	stp->st_stateid.si_fileid = fp->fi_id;
>  	stp->st_stateid.si_generation = 0;

-- 
Regards
Bian Naimeng

