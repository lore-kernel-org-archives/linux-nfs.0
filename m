Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755287Ab3LDMOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 07:14:08 -0500
Subject: Re: [Cluster-devel] [PATCH 16/18] gfs2: use generic posix ACL
 infrastructure
From: Steven Whitehouse <swhiteho@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, xfs@oss.sgi.com, reiserfs-devel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
In-Reply-To: <20131201120656.539995924@bombadil.infradead.org>
References: <20131201115903.910559036@bombadil.infradead.org>
	 <20131201120656.539995924@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 Dec 2013 12:12:37 +0000
Message-ID: <1386159157.2711.11.camel@menhir>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Sun, 2013-12-01 at 03:59 -0800, Christoph Hellwig wrote:
> plain text document attachment
> (0016-gfs2-use-generic-posix-ACL-infrastructure.patch)
> This contains some major refactoring for the create path so that
> inodes are created with the right mode to start with instead of
> fixing it up later.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/gfs2/acl.c   |  229 +++++++------------------------------------------------
>  fs/gfs2/acl.h   |    4 +-
>  fs/gfs2/inode.c |   33 ++++++--
>  fs/gfs2/xattr.c |    4 +-
>  4 files changed, 61 insertions(+), 209 deletions(-)
> 
Looks very good. I'd really like to be able to do something similar with
the security xattrs, in terms of the refactoring that at inode creation
to give the xattrs ahead of the inode allocation itself. That way it
should be possible to allocate the xattr blocks at the same time as the
inode, rather than as an after thought.

Some more comments below....

> diff --git a/fs/gfs2/acl.c b/fs/gfs2/acl.c
> index e82e4ac..e6c7a2c 100644
> --- a/fs/gfs2/acl.c
> +++ b/fs/gfs2/acl.c
[snip]
> -
> -static int gfs2_xattr_system_set(struct dentry *dentry, const char *name,
> -				 const void *value, size_t size, int flags,
> -				 int xtype)
> -{
> -	struct inode *inode = dentry->d_inode;
> -	struct gfs2_sbd *sdp = GFS2_SB(inode);
> -	struct posix_acl *acl = NULL;
> -	int error = 0, type;
> -
> -	if (!sdp->sd_args.ar_posix_acl)
> -		return -EOPNOTSUPP;
> -
> -	type = gfs2_acl_type(name);
> -	if (type < 0)
> -		return type;
> -	if (flags & XATTR_CREATE)
> -		return -EINVAL;
> -	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
> -		return value ? -EACCES : 0;
> -	if (!uid_eq(current_fsuid(), inode->i_uid) && !capable(CAP_FOWNER))
> -		return -EPERM;
> -	if (S_ISLNK(inode->i_mode))
> -		return -EOPNOTSUPP;
> -
> -	if (!value)
> -		goto set_acl;
>  
> -	acl = posix_acl_from_xattr(&init_user_ns, value, size);
> -	if (!acl) {
> -		/*
> -		 * acl_set_file(3) may request that we set default ACLs with
> -		 * zero length -- defend (gracefully) against that here.
> -		 */
> -		goto out;
> -	}
> -	if (IS_ERR(acl)) {
> -		error = PTR_ERR(acl);
> -		goto out;
> -	}
> -
> -	error = posix_acl_valid(acl);
> -	if (error)
> -		goto out_release;
> -
> -	error = -EINVAL;
>  	if (acl->a_count > GFS2_ACL_MAX_ENTRIES)
> -		goto out_release;
> +		return -EINVAL;
>  
>  	if (type == ACL_TYPE_ACCESS) {
>  		umode_t mode = inode->i_mode;
> +
>  		error = posix_acl_equiv_mode(acl, &mode);
> +		if (error < 0)
>  
Andy Price has pointed out a missing "return error;" here

> -		if (error <= 0) {
> -			posix_acl_release(acl);
> +		if (error == 0)
>  			acl = NULL;
>  
> -			if (error < 0)
> -				return error;
> -		}
> -

Also, there seems to be a white space error in the xfs patch around line
170 in fs/xfs/xfs_iops.c where there is an added "if (default_acl)" with
a space before the tab,

Steve.


