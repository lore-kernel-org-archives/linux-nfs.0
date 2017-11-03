Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39486 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751743AbdKCSup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Nov 2017 14:50:45 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2] grace: replace BUG_ON by WARN in exit_net hook
To: linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <903128e5-12e8-090f-ed8c-fd76777f8047@virtuozzo.com>
Date: Fri, 3 Nov 2017 21:50:39 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

let's generate warning instead of kernel crash

[ 9313.047796] NFSD: starting 90-second grace period (net ffff880e307fe240)
[ 9317.257203] nfsd: last server has exited, flushing export cache
...
[ 9320.097513] net ffff880e307fe240 exit: grace_list is not empty
[ 9320.098570] WARNING: CPU: 5 PID: 1556 at fs/nfs_common/grace.c:112 grace_exit_net+0x33/0x40 [grace]

v2: net pointer added to warning message

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs_common/grace.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index 420d3a0..3c602df 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -104,7 +104,8 @@ grace_exit_net(struct net *net)
 {
 	struct list_head *grace_list = net_generic(net, grace_net_id);
 
-	BUG_ON(!list_empty(grace_list));
+	WARN(!list_empty(grace_list),
+	     "net %p exit: grace_list is not empty\n", net);
 }
 
 static struct pernet_operations grace_net_ops = {
-- 
2.7.4

