Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51531 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2BERE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 12:04:56 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so1892528eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2012 09:04:56 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v8 05/10] nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
Date: Sun,  5 Feb 2012 18:07:54 +0100
Message-Id: <1328461679-4108-6-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4proc.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9a61bbf..66bd005 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1523,21 +1523,24 @@ static struct nfsd4_operation nfsd4_ops[] = {
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
1.7.7.6

