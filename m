Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41171 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756355Ab2D3R1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 13:27:14 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, iisaman@netapp.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Define nfs_direct_write_schedule_work() when v3 and v4 are disabled
Date: Mon, 30 Apr 2012 13:27:11 -0400
Message-Id: <1335806831-1968-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 doesn't have commits, so this function can be a no-op.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/direct.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d44de2f..e83545c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -601,6 +601,9 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
 }
 
 #else
+static void nfs_direct_write_schedule_work(struct work_struct *work)
+{
+}
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
-- 
1.7.10

