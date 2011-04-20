From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd41: make sure nfs server process OPEN with
 EXCLUSIVE4_1 correcttly
Date: Wed, 20 Apr 2011 17:00:20 -0400
Message-ID: <20110420210020.GG15919@fieldses.org>
References: <4D9C2CB2.7000101@cn.fujitsu.com>
 <20110407195005.GC11806@fieldses.org>
 <4D9EDC05.2080809@cn.fujitsu.com>
 <20110418200745.GA1162@fieldses.org>
 <4DAEA562.1040605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59810 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984Ab1DTVAV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 17:00:21 -0400
In-Reply-To: <4DAEA562.1040605@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 20, 2011 at 05:20:34PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > And I'd rather avoid these ifdef's in the main part of the code.  Could
> > we move the definition of NFS4_CREATE_EXCLUSIVE4_1 someplace common
> > instead?
> 
>   Maybe we don't need the ifdef here.

OK, thanks--applying this version for 2.6.40.

--b.

> 
> -- 
> ----
> thanks
> Mi Jinlong
> ============================================================
> >From 7363f39c0159e78bafcab3a002a6808d375f49f3 Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Thu, 20 Apr 2011 17:06:25 +0800
> Subject: [PATCH] nfsd41: make sure nfs server process OPEN with EXCLUSIVE4_1 correcttly
> 
> NFS server can't process OPEN with EXCLUSIVE4_1, because NFS server call 
> nfsd_create_v3 to create file instead implement a separate one. 
> But nfsd_create_v3 can't process createmode is EXCLUSIVE4_1.
> 
> This patch rename nfsd_create_v3() to do_nfsd_create(), and add some codes
> about process EXCLUSIVE4_1.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs3proc.c |    2 +-
>  fs/nfsd/nfs4proc.c |    4 ++--
>  fs/nfsd/vfs.c      |   20 ++++++++++++++++----
>  fs/nfsd/vfs.h      |    2 +-
>  4 files changed, 20 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 2247fc9..9095f3c 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -245,7 +245,7 @@ nfsd3_proc_create(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
>  	}
>  
>  	/* Now create the file and set attributes */
> -	nfserr = nfsd_create_v3(rqstp, dirfhp, argp->name, argp->len,
> +	nfserr = do_nfsd_create(rqstp, dirfhp, argp->name, argp->len,
>  				attr, newfhp,
>  				argp->createmode, argp->verf, NULL, NULL);
>  
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 5fcb139..e1d100f 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -196,9 +196,9 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
>  
>  		/*
>  		 * Note: create modes (UNCHECKED,GUARDED...) are the same
> -		 * in NFSv4 as in v3.
> +		 * in NFSv4 as in v3 except EXCLUSIVE4_1.
>  		 */
> -		status = nfsd_create_v3(rqstp, current_fh, open->op_fname.data,
> +		status = do_nfsd_create(rqstp, current_fh, open->op_fname.data,
>  					open->op_fname.len, &open->op_iattr,
>  					&resfh, open->op_createmode,
>  					(u32 *)open->op_verf.data,
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 2e1cebd..fee2530 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1340,11 +1340,18 @@ out_nfserr:
>  }
>  
>  #ifdef CONFIG_NFSD_V3
> +
> +static inline int nfsd_create_is_exclusive(int createmode)
> +{
> +	return createmode == NFS3_CREATE_EXCLUSIVE
> +	       || createmode == NFS4_CREATE_EXCLUSIVE4_1;
> +}
> +
>  /*
> - * NFSv3 version of nfsd_create
> + * NFSv3 and NFSv4 version of nfsd_create
>   */
>  __be32
> -nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		char *fname, int flen, struct iattr *iap,
>  		struct svc_fh *resfhp, int createmode, u32 *verifier,
>  	        int *truncp, int *created)
> @@ -1389,7 +1396,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (err)
>  		goto out;
>  
> -	if (createmode == NFS3_CREATE_EXCLUSIVE) {
> +	if (nfsd_create_is_exclusive(createmode)) {
>  		/* solaris7 gets confused (bugid 4218508) if these have
>  		 * the high bit set, so just clear the high bits. If this is
>  		 * ever changed to use different attrs for storing the
> @@ -1430,6 +1437,11 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  			    && dchild->d_inode->i_atime.tv_sec == v_atime
>  			    && dchild->d_inode->i_size  == 0 )
>  				break;
> +		case NFS4_CREATE_EXCLUSIVE4_1:
> +			if (   dchild->d_inode->i_mtime.tv_sec == v_mtime
> +			    && dchild->d_inode->i_atime.tv_sec == v_atime
> +			    && dchild->d_inode->i_size  == 0 )
> +				goto set_attr;
>  			 /* fallthru */
>  		case NFS3_CREATE_GUARDED:
>  			err = nfserr_exist;
> @@ -1448,7 +1460,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  
>  	nfsd_check_ignore_resizing(iap);
>  
> -	if (createmode == NFS3_CREATE_EXCLUSIVE) {
> +	if (nfsd_create_is_exclusive(createmode)) {
>  		/* Cram the verifier into atime/mtime */
>  		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
>  			| ATTR_MTIME_SET|ATTR_ATIME_SET;
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 9a370a5..10dbe9f 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -54,7 +54,7 @@ __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
>  				int type, dev_t rdev, struct svc_fh *res);
>  #ifdef CONFIG_NFSD_V3
>  __be32		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
> -__be32		nfsd_create_v3(struct svc_rqst *, struct svc_fh *,
> +__be32		do_nfsd_create(struct svc_rqst *, struct svc_fh *,
>  				char *name, int len, struct iattr *attrs,
>  				struct svc_fh *res, int createmode,
>  				u32 *verifier, int *truncp, int *created);
> -- 
> 1.7.4.4
> 
> 
