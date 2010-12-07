Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38756 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685Ab0LGSnY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 13:43:24 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oB7IhAxK028392
	for <linux-nfs@vger.kernel.org>; Tue, 7 Dec 2010 10:43:10 -0800 (PST)
Subject: Re: [PATCH 1/1] NFS fix the setting of exchange id flag
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1291394040-2993-1-git-send-email-andros@netapp.com>
References: <1291394040-2993-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 13:43:08 -0500
Message-ID: <1291747388.3049.11.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-12-03 at 11:34 -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Indicate support for referrals. Do not set any PNFS roles. Check the flags
> returned by the server for validity. Do not use exchange flags from an old
> client ID instance when recovering a client ID.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   23 +++++++++++++++++++----
>  1 files changed, 19 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c244000..e77a2b9 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4494,6 +4494,23 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
>  
>  #ifdef CONFIG_NFS_V4_1
>  /*
> + * Check the exchange flags returned by the server for invalid flags, having
> + * both PNFS and NON_PNFS flags set, and not having one of NON_PNFS, PNFS, or
> + * DS flags set.
> + */
> +static int nfs4_check_cl_exchange_flags(u32 flags)
> +{
> +	if (flags & ~EXCHGID4_FLAG_MASK_R ||
> +	    (flags & EXCHGID4_FLAG_USE_PNFS_MDS &&
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> +	     flags & EXCHGID4_FLAG_USE_NON_PNFS) ||
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
need brackets.
> +	    (!(flags & (EXCHGID4_FLAG_USE_PNFS_MDS |
> +			EXCHGID4_FLAG_USE_NON_PNFS |
> +			EXCHGID4_FLAG_USE_PNFS_DS))))
> +		return NFS4ERR_INVAL;
			^^^^^^^^^^^^^^^ -NFS4ERR_INVAL?
Can we clean this up a little bit:

	if (flags & EXCHGID4_FLAG_MASK_R)
		goto out_inval;
	if ((flags & EXCHGID4_FLAG_USE_PNFS_MDS) &&
	    (flags & EXCHGID4_FLAG_USE_NON_PNFS))
		goto out_inval;
	if (....)
		goto out_inval;
	return NFS_OK;
out_inval:
	return -NFS4ERR_INVAL;


> +	return NFS_OK;
> +}
> +
> +/*
>   * nfs4_proc_exchange_id()
>   *
>   * Since the clientid has expired, all compounds using sessions
> @@ -4506,7 +4523,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  	nfs4_verifier verifier;
>  	struct nfs41_exchange_id_args args = {
>  		.client = clp,
> -		.flags = clp->cl_exchange_flags,
> +		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
>  	};
>  	struct nfs41_exchange_id_res res = {
>  		.client = clp,
> @@ -4523,9 +4540,6 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  	dprintk("--> %s\n", __func__);
>  	BUG_ON(clp == NULL);
>  
> -	/* Remove server-only flags */
> -	args.flags &= ~EXCHGID4_FLAG_CONFIRMED_R;
> -
>  	p = (u32 *)verifier.data;
>  	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
>  	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
> @@ -4551,6 +4565,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  			break;
>  	}
>  
> +	status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
>  	dprintk("<-- %s status= %d\n", __func__, status);
>  	return status;
>  }

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

