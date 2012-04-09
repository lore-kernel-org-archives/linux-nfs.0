Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57517 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758246Ab2DIUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:53:00 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/26] NFS: create nfs_generic_commit_list
Date: Mon,  9 Apr 2012 16:52:18 -0400
Message-Id: <1334004744-31842-21-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simple refactoring.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 293ddb9..948df43 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1521,6 +1521,17 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
+static int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
+				   int how)
+{
+	int status;
+
+	status = pnfs_commit_list(inode, head, how);
+	if (status == PNFS_NOT_ATTEMPTED)
+		status = nfs_commit_list(inode, head, how);
+	return status;
+}
+
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
@@ -1534,9 +1545,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 	if (res) {
 		int error;
 
-		error = pnfs_commit_list(inode, &head, how);
-		if (error == PNFS_NOT_ATTEMPTED)
-			error = nfs_commit_list(inode, &head, how);
+		error = nfs_generic_commit_list(inode, &head, how);
 		if (error < 0)
 			return error;
 		if (!may_wait)
-- 
1.7.2.1

