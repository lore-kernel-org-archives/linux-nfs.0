Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34824 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbbGADz7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:55:59 -0400
Received: by pdbci14 with SMTP id ci14so17688935pdb.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:55:58 -0700 (PDT)
Message-ID: <559364C6.9070308@gmail.com>
Date: Wed, 01 Jul 2015 11:55:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 2/8] nfs: Remove unused argument in nfs_server_set_fsinfo()
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit e38eb6506f "NFS: set_pnfs_layoutdriver() from nfs4_proc_fsinfo()"
have remove the using of mntfh from nfs_server_set_fsinfo().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/client.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 892aeff..a13fada 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -825,7 +825,6 @@ error:
  * Load up the server record from information gained in an fsinfo record
  */
 static void nfs_server_set_fsinfo(struct nfs_server *server,
-				  struct nfs_fh *mntfh,
 				  struct nfs_fsinfo *fsinfo)
 {
 	unsigned long max_rpc_payload;
@@ -901,7 +900,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 	if (error < 0)
 		goto out_error;
 
-	nfs_server_set_fsinfo(server, mntfh, &fsinfo);
+	nfs_server_set_fsinfo(server, &fsinfo);
 
 	/* Get some general file system info */
 	if (server->namelen == 0) {
-- 
2.4.3

