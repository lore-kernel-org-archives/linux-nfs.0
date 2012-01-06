Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60115 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933108Ab2AFJmy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 04:42:54 -0500
Received: by mail-ey0-f174.google.com with SMTP id d14so860462eaa.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2012 01:42:53 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v5 7/8] nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
Date: Fri,  6 Jan 2012 10:45:15 +0100
Message-Id: <1325843116-20570-8-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4b32672..8ee49d8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1763,7 +1763,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME | OP_CLEAR_STATEID,
 		.op_name = "OP_CREATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_rsize,
 	},
@@ -1809,12 +1809,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
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

