Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:32123 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757568Ab2EERYe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 May 2012 13:24:34 -0400
Subject: [PATCH RFC 04/13] LockD: manage used host count per networks namespace
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Sat, 05 May 2012 21:22:01 +0400
Message-ID: <20120505172201.11559.25510.stgit@localhost.localdomain>
In-Reply-To: <20120505170722.11559.74503.stgit@localhost.localdomain>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch introduces moves nrhosts in per-net data.
It also adds kernel warning to nlm_shutdown_hosts_net() about remaining hosts
in specified network namespace context.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/host.c  |   18 ++++++++++++++++++
 fs/lockd/netns.h |    1 +
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 3636734..6c56090 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -173,6 +173,7 @@ out:
 static void nlm_destroy_host_locked(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
+	struct lockd_net *ln = net_generic(host->net, lockd_net_id);
 
 	dprintk("lockd: destroy host %s\n", host->h_name);
 
@@ -189,6 +190,7 @@ static void nlm_destroy_host_locked(struct nlm_host *host)
 		rpc_shutdown_client(clnt);
 	kfree(host);
 
+	ln->nrhosts--;
 	nrhosts--;
 }
 
@@ -229,6 +231,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 	struct nsm_handle *nsm = NULL;
+	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	dprintk("lockd: %s(host='%s', vers=%u, proto=%s)\n", __func__,
 			(hostname ? hostname : "<none>"), version,
@@ -263,6 +266,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		goto out;
 
 	hlist_add_head(&host->h_hash, chain);
+	ln->nrhosts++;
 	nrhosts++;
 
 	dprintk("lockd: %s created host %s (%s)\n", __func__,
@@ -384,6 +388,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	memcpy(nlm_srcaddr(host), src_sap, src_len);
 	host->h_srcaddrlen = src_len;
 	hlist_add_head(&host->h_hash, chain);
+	ln->nrhosts++;
 	nrhosts++;
 
 	dprintk("lockd: %s created host %s (%s)\n",
@@ -592,6 +597,19 @@ nlm_shutdown_hosts_net(struct net *net)
 	/* Then, perform a garbage collection pass */
 	nlm_gc_hosts(net);
 	mutex_unlock(&nlm_host_mutex);
+
+	/* complain if any hosts are left */
+	if (net) {
+		struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+		printk(KERN_WARNING "lockd: couldn't shutdown host module for net %p!\n", net);
+		dprintk("lockd: %lu hosts left in net %p:\n", ln->nrhosts, net);
+		for_each_host(host, pos, chain, nlm_server_hosts) {
+			dprintk("       %s (cnt %d use %d exp %ld net %p)\n",
+				host->h_name, atomic_read(&host->h_count),
+				host->h_inuse, host->h_expires, host->net);
+		}
+	}
 }
 
 /*
diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
index 97c6c77..44c8f0b 100644
--- a/fs/lockd/netns.h
+++ b/fs/lockd/netns.h
@@ -6,6 +6,7 @@
 struct lockd_net {
 	unsigned int nlmsvc_users;
 	unsigned long next_gc;
+	unsigned long nrhosts;
 };
 
 extern int lockd_net_id;

