Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbcF3Oje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 10:39:34 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: unregister notifier blocks if the service fails to come up completely
Date: Thu, 30 Jun 2016 10:39:32 -0400
Message-Id: <1467297572-27945-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the lockd service fails to start up then we need to be sure that the
notifier blocks are not registered, otherwise a subsequent start of the
service could cause the same notifier to be registered twice, leading to
soft lockups.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/lockd/svc.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 154a107..7d8217a 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -335,12 +335,17 @@ static struct notifier_block lockd_inet6addr_notifier = {
 };
 #endif
 
-static void lockd_svc_exit_thread(void)
+static void lockd_unregister_notifiers(void)
 {
 	unregister_inetaddr_notifier(&lockd_inetaddr_notifier);
 #if IS_ENABLED(CONFIG_IPV6)
 	unregister_inet6addr_notifier(&lockd_inet6addr_notifier);
 #endif
+}
+
+static void lockd_svc_exit_thread(void)
+{
+	lockd_unregister_notifiers();
 	svc_exit_thread(nlmsvc_rqst);
 }
 
@@ -450,12 +455,16 @@ int lockd_up(struct net *net)
 	}
 
 	error = lockd_up_net(serv, net);
-	if (error < 0)
+	if (error < 0) {
+		lockd_unregister_notifiers();
 		goto err_net;
+	}
 
 	error = lockd_start_svc(serv);
-	if (error < 0)
+	if (error < 0) {
+		lockd_unregister_notifiers();
 		goto err_start;
+	}
 
 	nlmsvc_users++;
 	/*
-- 
2.4.11

