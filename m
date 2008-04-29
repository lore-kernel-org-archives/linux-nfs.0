From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Tue, 29 Apr 2008 10:33:31 -0400
Message-ID: <20080429143331.GA5441__20363.529228098$1209481169$gmane$org@infradead.org>
References: <1201726404.2976.8.camel@localhost.localdomain>
	<20080205102955.GA28347@infradead.org>
	<1202233464.12188.43.camel@localhost.localdomain>
	<20080206180850.GD3475@duck.suse.cz>
	<1202331482.2727.8.camel@localhost.localdomain>
	<20080207054515.GA14585@infradead.org>
	<1202367997.17388.6.camel@localhost.localdomain>
	<20080207144859.GJ6140@duck.suse.cz>
	<1202396577.18175.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>,
	nfs@lists.sourceforge.net
To: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46601 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287AbYD2O6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2008 10:58:07 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JqrHQ-000810-57
	for linux-nfs@vger.kernel.org; Wed, 30 Apr 2008 00:58:04 +1000
In-Reply-To: <1202396577.18175.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2008 at 04:02:57PM +0100, Rasmus Rohde wrote:
> 
> > > Before posting the last and hopefully final patch I'd like to know what
> > > Jan says about open coding the lookup for ..
> > > It will mean a lot of code duplication and I think it makes good sense
> > > for udf_find_entry to be able to handle ..
> >   Yes, I think opencoding it would really lead to larger code duplication
> > than I'd like so please keep the change in udf_find_entry(). Thanks.
> Great - then I think we are hopefully at a patch that can be accepted.

Jan, any reason this patch didn't go in with the last merge?  I'd really
like to see it in .26.

> 
> Signed-off-by: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
> 
> diff -uprN -X linux-2.6.24-mm1-vanilla/Documentation/dontdiff linux-2.6.24-mm1-vanilla/fs/udf/namei.c linux-2.6.24-mm1/fs/udf/namei.c
> --- linux-2.6.24-mm1-vanilla/fs/udf/namei.c	2008-02-06 21:23:36.000000000 +0100
> +++ linux-2.6.24-mm1/fs/udf/namei.c	2008-02-07 07:13:04.000000000 +0100
> @@ -31,6 +31,7 @@
>  #include <linux/smp_lock.h>
>  #include <linux/buffer_head.h>
>  #include <linux/sched.h>
> +#include <linux/exportfs.h>
>  
>  static inline int udf_match(int len1, const char *name1, int len2,
>  			    const char *name2)
> @@ -159,6 +160,8 @@ static struct fileIdentDesc *udf_find_en
>  	sector_t offset;
>  	struct extent_position epos = {};
>  	struct udf_inode_info *dinfo = UDF_I(dir);
> +	int isdotdot = dentry->d_name.len == 2 &&
> +		dentry->d_name.name[0] == '.' && dentry->d_name.name[1] == '.';
>  
>  	size = udf_ext0_offset(dir) + dir->i_size;
>  	f_pos = udf_ext0_offset(dir);
> @@ -232,6 +235,12 @@ static struct fileIdentDesc *udf_find_en
>  				continue;
>  		}
>  
> +		if ((cfi->fileCharacteristics & FID_FILE_CHAR_PARENT) &&
> +		    isdotdot) {
> +			brelse(epos.bh);
> +			return fi;
> +		}
> +
>  		if (!lfi)
>  			continue;
>  
> @@ -324,9 +333,8 @@ static struct dentry *udf_lookup(struct 
>  		}
>  	}
>  	unlock_kernel();
> -	d_add(dentry, inode);
>  
> -	return NULL;
> +	return d_splice_alias(inode, dentry);
>  }
>  
>  static struct fileIdentDesc *udf_add_entry(struct inode *dir,
> @@ -1298,6 +1306,134 @@ end_rename:
>  	return retval;
>  }
>  
> +static struct dentry *udf_get_parent(struct dentry *child)
> +{
> +	struct dentry *parent;
> +	struct inode *inode = NULL;
> +	struct dentry dotdot;
> +	struct fileIdentDesc cfi;
> +	struct udf_fileident_bh fibh;
> +
> +	dotdot.d_name.name = "..";
> +	dotdot.d_name.len = 2;
> +
> +	lock_kernel();
> +	if (!udf_find_entry(child->d_inode, &dotdot, &fibh, &cfi))
> +		goto out_unlock;
> +
> +	if (fibh.sbh != fibh.ebh)
> +		brelse(fibh.ebh);
> +	brelse(fibh.sbh);
> +
> +	inode = udf_iget(child->d_inode->i_sb,
> +			 lelb_to_cpu(cfi.icb.extLocation));
> +	if (!inode)
> +		goto out_unlock;
> +	unlock_kernel();
> +
> +	parent = d_alloc_anon(inode);
> +	if (!parent) {
> +		iput(inode);
> +		parent = ERR_PTR(-ENOMEM);
> +	}
> +
> +	return parent;
> +out_unlock:
> +	unlock_kernel();
> +	return ERR_PTR(-EACCES);
> +}
> +
> +
> +static struct dentry *udf_nfs_get_inode(struct super_block *sb, u32 block,
> +					u16 partref, __u32 generation)
> +{
> +	struct inode *inode;
> +	struct dentry *result;
> +	kernel_lb_addr loc;
> +
> +	if (block == 0)
> +		return ERR_PTR(-ESTALE);
> +
> +	loc.logicalBlockNum = block;
> +	loc.partitionReferenceNum = partref;
> +	inode = udf_iget(sb, loc);
> +
> +	if (inode == NULL)
> +		return ERR_PTR(-ENOMEM);
> +
> +	if (generation && inode->i_generation != generation) {
> +		iput(inode);
> +		return ERR_PTR(-ESTALE);
> +	}
> +	result = d_alloc_anon(inode);
> +	if (!result) {
> +		iput(inode);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +	return result;
> +}
> +
> +static struct dentry *udf_fh_to_dentry(struct super_block *sb,
> +				       struct fid *fid, int fh_len, int fh_type)
> +{
> +	if ((fh_len != 3 && fh_len != 5) ||
> +	    (fh_type != FILEID_UDF_WITH_PARENT &&
> +	     fh_type != FILEID_UDF_WITHOUT_PARENT))
> +		return NULL;
> +
> +	return udf_nfs_get_inode(sb, fid->udf.block, fid->udf.partref,
> +			fid->udf.generation);
> +}
> +
> +static struct dentry *udf_fh_to_parent(struct super_block *sb,
> +				       struct fid *fid, int fh_len, int fh_type)
> +{
> +	if (fh_len != 5 || fh_type != FILEID_UDF_WITH_PARENT)
> +		return NULL;
> +
> +	return udf_nfs_get_inode(sb, fid->udf.parent_block,
> +				 fid->udf.parent_partref,
> +				 fid->udf.parent_generation);
> +}
> +static int udf_encode_fh(struct dentry *de, __u32 *fh, int *lenp,
> +			 int connectable)
> +{
> +	int len = *lenp;
> +	struct inode *inode =  de->d_inode;
> +	kernel_lb_addr location = UDF_I(inode)->i_location;
> +	struct fid *fid = (struct fid *)fh;
> +	int type = FILEID_UDF_WITHOUT_PARENT;
> +
> +	if (len < 3 || (connectable && len < 5))
> +		return 255;
> +
> +	*lenp = 3;
> +	fid->udf.block = location.logicalBlockNum;
> +	fid->udf.partref = location.partitionReferenceNum;
> +	fid->udf.generation = inode->i_generation;
> +
> +	if (connectable && !S_ISDIR(inode->i_mode)) {
> +		spin_lock(&de->d_lock);
> +		inode = de->d_parent->d_inode;
> +		location = UDF_I(inode)->i_location;
> +		fid->udf.parent_block = location.logicalBlockNum;
> +		fid->udf.parent_partref = location.partitionReferenceNum;
> +		fid->udf.parent_generation = inode->i_generation;
> +		spin_unlock(&de->d_lock);
> +		*lenp = 5;
> +		type = FILEID_UDF_WITH_PARENT;
> +	}
> +
> +	return type;
> +}
> +
> +const struct export_operations udf_export_ops = {
> +	.encode_fh	= udf_encode_fh,
> +	.fh_to_dentry   = udf_fh_to_dentry,
> +	.fh_to_parent   = udf_fh_to_parent,
> +	.get_parent     = udf_get_parent,
> +};
> +
>  const struct inode_operations udf_dir_inode_operations = {
>  	.lookup				= udf_lookup,
>  	.create				= udf_create,
> diff -uprN -X linux-2.6.24-mm1-vanilla/Documentation/dontdiff linux-2.6.24-mm1-vanilla/fs/udf/super.c linux-2.6.24-mm1/fs/udf/super.c
> --- linux-2.6.24-mm1-vanilla/fs/udf/super.c	2008-02-06 21:23:36.000000000 +0100
> +++ linux-2.6.24-mm1/fs/udf/super.c	2008-02-07 07:06:30.000000000 +0100
> @@ -1801,6 +1801,7 @@ static int udf_fill_super(struct super_b
>  
>  	/* Fill in the rest of the superblock */
>  	sb->s_op = &udf_sb_ops;
> +	sb->s_export_op = &udf_export_ops;
>  	sb->dq_op = NULL;
>  	sb->s_dirt = 0;
>  	sb->s_magic = UDF_SUPER_MAGIC;
> diff -uprN -X linux-2.6.24-mm1-vanilla/Documentation/dontdiff linux-2.6.24-mm1-vanilla/fs/udf/udfdecl.h linux-2.6.24-mm1/fs/udf/udfdecl.h
> --- linux-2.6.24-mm1-vanilla/fs/udf/udfdecl.h	2008-02-06 21:23:36.000000000 +0100
> +++ linux-2.6.24-mm1/fs/udf/udfdecl.h	2008-02-07 07:11:24.000000000 +0100
> @@ -45,6 +45,7 @@ struct task_struct;
>  struct buffer_head;
>  struct super_block;
>  
> +extern const struct export_operations udf_export_ops;
>  extern const struct inode_operations udf_dir_inode_operations;
>  extern const struct file_operations udf_dir_operations;
>  extern const struct inode_operations udf_file_inode_operations;
> diff -uprN -X linux-2.6.24-mm1-vanilla/Documentation/dontdiff linux-2.6.24-mm1-vanilla/include/linux/exportfs.h linux-2.6.24-mm1/include/linux/exportfs.h
> --- linux-2.6.24-mm1-vanilla/include/linux/exportfs.h	2008-02-06 21:23:46.000000000 +0100
> +++ linux-2.6.24-mm1/include/linux/exportfs.h	2008-02-06 21:25:06.000000000 +0100
> @@ -33,6 +33,19 @@ enum fid_type {
>  	 * 32 bit parent directory inode number.
>  	 */
>  	FILEID_INO32_GEN_PARENT = 2,
> +
> +	/*
> +	 * 32 bit block number, 16 bit partition reference,
> +	 * 16 bit unused, 32 bit generation number.
> +	 */
> +	FILEID_UDF_WITHOUT_PARENT = 0x51,
> +
> +	/*
> +	 * 32 bit block number, 16 bit partition reference,
> +	 * 16 bit unused, 32 bit generation number,
> +	 * 32 bit parent block number, 32 bit parent generation number
> +	 */
> +	FILEID_UDF_WITH_PARENT = 0x52,
>  };
>  
>  struct fid {
> @@ -43,6 +56,14 @@ struct fid {
>  			u32 parent_ino;
>  			u32 parent_gen;
>  		} i32;
> +		struct {
> +			u32 block;
> +			u16 partref;
> +			u16 parent_partref;
> +			u32 generation;
> +			u32 parent_block;
> +			u32 parent_generation;
> +		} udf;
>  		__u32 raw[6];
>  	};
>  };
> 
> 
---end quoted text---

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

