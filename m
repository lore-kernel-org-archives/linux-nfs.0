Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab3FYLAw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 07:00:52 -0400
Date: Tue, 25 Jun 2013 07:00:56 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] rpc_pipe: set dentry operations at d_alloc time
Message-ID: <20130625070056.6a507da0@corrin.poochiereds.net>
In-Reply-To: <1372122340-28982-3-git-send-email-jlayton@redhat.com>
References: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
	<1372122340-28982-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 24 Jun 2013 21:05:40 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> Currently the way these get set is a little convoluted. If the dentry is
> allocated via lookup from userland, then it gets set by simple_lookup.
> If it gets allocated when the kernel is populating the directory, then
> it gets set via __rpc_lookup_create_exclusive, which has to check
> whether they might already be set. Between both of these, this ensures
> that all dentries have their d_op pointer set.
> 
> Instead of doing that, just have them set at d_alloc time by pointing
> sb->s_d_op at them. With that change, we no longer want the lookup op
> to set them, so we must move to using our own lookup routine.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/rpc_pipe.c | 25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 99cd7db..7b471a2 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -471,6 +471,23 @@ struct rpc_filelist {
>  	umode_t mode;
>  };
>  
> +/*
> + * Lookup the data. This is trivial - if the dentry didn't already
> + * exist, we know it is negative.
> + */
> +static struct dentry *
> +rpc_lookup(struct inode *dir, struct dentry *dentry, unsigned int flags)
> +{
> +	if (dentry->d_name.len > NAME_MAX)
> +		return ERR_PTR(-ENAMETOOLONG);
> +	d_add(dentry, NULL);
> +	return NULL;
> +}
> +
> +const struct inode_operations rpc_dir_inode_operations = {
> +	.lookup		= rpc_lookup,
> +};
> +

Nit: the above should probably be static. Let me know if you want me to respin...

>  static struct inode *
>  rpc_get_inode(struct super_block *sb, umode_t mode)
>  {
> @@ -483,7 +500,7 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
>  	switch (mode & S_IFMT) {
>  	case S_IFDIR:
>  		inode->i_fop = &simple_dir_operations;
> -		inode->i_op = &simple_dir_inode_operations;
> +		inode->i_op = &rpc_dir_inode_operations;
>  		inc_nlink(inode);
>  	default:
>  		break;
> @@ -657,11 +674,8 @@ static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
>  		if (!dentry)
>  			return ERR_PTR(-ENOMEM);
>  	}
> -	if (dentry->d_inode == NULL) {
> -		if (!dentry->d_op)
> -			d_set_d_op(dentry, &simple_dentry_operations);
> +	if (dentry->d_inode == NULL)
>  		return dentry;
> -	}
>  	dput(dentry);
>  	return ERR_PTR(-EEXIST);
>  }
> @@ -1108,6 +1122,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
>  	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
>  	sb->s_magic = RPCAUTH_GSSMAGIC;
>  	sb->s_op = &s_ops;
> +	sb->s_d_op = &simple_dentry_operations;
>  	sb->s_time_gran = 1;
>  
>  	inode = rpc_get_inode(sb, S_IFDIR | S_IRUGO | S_IXUGO);


-- 
Jeff Layton <jlayton@redhat.com>
