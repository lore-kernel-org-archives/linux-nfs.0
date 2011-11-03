Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab1KCXaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 19:30:19 -0400
Date: Thu, 3 Nov 2011 19:30:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: when attempting to open a directory, fall back on
 normal lookup (try #2)
Message-ID: <20111103193013.6fefb499@tlielax.poochiereds.net>
In-Reply-To: <1319039154-6694-1-git-send-email-jlayton@redhat.com>
References: <1316695057-11610-1-git-send-email-jlayton@redhat.com>
	<1319039154-6694-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 19 Oct 2011 11:45:54 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> commit d953126 changed how nfs_atomic_lookup handles an -EISDIR return
> from an OPEN call. Prior to that patch, that caused the client to fall
> back to doing a normal lookup. When that patch went in, the code began
> returning that error to userspace. The d_revalidate codepath however
> never had the corresponding change, so it was still possible to end up
> with a NULL ctx->state pointer after that.
> 
> That patch caused a regression. When we attempt to open a directory that
> does not have a cached dentry, that open now errors out with EISDIR. If
> you attempt the same open with a cached dentry, it will succeed.
> 
> Fix this by reverting the change in nfs_atomic_lookup and allowing
> attempts to open directories to fall back to a normal lookup
> 
> Also, add a NFSv4-specific f_ops->open routine that just returns
> -ENOTDIR.  This should never be called if things are working properly.
> If it ever is, we can use the WARN() in that function to recognize it
> and perhaps troubleshoot it.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/dir.c           |    2 +-
>  fs/nfs/file.c          |   31 +++++++++++++++++++++++++++++++
>  fs/nfs/inode.c         |    5 ++++-
>  include/linux/nfs_fs.h |    1 +
>  4 files changed, 37 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b238d95..ac28990 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1468,12 +1468,12 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
>  				res = NULL;
>  				goto out;
>  			/* This turned out not to be a regular file */
> +			case -EISDIR:
>  			case -ENOTDIR:
>  				goto no_open;
>  			case -ELOOP:
>  				if (!(nd->intent.open.flags & O_NOFOLLOW))
>  					goto no_open;
> -			/* case -EISDIR: */
>  			/* case -EINVAL: */
>  			default:
>  				res = ERR_CAST(inode);
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 28b8c3f..9a5cab5 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -41,6 +41,7 @@
>  #define NFSDBG_FACILITY		NFSDBG_FILE
>  
>  static int nfs_file_open(struct inode *, struct file *);
> +static int nfs4_file_open(struct inode *, struct file *);
>  static int nfs_file_release(struct inode *, struct file *);
>  static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
>  static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
> @@ -63,6 +64,25 @@ static int nfs_setlease(struct file *file, long arg, struct file_lock **fl);
>  
>  static const struct vm_operations_struct nfs_file_vm_ops;
>  
> +const struct file_operations nfs4_file_operations = {
> +	.llseek		= nfs_file_llseek,
> +	.read		= do_sync_read,
> +	.write		= do_sync_write,
> +	.aio_read	= nfs_file_read,
> +	.aio_write	= nfs_file_write,
> +	.mmap		= nfs_file_mmap,
> +	.open		= nfs4_file_open,
> +	.flush		= nfs_file_flush,
> +	.release	= nfs_file_release,
> +	.fsync		= nfs_file_fsync,
> +	.lock		= nfs_lock,
> +	.flock		= nfs_flock,
> +	.splice_read	= nfs_file_splice_read,
> +	.splice_write	= nfs_file_splice_write,
> +	.check_flags	= nfs_check_flags,
> +	.setlease	= nfs_setlease,
> +};
> +
>  const struct file_operations nfs_file_operations = {
>  	.llseek		= nfs_file_llseek,
>  	.read		= do_sync_read,
> @@ -135,6 +155,17 @@ nfs_file_open(struct inode *inode, struct file *filp)
>  }
>  
>  static int
> +nfs4_file_open(struct inode *inode, struct file *filp)
> +{
> +	/*
> +	 * NFSv4 opens are handled in d_lookup and d_revalidate. If we get to
> +	 * this point, then something is very wrong
> +	 */
> +	dprintk("NFS: %s called! inode=%p filp=%p\n", __func__, inode, filp);
> +	return -ENOTDIR;
> +}
> +
> +static int
>  nfs_file_release(struct inode *inode, struct file *filp)
>  {
>  	struct dentry *dentry = filp->f_path.dentry;
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index b7c4301..3389f46 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -293,7 +293,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>  		 */
>  		inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->file_inode_ops;
>  		if (S_ISREG(inode->i_mode)) {
> -			inode->i_fop = &nfs_file_operations;
> +			if (NFS_SB(sb)->nfs_client->rpc_ops->version == 4)
> +				inode->i_fop = &nfs4_file_operations;
> +			else
> +				inode->i_fop = &nfs_file_operations;
>  			inode->i_data.a_ops = &nfs_file_aops;
>  			inode->i_data.backing_dev_info = &NFS_SB(sb)->backing_dev_info;
>  		} else if (S_ISDIR(inode->i_mode)) {
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index eaac770..81072b0 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -410,6 +410,7 @@ extern const struct inode_operations nfs_file_inode_operations;
>  extern const struct inode_operations nfs3_file_inode_operations;
>  #endif /* CONFIG_NFS_V3 */
>  extern const struct file_operations nfs_file_operations;
> +extern const struct file_operations nfs4_file_operations;
>  extern const struct address_space_operations nfs_file_aops;
>  extern const struct address_space_operations nfs_dir_aops;
>  

Hi Trond,

When we spoke at LinuxCon you mentioned that you were going to merge
this patch for 3.2, but I don't see it in any of your branches so far.
Are you still planning to do so?

I probably should have cc'ed stable on this too, btw...let me know if
you would prefer me to resend with that line...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
