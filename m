Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15892 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/13] NFS: Remove the BUG_ON() in the mount code
Date: Mon, 15 Oct 2012 17:31:03 -0400
Message-Id: <1350336667-18770-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/mount_clnt.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 8e65c7f..5955181 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -169,6 +169,9 @@ int nfs_mount(struct nfs_mount_request *info)
 		(info->hostname ? info->hostname : "server"),
 			info->dirpath);
 
+	if (strlen(info->dirpath) > MNTPATHLEN)
+		return -ENAMETOOLONG;
+
 	if (info->noresvport)
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
@@ -242,6 +245,9 @@ void nfs_umount(const struct nfs_mount_request *info)
 	struct rpc_clnt *clnt;
 	int status;
 
+	if (strlen(info->dirpath) > MNTPATHLEN)
+		return -ENAMETOOLONG;
+
 	if (info->noresvport)
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
@@ -283,7 +289,6 @@ static void encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 	const u32 pathname_len = strlen(pathname);
 	__be32 *p;
 
-	BUG_ON(pathname_len > MNTPATHLEN);
 	p = xdr_reserve_space(xdr, 4 + pathname_len);
 	xdr_encode_opaque(p, pathname, pathname_len);
 }
-- 
1.7.11.7

