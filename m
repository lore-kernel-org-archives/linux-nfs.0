Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:60073 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbaGHSGX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:23 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so5149523qaj.9
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 080/100] nfsd: add a forget_client set_clnt routine
Date: Tue,  8 Jul 2014 14:04:08 -0400
Message-Id: <1404842668-22521-81-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...that relies on the client_lock instead of client_mutex.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |  2 +-
 fs/nfsd/nfs4state.c    | 28 ++++++++++++++++++++++++++++
 fs/nfsd/state.h        |  3 +++
 3 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index a0387fd47e14..5f3ead0c72fb 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -136,7 +136,7 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 		.file     = "forget_clients",
 		.get	  = nfsd_inject_print_clients,
 		.set_val  = nfsd_inject_set,
-		.set_clnt = nfsd_inject_set_client,
+		.set_clnt = nfsd_inject_forget_client,
 		.forget   = nfsd_forget_client,
 	},
 	{
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e929e6f51788..62ac78b28efc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5739,6 +5739,34 @@ u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 	return 1;
 }
 
+u64
+nfsd_inject_forget_client(struct nfsd_fault_inject_op *op,
+			  struct sockaddr_storage *addr, size_t addr_size)
+{
+	u64 count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns,
+					  nfsd_net_id);
+
+	if (!nfsd_netns_ready(nn))
+		return count;
+
+	spin_lock(&nn->client_lock);
+	clp = nfsd_find_client(addr, addr_size);
+	if (clp) {
+		if (mark_client_expired_locked(clp) == nfs_ok)
+			++count;
+		else
+			clp = NULL;
+	}
+	spin_unlock(&nn->client_lock);
+
+	if (clp)
+		expire_client(clp);
+
+	return count;
+}
+
 static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 			     const char *type)
 {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e0bf42051c1f..ead0fe9027fb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -475,6 +475,9 @@ struct nfs4_client *nfsd_find_client(struct sockaddr_storage *, size_t);
 
 u64 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op);
 u64 nfsd_forget_client(struct nfs4_client *, u64);
+u64 nfsd_inject_forget_client(struct nfsd_fault_inject_op *,
+			      struct sockaddr_storage *, size_t);
+
 u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
 u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
-- 
1.9.3

