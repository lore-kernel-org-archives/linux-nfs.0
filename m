Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32740 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab2D3Sab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:30:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, iisaman@netapp.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2] NFS: Define dummy nfs_init_cinfo() and nfs_init_cinfo_from_inode()
Date: Mon, 30 Apr 2012 14:30:22 -0400
Message-Id: <1335810622-32127-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These are needed when v3 and v4 are not enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/write.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3636191..2f80aa5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -567,6 +567,17 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 }
 
 #else
+static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
+				      struct inode *inode)
+{
+}
+
+void nfs_init_cinfo(struct nfs_commit_info *cinfo,
+		    struct inode *inode,
+		    struct nfs_direct_req *dreq)
+{
+}
+
 void
 nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 			struct nfs_commit_info *cinfo)
-- 
1.7.10

