Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:34890 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751688AbdJ3SWh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 14:22:37 -0400
From: Jeff Layton <jlayton@kernel.org>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] grace: make __state_in_grace static
Date: Mon, 30 Oct 2017 14:22:34 -0400
Message-Id: <20171030182234.1183-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs_common/grace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 874ff25e12ac..db06a708d79f 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -63,7 +63,7 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
  * to answer ordinary lock requests, and when they should accept only
  * lock reclaims.
  */
-int
+static int
 __state_in_grace(struct net *net, bool open)
 {
 	struct list_head *grace_list = net_generic(net, grace_net_id);
-- 
2.13.6

