Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbbG3PQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 11:16:42 -0400
Date: Thu, 30 Jul 2015 11:16:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do nfs4_check_fh in nfs4_check_file instead of
 nfs4_check_olstateid
Message-ID: <20150730151641.GE9349@fieldses.org>
References: <1438253866-7393-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438253866-7393-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 06:57:46AM -0400, Jeff Layton wrote:
> Currently, preprocess_stateid_op calls nfs4_check_olstateid which
> verifies that the open stateid corresponds to the current_fh in the
> call by calling nfs4_check_fh.
> 
> If the stateid is a NFS4_DELEG_STID however, then no such check is
> done. Move the call to nfs4_check_fh into nfs4_check_file instead
> so that it can be done for all stateid types.

Thanks, applying for 4.2 and -stable with a note that this can screw up
permissions checking later in nfs4_check_file.

--b.

> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index cd8c33186e26..75f617a052cf 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4406,9 +4406,9 @@ laundromat_main(struct work_struct *laundry)
>  	queue_delayed_work(laundry_wq, &nn->laundromat_work, t*HZ);
>  }
>  
> -static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
> +static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stid *stp)
>  {
> -	if (!fh_match(&fhp->fh_handle, &stp->st_stid.sc_file->fi_fhandle))
> +	if (!fh_match(&fhp->fh_handle, &stp->sc_file->fi_fhandle))
>  		return nfserr_bad_stateid;
>  	return nfs_ok;
>  }
> @@ -4611,9 +4611,6 @@ nfs4_check_olstateid(struct svc_fh *fhp, struct nfs4_ol_stateid *ols, int flags)
>  {
>  	__be32 status;
>  
> -	status = nfs4_check_fh(fhp, ols);
> -	if (status)
> -		return status;
>  	status = nfsd4_check_openowner_confirmed(ols);
>  	if (status)
>  		return status;
> @@ -4628,6 +4625,10 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
>  	struct file *file;
>  	__be32 status;
>  
> +	status = nfs4_check_fh(fhp, s);
> +	if (status)
> +		return status;
> +
>  	file = nfs4_find_file(s, flags);
>  	if (file) {
>  		status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> @@ -4808,7 +4809,7 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
>  	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
>  	if (status)
>  		return status;
> -	return nfs4_check_fh(current_fh, stp);
> +	return nfs4_check_fh(current_fh, &stp->st_stid);
>  }
>  
>  /* 
> -- 
> 2.4.3
