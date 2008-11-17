From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 18/51] nfsd41: access_valid
Date: Mon, 17 Nov 2008 16:04:33 +0200
Message-ID: <492179F1.4030803@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350008-10772-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:11099 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752169AbYKQOEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:04:37 -0500
In-Reply-To: <1226350008-10772-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:46 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> For nfs41, the open share flags are used also for
> delegation "wants" and "signals".  Check that they are valid.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   27 ++++++++++++++++++++++-----
>  1 files changed, 22 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 14c1a0e..b772469 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1255,11 +1255,23 @@ find_file(struct inode *ino)
>  	return NULL;
>  }
>  
> -static inline int access_valid(u32 x)
> +static inline int access_valid(u32 x, u32 minorversion)
>  {
> -	if (x < NFS4_SHARE_ACCESS_READ)
> +	if ((x & NFS4_SHARE_DENY_MASK) < NFS4_SHARE_ACCESS_READ)
>  		return 0;
> -	if (x > NFS4_SHARE_ACCESS_BOTH)
> +	if ((x & NFS4_SHARE_DENY_MASK) > NFS4_SHARE_ACCESS_BOTH)
> +		return 0;
> +	x &= ~NFS4_SHARE_DENY_MASK;
> +#if defined(CONFIG_NFSD_V4_1)
> +	if (minorversion && x) {
> +		if ((x & NFS4_SHARE_WANT_MASK) > NFS4_SHARE_WANT_CANCEL)
> +			return 0;
> +		if ((x & NFS4_SHARE_WHEN_MASK) > NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED)
> +			return 0;
> +		x &= ~(NFS4_SHARE_WANT_MASK | NFS4_SHARE_WHEN_MASK);
> +	}
> +#endif /* CONFIG_NFSD_V4_1 */
> +	if (x)
>  		return 0;
>  	return 1;
>  }
> @@ -1805,7 +1817,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	__be32 status;
>  
>  	status = nfserr_inval;
> -	if (!access_valid(open->op_share_access)
> +	if (!access_valid(open->op_share_access, open->op_minorversion)

review 11-13: use minorversion via struct svc_rqst.rq_resp

>  			|| !deny_valid(open->op_share_deny))
>  		goto out;
>  	/*
> @@ -2405,12 +2417,17 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
>  	__be32 status;
>  	struct nfs4_stateid *stp;
>  	unsigned int share_access;
> +	u32 minorversion = 0;

review 11-13: no need for this hack

>  
>  	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
>  			(int)cstate->current_fh.fh_dentry->d_name.len,
>  			cstate->current_fh.fh_dentry->d_name.name);
>  
> -	if (!access_valid(od->od_share_access)
> +#if defined(CONFIG_NFSD_V4_1)
> +	if (cstate->current_ses)
> +		minorversion = 1;
> +#endif /* CONFIG_NFSD_V4_1 */
> +	if (!access_valid(od->od_share_access, minorversion)
>  			|| !deny_valid(od->od_share_deny))
>  		return nfserr_inval;
>  
