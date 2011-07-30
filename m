Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32566 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab1G3BEj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 21:04:39 -0400
Subject: Re: [PATCH v5 22/27] pnfsblock: encode_layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Fri, 29 Jul 2011 21:04:38 -0400
In-Reply-To: <1311954892-22038-23-git-send-email-rees@umich.edu>
References: <1311954892-22038-1-git-send-email-rees@umich.edu>
	 <1311954892-22038-23-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311987878.16078.14.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-29 at 11:54 -0400, Jim Rees wrote: 
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> In blocklayout driver. There are two things happening
> while layoutcommit/cleanup.
> 1. the modified extents are encoded.
> 2. On cleanup the extents are put back on the layout rw
>    extents list, for reads.
> 
> In the new system where actual xdr encoding is done in
> encode_layoutcommit() directly into xdr buffer, these are
> the new commit stages:
> 
> 1. On setup_layoutcommit, the range is adjusted as before
>    and a structure is allocated for communication with
>    bl_encode_layoutcommit && bl_cleanup_layoutcommit
>    (Generic layer provides a void-star to hang it on)
> 
> 2. bl_encode_layoutcommit is called to do the actual
>    encoding directly into xdr. The commit-extent-list is not
>    freed and is stored on above structure.
>    FIXME: The code is not yet converted to the new XDR cleanup
> 
> 3. On cleanup the commit-extent-list is put back by a call
>    to set_to_rw() as before, but with no need for XDR decoding
>    of the list as before. And the commit-extent-list is freed.
>    Finally allocated structure is freed.
> 
> [rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()]
> [pnfsblock: get rid of deprecated xdr macros]
> Signed-off-by: Jim Rees <rees@umich.edu>
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> [blocklayout: encode_layoutcommit implementation]
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> [pnfsblock: fix bug setting up layoutcommit.]
> Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
> [pnfsblock: prevent commit list corruption]
> [pnfsblock: fix layoutcommit with an empty opaque]
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |    2 +
>  fs/nfs/blocklayout/blocklayout.h |   12 +++
>  fs/nfs/blocklayout/extents.c     |  176 ++++++++++++++++++++++++++++----------
>  fs/nfs/nfs4proc.c                |    2 +-
>  fs/nfs/pnfs.c                    |    8 +-
>  fs/nfs/pnfs.h                    |    6 +-
>  6 files changed, 152 insertions(+), 54 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index c8db55e..e409f63 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -155,6 +155,8 @@ static void
>  bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
>  		       const struct nfs4_layoutcommit_args *arg)
>  {
> +	dprintk("%s enter\n", __func__);
> +	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
>  }
>  
>  static void
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index c002aa2..de908da 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -91,6 +91,15 @@ struct pnfs_block_extent {
>  	struct pnfs_inval_markings *be_inval; /* tracks INVAL->RW transition */
>  };
>  
> +/* Shortened extent used by LAYOUTCOMMIT */
> +struct pnfs_block_short_extent {
> +	struct list_head bse_node;
> +	struct nfs4_deviceid bse_devid;
> +	struct block_device *bse_mdev;
> +	sector_t	bse_f_offset;	/* the starting offset in the file */
> +	sector_t	bse_length;	/* the size of the extent */
> +};
> +
>  static inline void
>  INIT_INVAL_MARKS(struct pnfs_inval_markings *marks, sector_t blocksize)
>  {
> @@ -185,6 +194,9 @@ void bl_put_extent(struct pnfs_block_extent *be);
>  struct pnfs_block_extent *alloc_extent(void);
>  struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
>  int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
> +int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
> +				   struct xdr_stream *xdr,
> +				   const struct nfs4_layoutcommit_args *arg);
>  int bl_add_merge_extent(struct pnfs_block_layout *bl,
>  			 struct pnfs_block_extent *new);
>  
> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> index 7beae7c..b46c8be 100644
> --- a/fs/nfs/blocklayout/extents.c
> +++ b/fs/nfs/blocklayout/extents.c
> @@ -286,6 +286,49 @@ int bl_mark_sectors_init(struct pnfs_inval_markings *marks,
>  	return -ENOMEM;
>  }
>  
> +/* Marks sectors in [offest, offset+length) as having been written to disk.
> + * All lengths should be block aligned.
> + */
> +int mark_written_sectors(struct pnfs_inval_markings *marks,
> +			 sector_t offset, sector_t length)

Also needs a prefix or 'static' declaration

> +
> +void print_clist(struct list_head *list, unsigned int count)

Ditto.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

