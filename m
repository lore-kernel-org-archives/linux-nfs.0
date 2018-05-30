Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:38769 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbeE3CZi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 22:25:38 -0400
Received: by mail-it0-f65.google.com with SMTP id q4-v6so21488659ite.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 19:25:37 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id h197-v6sm8484393itb.27.2018.05.29.19.25.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 19:25:36 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Always clear the pNFS layout when handling ESTALE
Date: Tue, 29 May 2018 22:25:15 -0400
Message-Id: <20180530022515.39670-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we get an ESTALE error in response to an RPC call operating on the
file on the MDS, we should immediately cancel the layout for that file.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs42proc.c | 5 +++++
 fs/nfs/nfs4proc.c  | 6 ++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 4d4a3df28779..286731b22792 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -370,6 +370,11 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case 0:
 		break;
+	case -NFS4ERR_BADHANDLE:
+	case -NFS4ERR_STALE:
+	case -ESTALE:
+		pnfs_destroy_layout(NFS_I(inode));
+		break;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_DELEG_REVOKED:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 07a7f2d8f3e2..66664d814b3c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -407,6 +407,12 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 	switch(errorcode) {
 		case 0:
 			return 0;
+		case -NFS4ERR_BADHANDLE:
+		case -NFS4ERR_STALE:
+		case -ESTALE:
+			if (inode != NULL && S_ISREG(inode->i_mode))
+				pnfs_destroy_layout(NFS_I(inode));
+			break;
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_EXPIRED:
-- 
2.17.0

