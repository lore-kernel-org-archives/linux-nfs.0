Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:2172 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab3FYPg4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 11:36:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] rpc_pipe: export simple_dentry_operations and have
 rpc_pipefs use it
Date: Tue, 25 Jun 2013 15:36:54 +0000
Message-ID: <1372174611.5968.28.camel@leira.trondhjem.org>
References: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
	 <1372122340-28982-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372122340-28982-2-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-06-24 at 21:05 -0400, Jeff Layton wrote:
> ...instead of replicating a copy of them.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/libfs.c            |  9 +++++----
>  include/linux/fs.h    |  1 +
>  net/sunrpc/rpc_pipe.c | 11 +----------
>  3 files changed, 7 insertions(+), 14 deletions(-)
> 

Can you please get an ACK from Al on this patch.

Cheers
  Trond

> diff --git a/fs/libfs.c b/fs/libfs.c
> index 916da8c..69793f7 100644
> --- a/fs/libfs.c
> +++ b/fs/libfs.c
> @@ -49,16 +49,16 @@ static int simple_delete_dentry(const struct dentry *dentry)
>  	return 1;
>  }
>  
> +const struct dentry_operations simple_dentry_operations = {
> +	.d_delete = simple_delete_dentry,
> +};
> +
>  /*
>   * Lookup the data. This is trivial - if the dentry didn't already
>   * exist, we know it is negative.  Set d_op to delete negative dentries.
>   */
>  struct dentry *simple_lookup(struct inode *dir, struct dentry *dentry, unsigned int flags)
>  {
> -	static const struct dentry_operations simple_dentry_operations = {
> -		.d_delete = simple_delete_dentry,
> -	};
> -
>  	if (dentry->d_name.len > NAME_MAX)
>  		return ERR_PTR(-ENAMETOOLONG);
>  	d_set_d_op(dentry, &simple_dentry_operations);
> @@ -987,6 +987,7 @@ EXPORT_SYMBOL(simple_write_begin);
>  EXPORT_SYMBOL(simple_write_end);
>  EXPORT_SYMBOL(simple_dir_inode_operations);
>  EXPORT_SYMBOL(simple_dir_operations);
> +EXPORT_SYMBOL(simple_dentry_operations);
>  EXPORT_SYMBOL(simple_empty);
>  EXPORT_SYMBOL(simple_fill_super);
>  EXPORT_SYMBOL(simple_getattr);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 65c2be2..1d21364 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2546,6 +2546,7 @@ extern int simple_write_end(struct file *file, struct address_space *mapping,
>  extern struct dentry *simple_lookup(struct inode *, struct dentry *, unsigned int flags);
>  extern ssize_t generic_read_dir(struct file *, char __user *, size_t, loff_t *);
>  extern const struct file_operations simple_dir_operations;
> +extern const struct dentry_operations simple_dentry_operations;
>  extern const struct inode_operations simple_dir_inode_operations;
>  struct tree_descr { char *name; const struct file_operations *ops; int mode; };
>  struct dentry *d_alloc_name(struct dentry *, const char *);
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index a816b3a..99cd7db 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -471,15 +471,6 @@ struct rpc_filelist {
>  	umode_t mode;
>  };
>  
> -static int rpc_delete_dentry(const struct dentry *dentry)
> -{
> -	return 1;
> -}
> -
> -static const struct dentry_operations rpc_dentry_operations = {
> -	.d_delete = rpc_delete_dentry,
> -};
> -
>  static struct inode *
>  rpc_get_inode(struct super_block *sb, umode_t mode)
>  {
> @@ -668,7 +659,7 @@ static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
>  	}
>  	if (dentry->d_inode == NULL) {
>  		if (!dentry->d_op)
> -			d_set_d_op(dentry, &rpc_dentry_operations);
> +			d_set_d_op(dentry, &simple_dentry_operations);
>  		return dentry;
>  	}
>  	dput(dentry);


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
