From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Fix memory leak in nfsd_getxattr
Date: Wed, 22 Oct 2008 14:11:57 -0400
Message-ID: <20081022181157.GB2495@fieldses.org>
References: <20081022091836.22100.57827.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbYJVSMB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 14:12:01 -0400
In-Reply-To: <20081022091836.22100.57827.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2008 at 02:48:36PM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Fix a memory leak in nfsd_getxattr. nfsd_getxattr should free up memory
> 	that it allocated if vfs_getxattr fails.

Thanks!  Applied to for-2.6.28.

--b.

> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  fs/nfsd/vfs.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff -ruNp 2.6.27-org/fs/nfsd/vfs.c 2.6.27-new/fs/nfsd/vfs.c
> --- 2.6.27-org/fs/nfsd/vfs.c	2008-10-22 14:17:23.000000000 +0530
> +++ 2.6.27-new/fs/nfsd/vfs.c	2008-10-22 14:19:15.000000000 +0530
> @@ -411,6 +411,7 @@ out_nfserr:
>  static ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
>  {
>  	ssize_t buflen;
> +	ssize_t ret;
>  
>  	buflen = vfs_getxattr(dentry, key, NULL, 0);
>  	if (buflen <= 0)
> @@ -420,7 +421,10 @@ static ssize_t nfsd_getxattr(struct dent
>  	if (!*buf)
>  		return -ENOMEM;
>  
> -	return vfs_getxattr(dentry, key, *buf, buflen);
> +	ret = vfs_getxattr(dentry, key, *buf, buflen);
> +	if (ret < 0)
> +		kfree(*buf);
> +	return ret;
>  }
>  #endif
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
