Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53068 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab2AVSnY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2012 13:43:24 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so1081297eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 22 Jan 2012 10:43:23 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v7 07/10] nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
Date: Sun, 22 Jan 2012 19:46:06 +0100
Message-Id: <1327257968-14522-8-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1327257968-14522-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1327257968-14522-1-git-send-email-tigran.mkrtchyan@desy.de>
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
1.7.7.5

