Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:64184 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235Ab0LIPDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Dec 2010 10:03:21 -0500
From: Tobias Klauser <tklauser@distanz.ch>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Subject: [PATCH] NFS: Remove redundant unlikely()
Date: Thu,  9 Dec 2010 15:53:28 +0100
Message-Id: <1291906408-859-1-git-send-email-tklauser@distanz.ch>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

IS_ERR() already implies unlikely(), so it can be omitted here.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 fs/nfs/mount_clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index eceafe7..3f2a6be 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -248,7 +248,7 @@ void nfs_umount(const struct nfs_mount_request *info)
 		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
 	clnt = rpc_create(&args);
-	if (unlikely(IS_ERR(clnt)))
+	if (IS_ERR(clnt))
 		goto out_clnt_err;
 
 	dprintk("NFS: sending UMNT request for %s:%s\n",
-- 
1.7.0.4

