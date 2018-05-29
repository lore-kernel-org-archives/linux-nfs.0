Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:37370 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934948AbeE2PsN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:48:13 -0400
Received: by mail-io0-f193.google.com with SMTP id e20-v6so18158961iof.4
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:48:13 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id t7-v6sm7000580ite.35.2018.05.29.08.48.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:48:11 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Only pass the delegation to setattr if we're sending a truncate
Date: Tue, 29 May 2018 11:47:50 -0400
Message-Id: <20180529154750.12783-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Even then it isn't really necessary. The reason why we may not want to
pass in a stateid in other cases is that we cannot use the delegation
credential.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 553cb8f98194..844eafbf1564 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3032,7 +3032,6 @@ static int _nfs4_do_setattr(struct inode *inode,
 	};
 	struct rpc_cred *delegation_cred = NULL;
 	unsigned long timestamp = jiffies;
-	fmode_t fmode;
 	bool truncate;
 	int status;
 
@@ -3040,11 +3039,12 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 	/* Servers should only apply open mode checks for file size changes */
 	truncate = (arg->iap->ia_valid & ATTR_SIZE) ? true : false;
-	fmode = truncate ? FMODE_WRITE : FMODE_READ;
+	if (!truncate)
+		goto zero_stateid;
 
-	if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, &delegation_cred)) {
+	if (nfs4_copy_delegation_stateid(inode, FMODE_WRITE, &arg->stateid, &delegation_cred)) {
 		/* Use that stateid */
-	} else if (truncate && ctx != NULL) {
+	} else if (ctx != NULL) {
 		struct nfs_lock_context *l_ctx;
 		if (!nfs4_valid_open_stateid(ctx->state))
 			return -EBADF;
@@ -3056,8 +3056,10 @@ static int _nfs4_do_setattr(struct inode *inode,
 		nfs_put_lock_context(l_ctx);
 		if (status == -EIO)
 			return -EBADF;
-	} else
+	} else {
+zero_stateid:
 		nfs4_stateid_copy(&arg->stateid, &zero_stateid);
+	}
 	if (delegation_cred)
 		msg.rpc_cred = delegation_cred;
 
-- 
2.17.0

