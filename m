From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH] Make UDF exportable
Date: Tue, 5 Feb 2008 10:29:55 +0000
Message-ID: <20080205102955.GA28347__15772.2105192535$1202207458$gmane$org@infradead.org>
References: <1201726404.2976.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, jack@suse.cz,
	nfs@lists.sourceforge.net
To: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36194 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755032AbYBEKaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 05:30:15 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JML49-0003DA-PC
	for linux-nfs@vger.kernel.org; Tue, 05 Feb 2008 21:30:13 +1100
In-Reply-To: <1201726404.2976.8.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 30, 2008 at 09:53:24PM +0100, Rasmus Rohde wrote:
> I've cooked together a patch for making UDF exportable.

Thanks, I know some people have been waiting for this for quite a while.
Please make sure Jan Kara who's the new udf maintainer and linux-fsdevel
where we discuss general filesystem related issue for future revisions
of the patch.

> It is based on the code found in ISO fs. Since I am far from an expert
> in this area bugs may be present.

isofs might not be the very best example since it's an odd filesystem,
but then so is udf.  I'll go through your patch in a little more detail
below, but it looks quite reasonable.

> +static struct dentry *udf_export_get_parent(struct dentry *child)

Any reason this is not called udf_get_parent to follow the scheme
in most filesystems?

> +	lock_kernel();
> +	if (udf_find_entry(child->d_inode, &dotdot, &fibh, &cfi)) {
> +		if (fibh.sbh != fibh.ebh)
> +			brelse(fibh.ebh);
> +		brelse(fibh.sbh);
> +		
> +		inode = udf_iget(child->d_inode->i_sb,
> +				 lelb_to_cpu(cfi.icb.extLocation));
> +		if (!inode) {
> +			unlock_kernel();
> +			return ERR_PTR(-EACCES);
> +		}
> +	} else {
> +		unlock_kernel();
> +		return ERR_PTR(-EACCES);
> +	}
> +	unlock_kernel();

This if/else block looks little odd, and following the locking is a bit
hard.  What about doing it like the following:

	lock_kernel();
	if (!udf_find_entry(child->d_inode, &dotdot, &fibh, &cfi))
		goto out_unlock;

	if (fibh.sbh != fibh.ebh)
		brelse(fibh.ebh);
	brelse(fibh.sbh);

	inode = udf_iget(child->d_inode->i_sb,
			 lelb_to_cpu(cfi.icb.extLocation));
	if (!inode)
		goto out_unlock;
	unlock_kernel();

	parent = d_alloc_anon(inode);
	if (!parent) {
		iput(inode);
		parent = ERR_PTR(-ENOMEM);
	}

	return parent;
 out_unlock:
	unlock_kernel();
	return ERR_PTR(-EACCESS);
}


> +static struct dentry *
> +udf_export_iget(struct super_block *sb, u32 block,
> +		u16 offset, __u32 generation)

to follow other filesystems this should be called
udf_nfs_get_inode.  Also please decide if you want to put the static
and return type on the same line or on a separate one.  Having it on
the same one is documented in Documentation/Codingstyle but separate
ones are acceptable aswell.  Just make sure to stick to either one :)

> +{
> +	struct inode *inode;
> +	struct dentry *result;
> +	kernel_lb_addr loc;
> +
> +	if (block == 0)
> +		return ERR_PTR(-ESTALE);
> +
> +	loc.logicalBlockNum = block;
> +	loc.partitionReferenceNum = offset;
> +	inode = udf_iget(sb, loc);
> +
> +	if (inode == NULL)
> +		return ERR_PTR(-ENOMEM);
> +
> +	if (is_bad_inode(inode)
> +	    || (generation && inode->i_generation != generation))
> +	{

it would be better to introduce a version of udf_iget that can check
the generation and return an error instead of having to check this
later.  If you don't think you're up to modifying code we could do
this later on, though.  In this case please note this in the patch
description and fix up the above formatting to read something like:

	if (is_bad_inode(inode) ||
	    (generation && inode->i_generation != generation)) {

> +static struct dentry *udf_fh_to_dentry(struct super_block *sb,
> +	struct fid *fid, int fh_len, int fh_type)
> +{
> +	struct udf_fid *ufid = (struct udf_fid *)fid;
> +
> +	if (fh_len < 3 || fh_type > 2)
> +		return NULL;

It would be useful if you could add symbolic constants for the
two fh types you add and chose values not yet used by other filesystems,
e.g. 0x51 and 0x52.  This will help people sniffing the nfs on the
wire protocol to understand what file handle they're dealing with.

Also you migh want to make the fh_len check more explicit and check
that it's either 3 or 5 which is the only fhs you actually generate.

> +static struct dentry *udf_fh_to_parent(struct super_block *sb,
> +		struct fid *fid, int fh_len, int fh_type)
> +{
> +	struct udf_fid *ufid = (struct udf_fid *)fid;
> +
> +	if (fh_type != 2)
> +		return NULL;

and a check for len == 5 here.

> +
> +	return udf_export_iget(sb,
> +			fh_len > 2 ? ufid->parent_block : 0,
> +			ufid->parent_partref,
> +			fh_len > 4 ? ufid->parent_generation : 0);

and you can remove these checks as you only end up here with len == 5
fhs.

Also it would be nice if you could add your fid type to the union in
include/linux/exportfs.h and use the union member.  The symbolic names
for the FH types should go into enum fid_type with a short comment
describing them.

Thanks for all this work!

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

