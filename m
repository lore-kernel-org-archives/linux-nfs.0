From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/24] NFSv4: Reduce stack footprint of nfs4_proc_access() and nfs3_proc_access()
Date: Fri, 16 Apr 2010 16:31:08 -0400
Message-ID: <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932442Ab0DPUb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:29 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl5026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:28 -0700 (PDT)
In-Reply-To: <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c |   17 ++++++++++-------
 fs/nfs/nfs4proc.c |   11 +++++++----
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 72334c1..9d5d02f 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -181,13 +181,10 @@ nfs3_proc_lookup(struct inode *dir, struct qstr *name,
 
 static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
-	struct nfs_fattr	fattr;
 	struct nfs3_accessargs	arg = {
 		.fh		= NFS_FH(inode),
 	};
-	struct nfs3_accessres	res = {
-		.fattr		= &fattr,
-	};
+	struct nfs3_accessres	res;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_ACCESS],
 		.rpc_argp	= &arg,
@@ -195,7 +192,7 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		.rpc_cred	= entry->cred,
 	};
 	int mode = entry->mask;
-	int status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  access\n");
 
@@ -212,9 +209,13 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		if (mode & MAY_EXEC)
 			arg.access |= NFS3_ACCESS_EXECUTE;
 	}
-	nfs_fattr_init(&fattr);
+
+	res.fattr = nfs_alloc_fattr();
+	if (res.fattr == NULL)
+		goto out;
+
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_refresh_inode(inode, &fattr);
+	nfs_refresh_inode(inode, res.fattr);
 	if (status == 0) {
 		entry->mask = 0;
 		if (res.access & NFS3_ACCESS_READ)
@@ -224,6 +225,8 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		if (res.access & (NFS3_ACCESS_LOOKUP|NFS3_ACCESS_EXECUTE))
 			entry->mask |= MAY_EXEC;
 	}
+	nfs_free_fattr(res.fattr);
+out:
 	dprintk("NFS reply access: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6380670..3acce87 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2404,14 +2404,12 @@ static int nfs4_proc_lookup(struct inode *dir, struct qstr *name, struct nfs_fh
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs_fattr fattr;
 	struct nfs4_accessargs args = {
 		.fh = NFS_FH(inode),
 		.bitmask = server->attr_bitmask,
 	};
 	struct nfs4_accessres res = {
 		.server = server,
-		.fattr = &fattr,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
@@ -2438,7 +2436,11 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		if (mode & MAY_EXEC)
 			args.access |= NFS4_ACCESS_EXECUTE;
 	}
-	nfs_fattr_init(&fattr);
+
+	res.fattr = nfs_alloc_fattr();
+	if (res.fattr == NULL)
+		return -ENOMEM;
+
 	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (!status) {
 		entry->mask = 0;
@@ -2448,8 +2450,9 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 			entry->mask |= MAY_WRITE;
 		if (res.access & (NFS4_ACCESS_LOOKUP|NFS4_ACCESS_EXECUTE))
 			entry->mask |= MAY_EXEC;
-		nfs_refresh_inode(inode, &fattr);
+		nfs_refresh_inode(inode, res.fattr);
 	}
+	nfs_free_fattr(res.fattr);
 	return status;
 }
 
-- 
1.6.6.1

