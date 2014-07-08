Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:64181 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755388AbaGHSGW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:22 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so5478817qgd.10
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 079/100] nfsd: add a forget_clients "get" routine with proper locking
Date: Tue,  8 Jul 2014 14:04:07 -0400
Message-Id: <1404842668-22521-80-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new "get" routine for forget_clients that relies on the
client_lock instead of the client_mutex.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |  3 +--
 fs/nfsd/nfs4state.c    | 30 ++++++++++++++++++++++--------
 fs/nfsd/state.h        |  4 +++-
 3 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index b1159900d934..a0387fd47e14 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -134,11 +134,10 @@ void nfsd_fault_inject_cleanup(void)
 static struct nfsd_fault_inject_op inject_ops[] = {
 	{
 		.file     = "forget_clients",
-		.get	  = nfsd_inject_get,
+		.get	  = nfsd_inject_print_clients,
 		.set_val  = nfsd_inject_set,
 		.set_clnt = nfsd_inject_set_client,
 		.forget   = nfsd_forget_client,
-		.print    = nfsd_print_client,
 	},
 	{
 		.file     = "forget_locks",
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc2abf9428af..e929e6f51788 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5702,6 +5702,28 @@ nfs4_check_open_reclaim(clientid_t *clid,
 }
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
+u64
+nfsd_inject_print_clients(struct nfsd_fault_inject_op *op)
+{
+	struct nfs4_client *clp;
+	u64 count = 0;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+					  nfsd_net_id);
+	char buf[INET6_ADDRSTRLEN];
+
+	if (!nfsd_netns_ready(nn))
+		return 0;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, sizeof(buf));
+		pr_info("NFS Client: %s\n", buf);
+		++count;
+	}
+	spin_unlock(&nn->client_lock);
+
+	return count;
+}
 
 u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
@@ -5717,14 +5739,6 @@ u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 	return 1;
 }
 
-u64 nfsd_print_client(struct nfs4_client *clp, u64 num)
-{
-	char buf[INET6_ADDRSTRLEN];
-	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, sizeof(buf));
-	printk(KERN_INFO "NFS Client: %s\n", buf);
-	return 1;
-}
-
 static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 			     const char *type)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7e395f665b0f..e0bf42051c1f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -466,18 +466,20 @@ extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 
 /* nfs fault injection functions */
 #ifdef CONFIG_NFSD_FAULT_INJECTION
+struct nfsd_fault_inject_op;
+
 int nfsd_fault_inject_init(void);
 void nfsd_fault_inject_cleanup(void);
 u64 nfsd_for_n_state(u64, u64 (*)(struct nfs4_client *, u64));
 struct nfs4_client *nfsd_find_client(struct sockaddr_storage *, size_t);
 
+u64 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op);
 u64 nfsd_forget_client(struct nfs4_client *, u64);
 u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
 u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
 u64 nfsd_recall_client_delegations(struct nfs4_client *, u64);
 
-u64 nfsd_print_client(struct nfs4_client *, u64);
 u64 nfsd_print_client_locks(struct nfs4_client *, u64);
 u64 nfsd_print_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_print_client_delegations(struct nfs4_client *, u64);
-- 
1.9.3

