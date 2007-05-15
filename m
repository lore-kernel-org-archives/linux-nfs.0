From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Subject: Re: [PATCH 002 of 8] knfsd: exportfs: remove iget abuse
Date: Tue, 15 May 2007 07:30:20 -0500
Message-ID: <1179232221.9256.4.camel@kleikamp.austin.ibm.com>
References: <20070515170405.15621.patches@notabene>
	 <1070515071614.16259@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Christoph Hellwig <hch@lst.de>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762046AbXEOMac@vger.kernel.org>
In-Reply-To: <1070515071614.16259@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2007-05-15 at 17:16 +1000, NeilBrown wrote:

> diff .prev/fs/jfs/jfs_inode.h ./fs/jfs/jfs_inode.h
> --- .prev/fs/jfs/jfs_inode.h	2007-05-14 11:14:52.000000000 +1000
> +++ ./fs/jfs/jfs_inode.h	2007-05-14 11:15:29.000000000 +1000
> @@ -31,7 +31,7 @@ extern void jfs_truncate(struct inode *)
>  extern void jfs_truncate_nolock(struct inode *, loff_t);
>  extern void jfs_free_zero_link(struct inode *);
>  extern struct dentry *jfs_get_parent(struct dentry *dentry);
> -extern void jfs_get_inode_flags(struct jfs_inode_info *);

You don't want to remove the declaration of jfs_get_inode_flags().

> +extern struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp);
>  extern void jfs_set_inode_flags(struct inode *);
>  extern int jfs_get_block(struct inode *, sector_t, struct buffer_head *, int);
>  
> 
> diff .prev/fs/jfs/namei.c ./fs/jfs/namei.c
> --- .prev/fs/jfs/namei.c	2007-05-14 11:14:52.000000000 +1000
> +++ ./fs/jfs/namei.c	2007-05-14 11:15:29.000000000 +1000
> @@ -1477,6 +1477,38 @@ static struct dentry *jfs_lookup(struct 
>  	return dentry;
>  }
>  
> +struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp)
> +{
> +	__u32 *objp = vobjp;
> +	unsigned long ino = objp[0];
> +	__u32 generation = objp[1];
> +	struct inode *inode;
> +	struct dentry *result;
> +
> +	if (ino == 0)
> +		return ERR_PTR(-ESTALE);
> +	inode = iget(sb, ino);
> +	if (inode == NULL)
> +		return ERR_PTR(-ENOMEM);
> +
> +	if (is_bad_inode(inode) ||
> +	    (generation && inode->i_generation != generation)) {
> +	    	result = ERR_PTR(-ESTALE);
> +		goto out_iput;
> +	}
> +
> +	result = d_alloc_anon(inode);
> +	if (!result) {
> +		result = ERR_PTR(-ENOMEM);
> +		goto out_iput;
> +	}
> +	return result;
> +
> + out_iput:
> +	iput(inode);
> +	return result;
> +}
> +
>  struct dentry *jfs_get_parent(struct dentry *dentry)
>  {
>  	struct super_block *sb = dentry->d_inode->i_sb;
> 
> diff .prev/fs/jfs/super.c ./fs/jfs/super.c
> --- .prev/fs/jfs/super.c	2007-05-14 11:15:23.000000000 +1000
> +++ ./fs/jfs/super.c	2007-05-14 11:15:29.000000000 +1000
> @@ -738,6 +738,7 @@ static const struct super_operations jfs
>  };
>  
>  static struct export_operations jfs_export_operations = {
> +	.get_dentry	= jfs_get_dentry,
>  	.get_parent	= jfs_get_parent,
>  };

Looks sane.  You can add:
Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

-- 
David Kleikamp
IBM Linux Technology Center
