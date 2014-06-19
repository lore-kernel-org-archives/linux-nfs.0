Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:61187 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:57 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so2025647qaj.37
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 083/104] nfsd: add a forget_clients "get" routine with proper locking
Date: Thu, 19 Jun 2014 10:50:29 -0400
Message-Id: <1403189450-18729-84-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |  3 +--
 fs/nfsd/nfs4state.c    | 29 +++++++++++++++++++++--------
 fs/nfsd/state.h        |  4 +++-
 3 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index bbb00dcd926a..bbdd6eddb894 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -133,11 +133,10 @@ void nfsd_fault_inject_cleanup(void)
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
index 17fd48561cf8..3ca08358b142 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5570,6 +5570,27 @@ nfs4_check_open_reclaim(clientid_t *clid,
 }
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
+u64
+nfsd_inject_print_clients(struct nfsd_fault_inject_op *op)
+{
+	struct nfs4_client *clp;
+	u64 count = 0;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
+	char buf[INET6_ADDRSTRLEN];
+
+	if (!nfsd_netns_ready(nn))
+		return 0;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, sizeof(buf));
+		printk(KERN_INFO "NFS Client: %s\n", buf);
+		++count;
+	}
+	spin_unlock(&nn->client_lock);
+
+	return count;
+}
 
 u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
@@ -5585,14 +5606,6 @@ u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
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
index 880b5acd05f3..083ebd1c9733 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -467,18 +467,20 @@ extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
 
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

