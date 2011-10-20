Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50286 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab1JTMXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 08:23:35 -0400
Date: Thu, 20 Oct 2011 08:23:34 -0400
To: Benny Halevy <benny@tonian.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH 1/7] nfsd4: implement new 4.1 open reclaim types
Message-ID: <20111020122334.GM5444@fieldses.org>
References: <4E9F82FC.2000904@tonian.com>
 <1319076768-13311-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319076768-13311-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 07:12:48PM -0700, Benny Halevy wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4proc.c   |   15 +++------------
>  fs/nfsd/nfs4state.c  |   10 ++++++++--
>  fs/nfsd/nfs4xdr.c    |   13 +++++++++++++
>  include/linux/nfs4.h |    5 ++++-
>  4 files changed, 28 insertions(+), 15 deletions(-)

Adding Mi Jinlong--is there a chance you might be able to write pynfs
tests for these?  I don't know if clients are using them yet so it would
be nice to know if they work before committing this.

--b.

> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 5b192a2..e3fffab 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -366,12 +366,6 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
>  	switch (open->op_claim_type) {
>  		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
>  		case NFS4_OPEN_CLAIM_NULL:
> -			/*
> -			 * (1) set CURRENT_FH to the file being opened,
> -			 * creating it if necessary, (2) set open->op_cinfo,
> -			 * (3) set open->op_truncate if the file is to be
> -			 * truncated after opening, (4) do permission checking.
> -			 */
>  			status = do_open_lookup(rqstp, &cstate->current_fh,
>  						open);
>  			if (status)
> @@ -379,17 +373,14 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
>  			break;
>  		case NFS4_OPEN_CLAIM_PREVIOUS:
>  			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
> -			/*
> -			 * The CURRENT_FH is already set to the file being
> -			 * opened.  (1) set open->op_cinfo, (2) set
> -			 * open->op_truncate if the file is to be truncated
> -			 * after opening, (3) do permission checking.
> -			*/
> +		case NFS4_OPEN_CLAIM_FH:
> +		case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
>  			status = do_open_fhandle(rqstp, &cstate->current_fh,
>  						 open);
>  			if (status)
>  				goto out;
>  			break;
> +		case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
>               	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
>  			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
>  			dprintk("NFSD: unsupported OPEN claim type %d\n",
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 62aa91a..7da0748 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2562,6 +2562,12 @@ static int share_access_to_flags(u32 share_access)
>  	return delegstateid(ret);
>  }
>  
> +static bool nfsd4_is_deleg_cur(struct nfsd4_open *open)
> +{
> +	return open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR ||
> +	       open->op_claim_type == NFS4_OPEN_CLAIM_DELEG_CUR_FH;
> +}
> +
>  static __be32
>  nfs4_check_deleg(struct nfs4_client *cl, struct nfs4_file *fp, struct nfsd4_open *open,
>  		struct nfs4_delegation **dp)
> @@ -2577,7 +2583,7 @@ static int share_access_to_flags(u32 share_access)
>  	if (status)
>  		*dp = NULL;
>  out:
> -	if (open->op_claim_type != NFS4_OPEN_CLAIM_DELEGATE_CUR)
> +	if (!nfsd4_is_deleg_cur(open))
>  		return nfs_ok;
>  	if (status)
>  		return status;
> @@ -2882,7 +2888,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
>  			goto out;
>  	} else {
>  		status = nfserr_bad_stateid;
> -		if (open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
> +		if (nfsd4_is_deleg_cur(open))
>  			goto out;
>  		status = nfserr_jukebox;
>  		fp = alloc_init_file(ino);
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 645a0a9..fdc09a5 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -803,6 +803,19 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  		if ((status = check_filename(open->op_fname.data, open->op_fname.len, nfserr_inval)))
>  			return status;
>  		break;
> +	case NFS4_OPEN_CLAIM_FH:
> +	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
> +		if (argp->minorversion < 1)
> +			goto xdr_error;
> +		/* void */
> +		break;
> +	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
> +		if (argp->minorversion < 1)
> +			goto xdr_error;
> +		status = nfsd4_decode_stateid(argp, &open->op_delegate_stateid);
> +		if (status)
> +			return status;
> +		break;
>  	default:
>  		goto xdr_error;
>  	}
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index b875b03..32345c2 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -410,7 +410,10 @@ enum open_claim_type4 {
>  	NFS4_OPEN_CLAIM_NULL = 0,
>  	NFS4_OPEN_CLAIM_PREVIOUS = 1,
>  	NFS4_OPEN_CLAIM_DELEGATE_CUR = 2,
> -	NFS4_OPEN_CLAIM_DELEGATE_PREV = 3
> +	NFS4_OPEN_CLAIM_DELEGATE_PREV = 3,
> +	NFS4_OPEN_CLAIM_FH = 4, /* 4.1 */
> +	NFS4_OPEN_CLAIM_DELEG_CUR_FH = 5, /* 4.1 */
> +	NFS4_OPEN_CLAIM_DELEG_PREV_FH = 6, /* 4.1 */
>  };
>  
>  enum opentype4 {
> -- 
> 1.7.6
> 
