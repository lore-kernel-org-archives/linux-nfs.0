Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22627C282CC
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 18:13:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 018A12175B
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 18:13:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728765AbfBDSNQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 13:13:16 -0500
Received: from mx1.redhat.com ([209.132.183.28]:50148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727917AbfBDSNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 13:13:16 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9AFD6C04F4AE;
        Mon,  4 Feb 2019 18:13:15 +0000 (UTC)
Received: from bcodding.csb (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 413818A29B;
        Mon,  4 Feb 2019 18:13:15 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id D4BAF10C30F3; Mon,  4 Feb 2019 13:13:14 -0500 (EST)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't use page_file_mapping after removing the page
Date:   Mon,  4 Feb 2019 13:13:14 -0500
Message-Id: <b85247642d77ea12153d042a4dce85b94d7624ca.1549303962.git.bcodding@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 04 Feb 2019 18:13:15 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If nfs_page_async_flush() removes the page from the mapping, then we can't
use page_file_mapping() on it as nfs_updatepate() is wont to do when
receiving an error.  Instead, simplify nfs_zap_mapping() to take the inode.

Fixes: 8fc75bed96bb ("NFS: Fix up return value on fatal errors in nfs_page_async_flush()")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c           |  2 +-
 fs/nfs/direct.c        |  2 +-
 fs/nfs/inode.c         |  4 ++--
 fs/nfs/write.c         | 10 ++--------
 include/linux/nfs_fs.h |  2 +-
 5 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6bf4471850c8..eb8adceb9962 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -671,7 +671,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 
 	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
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
@@ -758,7 +758,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
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
 
-void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
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
@@ -237,12 +237,6 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 	spin_unlock(&inode->i_lock);
 }
 
-/* A writeback failed: mark the page as bad, and invalidate the page cache */
-static void nfs_set_pageerror(struct page *page)
-{
-	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
-}
-
 /*
  * nfs_page_group_search_locked
  * @head - head request of page group
@@ -994,7 +988,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 		nfs_list_remove_request(req);
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
 		    (hdr->good_bytes < bytes)) {
-			nfs_set_pageerror(req->wb_page);
+			nfs_zap_mapping(hdr->inode);
 			nfs_context_set_write_error(req->wb_context, hdr->error);
 			goto remove_req;
 		}
@@ -1366,7 +1360,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 
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
@@ -364,7 +364,7 @@ static inline int nfs_verify_change_attribute(struct inode *dir, unsigned long c
  * linux/fs/nfs/inode.c
  */
 extern int nfs_sync_mapping(struct address_space *mapping);
-extern void nfs_zap_mapping(struct inode *inode, struct address_space *mapping);
+extern void nfs_zap_mapping(struct inode *inode);
 extern void nfs_zap_caches(struct inode *);
 extern void nfs_invalidate_atime(struct inode *);
 extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
-- 
2.14.3

