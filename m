Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40275 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933658AbdKBPgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Nov 2017 11:36:04 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] grace: replace BUG_ON on WARN_ON in grace_exit_net()
To: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <18234b43-c052-0243-a3f2-277a1bfaa66e@virtuozzo.com>
Date: Thu, 2 Nov 2017 18:36:00 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

use WARN_ON instead of BUG_ON to prevent dispensable kernel crash

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs_common/grace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 420d3a0..77226e6 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -104,7 +104,7 @@ grace_exit_net(struct net *net)
 {
 	struct list_head *grace_list = net_generic(net, grace_net_id);
 
-	BUG_ON(!list_empty(grace_list));
+	WARN_ON(!list_empty(grace_list));
 }
 
 static struct pernet_operations grace_net_ops = {
-- 
2.7.4

