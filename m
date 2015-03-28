Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34306 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbC1PqS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:46:18 -0400
Received: by pacwe9 with SMTP id we9so124101928pac.1
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:46:18 -0700 (PDT)
Message-ID: <5516CCC1.2090608@gmail.com>
Date: Sat, 28 Mar 2015 23:46:09 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] nfsd: Remove duplicate macro define for max sec label length
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4_MAXLABELLEN has defined for sec label max length, use it directly.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 2 +-
 fs/nfsd/nfs4xdr.c  | 2 +-
 fs/nfsd/xdr4.h     | 1 -
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d30bea8..6bd4391 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1815,7 +1815,7 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
 		bmap0 &= ~FATTR4_WORD0_FILEHANDLE;
 	}
 	if (bmap2 & FATTR4_WORD2_SECURITY_LABEL) {
-		ret += NFSD4_MAX_SEC_LABEL_LEN + 12;
+		ret += NFS4_MAXLABELLEN + 12;
 		bmap2 &= ~FATTR4_WORD2_SECURITY_LABEL;
 	}
 	/*
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index df5e66c..eff0a94 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -424,7 +424,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		len += 4;
 		dummy32 = be32_to_cpup(p++);
 		READ_BUF(dummy32);
-		if (dummy32 > NFSD4_MAX_SEC_LABEL_LEN)
+		if (dummy32 > NFS4_MAXLABELLEN)
 			return nfserr_badlabel;
 		len += (XDR_QUADLEN(dummy32) << 2);
 		READMEM(buf, dummy32);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0bda93e..8bae5d8 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -40,7 +40,6 @@
 #include "state.h"
 #include "nfsd.h"
 
-#define NFSD4_MAX_SEC_LABEL_LEN	2048
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
-- 
2.3.4

