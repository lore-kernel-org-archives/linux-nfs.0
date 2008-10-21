From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Fix memory leak in nfsd_getxattr (& usage in
	_get_posix_acl)
Date: Tue, 21 Oct 2008 18:06:50 -0400
Message-ID: <20081021220650.GA18610@fieldses.org>
References: <20081021105139.13512.67162.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbYJUWGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Oct 2008 18:06:53 -0400
In-Reply-To: <20081021105139.13512.67162.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 21, 2008 at 04:21:39PM +0530, Krishna Kumar wrote:
> "J. Bruce Fields" <bfields@fieldses.org> wrote on 10/21/2008 02:32:59 AM:
> 
> > Is the current code really a problem?
> > 
> > Possibly more interesting to look into:
> > 
> >    - Can nfsd_getxattr actually return NULL?
> 
> You are right. I think it can return 0, eg any of the filesystem getxattr's.
> 
> >    - Why do we need to return ENODATA in that case?
> >      (nfsd_get_posix_acl, for example, seems to just end up
> >      returning -EINVAL in that case.)
> 
> Did you mean NULL rather than EINVAL (posix_acl_from_xattr returns NULL before
> EINVAL)?

Whoops, you're right--I missed that.

> 
> Another thing that seems slightly wrong. Both of the following functions:
> nfsd_get_posix_acl()
> {
> 	...
> 	size = nfsd_getxattr(fhp->fh_dentry, name, &value);
> 	if (size < 0)
> 		return ERR_PTR(size);
> 	...
> }
> _get_posix_acl(struct dentry *dentry, char *key)
> {
> 	...
> 	buflen = nfsd_getxattr(dentry, key, &buf);
> 	if (!buflen)
> 		buflen = -ENODATA;
> 	if (buflen <= 0)
> 		return ERR_PTR(buflen);
> 	...
> }
> call nfsd_getxattr which can allocate memory but still return < 0. Function
> allocates buf and calls vfs_getxattr() which fails and leaks memory. The best
> place to fix this is in nfsd_getxattr in case vfs_getxattr() returns < 0
> 
> Does that sound correct? Patch for this follows...

Yes, that sounds correct.  I'll take a look at the patch.

--b.

> 
> thanks,
> 
> - KK
> 
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> 1. Fix a memory leak in nfsd_getxattr. nfsd_getxattr should free up memory
> 	that it allocated if vfs_getxattr fails.
> 
> 2. Change _get_posix_acl to return NULL on buflen == 0.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  fs/nfsd/vfs.c |   12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff -ruNp org/fs/nfsd/vfs.c new/fs/nfsd/vfs.c
> --- org/fs/nfsd/vfs.c	2008-10-21 16:05:41.000000000 +0530
> +++ new/fs/nfsd/vfs.c	2008-10-21 15:57:30.000000000 +0530
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
> @@ -499,13 +503,11 @@ static struct posix_acl *
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
