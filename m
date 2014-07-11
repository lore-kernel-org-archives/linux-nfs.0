Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:46803 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744AbaGKOUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 10:20:54 -0400
Received: by mail-ig0-f176.google.com with SMTP id r10so4306167igi.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 07:20:54 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/5] nfs: nfs_page should take a ref on the head req
Date: Fri, 11 Jul 2014 10:20:46 -0400
Message-Id: <1405088449-11268-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1405088449-11268-1-git-send-email-dros@primarydata.com>
References: <1405088449-11268-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_pages that aren't the the head of a group must take a reference on the
head as long as ->wb_head is set to it. This stops the head from hitting
a refcount of 0 while there is still an active nfs_page for the page group.

This avoids kref warnings in the writeback code when the page group head
is found and referenced.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 50e10bb..8b074da 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -239,15 +239,21 @@ nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
 	WARN_ON_ONCE(prev == req);
 
 	if (!prev) {
+		/* a head request */
 		req->wb_head = req;
 		req->wb_this_page = req;
 	} else {
+		/* a subrequest */
 		WARN_ON_ONCE(prev->wb_this_page != prev->wb_head);
 		WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &prev->wb_head->wb_flags));
 		req->wb_head = prev->wb_head;
 		req->wb_this_page = prev->wb_this_page;
 		prev->wb_this_page = req;
 
+		/* All subrequests take a ref on the head request until
+		 * nfs_page_group_destroy is called */
+		kref_get(&req->wb_head->wb_kref);
+
 		/* grab extra ref if head request has extra ref from
 		 * the write/commit path to handle handoff between write
 		 * and commit lists */
@@ -271,6 +277,10 @@ nfs_page_group_destroy(struct kref *kref)
 	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
 	struct nfs_page *tmp, *next;
 
+	/* subrequests must release the ref on the head request */
+	if (req->wb_head != req)
+		nfs_release_request(req->wb_head);
+
 	if (!nfs_page_group_sync_on_bit(req, PG_TEARDOWN))
 		return;
 
-- 
1.8.5.2 (Apple Git-48)

