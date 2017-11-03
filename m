Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:10288 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751381AbdKCQca (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Nov 2017 12:32:30 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] lockd: added cleanup checks in exit_net hook
To: linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <cbc8333b-95a5-0bb2-9ef8-645ba3bb6185@virtuozzo.com>
Date: Fri, 3 Nov 2017 19:32:23 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patch generates warnings if exit_net hook detects that 
structures initialized in init_net hook are still in use. 

[ 2355.129218] per-netns lockd_manager.list is not empty
[ 2355.130483] WARNING: CPU: 7 PID: 97 at fs/lockd/svc.c:682 lockd_exit_net+0x52/0x80 [lockd]
...
[ 2355.148073] per-netns grace_period_end dealyed work was not cancelled
[ 2355.149205] WARNING: CPU: 7 PID: 97 at fs/lockd/svc.c:686 lockd_exit_net+0x78/0x80 [lockd]

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/svc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 809cbcc..119af0a 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -690,6 +690,14 @@ static int lockd_init_net(struct net *net)
 
 static void lockd_exit_net(struct net *net)
 {
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+	WARN(!list_empty(&ln->lockd_manager.list),
+		"per-netns lockd_manager.list is not empty\n");
+	WARN(!list_empty(&ln->nsm_handles),
+		"per-netns nsm_handles list is not empty\n");
+	WARN(delayed_work_pending(&ln->grace_period_end),
+		"per-netns grace_period_end dealyed work was not cancelled\n");
 }
 
 static struct pernet_operations lockd_net_ops = {
-- 
2.7.4

