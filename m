Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51389 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893Ab3JCTli (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Oct 2013 15:41:38 -0400
Date: Thu, 3 Oct 2013 15:41:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, jlayton@redhat.com,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/13] Implement NFSv4 delegations, take 12
Message-ID: <20131003194136.GB1577@fieldses.org>
References: <1379623837-30798-1-git-send-email-bfields@redhat.com>
 <20131002135423.GA14808@fieldses.org>
 <20131002201627.GI14808@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002201627.GI14808@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 04:16:27PM -0400, J. Bruce Fields wrote:
> On Wed, Oct 02, 2013 at 09:54:23AM -0400, bfields wrote:
> > On Thu, Sep 19, 2013 at 04:50:24PM -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > Al, if you don't see any objections, could you queue this up for 3.13?
> > 
> > Note: if it's more convenient, the identical patches are also available
> > from
> > 
> > 	git://linux-nfs.org/~bfields/linux.git for-viro
> 
> But kbuild points out I forgot to fix up some calls in ecryptfs.
> 
> I'll push out another version with the below folded in, once I've
> checked whether there's anything else I touched that got turned off in
> my test .config....

Done; the change below is now folded into the commits on the for-viro
branch at the url above.

--b.

> 
> --b.
> 
> diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> index 7b19ebb..a842ced 100644
> --- a/fs/ecryptfs/inode.c
> +++ b/fs/ecryptfs/inode.c
> @@ -208,7 +208,7 @@ ecryptfs_do_create(struct inode *directory_inode,
>  	inode = __ecryptfs_get_inode(lower_dentry->d_inode,
>  				     directory_inode->i_sb);
>  	if (IS_ERR(inode)) {
> -		vfs_unlink(lower_dir_dentry->d_inode, lower_dentry);
> +		vfs_unlink(lower_dir_dentry->d_inode, lower_dentry, NULL);
>  		goto out_lock;
>  	}
>  	fsstack_copy_attr_times(directory_inode, lower_dir_dentry->d_inode);
> @@ -640,7 +640,8 @@ ecryptfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  		goto out_lock;
>  	}
>  	rc = vfs_rename(lower_old_dir_dentry->d_inode, lower_old_dentry,
> -			lower_new_dir_dentry->d_inode, lower_new_dentry);
> +			lower_new_dir_dentry->d_inode, lower_new_dentry,
> +			NULL);
>  	if (rc)
>  		goto out_lock;
>  	if (target_inode)
> @@ -891,7 +892,7 @@ int ecryptfs_truncate(struct dentry *dentry, loff_t new_length)
>  		struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
>  
>  		mutex_lock(&lower_dentry->d_inode->i_mutex);
> -		rc = notify_change(lower_dentry, &lower_ia);
> +		rc = notify_change(lower_dentry, &lower_ia, NULL);
>  		mutex_unlock(&lower_dentry->d_inode->i_mutex);
>  	}
>  	return rc;
