Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46821 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757177Ab0LNPGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:06:16 -0500
Received: by ywl5 with SMTP id 5so382484ywl.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:06:15 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/11] lockd: Clean up nlmsvc_lookup_host()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:06:12 -0500
Message-ID: <20101214150612.2736.43587.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Change nlmsvc_lookup_host() to be purpose-built for server-side
nlm_host management.  This replaces the generic nlm_lookup_host()
helper function, just like on the client side.  The lookup logic is
specialized for server host lookups.

The server side cache also gets its own specialized equivalent of the
nlm_release_host() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   91 ++++++++++++++++++++++++++++++++++---------
 fs/lockd/svc4proc.c         |   16 ++++----
 fs/lockd/svcproc.c          |   18 ++++-----
 include/linux/lockd/lockd.h |    2 -
 4 files changed, 90 insertions(+), 37 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index c6942fb..0250b0e 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -383,6 +383,10 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 				    const char *hostname,
 				    const size_t hostname_len)
 {
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+	struct nlm_host	*host = NULL;
+	struct nsm_handle *nsm = NULL;
 	struct sockaddr_in sin = {
 		.sin_family	= AF_INET,
 	};
@@ -404,6 +408,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 			(int)hostname_len, hostname, rqstp->rq_vers,
 			(rqstp->rq_prot == IPPROTO_UDP ? "udp" : "tcp"));
 
+	mutex_lock(&nlm_host_mutex);
+
 	switch (ni.sap->sa_family) {
 	case AF_INET:
 		sin.sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
@@ -414,10 +420,73 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 		ni.src_sap = (struct sockaddr *)&sin6;
 		break;
 	default:
-		return NULL;
+		dprintk("lockd: %s failed; unrecognized address family\n",
+			__func__);
+		goto out;
 	}
 
-	return nlm_lookup_host(&ni);
+	if (time_after_eq(jiffies, next_gc))
+		nlm_gc_hosts();
+
+	chain = &nlm_hosts[nlm_hash_address(ni.sap)];
+	hlist_for_each_entry(host, pos, chain, h_hash) {
+		if (!rpc_cmp_addr(nlm_addr(host), ni.sap))
+			continue;
+
+		/* Same address. Share an NSM handle if we already have one */
+		if (nsm == NULL)
+			nsm = host->h_nsmhandle;
+
+		if (host->h_proto != ni.protocol)
+			continue;
+		if (host->h_version != ni.version)
+			continue;
+		if (!rpc_cmp_addr(nlm_srcaddr(host), ni.src_sap))
+			continue;
+
+		/* Move to head of hash chain. */
+		hlist_del(&host->h_hash);
+		hlist_add_head(&host->h_hash, chain);
+
+		nlm_get_host(host);
+		dprintk("lockd: %s found host %s (%s)\n",
+			__func__, host->h_name, host->h_addrbuf);
+		goto out;
+	}
+
+	host = nlm_alloc_host(&ni, nsm);
+	if (unlikely(host == NULL))
+		goto out;
+
+	memcpy(nlm_srcaddr(host), ni.src_sap, ni.src_len);
+	host->h_srcaddrlen = ni.src_len;
+	hlist_add_head(&host->h_hash, chain);
+	nrhosts++;
+
+	dprintk("lockd: %s created host %s (%s)\n",
+		__func__, host->h_name, host->h_addrbuf);
+
+out:
+	mutex_unlock(&nlm_host_mutex);
+	return host;
+}
+
+/**
+ * nlmsvc_release_host - release server nlm_host
+ * @host: nlm_host to release
+ *
+ * Host is destroyed later in nlm_gc_host().
+ */
+void nlmsvc_release_host(struct nlm_host *host)
+{
+	if (host == NULL)
+		return;
+
+	dprintk("lockd: release server host %s\n", host->h_name);
+
+	BUG_ON(atomic_read(&host->h_count) < 0);
+	BUG_ON(!host->h_server);
+	atomic_dec(&host->h_count);
 }
 
 /*
@@ -517,22 +586,6 @@ struct nlm_host * nlm_get_host(struct nlm_host *host)
 	return host;
 }
 
-/*
- * Release NLM host after use
- */
-void nlm_release_host(struct nlm_host *host)
-{
-	if (host != NULL) {
-		dprintk("lockd: release host %s\n", host->h_name);
-		BUG_ON(atomic_read(&host->h_count) < 0);
-		if (atomic_dec_and_test(&host->h_count)) {
-			BUG_ON(!list_empty(&host->h_lockowners));
-			BUG_ON(!list_empty(&host->h_granted));
-			BUG_ON(!list_empty(&host->h_reclaim));
-		}
-	}
-}
-
 static struct nlm_host *next_host_state(struct hlist_head *cache,
 					struct nsm_handle *nsm,
 					const struct nlm_reboot *info)
@@ -581,7 +634,7 @@ void nlm_host_rebooted(const struct nlm_reboot *info)
 	 */
 	while ((host = next_host_state(nlm_hosts, nsm, info)) != NULL) {
 		nlmsvc_free_host_resources(host);
-		nlm_release_host(host);
+		nlmsvc_release_host(host);
 	}
 	while ((host = next_host_state(nlm_client_hosts, nsm, info)) != NULL) {
 		nlmclnt_recovery(host);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index c187422..9a41fdc 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -51,7 +51,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return 0;
 
 no_locks:
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
  	if (error)
 		return error;	
 	return nlm_lck_denied_nolocks;
@@ -92,7 +92,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	else
 		dprintk("lockd: TEST4        status %d\n", ntohl(resp->status));
 
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rc;
 }
@@ -134,7 +134,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	else
 		dprintk("lockd: LOCK         status %d\n", ntohl(resp->status));
 
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rc;
 }
@@ -164,7 +164,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = nlmsvc_cancel_blocked(file, &argp->lock);
 
 	dprintk("lockd: CANCEL        status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -197,7 +197,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = nlmsvc_unlock(file, &argp->lock);
 
 	dprintk("lockd: UNLOCK        status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -334,7 +334,7 @@ nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = nlmsvc_share_file(host, file, argp);
 
 	dprintk("lockd: SHARE         status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -367,7 +367,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = nlmsvc_unshare_file(host, file, argp);
 
 	dprintk("lockd: UNSHARE       status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -399,7 +399,7 @@ nlm4svc_proc_free_all(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return rpc_success;
 
 	nlmsvc_free_host_resources(host);
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	return rpc_success;
 }
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 0df65ec..d27aab1 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -80,7 +80,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return 0;
 
 no_locks:
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	if (error)
 		return error;
 	return nlm_lck_denied_nolocks;
@@ -122,7 +122,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		dprintk("lockd: TEST          status %d vers %d\n",
 			ntohl(resp->status), rqstp->rq_vers);
 
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rc;
 }
@@ -164,7 +164,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	else
 		dprintk("lockd: LOCK         status %d\n", ntohl(resp->status));
 
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rc;
 }
@@ -194,7 +194,7 @@ nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = cast_status(nlmsvc_cancel_blocked(file, &argp->lock));
 
 	dprintk("lockd: CANCEL        status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -227,7 +227,7 @@ nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = cast_status(nlmsvc_unlock(file, &argp->lock));
 
 	dprintk("lockd: UNLOCK        status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -261,7 +261,7 @@ void nlmsvc_release_call(struct nlm_rqst *call)
 {
 	if (!atomic_dec_and_test(&call->a_count))
 		return;
-	nlm_release_host(call->a_host);
+	nlmsvc_release_host(call->a_host);
 	kfree(call);
 }
 
@@ -374,7 +374,7 @@ nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = cast_status(nlmsvc_share_file(host, file, argp));
 
 	dprintk("lockd: SHARE         status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -407,7 +407,7 @@ nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->status = cast_status(nlmsvc_unshare_file(host, file, argp));
 
 	dprintk("lockd: UNSHARE       status %d\n", ntohl(resp->status));
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	nlm_release_file(file);
 	return rpc_success;
 }
@@ -439,7 +439,7 @@ nlmsvc_proc_free_all(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return rpc_success;
 
 	nlmsvc_free_host_resources(host);
-	nlm_release_host(host);
+	nlmsvc_release_host(host);
 	return rpc_success;
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 6c2a0e2..ff9abff 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -227,10 +227,10 @@ void		  nlmclnt_release_host(struct nlm_host *);
 struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 					const char *hostname,
 					const size_t hostname_len);
+void		  nlmsvc_release_host(struct nlm_host *);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
-void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
 void		  nlm_host_rebooted(const struct nlm_reboot *);
 

