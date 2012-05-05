Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:8608 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757742Ab2EERZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 May 2012 13:25:03 -0400
Subject: [PATCH RFC 13/13] Lockd: move grace period management from lockd() to
	per-net functions
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Sat, 05 May 2012 21:23:05 +0400
Message-ID: <20120505172305.11559.3657.stgit@localhost.localdomain>
In-Reply-To: <20120505170722.11559.74503.stgit@localhost.localdomain>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/svc.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 68271c2..31a63f8 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -128,8 +128,6 @@ lockd(void *vrqstp)
 {
 	int		err = 0, preverr = 0;
 	struct svc_rqst *rqstp = vrqstp;
-	struct net *net = &init_net;
-	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	/* try_to_freeze() is called from svc_recv() */
 	set_freezable();
@@ -143,8 +141,6 @@ lockd(void *vrqstp)
 		nlm_timeout = LOCKD_DFLT_TIMEO;
 	nlmsvc_timeout = nlm_timeout * HZ;
 
-	set_grace_period(net);
-
 	/*
 	 * The main request loop. We don't terminate until the last
 	 * NFS mount or NFS daemon has gone away.
@@ -190,8 +186,6 @@ lockd(void *vrqstp)
 		svc_process(rqstp);
 	}
 	flush_signals(current);
-	cancel_delayed_work_sync(&ln->grace_period_end);
-	locks_end_grace(&ln->lockd_manager);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
@@ -272,6 +266,7 @@ static int lockd_up_net(struct svc_serv *serv, struct net *net)
 	error = make_socks(serv, net);
 	if (error < 0)
 		goto err_socks;
+	set_grace_period(net);
 	dprintk("lockd_up_net: per-net data created; net=%p\n", net);
 	return 0;
 
@@ -289,6 +284,8 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
 	if (ln->nlmsvc_users) {
 		if (--ln->nlmsvc_users == 0) {
 			nlm_shutdown_hosts_net(net);
+			cancel_delayed_work_sync(&ln->grace_period_end);
+			locks_end_grace(&ln->lockd_manager);
 			svc_shutdown_net(serv, net);
 			dprintk("lockd_down_net: per-net data destroyed; net=%p\n", net);
 		}

