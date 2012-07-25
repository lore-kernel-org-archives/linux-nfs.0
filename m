Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:36937 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659Ab2GYM5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jul 2012 08:57:20 -0400
Subject: [PATCH v2 01/15] LockD: mark host per network namespace on garbage
	collect
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Jul 2012 16:55:54 +0400
Message-ID: <20120725125554.24376.79319.stgit@localhost.localdomain>
In-Reply-To: <20120725125258.24376.82525.stgit@localhost.localdomain>
References: <20120725125258.24376.82525.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is required for per-network NLM shutdown and cleanup.
This patch passes init_net for a while.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/host.c             |    3 ++-
 fs/lockd/svcsubs.c          |   19 +++++++++++++------
 include/linux/lockd/lockd.h |    2 +-
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index eb75ca7..2c5f41b 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -628,13 +628,14 @@ nlm_gc_hosts(void)
 	struct hlist_head *chain;
 	struct hlist_node *pos, *next;
 	struct nlm_host	*host;
+	struct net *net = &init_net;
 
 	dprintk("lockd: host garbage collection\n");
 	for_each_host(host, pos, chain, nlm_server_hosts)
 		host->h_inuse = 0;
 
 	/* Mark all hosts that hold locks, blocks or shares */
-	nlmsvc_mark_resources();
+	nlmsvc_mark_resources(net);
 
 	for_each_host_safe(host, pos, next, chain, nlm_server_hosts) {
 		if (atomic_read(&host->h_count) || host->h_inuse
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 2240d38..0deb5f6 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -309,7 +309,8 @@ nlm_release_file(struct nlm_file *file)
  * Helpers function for resource traversal
  *
  * nlmsvc_mark_host:
- *	used by the garbage collector; simply sets h_inuse.
+ *	used by the garbage collector; simply sets h_inuse only for those
+ *	hosts, which passed network check.
  *	Always returns 0.
  *
  * nlmsvc_same_host:
@@ -320,12 +321,15 @@ nlm_release_file(struct nlm_file *file)
  *	returns 1 iff the host is a client.
  *	Used by nlmsvc_invalidate_all
  */
+
 static int
-nlmsvc_mark_host(void *data, struct nlm_host *dummy)
+nlmsvc_mark_host(void *data, struct nlm_host *hint)
 {
 	struct nlm_host *host = data;
 
-	host->h_inuse = 1;
+	if ((hint->net == NULL) ||
+	    (host->net == hint->net))
+		host->h_inuse = 1;
 	return 0;
 }
 
@@ -358,10 +362,13 @@ nlmsvc_is_client(void *data, struct nlm_host *dummy)
  * Mark all hosts that still hold resources
  */
 void
-nlmsvc_mark_resources(void)
+nlmsvc_mark_resources(struct net *net)
 {
-	dprintk("lockd: nlmsvc_mark_resources\n");
-	nlm_traverse_files(NULL, nlmsvc_mark_host, NULL);
+	struct nlm_host hint;
+
+	dprintk("lockd: nlmsvc_mark_resources for net %p\n", net);
+	hint.net = net;
+	nlm_traverse_files(&hint, nlmsvc_mark_host, NULL);
 }
 
 /*
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index f04ce6a..50e31a2 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -279,7 +279,7 @@ void		  nlmsvc_release_call(struct nlm_rqst *);
 __be32		  nlm_lookup_file(struct svc_rqst *, struct nlm_file **,
 					struct nfs_fh *);
 void		  nlm_release_file(struct nlm_file *);
-void		  nlmsvc_mark_resources(void);
+void		  nlmsvc_mark_resources(struct net *);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 

