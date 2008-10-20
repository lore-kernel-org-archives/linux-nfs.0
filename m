From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/4] nfsd: Minor cleanup of _get_posix_acl
Date: Mon, 20 Oct 2008 17:02:59 -0400
Message-ID: <20081020210259.GD27702@fieldses.org>
References: <20081020061709.18370.85373.sendpatchset@localhost.localdomain> <20081020061721.18370.93671.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555AbYJTVDB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 17:03:01 -0400
In-Reply-To: <20081020061721.18370.93671.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2008 at 11:47:21AM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Rewrite error case to not check twice for !buflen. Compile tested.

Is the current code really a problem?

Possibly more interesting to look into:

	- Can nfsd_getxattr actually return NULL?
	- Why do we need to return ENODATA in that case?
	  (nfsd_get_posix_acl, for example, seems to just end up
	  returning -EINVAL in that case.)

--b.

> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  fs/nfsd/vfs.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff -ruNp linux-2.6.27.org/fs/nfsd/vfs.c linux-2.6.27.new/fs/nfsd/vfs.c
> --- linux-2.6.27.org/fs/nfsd/vfs.c	2008-10-20 10:47:19.000000000 +0530
> +++ linux-2.6.27.new/fs/nfsd/vfs.c	2008-10-20 10:48:32.000000000 +0530
> @@ -503,10 +503,11 @@ _get_posix_acl(struct dentry *dentry, ch
>  	int buflen;
>  
>  	buflen = nfsd_getxattr(dentry, key, &buf);
> -	if (!buflen)
> -		buflen = -ENODATA;
> -	if (buflen <= 0)
> +	if (buflen <= 0) {
> +		if (!buflen)
> +			buflen = -ENODATA;
>  		return ERR_PTR(buflen);
> +	}
>  
>  	pacl = posix_acl_from_xattr(buf, buflen);
>  	kfree(buf);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
