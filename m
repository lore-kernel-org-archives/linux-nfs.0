Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:35251 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab1HDEza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 00:55:30 -0400
Message-ID: <4E3A263A.2020707@panasas.com>
Date: Wed, 3 Aug 2011 21:55:22 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-obj: Fix the comp_index != 0 case
References: <1312082377.10882.1.camel@lade.trondhjem.org> <4E39DF02.80306@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A8AA600@SACMVEXC2-PRD.hq.netapp.com> <4E3A25A3.7020804@panasas.com>
In-Reply-To: <4E3A25A3.7020804@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Opps:  [PATCH 2/2] pnfs-obj: Fix the comp_index != 0 case

Thanks

On 08/03/2011 09:52 PM, Boaz Harrosh wrote:
> 
> There were bugs in the case of partial layout where olo_comp_index
> is not zero. This used to work and was tested but one of the later
> cleanup SQUASHMEs broke it and was not tested since.
> 
> Also add a dprint that specify those received layout parameters.
> Everything else was already printed.
> 
> [Needed in v3.0]
> CC: Stable Tree <stable@kernel.org>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objio_osd.c        |   16 +++++++---------
>  fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    3 +++
>  2 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index aa8663a..d0cda12 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -479,7 +479,6 @@ static int _io_check(struct objio_state *ios, bool is_write)
>  	for (i = 0; i <  ios->numdevs; i++) {
>  		struct osd_sense_info osi;
>  		struct osd_request *or = ios->per_dev[i].or;
> -		unsigned dev;
>  		int ret;
>  
>  		if (!or)
> @@ -500,9 +499,8 @@ static int _io_check(struct objio_state *ios, bool is_write)
>  
>  			continue; /* we recovered */
>  		}
> -		dev = ios->per_dev[i].dev;
> -		objlayout_io_set_result(&ios->ol_state, dev,
> -					&ios->layout->comps[dev].oc_object_id,
> +		objlayout_io_set_result(&ios->ol_state, i,
> +					&ios->layout->comps[i].oc_object_id,
>  					osd_pri_2_pnfs_err(osi.osd_err_pri),
>  					ios->per_dev[i].offset,
>  					ios->per_dev[i].length,
> @@ -648,7 +646,7 @@ static int _prepare_one_group(struct objio_state *ios, u64 length,
>  	int ret = 0;
>  
>  	while (length) {
> -		struct _objio_per_comp *per_dev = &ios->per_dev[dev];
> +		struct _objio_per_comp *per_dev = &ios->per_dev[dev - first_dev];
>  		unsigned cur_len, page_off = 0;
>  
>  		if (!per_dev->length) {
> @@ -668,8 +666,8 @@ static int _prepare_one_group(struct objio_state *ios, u64 length,
>  				cur_len = stripe_unit;
>  			}
>  
> -			if (max_comp < dev)
> -				max_comp = dev;
> +			if (max_comp < dev - first_dev)
> +				max_comp = dev - first_dev;
>  		} else {
>  			cur_len = stripe_unit;
>  		}
> @@ -804,7 +802,7 @@ static int _read_mirrors(struct objio_state *ios, unsigned cur_comp)
>  	struct _objio_per_comp *per_dev = &ios->per_dev[cur_comp];
>  	unsigned dev = per_dev->dev;
>  	struct pnfs_osd_object_cred *cred =
> -			&ios->layout->comps[dev];
> +			&ios->layout->comps[cur_comp];
>  	struct osd_obj_id obj = {
>  		.partition = cred->oc_object_id.oid_partition_id,
>  		.id = cred->oc_object_id.oid_object_id,
> @@ -902,7 +900,7 @@ static int _write_mirrors(struct objio_state *ios, unsigned cur_comp)
>  	for (; cur_comp < last_comp; ++cur_comp, ++dev) {
>  		struct osd_request *or = NULL;
>  		struct pnfs_osd_object_cred *cred =
> -					&ios->layout->comps[dev];
> +					&ios->layout->comps[cur_comp];
>  		struct osd_obj_id obj = {
>  			.partition = cred->oc_object_id.oid_partition_id,
>  			.id = cred->oc_object_id.oid_object_id,
> diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> index 16fc758..b3918f7 100644
> --- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> +++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> @@ -170,6 +170,9 @@ int pnfs_osd_xdr_decode_layout_map(struct pnfs_osd_layout *layout,
>  	p = _osd_xdr_decode_data_map(p, &layout->olo_map);
>  	layout->olo_comps_index = be32_to_cpup(p++);
>  	layout->olo_num_comps = be32_to_cpup(p++);
> +	dprintk("%s: olo_comps_index=%d olo_num_comps=%d\n", __func__,
> +		layout->olo_comps_index, layout->olo_num_comps);
> +
>  	iter->total_comps = layout->olo_num_comps;
>  	return 0;
>  }

