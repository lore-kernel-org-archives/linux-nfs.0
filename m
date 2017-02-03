Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33955 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752286AbdBCOwn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 09:52:43 -0500
Received: by mail-io0-f193.google.com with SMTP id c80so2420052iod.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 Feb 2017 06:52:42 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/2] NFSD: Reserve adequate space for LOCKT operation
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <941e34dd-f93c-cd20-e397-d4829766a244@gmail.com>
Date: Fri, 3 Feb 2017 22:51:46 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Process OP_LOCKT of getting response size as LOCK operation,
get some warning message as, 

[11512.783519] RPC request reserved 124 but used 152
[11512.813624] RPC request reserved 108 but used 136

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8fae53c..14aa53e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1941,12 +1941,12 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		} else
 			max_reply += nfsd4_max_reply(argp->rqstp, op);
 		/*
-		 * OP_LOCK may return a conflicting lock.  (Special case
-		 * because it will just skip encoding this if it runs
-		 * out of xdr buffer space, and it is the only operation
-		 * that behaves this way.)
+		 * OP_LOCK and OP_LOCKT may return a conflicting lock.
+		 * (Special case because it will just skip encoding this
+		 * if it runs out of xdr buffer space, and it is the only
+		 * operation that behaves this way.)
 		 */
-		if (op->opnum == OP_LOCK)
+		if (op->opnum == OP_LOCK || op->opnum == OP_LOCKT)
 			max_reply += NFS4_OPAQUE_LIMIT;
 
 		if (op->status) {
-- 
2.9.3

