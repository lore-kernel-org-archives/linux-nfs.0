Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:50928 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966745AbdIZHQV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Sep 2017 03:16:21 -0400
From: Corentin Labbe <clabbe.montjoie@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/3] nfs_common: convert int to bool
Date: Tue, 26 Sep 2017 09:14:07 +0200
Message-Id: <20170926071407.31719-4-clabbe.montjoie@gmail.com>
In-Reply-To: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
References: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since __state_in_grace return only true/false, make it return bool
instead of int.
Same change for the two user of it, locks_in_grace/opens_in_grace

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 fs/nfs_common/grace.c | 10 +++++-----
 include/linux/fs.h    |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index c030cd618b99..897b299db55e 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -55,7 +55,7 @@ locks_end_grace(struct lock_manager *lm)
 }
 EXPORT_SYMBOL_GPL(locks_end_grace);
 
-static int
+static bool
 __state_in_grace(struct net *net, bool open)
 {
 	struct list_head *grace_list = net_generic(net, grace_net_id);
@@ -78,15 +78,15 @@ __state_in_grace(struct net *net, bool open)
  * to answer ordinary lock requests, and when they should accept only
  * lock reclaims.
  */
-int locks_in_grace(struct net *net)
+bool locks_in_grace(struct net *net)
 {
-	return __state_in_grace(net, 0);
+	return __state_in_grace(net, false);
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
 
-int opens_in_grace(struct net *net)
+bool opens_in_grace(struct net *net)
 {
-	return __state_in_grace(net, 1);
+	return __state_in_grace(net, true);
 }
 EXPORT_SYMBOL_GPL(opens_in_grace);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8a84a45ecbf9..df843e8c9b50 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -970,8 +970,8 @@ struct lock_manager {
 struct net;
 void locks_start_grace(struct net *, struct lock_manager *);
 void locks_end_grace(struct lock_manager *);
-int locks_in_grace(struct net *);
-int opens_in_grace(struct net *);
+bool locks_in_grace(struct net *);
+bool opens_in_grace(struct net *);
 
 /* that will die - we need it for nfs_lock_info */
 #include <linux/nfs_fs_i.h>
-- 
2.13.5

