Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbaCNTTw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Mar 2014 15:19:52 -0400
Date: Fri, 14 Mar 2014 15:19:48 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/5] nfs: convert nfs_rename to use async_rename
 infrastructure
Message-ID: <20140314151948.0f6a3b28@tlielax.poochiereds.net>
In-Reply-To: <1394819225-13713-4-git-send-email-jlayton@redhat.com>
References: <1394819225-13713-1-git-send-email-jlayton@redhat.com>
	<1394819225-13713-4-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 14 Mar 2014 13:47:03 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> There isn't much sense in maintaining two separate versions of rename
> code. Convert nfs_rename to use the asynchronous rename infrastructure
> that nfs_sillyrename uses, and emulate synchronous behavior by having
> the task just wait on the reply.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/dir.c | 26 +++++++++++++++++++++-----
>  1 file changed, 21 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 4a48fe4b84b6..70099b402b0d 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1911,6 +1911,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	struct inode *old_inode = old_dentry->d_inode;
>  	struct inode *new_inode = new_dentry->d_inode;
>  	struct dentry *dentry = NULL, *rehash = NULL;
> +	struct rpc_task *task;
>  	int error = -EBUSY;
>  
>  	dfprintk(VFS, "NFS: rename(%pd2 -> %pd2, ct=%d)\n",
> @@ -1958,23 +1959,38 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	if (new_inode != NULL)
>  		NFS_PROTO(new_inode)->return_delegation(new_inode);
>  
> -	error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
> -					   new_dir, &new_dentry->d_name);
> +	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry, NULL);
> +	if (IS_ERR(task)) {
> +		error = PTR_ERR(task);
> +		goto out_dput;
> +	}
> +
> +	error = rpc_wait_for_completion_task(task);
> +	if (error == 0)
> +		error = task->tk_status;
> +	rpc_put_task(task);
>  	nfs_mark_for_revalidate(old_inode);
>  out:
>  	if (rehash)
>  		d_rehash(rehash);
>  	trace_nfs_rename_exit(old_dir, old_dentry,
>  			new_dir, new_dentry, error);
> -	if (!error) {
> +	switch (error) {
> +	case 0:
>  		if (new_inode != NULL)
>  			nfs_drop_nlink(new_inode);
>  		d_move(old_dentry, new_dentry);
>  		nfs_set_verifier(new_dentry,
>  					nfs_save_change_attribute(new_dir));
> -	} else if (error == -ENOENT)
> +		break;
> +	case -ENOENT:
>  		nfs_dentry_handle_enoent(old_dentry);
> -
> +		break;
> +	case -ERESTARTSYS:
> +		d_drop(old_dentry);
> +		d_drop(new_dentry);

Al pointed out to me on IRC that the -ERESTARTSYS handling is probably
not correct for directories. If the old/new_dentries have children then
it's not safe to just d_drop them. Since the sillyrename code never
operates on directories, it's safe to do it there, but nfs_rename is
different.

I think what we probably ought to do there is replace those with:

        nfs_force_lookup_revalidate(old_dir);
        nfs_force_lookup_revalidate(new_dir);

...or possibly just do that in the event that old_dentry->d_inode
refers to a directory and d_drop the dentries otherwise.

Thoughts?

> +	}
> +out_dput:
>  	/* new dentry created? */
>  	if (dentry)
>  		dput(dentry);


-- 
Jeff Layton <jlayton@redhat.com>
