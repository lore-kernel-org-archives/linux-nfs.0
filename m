Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbcCPJRJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 05:17:09 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Retry a zero-length short read
Date: Wed, 16 Mar 2016 05:17:07 -0400
Message-Id: <79adfc63f33887475f6a0f0eeaacd8b52b2ed12c.1458119750.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A zero-length short read without eof should be retried rather than sending
an error to the application.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/read.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index eb31e23..7269d42 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -244,11 +244,6 @@ static void nfs_readpage_retry(struct rpc_task *task,
 
 	/* This is a short read! */
 	nfs_inc_stats(hdr->inode, NFSIOS_SHORTREAD);
-	/* Has the server at least made some progress? */
-	if (resp->count == 0) {
-		nfs_set_pgio_error(hdr, -EIO, argp->offset);
-		return;
-	}
 
 	/* For non rpc-based layout drivers, retry-through-MDS */
 	if (!task->tk_ops) {
-- 
1.7.1

