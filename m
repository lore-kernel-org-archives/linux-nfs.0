Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:47024 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005AbcEYPPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 11:15:07 -0400
Date: Wed, 25 May 2016 17:15:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/4] nfsd: Add a super simple flex file server
Message-ID: <20160525151504.GD27535@lst.de>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com> <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nice!  A few comments below:

> + * where the NFSv4.1 mds is also the ds. And the storage is
> + * the same. I.e., writing to the mds via a NFSv4.1 WRITE
> + * goes to the same location as the NFSv3 WRITE.
> + */
> +#include <linux/exportfs.h>
> +#include <linux/genhd.h>

> +#include <linux/pr.h>

I don't think you need any of the three headers above.

> +static __be32
> +nfsd4_ff_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
> +		struct nfsd4_layoutget *args)
> +{
> +	struct nfsd4_layout_seg *seg = &args->lg_seg;
> +	u32 block_size = (1 << inode->i_blkbits);
> +	u32 device_generation = 0;
> +	int error;
> +
> +	struct pnfs_ff_layout *fl;
> +
> +	if (seg->offset & (block_size - 1)) {
> +		dprintk("pnfsd: I/O misaligned\n");
> +		goto out_layoutunavailable;
> +	}

Do we really care about aligned I/O for flexfiles layouts?

> +	 * effectively be WRITE only.
> +	 */
> +	fl->flags = FF_FLAGS_NO_LAYOUTCOMMIT | FF_FLAGS_NO_IO_THRU_MDS |
> +		    FF_FLAGS_NO_READ_IO;
> +
> +	fl->uid = inode->i_uid;
> +	fl->gid = inode->i_gid;

Maybe I need to actually read the latest draft, but what's the story
about these on the wire uids/gids?

> +#ifdef CONFIG_NFSD_FLEXFILELAYOUT

I don't think you need this - the whole file is conditional on this
symbol.

> +	if (sb->s_bdev != sb->s_bdev->bd_contains)
> +		return nfserr_inval;

Shouldn't be needed.

> +#include <linux/exportfs.h>

probably not needed.

> +struct iomap;

no needed.

>  void nfsd4_setup_layout_type(struct svc_export *exp)
>  {
> +#if defined(CONFIG_NFSD_BLOCKLAYOUT) || defined(CONFIG_NFSD_SCSILAYOUT)
>  	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
> +#endif
>  
>  	if (!(exp->ex_flags & NFSEXP_PNFS))
>  		return;
> @@ -145,6 +150,11 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
>  	    sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
>  		exp->ex_layout_type = LAYOUT_SCSI;
>  #endif
> +#ifdef CONFIG_NFSD_FLEXFILELAYOUT
> +	// FIXME: How do we "export" this and how does it mingle with
> +	// the above types?
> +	exp->ex_layout_type = LAYOUT_FLEX_FILES;
> +#endif

As pointed out by Jeff we'll probably need a bitmap of supported layouts
here.  Something like

	unsigned long ex_layout_types;

...

	if (supported)
		ex_layout_types |= (1 << LAYOUT_XXX)

probably best done as a separate preparation patch.

The other issue is that the Linux client is currently confused when
more than a single layout type is supported - we'll need some sort
of runtime option to chose the layout(s) supported.
