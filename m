Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757953Ab2FTTyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:06 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/10] NFS: set_pnfs_layoutdriver() from nfs4_proc_fsinfo()
Date: Wed, 20 Jun 2012 15:53:40 -0400
Message-Id: <1340222029-18027-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The generic client doesn't need to know about pnfs layout drivers, so
this should be done in the v4 code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c   | 1 -
 fs/nfs/nfs4proc.c | 8 +++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f005b5b..e646b14 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -975,7 +975,6 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	server->pnfs_blksize = fsinfo->blksize;
-	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a7b372..a533e63 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3330,8 +3330,14 @@ static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, str
 
 static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
 {
+	int error;
+
 	nfs_fattr_init(fsinfo->fattr);
-	return nfs4_do_fsinfo(server, fhandle, fsinfo);
+	error = nfs4_do_fsinfo(server, fhandle, fsinfo);
+	if (error == 0)
+		set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
+
+	return error;
 }
 
 static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
-- 
1.7.11

