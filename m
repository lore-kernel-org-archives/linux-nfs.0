Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44561 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179Ab2DRNTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 09:19:36 -0400
Subject: [PATCH] LockD: call per-net shutdown on every global shutdown call
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 18 Apr 2012 17:18:54 +0400
Message-ID: <20120418131827.16800.33207.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Per-net LockD shutdown call must be called regardless of global nlm users
counter.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1ead075..2ad3715 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -381,10 +381,9 @@ lockd_down(struct net *net)
 {
 	mutex_lock(&nlmsvc_mutex);
 	if (nlmsvc_users) {
-		if (--nlmsvc_users) {
-			lockd_down_net(net);
+		lockd_down_net(net);
+		if (--nlmsvc_users)
 			goto out;
-		}
 	} else {
 		printk(KERN_ERR "lockd_down: no users! task=%p\n",
 			nlmsvc_task);

