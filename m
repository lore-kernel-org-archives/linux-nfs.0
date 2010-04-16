From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/24] NFS: Reduce stack footprint of nfs3_proc_readlink()
Date: Fri, 16 Apr 2010 16:31:13 -0400
Message-ID: <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
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
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3308 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932475Ab0DPUbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:32 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlA026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:31 -0700 (PDT)
In-Reply-To: <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 982a81b..088dceb 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -234,7 +234,7 @@ out:
 static int nfs3_proc_readlink(struct inode *inode, struct page *page,
 		unsigned int pgbase, unsigned int pglen)
 {
-	struct nfs_fattr	fattr;
+	struct nfs_fattr	*fattr;
 	struct nfs3_readlinkargs args = {
 		.fh		= NFS_FH(inode),
 		.pgbase		= pgbase,
@@ -244,14 +244,19 @@ static int nfs3_proc_readlink(struct inode *inode, struct page *page,
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_READLINK],
 		.rpc_argp	= &args,
-		.rpc_resp	= &fattr,
 	};
-	int			status;
+	int status = -ENOMEM;
 
 	dprintk("NFS call  readlink\n");
-	nfs_fattr_init(&fattr);
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto out;
+	msg.rpc_resp = fattr;
+
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_refresh_inode(inode, &fattr);
+	nfs_refresh_inode(inode, fattr);
+	nfs_free_fattr(fattr);
+out:
 	dprintk("NFS reply readlink: %d\n", status);
 	return status;
 }
-- 
1.6.6.1

