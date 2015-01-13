Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:32771 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbbAMQKQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:10:16 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so17647848igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 08:10:15 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH v3 34/49] pnfs: pass ds_commit_idx through the commit path
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <54B53BD0.9000006@Netapp.com>
Date: Tue, 13 Jan 2015 11:10:13 -0500
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <ACAB31F9-E203-4802-8A59-B76674F6AB09@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <1420590534-84063-35-git-send-email-loghyr@primarydata.com> <54B53BD0.9000006@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 13, 2015, at 10:37 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> Hi Dros,
> 
> On 01/06/2015 07:28 PM, Tom Haynes wrote:
>> From: Weston Andros Adamson <dros@primarydata.com>
>> 
>> Pass ds_commit_idx through the nfs commit path. It's used to select
>> the commit bucket when using pnfs and is ignored when not using pnfs.
>> Several functions had to be changed: nfs_retry_commit,
>> nfs_mark_request_commit, pnfs_mark_request_commit and the pnfs layout
>> driver .mark_request_commit functions.
> 
> We're already passing the struct nfs_commit_info everywhere with these functions.  Would it make sense to add ds_commit_index as another field in the commit info?

That might work. I kind of remember there being a reason that it wouldn’t work,
but I can’t think of it now.

I should have some time later this week to give it a shot.

-dros

> 
>> 
>> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
>> ---
>> fs/nfs/direct.c                |  5 +++--
>> fs/nfs/filelayout/filelayout.c |  3 ++-
>> fs/nfs/internal.h              |  6 ++++--
>> fs/nfs/pnfs.h                  |  9 +++++----
>> fs/nfs/pnfs_nfsio.c            |  4 ++--
>> fs/nfs/write.c                 | 14 ++++++++------
>> 6 files changed, 24 insertions(+), 17 deletions(-)
>> 
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index d7c2d43..1ee41d7 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -649,7 +649,7 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
>> 		nfs_list_remove_request(req);
>> 		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
>> 			/* Note the rewrite will go through mds */
>> -			nfs_mark_request_commit(req, NULL, &cinfo);
>> +			nfs_mark_request_commit(req, NULL, &cinfo, 0);
>> 		} else
>> 			nfs_release_request(req);
>> 		nfs_unlock_and_release_request(req);
>> @@ -748,7 +748,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>> 		nfs_list_remove_request(req);
>> 		if (request_commit) {
>> 			kref_get(&req->wb_kref);
>> -			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
>> +			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
>> +				hdr->ds_commit_idx);
>> 		}
>> 		nfs_unlock_and_release_request(req);
>> 	}
>> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
>> index 520cbc5..3c97694 100644
>> --- a/fs/nfs/filelayout/filelayout.c
>> +++ b/fs/nfs/filelayout/filelayout.c
>> @@ -954,7 +954,8 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
>> static void
>> filelayout_mark_request_commit(struct nfs_page *req,
>> 			       struct pnfs_layout_segment *lseg,
>> -			       struct nfs_commit_info *cinfo)
>> +			       struct nfs_commit_info *cinfo,
>> +			       u32 ds_commit_idx)
>> 
>> {
>> 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index e9305e9..05f9a87 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -450,13 +450,15 @@ int nfs_scan_commit(struct inode *inode, struct list_head *dst,
>> 		    struct nfs_commit_info *cinfo);
>> void nfs_mark_request_commit(struct nfs_page *req,
>> 			     struct pnfs_layout_segment *lseg,
>> -			     struct nfs_commit_info *cinfo);
>> +			     struct nfs_commit_info *cinfo,
>> +			     u32 ds_commit_idx);
>> int nfs_write_need_commit(struct nfs_pgio_header *);
>> int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
>> 			    int how, struct nfs_commit_info *cinfo);
>> void nfs_retry_commit(struct list_head *page_list,
>> 		      struct pnfs_layout_segment *lseg,
>> -		      struct nfs_commit_info *cinfo);
>> +		      struct nfs_commit_info *cinfo,
>> +		      u32 ds_commit_idx);
>> void nfs_commitdata_release(struct nfs_commit_data *data);
>> void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
>> 				 struct nfs_commit_info *cinfo);
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index d3cbb6e..ebb4e82 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -137,7 +137,8 @@ struct pnfs_layoutdriver_type {
>> 	struct pnfs_ds_commit_info *(*get_ds_info) (struct inode *inode);
>> 	void (*mark_request_commit) (struct nfs_page *req,
>> 				     struct pnfs_layout_segment *lseg,
>> -				     struct nfs_commit_info *cinfo);
>> +				     struct nfs_commit_info *cinfo,
>> +				     u32 ds_commit_idx);
>> 	void (*clear_request_commit) (struct nfs_page *req,
>> 				      struct nfs_commit_info *cinfo);
>> 	int (*scan_commit_lists) (struct nfs_commit_info *cinfo,
>> @@ -388,14 +389,14 @@ pnfs_generic_mark_devid_invalid(struct nfs4_deviceid_node *node)
>> 
>> static inline bool
>> pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
>> -			 struct nfs_commit_info *cinfo)
>> +			 struct nfs_commit_info *cinfo, u32 ds_commit_idx)
>> {
>> 	struct inode *inode = req->wb_context->dentry->d_inode;
>> 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
>> 
>> 	if (lseg == NULL || ld->mark_request_commit == NULL)
>> 		return false;
>> -	ld->mark_request_commit(req, lseg, cinfo);
>> +	ld->mark_request_commit(req, lseg, cinfo, ds_commit_idx);
>> 	return true;
>> }
>> 
>> @@ -573,7 +574,7 @@ pnfs_get_ds_info(struct inode *inode)
>> 
>> static inline bool
>> pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
>> -			 struct nfs_commit_info *cinfo)
>> +			 struct nfs_commit_info *cinfo, u32 ds_commit_idx)
>> {
>> 	return false;
>> }
>> diff --git a/fs/nfs/pnfs_nfsio.c b/fs/nfs/pnfs_nfsio.c
>> index c6c3efc..842258e 100644
>> --- a/fs/nfs/pnfs_nfsio.c
>> +++ b/fs/nfs/pnfs_nfsio.c
>> @@ -183,7 +183,7 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
>> 		bucket = &fl_cinfo->buckets[i];
>> 		if (list_empty(&bucket->committing))
>> 			continue;
>> -		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
>> +		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo, i);
>> 		spin_lock(cinfo->lock);
>> 		freeme = bucket->clseg;
>> 		bucket->clseg = NULL;
>> @@ -242,7 +242,7 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
>> 			list_add(&data->pages, &list);
>> 			nreq++;
>> 		} else {
>> -			nfs_retry_commit(mds_pages, NULL, cinfo);
>> +			nfs_retry_commit(mds_pages, NULL, cinfo, 0);
>> 			pnfs_generic_retry_commit(cinfo, 0);
>> 			cinfo->completion_ops->error_cleanup(NFS_I(inode));
>> 			return -ENOMEM;
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index a6eadac..db802d9 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -847,9 +847,9 @@ EXPORT_SYMBOL_GPL(nfs_init_cinfo);
>>  */
>> void
>> nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
>> -			struct nfs_commit_info *cinfo)
>> +			struct nfs_commit_info *cinfo, u32 ds_commit_idx)
>> {
>> -	if (pnfs_mark_request_commit(req, lseg, cinfo))
>> +	if (pnfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx))
>> 		return;
>> 	nfs_request_add_commit_list(req, &cinfo->mds->list, cinfo);
>> }
>> @@ -905,7 +905,8 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
>> 		}
>> 		if (nfs_write_need_commit(hdr)) {
>> 			memcpy(&req->wb_verf, &hdr->verf.verifier, sizeof(req->wb_verf));
>> -			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
>> +			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
>> +				0);
>> 			goto next;
>> 		}
>> remove_req:
>> @@ -1561,14 +1562,15 @@ EXPORT_SYMBOL_GPL(nfs_init_commit);
>> 
>> void nfs_retry_commit(struct list_head *page_list,
>> 		      struct pnfs_layout_segment *lseg,
>> -		      struct nfs_commit_info *cinfo)
>> +		      struct nfs_commit_info *cinfo,
>> +		      u32 ds_commit_idx)
>> {
>> 	struct nfs_page *req;
>> 
>> 	while (!list_empty(page_list)) {
>> 		req = nfs_list_entry(page_list->next);
>> 		nfs_list_remove_request(req);
>> -		nfs_mark_request_commit(req, lseg, cinfo);
>> +		nfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx);
>> 		if (!cinfo->dreq) {
>> 			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>> 			dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
>> @@ -1599,7 +1601,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
>> 	return nfs_initiate_commit(NFS_CLIENT(inode), data, NFS_PROTO(inode),
>> 				   data->mds_ops, how, 0);
>>  out_bad:
>> -	nfs_retry_commit(head, NULL, cinfo);
>> +	nfs_retry_commit(head, NULL, cinfo, 0);
>> 	cinfo->completion_ops->error_cleanup(NFS_I(inode));
>> 	return -ENOMEM;
>> }
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

