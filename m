Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9807 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933759AbdJQQkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 12:40:52 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] lockd: double unregister of inetaddr notifiers
To: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <7407ca70-f5bc-ae87-63e5-1bef5e14a142@virtuozzo.com>
Date: Tue, 17 Oct 2017 19:40:36 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd_up() can call lockd_unregister_notifiers twice:
inside lockd_start_svc() when it calls lockd_svc_exit_thread()
and then in error path of lockd_up()

Patch forces lockd_start_svc() to unregister notifiers in all error cases
and removes extra unregister in error path of lockd_up().

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/svc.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index b995bdc..f04ecfc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -369,6 +369,7 @@ static int lockd_start_svc(struct svc_serv *serv)
 		printk(KERN_WARNING
 			"lockd_up: svc_rqst allocation failed, error=%d\n",
 			error);
+		lockd_unregister_notifiers();
 		goto out_rqst;
 	}
 
@@ -459,13 +460,16 @@ int lockd_up(struct net *net)
 	}
 
 	error = lockd_up_net(serv, net);
-	if (error < 0)
-		goto err_net;
+	if (error < 0) {
+		lockd_unregister_notifiers();
+		goto err_put;
+	}
 
 	error = lockd_start_svc(serv);
-	if (error < 0)
-		goto err_start;
-
+	if (error < 0) {
+		lockd_down_net(serv, net);
+		goto err_put;
+	}
 	nlmsvc_users++;
 	/*
 	 * Note: svc_serv structures have an initial use count of 1,
@@ -476,12 +480,6 @@ int lockd_up(struct net *net)
 err_create:
 	mutex_unlock(&nlmsvc_mutex);
 	return error;
-
-err_start:
-	lockd_down_net(serv, net);
-err_net:
-	lockd_unregister_notifiers();
-	goto err_put;
 }
 EXPORT_SYMBOL_GPL(lockd_up);
 
-- 
2.7.4
