From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/24] NFSv4: Reduce the stack footprint of try_location()
Date: Fri, 16 Apr 2010 16:31:03 -0400
Message-ID: <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932414Ab0DPUb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:26 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl0026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:25 -0700 (PDT)
In-Reply-To: <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4namespace.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index f071d12..832f9b5 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -115,6 +115,7 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 				     char *page, char *page2,
 				     const struct nfs4_fs_location *location)
 {
+	const size_t addr_bufsize = sizeof(struct sockaddr_storage);
 	struct vfsmount *mnt = ERR_PTR(-ENOENT);
 	char *mnt_path;
 	unsigned int maxbuflen;
@@ -126,9 +127,12 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 	mountdata->mnt_path = mnt_path;
 	maxbuflen = mnt_path - 1 - page2;
 
+	mountdata->addr = kmalloc(addr_bufsize, GFP_KERNEL);
+	if (mountdata->addr == NULL)
+		return ERR_PTR(-ENOMEM);
+
 	for (s = 0; s < location->nservers; s++) {
 		const struct nfs4_string *buf = &location->servers[s];
-		struct sockaddr_storage addr;
 
 		if (buf->len <= 0 || buf->len >= maxbuflen)
 			continue;
@@ -137,11 +141,10 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 			continue;
 
 		mountdata->addrlen = nfs_parse_server_name(buf->data, buf->len,
-				(struct sockaddr *)&addr, sizeof(addr));
+				mountdata->addr, addr_bufsize);
 		if (mountdata->addrlen == 0)
 			continue;
 
-		mountdata->addr = (struct sockaddr *)&addr;
 		rpc_set_port(mountdata->addr, NFS_PORT);
 
 		memcpy(page2, buf->data, buf->len);
@@ -156,6 +159,7 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 		if (!IS_ERR(mnt))
 			break;
 	}
+	kfree(mountdata->addr);
 	return mnt;
 }
 
-- 
1.6.6.1

