Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46795 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933804AbdDGSQC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:02 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 25/34] NFS: Clean up nfs4_get_rootfh()
Date: Fri, 7 Apr 2017 14:15:19 -0400
Message-ID: <20170407181528.2832-26-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4getroot.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/nfs4getroot.c b/fs/nfs/nfs4getroot.c
index 039b3eb6d834..ac8406018962 100644
--- a/fs/nfs/nfs4getroot.c
+++ b/fs/nfs/nfs4getroot.c
@@ -14,8 +14,6 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool auth_p
 	struct nfs_fsinfo fsinfo;
 	int ret = -ENOMEM;
 
-	dprintk("--> nfs4_get_rootfh()\n");
-
 	fsinfo.fattr = nfs_alloc_fattr();
 	if (fsinfo.fattr == NULL)
 		goto out;
@@ -38,6 +36,5 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool auth_p
 	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
 out:
 	nfs_free_fattr(fsinfo.fattr);
-	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
 	return ret;
 }
-- 
2.12.2

