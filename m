Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51531 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2BERE7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 12:04:59 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so1892528eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2012 09:04:59 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v8 07/10] nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
Date: Sun,  5 Feb 2012 18:07:56 +0100
Message-Id: <1328461679-4108-8-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 59d9b4b..620abcc 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1445,7 +1445,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME | OP_CLEAR_STATEID,
 		.op_name = "OP_CREATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_rsize,
 	},
@@ -1491,12 +1491,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
-		.op_flags = OP_HANDLES_WRONGSEC,
+		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
 		.op_name = "OP_LOOKUP",
 	},
 	[OP_LOOKUPP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookupp,
-		.op_flags = OP_HANDLES_WRONGSEC,
+		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
 		.op_name = "OP_LOOKUPP",
 	},
 	[OP_NVERIFY] = {
-- 
1.7.7.6

