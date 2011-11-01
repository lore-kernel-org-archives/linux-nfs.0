Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab1KAU1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 16:27:18 -0400
Date: Tue, 1 Nov 2011 16:27:16 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own
 cache
Message-ID: <20111101202715.GB1891@fieldses.org>
References: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 18, 2011 at 08:09:15PM -0400, Myklebust, Trond wrote:
> We should already optimize away the unnecessary setting of the size.

Do you remember what commit fixed that?  (Was it an nfs change or a vfs
change?)

> The problem is that truncate() still requires you to set the ctime, whereas ftruncate() does not iirc.

Staring at the code....  I think you mean the opposite?  I notice
do_sys_ftruncate() calling

	do_truncate(dentry, length, ATTR_MTIME|ATTR_CTIME, file);

and do_sys_truncate() calling

	do_truncate(path.dentry, length, 0, NULL);

where the third argument is getting OR'd with ATTR_FILE to pass into
notify_change().

Also even when a setattr does get through, I don't understand why it
should be invalidating our data cache.  Is there some reason it needs
to, or is this just a case that hasn't seemed worth fixing?

--b.

> 
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We recently noticed that NFSv4 iozone read tests that should have been
> performing at local-cache speeds were running at wire speeds, and found
> that currently,
> 
> 	open(O_RDWR|O_TRUNC)
> 	write()
> 	close()
> 	open(O_RDONLY)
> 	read()
> 
> results in an over-the-wire read (due to a setattr triggered by
> O_TRUNC).  Even non-O_TRUNC opens send setattrs (of timestamps) in some
> cases, causing the same problem.
> 
> In discussion with Trond, he blames a VFS bug for breaking what should
> be a single open into an open followed by a setattr.
> 
> However, it may make sense even in a case like
> 
> 	open(O_RDWR)
> 	write()
> 	setattr()
> 	close()
> 	open(O_RDONLY)
> 	read()
> 
> to treat the setattr similarly to the write, and not invalidate the
> client's own cache as long as the setattr is performed under a write
> open.
> 
> (That said, I don't know if this is the correct place in the code to
> implement that behavior.)
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfs/inode.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 6f4850d..d4eed06 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -438,8 +438,13 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
>  	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
>  		nfs_inode_return_delegation(inode);
>  	error = NFS_PROTO(inode)->setattr(dentry, fattr, attr);
> -	if (error == 0)
> +	if (error)
> +		goto out_free;
> +	if (attr->ia_valid & ATTR_FILE)
> +		nfs_post_op_update_inode_force_wcc(inode, fattr);
> +	else
>  		nfs_refresh_inode(inode, fattr);
> +out_free:
>  	nfs_free_fattr(fattr);
>  out:
>  	return error;
> -- 
> 1.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
