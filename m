Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49487 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755043Ab1DFJFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 05:05:25 -0400
Message-ID: <4D9C2CB2.7000101@cn.fujitsu.com>
Date: Wed, 06 Apr 2011 17:04:50 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: make sure nfs server process OPEN with EXCLUSIVE4_1
 correcttly
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At the recent kernel(2.6.39-rc1), NFS server can't process OPEN with EXCLUSIVE4_1,
because NFS server call nfsd_create_v3 to create file instead implement a separate
one. But nfsd_create_v3 can't process createmode is EXCLUSIVE4_1.

According to RFC5661, at nfsd_create_v3, EXCLUSIVE4_1 should be processed as 
EXCLUSIVE4.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4proc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5fcb139..5325490 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -173,7 +173,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 {
 	struct svc_fh resfh;
 	__be32 status;
-	int created = 0;
+	int created = 0, createmode = 0;
 
 	fh_init(&resfh, NFS4_FHSIZE);
 	open->op_truncate = 0;
@@ -196,11 +196,16 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 
 		/*
 		 * Note: create modes (UNCHECKED,GUARDED...) are the same
-		 * in NFSv4 as in v3.
+		 * in NFSv4 as in v3 except EXCLUSIVE4_1.
 		 */
+		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE4_1)
+			createmode = NFS4_CREATE_EXCLUSIVE;
+		else
+			createmode = open->op_createmode;
+
 		status = nfsd_create_v3(rqstp, current_fh, open->op_fname.data,
 					open->op_fname.len, &open->op_iattr,
-					&resfh, open->op_createmode,
+					&resfh, createmode,
 					(u32 *)open->op_verf.data,
 					&open->op_truncate, &created);
 
-- 
1.7.4.1



