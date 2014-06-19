Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:49864 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOw6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:58 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so2225518qgf.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 084/104] nfsd: add a forget_client set_clnt routine
Date: Thu, 19 Jun 2014 10:50:30 -0400
Message-Id: <1403189450-18729-85-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/fault_inject.c |  2 +-
 fs/nfsd/nfs4state.c    | 27 +++++++++++++++++++++++++++
 fs/nfsd/state.h        |  2 ++
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index bbdd6eddb894..e24d7f301b71 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -135,7 +135,7 @@ static struct nfsd_fault_inject_op inject_ops[] = {
 		.file     = "forget_clients",
 		.get	  = nfsd_inject_print_clients,
 		.set_val  = nfsd_inject_set,
-		.set_clnt = nfsd_inject_set_client,
+		.set_clnt = nfsd_inject_forget_client,
 		.forget   = nfsd_forget_client,
 	},
 	{
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3ca08358b142..6da8766b87dd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5606,6 +5606,33 @@ u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 	return 1;
 }
 
+u64
+nfsd_inject_forget_client(struct nfsd_fault_inject_op *op,
+			  struct sockaddr_storage *addr, size_t addr_size)
+{
+	u64 count = 0;
+	struct nfs4_client *clp;
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
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
index 083ebd1c9733..dfcb72a936b3 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -476,6 +476,8 @@ struct nfs4_client *nfsd_find_client(struct sockaddr_storage *, size_t);
 
 u64 nfsd_inject_print_clients(struct nfsd_fault_inject_op *op);
 u64 nfsd_forget_client(struct nfs4_client *, u64);
+u64 nfsd_inject_forget_client(struct nfsd_fault_inject_op *, struct sockaddr_storage *, size_t);
+
 u64 nfsd_forget_client_locks(struct nfs4_client*, u64);
 u64 nfsd_forget_client_openowners(struct nfs4_client *, u64);
 u64 nfsd_forget_client_delegations(struct nfs4_client *, u64);
-- 
1.9.3

