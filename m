Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:64903 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932571AbaEST5d convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 15:57:33 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so3964538igq.4
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 12:57:32 -0700 (PDT)
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 6/8] pnfs: clean up *_resend_to_mds
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <537A5ABA.7070808@gmail.com>
Date: Mon, 19 May 2014 15:57:28 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <34BC8072-B48A-42E9-95F8-AC698231874C@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com> <1400512508-7530-7-git-send-email-dros@primarydata.com> <537A5ABA.7070808@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2014, at 3:25 PM, Anna Schumaker <schumaker.anna@gmail.com> wrote:

> On 05/19/2014 11:15 AM, Weston Andros Adamson wrote:
>> Clean up pnfs_read_done_resend_to_mds and pnfs_write_done_resend_to_mds:
>> - instead of passing all arguments from a nfs_pgio_header, just pass the header
>> - share the common code
>> 
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>> ---
>> fs/nfs/nfs4filelayout.c  | 10 ++------
>> fs/nfs/pagelist.c        | 32 +++++++++++++++++++++++++
>> fs/nfs/pnfs.c            | 62 +++++++-----------------------------------------
>> fs/nfs/pnfs.h            |  8 ++-----
>> include/linux/nfs_page.h |  2 ++
>> 5 files changed, 47 insertions(+), 67 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index e7f21b4..37e0b65 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -97,10 +97,7 @@ static void filelayout_reset_write(struct nfs_pgio_header *hdr)
>> 			hdr->args.count,
>> 			(unsigned long long)hdr->args.offset);
>> 
>> -		task->tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
>> -							&hdr->pages,
>> -							hdr->completion_ops,
>> -							hdr->dreq);
>> +		task->tk_status = pnfs_write_done_resend_to_mds(hdr);
>> 	}
>> }
>> 
>> @@ -117,10 +114,7 @@ static void filelayout_reset_read(struct nfs_pgio_header *hdr)
>> 			hdr->args.count,
>> 			(unsigned long long)hdr->args.offset);
>> 
>> -		task->tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
>> -							&hdr->pages,
>> -							hdr->completion_ops,
>> -							hdr->dreq);
>> +		task->tk_status = pnfs_read_done_resend_to_mds(hdr);
>> 	}
>> }
>> 
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index 8f029ed..0fcd34a 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -945,6 +945,38 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>> }
>> EXPORT_SYMBOL_GPL(nfs_pageio_add_request);
>> 
>> +/*
>> + * nfs_pageio_resend - Transfer requests to new descriptor and resend
>> + * @hdr - the pgio header to move request from
>> + * @desc - the pageio descriptor to add requests to
>> + *
>> + * Try to move each request (nfs_page) from @hdr to @desc then attempt
>> + * to send them.
>> + *
>> + * Returns 0 on success and < 0 on error.
>> + */
>> +int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
>> +		      struct nfs_pgio_header *hdr)
>> +{
>> +	LIST_HEAD(failed);
>> +
>> +	desc->pg_dreq = hdr->dreq;
>> +	while (!list_empty(&hdr->pages)) {
>> +		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
>> +
>> +		nfs_list_remove_request(req);
>> +		if (!nfs_pageio_add_request(desc, req))
>> +			nfs_list_add_request(req, &failed);
>> +	}
>> +	nfs_pageio_complete(desc);
>> +	if (!list_empty(&failed)) {
>> +		list_move(&failed, &hdr->pages);
>> +		return -EIO;
>> +	}
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(nfs_pageio_resend);
>> +
>> /**
>>  * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
>>  * @desc: pointer to io descriptor
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 902783ab..79792a4 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1466,35 +1466,14 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>> }
>> EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
>> 
>> -int pnfs_write_done_resend_to_mds(struct inode *inode,
>> -				struct list_head *head,
>> -				const struct nfs_pgio_completion_ops *compl_ops,
>> -				struct nfs_direct_req *dreq)
>> +int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *hdr)
>> {
>> 	struct nfs_pageio_descriptor pgio;
>> -	LIST_HEAD(failed);
>> 
>> 	/* Resend all requests through the MDS */
>> -	nfs_pageio_init_write(&pgio, inode, FLUSH_STABLE, true, compl_ops);
>> -	pgio.pg_dreq = dreq;
>> -	while (!list_empty(head)) {
>> -		struct nfs_page *req = nfs_list_entry(head->next);
>> -
>> -		nfs_list_remove_request(req);
>> -		if (!nfs_pageio_add_request(&pgio, req))
>> -			nfs_list_add_request(req, &failed);
>> -	}
>> -	nfs_pageio_complete(&pgio);
>> -
>> -	if (!list_empty(&failed)) {
>> -		/* For some reason our attempt to resend pages. Mark the
>> -		 * overall send request as having failed, and let
>> -		 * nfs_writeback_release_full deal with the error.
>> -		 */
>> -		list_move(&failed, head);
>> -		return -EIO;
>> -	}
>> -	return 0;
>> +	nfs_pageio_init_write(&pgio, hdr->inode, FLUSH_STABLE, true,
>> +			      hdr->completion_ops);
>> +	return nfs_pageio_resend(&pgio, hdr);
>> }
>> EXPORT_SYMBOL_GPL(pnfs_write_done_resend_to_mds);
>> 
>> @@ -1507,10 +1486,7 @@ static void pnfs_ld_handle_write_error(struct nfs_pgio_header *hdr)
>> 		pnfs_return_layout(hdr->inode);
>> 	}
>> 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
>> -		hdr->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
>> -							&hdr->pages,
>> -							hdr->completion_ops,
>> -							hdr->dreq);
>> +		hdr->task.tk_status = pnfs_write_done_resend_to_mds(hdr);
>> }
>> 
>> /*
>> @@ -1608,30 +1584,13 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>> }
>> EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
>> 
>> -int pnfs_read_done_resend_to_mds(struct inode *inode,
>> -				struct list_head *head,
>> -				const struct nfs_pgio_completion_ops *compl_ops,
>> -				struct nfs_direct_req *dreq)
>> +int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *hdr)
>> {
>> 	struct nfs_pageio_descriptor pgio;
>> -	LIST_HEAD(failed);
>> 
>> 	/* Resend all requests through the MDS */
>> -	nfs_pageio_init_read(&pgio, inode, true, compl_ops);
>> -	pgio.pg_dreq = dreq;
>> -	while (!list_empty(head)) {
>> -		struct nfs_page *req = nfs_list_entry(head->next);
>> -
>> -		nfs_list_remove_request(req);
>> -		if (!nfs_pageio_add_request(&pgio, req))
>> -			nfs_list_add_request(req, &failed);
>> -	}
>> -	nfs_pageio_complete(&pgio);
>> -
>> -	if (!list_empty(&failed)) {
>> -		list_move(&failed, head);
>> -		return -EIO;
>> -	}
>> +	nfs_pageio_init_read(&pgio, hdr->inode, true, hdr->completion_ops);
>> +	nfs_pageio_resend(&pgio, hdr);
>> 	return 0;
>> }
> 
> Write returns the value of nfs_pageio_resend().  Why does read always return 0?
> 
> Anna

Good catch! Thanks!

-dros

>> EXPORT_SYMBOL_GPL(pnfs_read_done_resend_to_mds);
>> @@ -1644,10 +1603,7 @@ static void pnfs_ld_handle_read_error(struct nfs_pgio_header *hdr)
>> 		pnfs_return_layout(hdr->inode);
>> 	}
>> 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
>> -		hdr->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
>> -							&hdr->pages,
>> -							hdr->completion_ops,
>> -							hdr->dreq);
>> +		hdr->task.tk_status = pnfs_read_done_resend_to_mds(hdr);
>> }
>> 
>> /*
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index f385afa..552b2e9 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -228,12 +228,8 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
>> 					       gfp_t gfp_flags);
>> 
>> void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
>> -int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head,
>> -			const struct nfs_pgio_completion_ops *compl_ops,
>> -			struct nfs_direct_req *dreq);
>> -int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *head,
>> -			const struct nfs_pgio_completion_ops *compl_ops,
>> -			struct nfs_direct_req *dreq);
>> +int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
>> +int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
>> struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
>> 
>> /* nfs4_deviceid_flags */
>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>> index d0fae7b..4b48548 100644
>> --- a/include/linux/nfs_page.h
>> +++ b/include/linux/nfs_page.h
>> @@ -112,6 +112,8 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>> 			     int how);
>> extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
>> 				   struct nfs_page *);
>> +extern  int nfs_pageio_resend(struct nfs_pageio_descriptor *,
>> +			      struct nfs_pgio_header *);
>> extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
>> extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
>> extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
> 

