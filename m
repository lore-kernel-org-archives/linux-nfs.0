Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4376 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325Ab2DYOXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 10:23:06 -0400
Subject: [PATCH 3/6] LockD: service creation function introduced
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 18:22:54 +0400
Message-ID: <20120425142254.22909.92489.stgit@localhost6.localdomain6>
In-Reply-To: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function creates service if it's not exist, or increase usage counter of
the existent, and returns pointer to it.
Usage counter will be droppepd by svc_destroy() later in lockd_up().

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |   38 +++++++++++++++++++++++++++-----------
 1 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 71c6c31..ad11ea7 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -291,21 +291,20 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
 	}
 }
 
-/*
- * Bring up the lockd process if it's not already up.
- */
-int lockd_up(struct net *net)
+static struct svc_serv *lockd_create_svc(void)
 {
 	struct svc_serv *serv;
-	int		error = 0;
 
-	mutex_lock(&nlmsvc_mutex);
 	/*
 	 * Check whether we're already up and running.
 	 */
 	if (nlmsvc_rqst) {
-		error = lockd_up_net(nlmsvc_rqst->rq_server, net);
-		goto out;
+		/*
+		 * Note: increase service usage, because later in case of error
+		 * svc_destroy() will be called.
+		 */
+		svc_get(nlmsvc_rqst->rq_server);
+		return nlmsvc_rqst->rq_server;
 	}
 
 	/*
@@ -316,11 +315,28 @@ int lockd_up(struct net *net)
 		printk(KERN_WARNING
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
-	error = -ENOMEM;
 	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
-		goto out;
+		return ERR_PTR(-ENOMEM);
+	}
+	return serv;
+}
+
+/*
+ * Bring up the lockd process if it's not already up.
+ */
+int lockd_up(struct net *net)
+{
+	struct svc_serv *serv;
+	int		error = 0;
+
+	mutex_lock(&nlmsvc_mutex);
+
+	serv = lockd_create_svc();
+	if (IS_ERR(serv)) {
+		error = PTR_ERR(serv);
+		goto err_create;
 	}
 
 	error = lockd_up_net(serv, net);
@@ -360,9 +376,9 @@ int lockd_up(struct net *net)
 	 */
 err_net:
 	svc_destroy(serv);
-out:
 	if (!error)
 		nlmsvc_users++;
+err_create:
 	mutex_unlock(&nlmsvc_mutex);
 	return error;
 

