Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:50102 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbaF3Pwq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:46 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so7159783qcr.2
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:46 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 095/114] nfsd: add nfsd_inject_forget_clients
Date: Mon, 30 Jun 2014 11:50:04 -0400
Message-Id: <1404143423-24381-96-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...which uses the client_lock for protection instead of client_mutex.
Also remove nfsd_forget_client as there are no more callers.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |  3 +--
 fs/nfsd/nfs4state.c    | 42 ++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h        |  2 +-
 3 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 5f3ead0c72fb..76ecdff37ea2 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -135,9 +135,8 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 	{
 		.file     = "forget_clients",
 		.get	  = nfsd_inject_print_clients,
-		.set_val  = nfsd_inject_set,
+		.set_val  = nfsd_inject_forget_clients,
 		.set_clnt = nfsd_inject_forget_client,
-		.forget   = nfsd_forget_client,
 	},
 	{
 		.file     = "forget_locks",
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2795f549e29e..f395afc19d4c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5687,20 +5687,6 @@ nfsd_inject_print_clients(struct nfsd_fault_inject_op *op)
 	return count;
 }
 
-u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
-{
-	__be32 ret;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	spin_lock(&nn->client_lock);
-	ret = mark_client_expired_locked(clp);
-	spin_unlock(&nn->client_lock);
-	if (ret != nfs_ok)
-		return 0;
-	expire_client(clp);
-	return 1;
-}
-
 u64
 nfsd_inject_forget_client(struct nfsd_fault_inject_op *op,
 			  struct sockaddr_storage *addr, size_t addr_size)
@@ -5729,6 +5715,34 @@ nfsd_inject_forget_client(struct nfsd_fault_inject_op *op,
 	return count;
 }
 
+u64
+nfsd_inject_forget_clients(struct nfsd_fault_inject_op *op, u64 max)
+{
+	u64 count = 0;
+	struct nfs4_client *clp, *next;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+						nfsd_net_id);
+	LIST_HEAD(reaplist);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
+		if (mark_client_expired_locked(clp) == nfs_ok) {
+			list_add(&clp->cl_lru, &reaplist);
+			if (max != 0 && ++count >= max)
+				break;
+		}
+	}
+	spin_unlock(&nn->client_lock);
+
+	list_for_each_entry_safe(clp, next, &reaplist, cl_lru)
+		expire_client(clp);
+
+	return count;
+}
+
 static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 			     const char *type)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ead0fe9027fb..25b4df7bc57a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -474,9 +474,9 @@ u64 nfsd_for_n_state(u64, u64 (*)(struct nfs4_client *, u64));
 struct nfs4_client *nfsd_find_client(struct sockaddr_storage *, size_t);
 
 u64 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op);
-u64 nfsd_forget_client(struct nfs4_client *, u64);
 u64 nfsd_inject_forget_client(struct nfsd_fault_inject_op *,
 			      struct sockaddr_storage *, size_t);
+u64 nfsd_inject_forget_clients(struct nfsd_fault_inject_op *, u64);
 
 u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
 u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
-- 
1.9.3

