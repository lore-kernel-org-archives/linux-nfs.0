Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36245 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755371Ab0H3Qnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:43:51 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: pnfs-submit: do not use NIPQUAD in nfs4_callback_layoutrecall dprintk
Date: Mon, 30 Aug 2010 19:43:48 +0300
Message-Id: <1283186628-17006-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C7BDD8C.40509@panasas.com>
References: <4C7BDD8C.40509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Not available in 2.6.26

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6107b2e..09991d2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -362,11 +362,8 @@ __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 
 	res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
 	clp  = nfs_find_client(args->cbl_addr, 4);
-	if (clp == NULL) {
-		dprintk("%s: no client for addr %u.%u.%u.%u\n",
-			__func__, NIPQUAD(args->cbl_addr));
+	if (clp == NULL)
 		goto out;
-	}
 
 	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
 	do {
-- 
1.7.2.2

