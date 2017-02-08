Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44918 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751916AbdBHVzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Feb 2017 16:55:25 -0500
Date: Wed, 8 Feb 2017 16:45:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't get =?utf-8?Q?writ?=
 =?utf-8?Q?e_access_tw=D1=96ce?= in nfsd_setattr
Message-ID: <20170208214538.GB17622@fieldses.org>
References: <20170207091244.GA14911@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170207091244.GA14911@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 07, 2017 at 10:12:44AM +0100, Christoph Hellwig wrote:
> Turns out doing mnt_want_write twice for the same process makes
> lockdep unhappy, so move the fh_want_write down to after calling
> vfs_truncate in nfsd_setattr.  No changes to error handling required
> as the want write state is automatically cleaned up by the caller
> based on a flag in the svc_fh.
> 
> Fixes: 41f53350 ("nfsd: special case truncates some more")
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Dave Jones <davej@codemonkey.org.uk>

Thanks, I'll see if I can squeeze this into 4.10.--b.

> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index ca13236dbb1f..a974368026a1 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -359,11 +359,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	err = fh_verify(rqstp, fhp, ftype, accmode);
>  	if (err)
>  		return err;
> -	if (get_write_count) {
> -		host_err = fh_want_write(fhp);
> -		if (host_err)
> -			goto out_host_err;
> -	}
>  
>  	dentry = fhp->fh_dentry;
>  	inode = d_inode(dentry);
> @@ -416,6 +411,12 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  
>  	iap->ia_valid |= ATTR_CTIME;
>  
> +	if (get_write_count) {
> +		host_err = fh_want_write(fhp);
> +		if (host_err)
> +			goto out_host_err;
> +	}
> +
>  	fh_lock(fhp);
>  	host_err = notify_change(dentry, iap, NULL);
>  	fh_unlock(fhp);
