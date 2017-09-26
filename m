Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34725 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966725AbdIZHQT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Sep 2017 03:16:19 -0400
From: Corentin Labbe <clabbe.montjoie@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/3] nfs_common: fix build warning in grace.c
Date: Tue, 26 Sep 2017 09:14:05 +0200
Message-Id: <20170926071407.31719-2-clabbe.montjoie@gmail.com>
In-Reply-To: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
References: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fix the following warning
fs/nfs_common/grace.c:66:1: warning: no previous prototype for function '__state_in_grace' [-Wmissing-prototypes]
by adding the missing static.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 fs/nfs_common/grace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 420d3a0ab258..519396967e79 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
  * to answer ordinary lock requests, and when they should accept only
  * lock reclaims.
  */
-int
+static int
 __state_in_grace(struct net *net, bool open)
 {
 	struct list_head *grace_list = net_generic(net, grace_net_id);
-- 
2.13.5

