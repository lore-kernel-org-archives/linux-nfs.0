Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61B0CC282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 17:37:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3D42C20815
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 17:37:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726585AbfBDRhi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 12:37:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:38544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725992AbfBDRhi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 12:37:38 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 650973DE2F;
        Mon,  4 Feb 2019 17:37:37 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 4903567155;
        Mon,  4 Feb 2019 17:37:36 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@gmail.com>
Cc:     "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFS: Fix up return value on fatal errors in
 nfs_page_async_flush()
Date:   Mon, 04 Feb 2019 12:37:34 -0500
Message-ID: <D5A56EB5-2D62-48AA-A453-EEE93359A9DD@redhat.com>
In-Reply-To: <20190129205255.12467-1-trond.myklebust@hammerspace.com>
References: <20190129205255.12467-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 04 Feb 2019 17:37:37 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 29 Jan 2019, at 15:52, Trond Myklebust wrote:

> Ensure that we return the fatal error value that caused us to exit
> nfs_page_async_flush().
>
> Fixes: c373fff7bd25 ("NFSv4: Don't special case "launder"")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> Cc: stable@vger.kernel.org # v4.12+
> Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/write.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 5a0bbf917a32..f12cb31a41e5 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -621,11 +621,12 @@ static int nfs_page_async_flush(struct 
> nfs_pageio_descriptor *pgio,
>  	nfs_set_page_writeback(page);
>  	WARN_ON_ONCE(test_bit(PG_CLEAN, &req->wb_flags));
>
> -	ret = 0;
> +	ret = req->wb_context->error;
>  	/* If there is a fatal error that covers this write, just exit */
> -	if (nfs_error_is_fatal_on_server(req->wb_context->error))
> +	if (nfs_error_is_fatal_on_server(ret))
>  		goto out_launder;
>
> +	ret = 0;
>  	if (!nfs_pageio_add_request(pgio, req)) {
>  		ret = pgio->pg_error;
>  		/*
> @@ -635,9 +636,9 @@ static int nfs_page_async_flush(struct 
> nfs_pageio_descriptor *pgio,
>  			nfs_context_set_write_error(req->wb_context, ret);
>  			if (nfs_error_is_fatal_on_server(ret))
>  				goto out_launder;
> -		}
> +		} else
> +			ret = -EAGAIN;
>  		nfs_redirty_request(req);
> -		ret = -EAGAIN;
>  	} else
>  		nfs_add_stats(page_file_mapping(page)->host,
>  				NFSIOS_WRITEPAGES, 1);

Hi Trond,

There's another problem with this one - nfs_updatepage() will try to
nfs_set_pageerror() and dereference a NULL page->mapping.

I think nfs_zap_mapping() only needs the inode, so can use 
inode->i_mapping
to check the number of pages..  I'm testing something like the below.  I
just want to bring it up early since we're late in the cycle.

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6bf4471850c8..eb8adceb9962 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -671,7 +671,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t 
*desc, struct page* page)

  	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, 
-1) < 0) {
  		/* Should never happen */
-		nfs_zap_mapping(inode, inode->i_mapping);
+		nfs_zap_mapping(inode);
  	}
  	unlock_page(page);
  	return 0;
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 33824a0a57bf..9ef96c7a5826 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -758,7 +758,7 @@ static void nfs_direct_write_schedule_work(struct 
work_struct *work)
  			nfs_direct_write_reschedule(dreq);
  			break;
  		default:
-			nfs_zap_mapping(dreq->inode, dreq->inode->i_mapping);
+			nfs_zap_mapping(dreq->inode);
  			nfs_direct_complete(dreq);
  	}
  }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 094775ea0781..e56e05984a01 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -247,9 +247,9 @@ void nfs_zap_caches(struct inode *inode)
  	spin_unlock(&inode->i_lock);
  }

-void nfs_zap_mapping(struct inode *inode, struct address_space 
*mapping)
+void nfs_zap_mapping(struct inode *inode)
  {
-	if (mapping->nrpages != 0) {
+	if (inode->i_mapping->nrpages != 0) {
  		spin_lock(&inode->i_lock);
  		nfs_set_cache_invalid(inode, NFS_INO_INVALID_DATA);
  		spin_unlock(&inode->i_lock);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f12cb31a41e5..609bea7e2434 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -237,12 +237,6 @@ static void nfs_grow_file(struct page *page, 
unsigned int offset, unsigned int c
  	spin_unlock(&inode->i_lock);
  }

-/* A writeback failed: mark the page as bad, and invalidate the page 
cache */
-static void nfs_set_pageerror(struct page *page)
-{
-	nfs_zap_mapping(page_file_mapping(page)->host, 
page_file_mapping(page));
-}
-
  /*
   * nfs_page_group_search_locked
   * @head - head request of page group
@@ -994,7 +988,7 @@ static void nfs_write_completion(struct 
nfs_pgio_header *hdr)
  		nfs_list_remove_request(req);
  		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
  		    (hdr->good_bytes < bytes)) {
-			nfs_set_pageerror(req->wb_page);
+			nfs_zap_mapping(hdr->inode);
  			nfs_context_set_write_error(req->wb_context, hdr->error);
  			goto remove_req;
  		}
@@ -1366,7 +1360,7 @@ int nfs_updatepage(struct file *file, struct page 
*page,

  	status = nfs_writepage_setup(ctx, page, offset, count);
  	if (status < 0)
-		nfs_set_pageerror(page);
+		nfs_zap_mapping(file_inode(file));
  	else
  		__set_page_dirty_nobuffers(page);
  out:
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 40e30376130b..6afd64d140f2 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -364,7 +364,7 @@ static inline int nfs_verify_change_attribute(struct 
inode *dir, unsigned long c
   * linux/fs/nfs/inode.c
   */
  extern int nfs_sync_mapping(struct address_space *mapping);
-extern void nfs_zap_mapping(struct inode *inode, struct address_space 
*mapping);
+extern void nfs_zap_mapping(struct inode *inode);
  extern void nfs_zap_caches(struct inode *);
  extern void nfs_invalidate_atime(struct inode *);
  extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,

Ben
