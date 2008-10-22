From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Change error handling in _get_posix_acl and it's
	callers
Date: Wed, 22 Oct 2008 16:12:45 -0400
Message-ID: <20081022201245.GA5572@fieldses.org>
References: <20081022091836.22100.57827.sendpatchset@localhost.localdomain> <20081022091848.22100.80769.sendpatchset@localhost.localdomain> <20081022181753.GC2495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50032 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759295AbYJVUMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 16:12:50 -0400
In-Reply-To: <20081022181753.GC2495@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2008 at 02:17:53PM -0400, bfields wrote:
> On Wed, Oct 22, 2008 at 02:48:48PM +0530, Krishna Kumar wrote:
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> > 
> > Change _get_posix_acl to return NULL on buflen == 0, and change users of
> > 	this function to handle error cases.
> 
> OK, the code's certainly simpler.  Makes sense.  Applied to for-2.6.29.

Whoops!  Sorry, spoke to soon--dropped.  This breaks some ACL-related
newpynfs tests:

	http://www.citi.umich.edu/projects/nfsv4/pynfs/

The assumption that nfsd_getxattr leaves *buf untouched is probably
wrong.  At the least, there's a race here--something could change
between the two calls to vfs_getxattr(), though that's not the case I'm
seeing.  The filesystem may just be giving a high estimate for the
buflen in the first call.

--b.

> >  {
> >  	void *buf = NULL;
> > -	struct posix_acl *pacl = NULL;
> > +	struct posix_acl *pacl;
> >  	int buflen;
> >  
> >  	buflen = nfsd_getxattr(dentry, key, &buf);
> > -	if (!buflen)
> > -		buflen = -ENODATA;
> > -	if (buflen <= 0)
> > +	if (buflen < 0)
> >  		return ERR_PTR(buflen);
> >  
> >  	pacl = posix_acl_from_xattr(buf, buflen);
> > @@ -526,7 +524,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqst
> >  	unsigned int flags = 0;
> >  
> >  	pacl = _get_posix_acl(dentry, POSIX_ACL_XATTR_ACCESS);
> > -	if (IS_ERR(pacl) && PTR_ERR(pacl) == -ENODATA)
> > +	if (!pacl)
> >  		pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
> >  	if (IS_ERR(pacl)) {
> >  		error = PTR_ERR(pacl);
> > @@ -536,9 +534,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqst
> >  
> >  	if (S_ISDIR(inode->i_mode)) {
> >  		dpacl = _get_posix_acl(dentry, POSIX_ACL_XATTR_DEFAULT);
> > -		if (IS_ERR(dpacl) && PTR_ERR(dpacl) == -ENODATA)
> > -			dpacl = NULL;
> > -		else if (IS_ERR(dpacl)) {
> > +		if (IS_ERR(dpacl)) {
> >  			error = PTR_ERR(dpacl);
> >  			dpacl = NULL;
> >  			goto out;
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
