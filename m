From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 08/12] SQUASHME: objio alloc/free lseg Bugs fixes
Date: Tue, 24 May 2011 20:06:24 +0300
Message-ID: <4DDBE590.1080606@panasas.com>
References: <4DDBC611.3050202@panasas.com> <1306249617-23391-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54779 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799Ab1EXRG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 13:06:27 -0400
In-Reply-To: <1306249617-23391-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-05-24 18:06, Boaz Harrosh wrote:
> Wrong allocation and pointering in lseg_alloc.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objio_osd.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index a4201d8..167cd1e 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -117,7 +117,7 @@ struct objio_segment {
>  	unsigned comps_index;
>  	unsigned num_comps;
>  	/* variable length */
> -	struct objio_dev_ent *ods[1];
> +	struct objio_dev_ent *ods[0];
>  };
>  
>  static inline struct objio_segment *
> @@ -278,7 +278,6 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>  	struct pnfs_osd_layout layout;
>  	struct pnfs_osd_object_cred *cur_comp, src_comp;
>  	struct caps_buffers *caps_p;
> -
>  	int err;
>  
>  	err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
> @@ -289,14 +288,16 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>  	if (unlikely(err))
>  		return err;
>  
> -	objio_seg = kzalloc(sizeof(*objio_seg) +
> +	objio_seg = kzalloc(sizeof(*objio_seg) + 

nit: While at it, the trailing space is extraneous...

Benny

> +			    sizeof(objio_seg->ods[0]) * layout.olo_num_comps +
>  			    sizeof(*objio_seg->comps) * layout.olo_num_comps +
>  			    sizeof(struct caps_buffers) * layout.olo_num_comps,
>  			    gfp_flags);
>  	if (!objio_seg)
>  		return -ENOMEM;
>  
> -	cur_comp = objio_seg->comps = (void *)(objio_seg + 1);
> +	objio_seg->comps = (void *)(objio_seg->ods + layout.olo_num_comps);
> +	cur_comp = objio_seg->comps;
>  	caps_p = (void *)(cur_comp + layout.olo_num_comps);
>  	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err))
>  		copy_single_comp(cur_comp++, &src_comp, caps_p++);

