Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38192 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbdIJVwr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Sep 2017 17:52:47 -0400
Received: by mail-io0-f195.google.com with SMTP id j141so2798953ioj.5
        for <linux-nfs@vger.kernel.org>; Sun, 10 Sep 2017 14:52:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Count the bytes of skipped subrequests in nfs_lock_and_join_requests()
Date: Sun, 10 Sep 2017 17:52:42 -0400
Message-Id: <20170910215242.4212-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170910215242.4212-1-trond.myklebust@primarydata.com>
References: <20170910215242.4212-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we skip a subrequest due to a zero refcount, we should still count
the byte range that it covered so that we accurately reconstruct the
original request size.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 36d34a4c86bd..f68083db63c8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -504,8 +504,12 @@ nfs_lock_and_join_requests(struct page *page)
 	for (subreq = head->wb_this_page; subreq != head;
 			subreq = subreq->wb_this_page) {
 
-		if (!kref_get_unless_zero(&subreq->wb_kref))
+		if (!kref_get_unless_zero(&subreq->wb_kref)) {
+			if (subreq->wb_offset == head->wb_offset + total_bytes)
+				total_bytes += subreq->wb_bytes;
 			continue;
+		}
+
 		while (!nfs_lock_request(subreq)) {
 			/*
 			 * Unlock page to allow nfs_page_group_sync_on_bit()
-- 
2.13.5

