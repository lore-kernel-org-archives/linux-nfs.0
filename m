Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:16651 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757454Ab2INOdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 10:33:00 -0400
Subject: [PATCH 2/3] lockd: per-net NSM client creation and destruction
	helpers introduced
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Fri, 14 Sep 2012 18:26:00 +0400
Message-ID: <20120914142600.10835.70696.stgit@localhost.localdomain>
In-Reply-To: <20120914140811.10835.81465.stgit@localhost.localdomain>
References: <20120914140811.10835.81465.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NSM RPC client can be required on NFSv3 umount, when child reaper is dying (and
destroying it's mount namespace). It means, that current nsproxy is set to
NULL already, but creation of RPC client requires UTS namespace for gaining
hostname string.
This patch introduces reference counted NFS RPC clients creation and
destruction helpers (similar to RPCBIND RPC clients).

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: <stable@vger.kernel.org>
---
 fs/lockd/mon.c   |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/lockd/netns.h |    4 ++++
 fs/lockd/svc.c   |    1 +
 3 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index c6186fb..77e07fe 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -19,6 +19,8 @@
 
 #include <asm/unaligned.h>
 
+#include "netns.h"
+
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 #define NSM_PROGRAM		100024
 #define NSM_VERSION		1
@@ -83,6 +85,51 @@ static struct rpc_clnt *nsm_create(struct net *net)
 	return rpc_create(&args);
 }
 
+__maybe_unused static struct rpc_clnt *nsm_client_get(struct net *net)
+{
+	static DEFINE_MUTEX(nsm_create_mutex);
+	struct rpc_clnt	*clnt;
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+	spin_lock(&ln->nsm_clnt_lock);
+	if (ln->nsm_users) {
+		ln->nsm_users++;
+		clnt = ln->nsm_clnt;
+		spin_unlock(&ln->nsm_clnt_lock);
+		goto out;
+	}
+	spin_unlock(&ln->nsm_clnt_lock);
+
+	mutex_lock(&nsm_create_mutex);
+	clnt = nsm_create(net);
+	if (!IS_ERR(clnt)) {
+		ln->nsm_clnt = clnt;
+		smp_wmb();
+		ln->nsm_users = 1;
+	}
+	mutex_unlock(&nsm_create_mutex);
+out:
+	return clnt;
+}
+
+__maybe_unused static void nsm_client_put(struct net *net)
+{
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
+	struct rpc_clnt	*clnt = ln->nsm_clnt;
+	int shutdown = 0;
+
+	spin_lock(&ln->nsm_clnt_lock);
+	if (ln->nsm_users) {
+		if (--ln->nsm_users)
+			ln->nsm_clnt = NULL;
+		shutdown = !ln->nsm_users;
+	}
+	spin_unlock(&ln->nsm_clnt_lock);
+
+	if (shutdown)
+		rpc_shutdown_client(clnt);
+}
+
 static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
 			 struct net *net)
 {
diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
index 4eee248..5010b55 100644
--- a/fs/lockd/netns.h
+++ b/fs/lockd/netns.h
@@ -12,6 +12,10 @@ struct lockd_net {
 	struct delayed_work grace_period_end;
 	struct lock_manager lockd_manager;
 	struct list_head grace_list;
+
+	spinlock_t nsm_clnt_lock;
+	unsigned int nsm_users;
+	struct rpc_clnt *nsm_clnt;
 };
 
 extern int lockd_net_id;
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 31a63f8..7e35587 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -596,6 +596,7 @@ static int lockd_init_net(struct net *net)
 
 	INIT_DELAYED_WORK(&ln->grace_period_end, grace_ender);
 	INIT_LIST_HEAD(&ln->grace_list);
+	spin_lock_init(&ln->nsm_clnt_lock);
 	return 0;
 }
 

