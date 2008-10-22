From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Change error handling in _get_posix_acl and it's
	callers
Date: Wed, 22 Oct 2008 14:17:53 -0400
Message-ID: <20081022181753.GC2495@fieldses.org>
References: <20081022091836.22100.57827.sendpatchset@localhost.localdomain> <20081022091848.22100.80769.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41964 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbYJVSR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 14:17:56 -0400
In-Reply-To: <20081022091848.22100.80769.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2008 at 02:48:48PM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Change _get_posix_acl to return NULL on buflen == 0, and change users of
> 	this function to handle error cases.

OK, the code's certainly simpler.  Makes sense.  Applied to for-2.6.29.

Hm.  Could we replace the last lines of nfsd_get_posix_acl() by a call
to _get_posix_acl() now?  The two functions are under different CONFIG_
ifdef's, so some fussing around would be required.

--b.

> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  fs/nfsd/vfs.c |   12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff -ruNp 2.6.27-org/fs/nfsd/vfs.c 2.6.27-new/fs/nfsd/vfs.c
> --- 2.6.27-org/fs/nfsd/vfs.c	2008-10-22 14:19:15.000000000 +0530
> +++ 2.6.27-new/fs/nfsd/vfs.c	2008-10-22 14:35:16.000000000 +0530
> @@ -503,13 +503,11 @@ static struct posix_acl *
>  _get_posix_acl(struct dentry *dentry, char *key)
>  {
>  	void *buf = NULL;
> -	struct posix_acl *pacl = NULL;
> +	struct posix_acl *pacl;
>  	int buflen;
>  
>  	buflen = nfsd_getxattr(dentry, key, &buf);
> -	if (!buflen)
> -		buflen = -ENODATA;
> -	if (buflen <= 0)
> +	if (buflen < 0)
>  		return ERR_PTR(buflen);
>  
>  	pacl = posix_acl_from_xattr(buf, buflen);
> @@ -526,7 +524,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqst
>  	unsigned int flags = 0;
>  
>  	pacl = _get_posix_acl(dentry, POSIX_ACL_XATTR_ACCESS);
> -	if (IS_ERR(pacl) && PTR_ERR(pacl) == -ENODATA)
> +	if (!pacl)
>  		pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
>  	if (IS_ERR(pacl)) {
>  		error = PTR_ERR(pacl);
> @@ -536,9 +534,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqst
>  
>  	if (S_ISDIR(inode->i_mode)) {
>  		dpacl = _get_posix_acl(dentry, POSIX_ACL_XATTR_DEFAULT);
> -		if (IS_ERR(dpacl) && PTR_ERR(dpacl) == -ENODATA)
> -			dpacl = NULL;
> -		else if (IS_ERR(dpacl)) {
> +		if (IS_ERR(dpacl)) {
>  			error = PTR_ERR(dpacl);
>  			dpacl = NULL;
>  			goto out;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
