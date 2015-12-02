Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887AbbLBWE4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 17:04:56 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 0E57168E18
	for <linux-nfs@vger.kernel.org>; Wed,  2 Dec 2015 22:04:56 +0000 (UTC)
Received: from tonberry.usersys.redhat.com (dhcp145-110.rdu.redhat.com [10.13.145.110])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tB2M4toI001422
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 2 Dec 2015 17:04:55 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.15.2/8.14.5) with ESMTP id tB2M4t0t041663
	for <linux-nfs@vger.kernel.org>; Wed, 2 Dec 2015 17:04:55 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.15.2/8.15.2/Submit) id tB2M4tx3041662
	for linux-nfs@vger.kernel.org; Wed, 2 Dec 2015 17:04:55 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 3/3] lockd: Register callbacks on the inetaddr_chain and inet6addr_chain
Date: Wed,  2 Dec 2015 17:04:54 -0500
Message-Id: <1449093894-41591-4-git-send-email-smayhew@redhat.com>
In-Reply-To: <1449093894-41591-1-git-send-email-smayhew@redhat.com>
References: <1449093894-41591-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Register callbacks on inetaddr_chain and inet6addr_chain to trigger
cleanup of lockd transport sockets when an ip address is deleted.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/lockd/svc.c | 74 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 72 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 5f31ebd..44d18ad 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -25,13 +25,17 @@
 #include <linux/mutex.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
+#include <linux/inetdevice.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include <net/ip.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
 #include <linux/lockd/lockd.h>
 #include <linux/nfs.h>
 
@@ -279,6 +283,68 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
 	}
 }
 
+static int lockd_inetaddr_event(struct notifier_block *this,
+	unsigned long event, void *ptr)
+{
+	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
+	struct sockaddr_in sin;
+
+	if (event != NETDEV_DOWN)
+		goto out;
+
+	if (nlmsvc_rqst) {
+		dprintk("lockd_inetaddr_event: removed %pI4\n",
+			&ifa->ifa_local);
+		sin.sin_family = AF_INET;
+		sin.sin_addr.s_addr = ifa->ifa_local;
+		svc_age_temp_xprts_now(nlmsvc_rqst->rq_server,
+			(struct sockaddr *)&sin);
+	}
+
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block lockd_inetaddr_notifier = {
+	.notifier_call = lockd_inetaddr_event,
+};
+
+#if IS_ENABLED(CONFIG_IPV6)
+static int lockd_inet6addr_event(struct notifier_block *this,
+	unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
+	struct sockaddr_in6 sin6;
+
+	if (event != NETDEV_DOWN)
+		goto out;
+
+	if (nlmsvc_rqst) {
+		dprintk("lockd_inet6addr_event: removed %pI6\n", &ifa->addr);
+		sin6.sin6_family = AF_INET6;
+		sin6.sin6_addr = ifa->addr;
+		svc_age_temp_xprts_now(nlmsvc_rqst->rq_server,
+			(struct sockaddr *)&sin6);
+	}
+
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block lockd_inet6addr_notifier = {
+	.notifier_call = lockd_inet6addr_event,
+};
+#endif
+
+static void lockd_svc_exit_thread(void)
+{
+	unregister_inetaddr_notifier(&lockd_inetaddr_notifier);
+#if IS_ENABLED(CONFIG_IPV6)
+	unregister_inet6addr_notifier(&lockd_inet6addr_notifier);
+#endif
+	svc_exit_thread(nlmsvc_rqst);
+}
+
 static int lockd_start_svc(struct svc_serv *serv)
 {
 	int error;
@@ -315,7 +381,7 @@ static int lockd_start_svc(struct svc_serv *serv)
 	return 0;
 
 out_task:
-	svc_exit_thread(nlmsvc_rqst);
+	lockd_svc_exit_thread();
 	nlmsvc_task = NULL;
 out_rqst:
 	nlmsvc_rqst = NULL;
@@ -360,6 +426,10 @@ static struct svc_serv *lockd_create_svc(void)
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		return ERR_PTR(-ENOMEM);
 	}
+	register_inetaddr_notifier(&lockd_inetaddr_notifier);
+#if IS_ENABLED(CONFIG_IPV6)
+	register_inet6addr_notifier(&lockd_inet6addr_notifier);
+#endif
 	dprintk("lockd_up: service created\n");
 	return serv;
 }
@@ -428,7 +498,7 @@ lockd_down(struct net *net)
 	}
 	kthread_stop(nlmsvc_task);
 	dprintk("lockd_down: service stopped\n");
-	svc_exit_thread(nlmsvc_rqst);
+	lockd_svc_exit_thread();
 	dprintk("lockd_down: service destroyed\n");
 	nlmsvc_task = NULL;
 	nlmsvc_rqst = NULL;
-- 
2.4.3

