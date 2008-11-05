From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] NLM: Create a SLAB/SLUB cache for nlm_host entries
Date: Wed, 05 Nov 2008 16:52:36 -0500
Message-ID: <20081105215235.16549.39687.stgit@ingres.1015granger.net>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12215 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbYKEVw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:52:56 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have a couple of large text buffers in the nlm_host struct,
the nlm_host cache should use a slab to reduce memory utilization and
fragmentation on systems that manage a large number of NLM peers.

We keep these hardware cache-aligned to speed up the linked list search
in nlm_lookup_host().

The overhead of creating a fresh nlm_host entry is also reduced using
SLAB's init_once callback instead of using kzalloc().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   44 ++++++++++++++++++++++++++++++++++++++++++-
 fs/lockd/svc.c              |   12 +++++++++---
 include/linux/lockd/lockd.h |    2 ++
 3 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 4dfe250..015c787 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -25,6 +25,8 @@
 #define NLM_HOST_EXPIRE		(300 * HZ)
 #define NLM_HOST_COLLECT	(120 * HZ)
 
+static struct kmem_cache	*nlm_host_cachep;
+
 static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
 static unsigned long		nlm_next_gc;
 static unsigned long		nlm_nrhosts;
@@ -609,7 +611,8 @@ nlm_shutdown_hosts(void)
 					host->h_inuse, host->h_expires);
 			}
 		}
-	}
+	} else
+		nlm_destroy_host_cache();
 }
 
 /*
@@ -651,3 +654,42 @@ nlm_gc_hosts(void)
 
 	nlm_next_gc = jiffies + NLM_HOST_COLLECT;
 }
+
+static void nlm_host_init_once(void *foo)
+{
+	struct nlm_host *host = (struct nlm_host *)foo;
+
+	INIT_HLIST_NODE(&host->h_hash);
+	host->h_rpcclnt = NULL;
+	init_waitqueue_head(&host->h_gracewait);
+	init_rwsem(&host->h_rwsem);
+	mutex_init(&host->h_mutex);
+	INIT_LIST_HEAD(&host->h_lockowners);
+	spin_lock_init(&host->h_lock);
+	INIT_LIST_HEAD(&host->h_granted);
+	INIT_LIST_HEAD(&host->h_reclaim);
+}
+
+/**
+ * nlm_init_host_cache - create a slab cache for nlm_host entries
+ *
+ */
+int __init nlm_init_host_cache(void)
+{
+	nlm_host_cachep = kmem_cache_create("nlm_host_cache",
+						sizeof(struct nlm_host), 0,
+						SLAB_HWCACHE_ALIGN,
+						nlm_host_init_once);
+	if (nlm_host_cachep == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+/**
+ * nlm_destroy_host_cache - destroy the slab cache for nlm_host entries
+ *
+ */
+void nlm_destroy_host_cache(void)
+{
+	kmem_cache_destroy(nlm_host_cachep);
+}
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index cdfdc4e..e747e48 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -508,12 +508,18 @@ module_param(nsm_use_hostnames, bool, 0644);
 
 static int __init init_nlm(void)
 {
+	if (nlm_init_host_cache())
+		return -ENOMEM;
+
 #ifdef CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
-	return nlm_sysctl_table ? 0 : -ENOMEM;
-#else
-	return 0;
+	if (!nlm_sysctl_table) {
+		nlm_destroy_host_cache();
+		return -ENOMEM;
+	}
 #endif
+
+	return 0;
 }
 
 static void __exit exit_nlm(void)
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 6fc4f3e..73b3b0c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -214,6 +214,8 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
 /*
  * Host cache
  */
+int __init	  nlm_init_host_cache(void);
+void		  nlm_destroy_host_cache(void);
 struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 					const size_t salen,
 					const unsigned short protocol,

