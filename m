Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507Ab2D3SAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:00:43 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/3] NFS: O_DIRECT pgio_completion_ops error_cleanup must unlock the request
Date: Mon, 30 Apr 2012 14:00:40 -0400
Message-Id: <1335808841-11623-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335808841-11623-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335808841-11623-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5ce5c6b..450ba54 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -292,7 +292,7 @@ out_put:
 	hdr->release(hdr);
 }
 
-static void nfs_sync_pgio_error(struct list_head *head)
+static void nfs_read_sync_pgio_error(struct list_head *head)
 {
 	struct nfs_page *req;
 
@@ -309,7 +309,7 @@ static void nfs_direct_pgio_init(struct nfs_pgio_header *hdr)
 }
 
 static const struct nfs_pgio_completion_ops nfs_direct_read_completion_ops = {
-	.error_cleanup = nfs_sync_pgio_error,
+	.error_cleanup = nfs_read_sync_pgio_error,
 	.init_hdr = nfs_direct_pgio_init,
 	.completion = nfs_direct_read_completion,
 };
@@ -772,8 +772,20 @@ out_put:
 	hdr->release(hdr);
 }
 
+static void nfs_write_sync_pgio_error(struct list_head *head)
+{
+	struct nfs_page *req;
+
+	while (!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		nfs_release_request(req);
+		nfs_unlock_request(req);
+	}
+}
+
 static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops = {
-	.error_cleanup = nfs_sync_pgio_error,
+	.error_cleanup = nfs_write_sync_pgio_error,
 	.init_hdr = nfs_direct_pgio_init,
 	.completion = nfs_direct_write_completion,
 };
-- 
1.7.7.6

