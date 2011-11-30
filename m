Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62708 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1K3NBJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 08:01:09 -0500
Received: by bkas6 with SMTP id s6so839408bka.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 05:01:07 -0800 (PST)
Message-ID: <4ED6290F.4020407@tonian.com>
Date: Wed, 30 Nov 2011 15:01:03 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH 3/4] nfsv41: get lseg before issue LD IO if pgio doesn't
 carry lseg
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com> <1322887965-2938-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1322887965-2938-4-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-03 06:52, Peng Tao wrote:
> This gives LD option not to ask for layout in pg_init.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/pnfs.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 46 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 734e670..c8dc0b1 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1254,6 +1254,7 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
>  	struct nfs_write_data *data;
>  	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
>  	struct pnfs_layout_segment *lseg = desc->pg_lseg;
> +	const bool has_lseg = !!lseg;

nit: "has_lseg = (lseg != NULL)" would be more straight forward IMO

>  
>  	desc->pg_lseg = NULL;
>  	while (!list_empty(head)) {
> @@ -1262,7 +1263,29 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
>  		data = list_entry(head->next, struct nfs_write_data, list);
>  		list_del_init(&data->list);
>  
> +		if (!has_lseg) {
> +			struct nfs_page *req = nfs_list_entry(data->pages.next);
> +			__u64 length = data->npages << PAGE_CACHE_SHIFT;
> +
> +			lseg = pnfs_update_layout(desc->pg_inode,
> +						  req->wb_context,
> +						  req_offset(req),
> +						  length,
> +						  IOMODE_RW,
> +						  GFP_NOFS);
> +			if (!lseg || length > (lseg->pls_range.length)) {

I'm concerned about the 'length' part of this condition.
pnfs_try_to_write_data should handle short writes/reads and
we should be able to iterate through the I/O using different
layout segments.

> +				put_lseg(lseg);
> +				lseg = NULL;
> +				pnfs_write_through_mds(desc,data);
> +				continue;
> +			}
> +		}
> +
>  		trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
> +		if (!has_lseg) {
> +			put_lseg(lseg);
> +			lseg = NULL;
> +		}

We had an implementation in the past that saved the most recent lseg in 'desc'
so it could be used for the remaining requests.  Once exhausted, you can
look for a new one.

>  		if (trypnfs == PNFS_NOT_ATTEMPTED)
>  			pnfs_write_through_mds(desc, data);
>  	}
> @@ -1350,6 +1373,7 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
>  	struct nfs_read_data *data;
>  	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
>  	struct pnfs_layout_segment *lseg = desc->pg_lseg;
> +	const bool has_lseg = !!lseg;

ditto

>  
>  	desc->pg_lseg = NULL;
>  	while (!list_empty(head)) {
> @@ -1358,7 +1382,29 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
>  		data = list_entry(head->next, struct nfs_read_data, list);
>  		list_del_init(&data->list);
>  
> +		if (!has_lseg) {
> +			struct nfs_page *req = nfs_list_entry(data->pages.next);
> +			__u64 length = data->npages << PAGE_CACHE_SHIFT;
> +
> +			lseg = pnfs_update_layout(desc->pg_inode,
> +						  req->wb_context,
> +						  req_offset(req),
> +						  length,
> +						  IOMODE_READ,
> +						  GFP_KERNEL);
> +			if (!lseg || length > lseg->pls_range.length) {
> +				put_lseg(lseg);
> +				lseg = NULL;
> +				pnfs_read_through_mds(desc, data);
> +				continue;
> +			}
> +		}
> +
>  		trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
> +		if (!has_lseg) {
> +			put_lseg(lseg);
> +			lseg = NULL;
> +		}

ditto

Benny

>  		if (trypnfs == PNFS_NOT_ATTEMPTED)
>  			pnfs_read_through_mds(desc, data);
>  	}
