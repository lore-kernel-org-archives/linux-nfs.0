Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:30268 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759290Ab2DYOW6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 10:22:58 -0400
Subject: [PATCH 2/6] LockD: use existent per-net data function on service
 creation
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 18:22:47 +0400
Message-ID: <20120425142247.22909.7047.stgit@localhost6.localdomain6>
In-Reply-To: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch also replaces svc_rpcb_setup() with svc_bind().

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 58ddc38..71c6c31 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -259,9 +259,9 @@ static int lockd_up_net(struct svc_serv *serv, struct net *net)
 	if (ln->nlmsvc_users++)
 		return 0;
 
-	error = svc_rpcb_setup(serv, net);
+	error = svc_bind(serv, net);
 	if (error)
-		goto err_rpcb;
+		goto err_bind;
 
 	error = make_socks(serv, net);
 	if (error < 0)
@@ -270,7 +270,7 @@ static int lockd_up_net(struct svc_serv *serv, struct net *net)
 
 err_socks:
 	svc_rpcb_cleanup(serv, net);
-err_rpcb:
+err_bind:
 	ln->nlmsvc_users--;
 	return error;
 }
@@ -298,7 +298,6 @@ int lockd_up(struct net *net)
 {
 	struct svc_serv *serv;
 	int		error = 0;
-	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	mutex_lock(&nlmsvc_mutex);
 	/*
@@ -324,17 +323,9 @@ int lockd_up(struct net *net)
 		goto out;
 	}
 
-	error = svc_bind(serv, net);
-	if (error < 0) {
-		printk(KERN_WARNING "lockd_up: bind service failed\n");
-		goto destroy_and_out;
-	}
-
-	ln->nlmsvc_users++;
-
-	error = make_socks(serv, net);
+	error = lockd_up_net(serv, net);
 	if (error < 0)
-		goto err_start;
+		goto err_net;
 
 	/*
 	 * Create the kernel thread and wait for it to start.
@@ -367,7 +358,7 @@ int lockd_up(struct net *net)
 	 * Note: svc_serv structures have an initial use count of 1,
 	 * so we exit through here on both success and failure.
 	 */
-destroy_and_out:
+err_net:
 	svc_destroy(serv);
 out:
 	if (!error)
@@ -377,7 +368,7 @@ out:
 
 err_start:
 	lockd_down_net(serv, net);
-	goto destroy_and_out;
+	goto err_net;
 }
 EXPORT_SYMBOL_GPL(lockd_up);
 

