Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35121 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbC0RFQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:05:16 -0400
Received: by igcau2 with SMTP id au2so25939435igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:05:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: File unlock needs to be a metadata synchronisation point
Date: Fri, 27 Mar 2015 13:05:12 -0400
Message-Id: <1427475913-14626-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1427475913-14626-1-git-send-email-trond.myklebust@primarydata.com>
References: <1427475913-14626-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

File unlock needs to update both data and metadata on the NFS server
in order to act as a synchronisation point for other clients.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e679d24c39d3..6959cb76744b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -780,7 +780,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * Flush all pending writes before doing anything
 	 * with locks..
 	 */
-	nfs_sync_mapping(filp->f_mapping);
+	vfs_fsync(filp, 0);
 
 	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
-- 
2.1.0

