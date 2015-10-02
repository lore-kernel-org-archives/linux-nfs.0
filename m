Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33842 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbbJBO6C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 10:58:02 -0400
Received: by iow1 with SMTP id 1so85562890iow.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2015 07:58:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix up page writeback accounting
Date: Fri,  2 Oct 2015 10:57:59 -0400
Message-Id: <1443797879-4525-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we are crediting all the calls to nfs_writepages_callback()
(i.e. the nfs_writepages() callback) to nfs_writepage(). Aside from
being inconsistent with the behaviour of the equivalent readpage/readpages
accounting, this also means that we cannot distinguish between bulk writes
and single page writebacks (which confuses the 'nfsiostat -p' tool).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 72624dc4a623..cfa47761a8ce 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -569,19 +569,17 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	if (!nfs_pageio_add_request(pgio, req)) {
 		nfs_redirty_request(req);
 		ret = pgio->pg_error;
-	}
+	} else
+		nfs_add_stats(page_file_mapping(page)->host,
+				NFSIOS_WRITEPAGES, 1);
 out:
 	return ret;
 }
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
-	struct inode *inode = page_file_mapping(page)->host;
 	int ret;
 
-	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
-	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
-
 	nfs_pageio_cond_complete(pgio, page_file_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
 	if (ret == -EAGAIN) {
@@ -597,9 +595,11 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, st
 static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc)
 {
 	struct nfs_pageio_descriptor pgio;
+	struct inode *inode = page_file_mapping(page)->host;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc),
+	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
+	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc),
 				false, &nfs_async_write_completion_ops);
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
-- 
2.4.3

