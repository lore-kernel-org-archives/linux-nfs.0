Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35997 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966733AbdIZHQU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Sep 2017 03:16:20 -0400
From: Corentin Labbe <clabbe.montjoie@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/3] nfs_common: move locks_in_grace comment at the right place
Date: Tue, 26 Sep 2017 09:14:06 +0200
Message-Id: <20170926071407.31719-3-clabbe.montjoie@gmail.com>
In-Reply-To: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
References: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c87fb4a378f9 ("lockd: NLM grace period shouldn't block NFSv4 opens")
made the locks_in_grace() comment be in the wrong place.

This patch move this comment just at the right place.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 fs/nfs_common/grace.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 519396967e79..c030cd618b99 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -55,13 +55,6 @@ locks_end_grace(struct lock_manager *lm)
 }
 EXPORT_SYMBOL_GPL(locks_end_grace);
 
-/**
- * locks_in_grace
- *
- * Lock managers call this function to determine when it is OK for them
- * to answer ordinary lock requests, and when they should accept only
- * lock reclaims.
- */
 static int
 __state_in_grace(struct net *net, bool open)
 {
@@ -78,6 +71,13 @@ __state_in_grace(struct net *net, bool open)
 	return false;
 }
 
+/**
+ * locks_in_grace
+ *
+ * Lock managers call this function to determine when it is OK for them
+ * to answer ordinary lock requests, and when they should accept only
+ * lock reclaims.
+ */
 int locks_in_grace(struct net *net)
 {
 	return __state_in_grace(net, 0);
-- 
2.13.5

