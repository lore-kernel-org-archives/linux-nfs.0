Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53124 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146AbbE0SgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 14:36:04 -0400
Date: Wed, 27 May 2015 14:36:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Process time setting separately only for nfsv2
Message-ID: <20150527183601.GB23302@fieldses.org>
References: <55657AB6.6060105@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55657AB6.6060105@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 27, 2015 at 04:05:10PM +0800, Kinglong Mee wrote:
> NFSv2 does not different between "set-[ac]time-to-now" which only
> requires access, and "set-[ac]time-to-X" which requires ownership.
> 
> But, NFSv3/v4 are support the difference.
> Just let those codes valid for NFSv2.

Looks like this is already done by Andreas Gruenbacher's "nfsd: Disable
NFSv2 timestamp workaround for NFSv3+" in my for-4.2-incoming branch.
Do you see any problem with that patch?

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/vfs.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 84d770b..bf4a15b 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -300,7 +300,7 @@ commit_metadata(struct svc_fh *fhp)
>   * NFS semantics and what Linux expects.
>   */
>  static void
> -nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
> +nfsd_sanitize_attrs(struct svc_rqst *rqstp, struct inode *inode, struct iattr *iap)
>  {
>  	/*
>  	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
> @@ -315,7 +315,8 @@ nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
>  	 */
>  #define BOTH_TIME_SET (ATTR_ATIME_SET | ATTR_MTIME_SET)
>  #define	MAX_TOUCH_TIME_ERROR (30*60)
> -	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
> +	if (rqstp->rq_vers == 2 &&
> +	    (iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
>  	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec) {
>  		/*
>  		 * Looks probable.
> @@ -435,7 +436,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	if (!iap->ia_valid)
>  		goto out;
>  
> -	nfsd_sanitize_attrs(inode, iap);
> +	nfsd_sanitize_attrs(rqstp, inode, iap);
>  
>  	/*
>  	 * The size case is special, it changes the file in addition to the
> -- 
> 2.4.1
