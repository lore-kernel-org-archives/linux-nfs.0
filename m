Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35499 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756860AbbLBWEz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 17:04:55 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id B76AF33E616
	for <linux-nfs@vger.kernel.org>; Wed,  2 Dec 2015 22:04:55 +0000 (UTC)
Received: from tonberry.usersys.redhat.com (dhcp145-110.rdu.redhat.com [10.13.145.110])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tB2M4tpj001413
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 2 Dec 2015 17:04:55 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.15.2/8.14.5) with ESMTP id tB2M4sIO041656
	for <linux-nfs@vger.kernel.org>; Wed, 2 Dec 2015 17:04:54 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.15.2/8.15.2/Submit) id tB2M4sYi041642
	for linux-nfs@vger.kernel.org; Wed, 2 Dec 2015 17:04:54 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 2/3] nfsd: Register callbacks on the inetaddr_chain and inet6addr_chain
Date: Wed,  2 Dec 2015 17:04:53 -0500
Message-Id: <1449093894-41591-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1449093894-41591-1-git-send-email-smayhew@redhat.com>
References: <1449093894-41591-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Register callbacks on inetaddr_chain and inet6addr_chain to trigger
cleanup of nfsd transport sockets when an ip address is deleted.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfssvc.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 68 insertions(+)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ad4e237..3779a5f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -14,9 +14,13 @@
 
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
+#include <linux/inetdevice.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
 #include <net/net_namespace.h>
 #include "nfsd.h"
 #include "cache.h"
@@ -306,10 +310,70 @@ static void nfsd_shutdown_net(struct net *net)
 	nfsd_shutdown_generic();
 }
 
+static int nfsd_inetaddr_event(struct notifier_block *this, unsigned long event,
+	void *ptr)
+{
+	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
+	struct net_device *dev = ifa->ifa_dev->dev;
+	struct net *net = dev_net(dev);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct sockaddr_in sin;
+
+	if (event != NETDEV_DOWN)
+		goto out;
+
+	if (nn->nfsd_serv) {
+		dprintk("nfsd_inetaddr_event: removed %pI4\n", &ifa->ifa_local);
+		sin.sin_family = AF_INET;
+		sin.sin_addr.s_addr = ifa->ifa_local;
+		svc_age_temp_xprts_now(nn->nfsd_serv, (struct sockaddr *)&sin);
+	}
+
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nfsd_inetaddr_notifier = {
+	.notifier_call = nfsd_inetaddr_event,
+};
+
+#if IS_ENABLED(CONFIG_IPV6)
+static int nfsd_inet6addr_event(struct notifier_block *this,
+	unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
+	struct net_device *dev = ifa->idev->dev;
+	struct net *net = dev_net(dev);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct sockaddr_in6 sin6;
+
+	if (event != NETDEV_DOWN)
+		goto out;
+
+	if (nn->nfsd_serv) {
+		dprintk("nfsd_inet6addr_event: removed %pI6\n", &ifa->addr);
+		sin6.sin6_family = AF_INET6;
+		sin6.sin6_addr = ifa->addr;
+		svc_age_temp_xprts_now(nn->nfsd_serv, (struct sockaddr *)&sin6);
+	}
+
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nfsd_inet6addr_notifier = {
+	.notifier_call = nfsd_inet6addr_event,
+};
+#endif
+
 static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
+	unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
+#if IS_ENABLED(CONFIG_IPV6)
+	unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
+#endif
 	/*
 	 * write_ports can create the server without actually starting
 	 * any threads--if we get shut down before any threads are
@@ -425,6 +489,10 @@ int nfsd_create_serv(struct net *net)
 	}
 
 	set_max_drc();
+	register_inetaddr_notifier(&nfsd_inetaddr_notifier);
+#if IS_ENABLED(CONFIG_IPV6)
+	register_inet6addr_notifier(&nfsd_inet6addr_notifier);
+#endif
 	do_gettimeofday(&nn->nfssvc_boot);		/* record boot time */
 	return 0;
 }
-- 
2.4.3

