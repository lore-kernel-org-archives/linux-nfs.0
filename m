Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38983 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab2FKPni (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 11:43:38 -0400
Received: by bkcji2 with SMTP id ji2so3661307bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jun 2012 08:43:37 -0700 (PDT)
Message-ID: <4FD61223.3060309@tonian.com>
Date: Mon, 11 Jun 2012 18:43:31 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfsd-exofs: Two clients must not write to the same RAID
 stripe
References: <4FC6B29C.3030803@panasas.com> <4FC6BA73.3060600@panasas.com>
In-Reply-To: <4FC6BA73.3060600@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-31 03:25, Boaz Harrosh wrote:
> If any one is interested the below is the behavior
> I'm striving for.

This patch looks reasonable to me.
Would you like me to commit it?

Benny

> 
> ----
> From: Boaz Harrosh <bharrosh@panasas.com>
> Subject: [PATCH] pnfsd-exofs: Two clients must not write to the same RAID stripe
> 
> If we have file redundancy  RAID1/4/5/6 then two clients cannot
> write to the same stripe/region.
> 
> We take care of this by giving out smaller regions of the file.
> Before any layout_get we make sure to recall the same exact
> region from any client. If a recall was issued we return
> NFS4ERR_RECALLCONFLICT. The client will come again later for
> it's layout.
> 
> Meanwhile the fist client can flush data and release the
> layout. The next time the segment might be free and the
> lo_get succeed.
> 
> It is very possible that multiple writers will fight and
> some clients will starve forever. But the smaller the
> region, and if the clients randomize a wait, it should
> statistically be OK.
> (We could manage a fairness queue. What about an lo_available
>  notification)
> 
> On the other hand a very small segment will hurt performance,
> so default size is now set to 8 stripes.
> TODO: Let segment size be set in sysfs.
> 
> TODO:
>   For debugging we always give out small segments. But we should
>   only start giving out small segments on a shared file. The
>   first/single writer should get a large seg as before.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/exofs/export.c | 48 ++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 42 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/exofs/export.c b/fs/exofs/export.c
> index c5712f3..a1f112f 100644
> --- a/fs/exofs/export.c
> +++ b/fs/exofs/export.c
> @@ -29,6 +29,9 @@
>  
>  #include "linux/nfsd/pnfs_osd_xdr_srv.h"
>  
> +/* TODO: put in sysfs per sb */
> +const static unsigned sb_shared_num_stripes = 8;
> +
>  static int exofs_layout_type(struct super_block *sb)
>  {
>  	return LAYOUT_OSD2_OBJECTS;
> @@ -94,14 +97,27 @@ void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
>  	}
>  }
>  
> -static void _align_io(struct ore_layout *layout, u64 *offset, u64 *length)
> +static bool _align_io(struct ore_layout *layout, struct nfsd4_layout_seg *lseg,
> +		      bool shared)
>  {
>  	u64 stripe_size = (layout->group_width - layout->parity) *
>  							layout->stripe_unit;
>  	u64 group_size = stripe_size * layout->group_depth;
>  
> -	*offset = div64_u64(*offset, group_size) * group_size;
> -	*length = group_size;
> +	/* TODO: Don't ignore shared flag. Single writer can get a full group */
> +	if (lseg->iomode != IOMODE_READ &&
> +	    (layout->parity || (layout->mirrors_p1 > 1))) {
> +		/* RAID writes */
> +		lseg->offset = div64_u64(lseg->offset, stripe_size) *
> +								stripe_size;
> +		lseg->length = stripe_size * sb_shared_num_stripes;
> +		return true;
> +	} else {
> +		/* reads or no data redundancy */
> +		lseg->offset = div64_u64(lseg->offset, group_size) * group_size;
> +		lseg->length = group_size;
> +		return false;
> +	}
>  }
>  
>  static enum nfsstat4 exofs_layout_get(
> @@ -116,15 +132,15 @@ static enum nfsstat4 exofs_layout_get(
>  	struct pnfs_osd_layout layout;
>  	__be32 *start;
>  	unsigned i;
> -	bool in_recall;
> +	bool in_recall, need_recall;
>  	enum nfsstat4 nfserr;
>  
>  	EXOFS_DBGMSG("(0x%lx) REQUESTED offset=0x%llx len=0x%llx iomod=0x%x\n",
>  		     inode->i_ino, res->lg_seg.offset,
>  		     res->lg_seg.length, res->lg_seg.iomode);
>  
> -	_align_io(&sbi->layout, &res->lg_seg.offset, &res->lg_seg.length);
> -	res->lg_seg.iomode = IOMODE_RW;
> +	need_recall = _align_io(&sbi->layout, &res->lg_seg,
> +				test_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags));
>  	res->lg_return_on_close = true;
>  	res->lg_lo_cookie = inode; /* Just for debug prints */
>  
> @@ -132,6 +148,26 @@ static enum nfsstat4 exofs_layout_get(
>  		     inode->i_ino, res->lg_seg.offset,
>  		     res->lg_seg.length, res->lg_seg.iomode);
>  
> +	if (need_recall) {
> +		int rc = cb_layout_recall(inode, IOMODE_RW, res->lg_seg.offset,
> +				      res->lg_seg.length, (void *)0x17);
> +		switch (rc) {
> +		case 0:
> +		case -EAGAIN:
> +			EXOFS_DBGMSG("(0x%lx) @@@ Sharing of RAID5/1 stripe\n",
> +				     inode->i_ino);
> +			return NFS4ERR_RECALLCONFLICT;
> +		default:
> +			/* This is fine for now */
> +			/* TODO: Fence object off */
> +			EXOFS_DBGMSG("(0x%lx) !!!cb_layout_recall => %d\n",
> +				     inode->i_ino, rc);
> +			/*fallthrough*/
> +		case -ENOENT:
> +			break;
> +		}
> +	}
> +
>  	/* skip opaque size, will be filled-in later */
>  	start = exp_xdr_reserve_qwords(xdr, 1);
>  	if (!start) {
