Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1863 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756366Ab2GYM5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jul 2012 08:57:36 -0400
Subject: [PATCH v2 03/15] LockD: manage garbage collection timeout per
	networks namespace
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Jul 2012 16:56:11 +0400
Message-ID: <20120725125611.24376.76843.stgit@localhost.localdomain>
In-Reply-To: <20120725125258.24376.82525.stgit@localhost.localdomain>
References: <20120725125258.24376.82525.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch moves next_gc to per-net data.

Note: passed network can be NULL (when Lockd kthread is exiting of Lockd
module is removing).

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/host.c  |   12 +++++++++---
 fs/lockd/netns.h |    1 +
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 991274a..3636734 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -21,6 +21,8 @@
 
 #include <net/ipv6.h>
 
+#include "netns.h"
+
 #define NLMDBG_FACILITY		NLMDBG_HOSTCACHE
 #define NLM_HOST_NRHASH		32
 #define NLM_HOST_REBIND		(60 * HZ)
@@ -41,7 +43,6 @@ static struct hlist_head	nlm_client_hosts[NLM_HOST_NRHASH];
 		hlist_for_each_entry_safe((host), (pos), (next), \
 						(chain), h_hash)
 
-static unsigned long		next_gc;
 static unsigned long		nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
@@ -337,6 +338,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 		.hostname_len	= hostname_len,
 		.net		= net,
 	};
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	dprintk("lockd: %s(host='%*s', vers=%u, proto=%s)\n", __func__,
 			(int)hostname_len, hostname, rqstp->rq_vers,
@@ -344,7 +346,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 
 	mutex_lock(&nlm_host_mutex);
 
-	if (time_after_eq(jiffies, next_gc))
+	if (time_after_eq(jiffies, ln->next_gc))
 		nlm_gc_hosts(net);
 
 	chain = &nlm_server_hosts[nlm_hash_address(ni.sap)];
@@ -653,5 +655,9 @@ nlm_gc_hosts(struct net *net)
 		nlm_destroy_host_locked(host);
 	}
 
-	next_gc = jiffies + NLM_HOST_COLLECT;
+	if (net) {
+		struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+		ln->next_gc = jiffies + NLM_HOST_COLLECT;
+	}
 }
diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
index ce227e0..97c6c77 100644
--- a/fs/lockd/netns.h
+++ b/fs/lockd/netns.h
@@ -5,6 +5,7 @@
 
 struct lockd_net {
 	unsigned int nlmsvc_users;
+	unsigned long next_gc;
 };
 
 extern int lockd_net_id;

