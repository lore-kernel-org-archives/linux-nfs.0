From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/24] NFS: Reduce stack footprint of nfs3_proc_getacl() and nfs3_proc_setacl()
Date: Fri, 16 Apr 2010 16:31:21 -0400
Message-ID: <1271449882-8580-24-git-send-email-Trond.Myklebust@netapp.com>
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
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-21-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-22-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-23-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16405 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932487Ab0DPUbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:39 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlI026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:38 -0700 (PDT)
In-Reply-To: <1271449882-8580-23-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3acl.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index d150ae0..9f88c5f 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -185,7 +185,6 @@ static void nfs3_cache_acls(struct inode *inode, struct posix_acl *acl,
 struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs_fattr fattr;
 	struct page *pages[NFSACL_MAXPAGES] = { };
 	struct nfs3_getaclargs args = {
 		.fh = NFS_FH(inode),
@@ -193,7 +192,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 		.pages = pages,
 	};
 	struct nfs3_getaclres res = {
-		.fattr =	&fattr,
+		0
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
@@ -228,7 +227,10 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 
 	dprintk("NFS call getacl\n");
 	msg.rpc_proc = &server->client_acl->cl_procinfo[ACLPROC3_GETACL];
-	nfs_fattr_init(&fattr);
+	res.fattr = nfs_alloc_fattr();
+	if (res.fattr == NULL)
+		return ERR_PTR(-ENOMEM);
+
 	status = rpc_call_sync(server->client_acl, &msg, 0);
 	dprintk("NFS reply getacl: %d\n", status);
 
@@ -238,7 +240,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 
 	switch (status) {
 		case 0:
-			status = nfs_refresh_inode(inode, &fattr);
+			status = nfs_refresh_inode(inode, res.fattr);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
@@ -278,6 +280,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 getout:
 	posix_acl_release(res.acl_access);
 	posix_acl_release(res.acl_default);
+	nfs_free_fattr(res.fattr);
 
 	if (status != 0) {
 		posix_acl_release(acl);
@@ -290,7 +293,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		  struct posix_acl *dfacl)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs_fattr fattr;
+	struct nfs_fattr *fattr;
 	struct page *pages[NFSACL_MAXPAGES];
 	struct nfs3_setaclargs args = {
 		.inode = inode,
@@ -335,8 +338,13 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	}
 
 	dprintk("NFS call setacl\n");
+	status = -ENOMEM;
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto out_freepages;
+
 	msg.rpc_proc = &server->client_acl->cl_procinfo[ACLPROC3_SETACL];
-	nfs_fattr_init(&fattr);
+	msg.rpc_resp = fattr;
 	status = rpc_call_sync(server->client_acl, &msg, 0);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
@@ -344,7 +352,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 
 	switch (status) {
 		case 0:
-			status = nfs_refresh_inode(inode, &fattr);
+			status = nfs_refresh_inode(inode, fattr);
 			nfs3_cache_acls(inode, acl, dfacl);
 			break;
 		case -EPFNOSUPPORT:
@@ -355,6 +363,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 	}
+	nfs_free_fattr(fattr);
 out_freepages:
 	while (args.npages != 0) {
 		args.npages--;
-- 
1.6.6.1

