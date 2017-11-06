Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:30900 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753163AbdKFNWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 08:22:53 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 01/21] grace: replace BUG_ON by WARN_ONCE in exit_net hook
To: netdev@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Message-ID: <a059abdd-e727-adcb-7b43-976be1d0a08e@virtuozzo.com>
Date: Mon, 6 Nov 2017 16:22:48 +0300
MIME-Version: 1.0
In-Reply-To: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs_common/grace.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 420d3a0..1bd6599 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -104,7 +104,9 @@ grace_exit_net(struct net *net)
 {
 	struct list_head *grace_list = net_generic(net, grace_net_id);
 
-	BUG_ON(!list_empty(grace_list));
+	WARN_ONCE(!list_empty(grace_list),
+		  "net %x %s: grace_list is not empty\n",
+		  net->ns.inum, __func__);
 }
 
 static struct pernet_operations grace_net_ops = {
-- 
2.7.4

