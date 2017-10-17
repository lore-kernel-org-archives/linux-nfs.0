Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13649 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932791AbdJQQs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 12:48:28 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [RFC PATCH 2/2] race of nfsd inetaddr notifiers with nn->nfsd_serv
 change
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <750592ab-8a99-884b-104f-7569c4762c1b@virtuozzo.com>
Date: Tue, 17 Oct 2017 19:48:24 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd_inet[6]addr_event use nn->nfsd_serv without taken nfsd_mutex,
pointer can be changed during execution of notifiers and crash the host.

Moreover if notifiers was enabled in one net namespace it will be enabled 
in all other net namespaces, from its creation until its destroy.

Patch allows notifiers to access to nn->nfsd_serv only when the pointer was 
correctly initialized and delays its cleanup until notifiers are in use.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfsd/netns.h  |  3 +++
 fs/nfsd/nfsctl.c |  3 +++
 fs/nfsd/nfssvc.c | 14 +++++++++++---
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 3714231..82f7999 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -119,6 +119,9 @@ struct nfsd_net {
 	u32 clverifier_counter;
 
 	struct svc_serv *nfsd_serv;
+
+	wait_queue_head_t ntf_wq;
+	atomic_t ntf_refcnt;
 };
 
 /* Simple check to find out if a given net was properly initialized */
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6493df6..d107b44 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1241,6 +1241,9 @@ static __net_init int nfsd_init_net(struct net *net)
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
+
+	atomic_set(&nn->ntf_refcnt, 0);
+	init_waitqueue_head(&nn->ntf_wq);
 	return 0;
 
 out_idmap_error:
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 7e3af3e..29a263b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -334,7 +334,8 @@ static int nfsd_inetaddr_event(struct notifier_block *this, unsigned long event,
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct sockaddr_in sin;
 
-	if (event != NETDEV_DOWN)
+	if ((event != NETDEV_DOWN) ||
+	    !atomic_inc_not_zero(&nn->ntf_refcnt))
 		goto out;
 
 	if (nn->nfsd_serv) {
@@ -343,6 +344,8 @@ static int nfsd_inetaddr_event(struct notifier_block *this, unsigned long event,
 		sin.sin_addr.s_addr = ifa->ifa_local;
 		svc_age_temp_xprts_now(nn->nfsd_serv, (struct sockaddr *)&sin);
 	}
+	atomic_dec(&nn->ntf_refcnt);
+	wake_up(&nn->ntf_wq);
 
 out:
 	return NOTIFY_DONE;
@@ -362,7 +365,8 @@ static int nfsd_inet6addr_event(struct notifier_block *this,
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct sockaddr_in6 sin6;
 
-	if (event != NETDEV_DOWN)
+	if ((event != NETDEV_DOWN) ||
+	    !atomic_inc_not_zero(&nn->ntf_refcnt))
 		goto out;
 
 	if (nn->nfsd_serv) {
@@ -373,7 +377,8 @@ static int nfsd_inet6addr_event(struct notifier_block *this,
 			sin6.sin6_scope_id = ifa->idev->dev->ifindex;
 		svc_age_temp_xprts_now(nn->nfsd_serv, (struct sockaddr *)&sin6);
 	}
-
+	atomic_dec(&nn->ntf_refcnt);
+	wake_up(&nn->ntf_wq);
 out:
 	return NOTIFY_DONE;
 }
@@ -390,6 +395,7 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
+	atomic_dec(&nn->ntf_refcnt);
 	/* check if the notifier still has clients */
 	if (atomic_dec_return(&nfsd_notifier_refcount) == 0) {
 		unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
@@ -397,6 +403,7 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 		unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
 #endif
 	}
+	wait_event(nn->ntf_wq, atomic_read(&nn->ntf_refcnt) == 0);
 
 	/*
 	 * write_ports can create the server without actually starting
@@ -516,6 +523,7 @@ int nfsd_create_serv(struct net *net)
 		register_inet6addr_notifier(&nfsd_inet6addr_notifier);
 #endif
 	}
+	atomic_inc(&nn->ntf_refcnt);
 	do_gettimeofday(&nn->nfssvc_boot);		/* record boot time */
 	return 0;
 }
-- 
2.7.4

