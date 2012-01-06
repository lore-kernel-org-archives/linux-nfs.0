Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34396 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933024Ab2AFJmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 04:42:51 -0500
Received: by mail-bk0-f46.google.com with SMTP id jm19so273098bkc.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2012 01:42:51 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v5 5/8] nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
Date: Fri,  6 Jan 2012 10:45:13 +0100
Message-Id: <1325843116-20570-6-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4proc.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 20c8d24..76b96a2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1841,21 +1841,24 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
+				| OP_CLEAR_STATEID,
 		.op_name = "OP_PUTFH",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_PUTPUBFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
+				| OP_CLEAR_STATEID,
 		.op_name = "OP_PUTPUBFH",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
+				| OP_CLEAR_STATEID,
 		.op_name = "OP_PUTROOTFH",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
-- 
1.7.7.5

