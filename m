Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34617 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244Ab2BMVvd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 16:51:33 -0500
Received: by mail-ey0-f174.google.com with SMTP id h12so1933722eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 13:51:32 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bhalevy@tonian.com, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v9 05/10] nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
Date: Mon, 13 Feb 2012 22:54:39 +0100
Message-Id: <1329170084-7032-6-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
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

