Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36725 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbC1Psa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:48:30 -0400
Received: by padcy3 with SMTP id cy3so124132532pad.3
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:48:30 -0700 (PDT)
Message-ID: <5516CD45.7060200@gmail.com>
Date: Sat, 28 Mar 2015 23:48:21 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 1/4] nfs: define NFS4_MAXTAGLEN to OPAQUE limits
References: <5516CCDB.4020509@gmail.com>
In-Reply-To: <5516CCDB.4020509@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to rfc3530 and rfc5661, the max tag length should be
limited by opaque limited.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4xdr.c     | 7 -------
 include/linux/nfs4.h | 1 +
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5c399ec..1c2ad01 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -67,13 +67,6 @@
 
 static int nfs4_stat_to_errno(int);
 
-/* NFSv4 COMPOUND tags are only wanted for debugging purposes */
-#ifdef DEBUG
-#define NFS4_MAXTAGLEN		20
-#else
-#define NFS4_MAXTAGLEN		0
-#endif
-
 /* lock,open owner id:
  * we currently use size 2 (u64) out of (NFS4_OPAQUE_LIMIT  >> 2)
  */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index ed43cb7..ba54ec2 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -33,6 +33,7 @@ struct nfs4_acl {
 };
 
 #define NFS4_MAXLABELLEN	2048
+#define NFS4_MAXTAGLEN		NFS4_OPAQUE_LIMIT
 
 struct nfs4_label {
 	uint32_t	lfs;
-- 
2.3.4

