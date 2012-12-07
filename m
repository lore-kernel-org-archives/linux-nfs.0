Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32266 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab2LGVRb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 16:17:31 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSD: Pass correct buffer size to rpc_ntop
Date: Fri,  7 Dec 2012 16:17:28 -0500
Message-Id: <1354915049-6892-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I honestly have no idea where I got 129 from, but it's a much bigger
value than the actual buffer size (INET6_ADDRSTRLEN).

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/fault_inject.c | 2 +-
 fs/nfsd/nfs4state.c    | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 96ffdf5..7a7b079 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -79,7 +79,7 @@ static void nfsd_inject_set_client(struct nfsd_fault_inject_op *op,
 	clp = nfsd_find_client(addr, addr_size);
 	if (clp) {
 		count = op->forget(clp, 0);
-		rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, 129);
+		rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, sizeof(buf));
 		printk(KERN_INFO "NFSD [%s]: Client %s had %llu state object(s)\n", op->file, buf, count);
 	}
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eff7340..ce94174 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4614,7 +4614,7 @@ u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 u64 nfsd_print_client(struct nfs4_client *clp, u64 num)
 {
 	char buf[INET6_ADDRSTRLEN];
-	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, 129);
+	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, sizeof(buf));
 	printk(KERN_INFO "NFS Client: %s\n", buf);
 	return 1;
 }
@@ -4623,7 +4623,7 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 			     const char *type)
 {
 	char buf[INET6_ADDRSTRLEN];
-	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, 129);
+	rpc_ntop((struct sockaddr *)&clp->cl_addr, buf, sizeof(buf));
 	printk(KERN_INFO "NFS Client: %s has %u %s\n", buf, count, type);
 }
 
-- 
1.8.0.1

