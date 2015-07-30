Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33326 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbG3Nxz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:53:55 -0400
Received: by ykba194 with SMTP id a194so34455152ykb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:53:55 -0700 (PDT)
Date: Thu, 30 Jul 2015 09:53:50 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do nfs4_check_fh in nfs4_check_file instead of
 nfs4_check_olstateid
Message-ID: <20150730095350.6e41f731@tlielax.poochiereds.net>
In-Reply-To: <1438264341-18048-2-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438264341-18048-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 30 Jul 2015 09:52:12 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

> Currently, preprocess_stateid_op calls nfs4_check_olstateid which
> verifies that the open stateid corresponds to the current_fh in the
> call by calling nfs4_check_fh.
> 
> If the stateid is a NFS4_DELEG_STID however, then no such check is
> done. Move the call to nfs4_check_fh into nfs4_check_file instead
> so that it can be done for all stateid types.
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

Doh! Sorry -- I had already sent this separately but forgot to clean
out the directory before running git-send-email. It's identical though
to the one that I sent earlier today.

-- 
Jeff Layton <jlayton@poochiereds.net>
