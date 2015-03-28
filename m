Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35104 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbC1PvC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:51:02 -0400
Received: by pacwz10 with SMTP id wz10so73185014pac.2
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:51:01 -0700 (PDT)
Message-ID: <5516CDDC.9030000@gmail.com>
Date: Sat, 28 Mar 2015 23:50:52 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 3/4] nfsd: use NFS4_MAXTAGLEN for taglen checking
References: <5516CCDB.4020509@gmail.com>
In-Reply-To: <5516CCDB.4020509@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 fs/nfsd/xdr4.h    | 1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index eff0a94..4db519e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1808,7 +1808,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	argp->opcnt = be32_to_cpup(p++);
 	max_reply += 4 + (XDR_QUADLEN(argp->taglen) << 2);
 
-	if (argp->taglen > NFSD4_MAX_TAGLEN)
+	if (argp->taglen > NFS4_MAXTAGLEN)
 		goto xdr_error;
 	if (argp->opcnt > 100)
 		goto xdr_error;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 8bae5d8..613cece 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -40,7 +40,6 @@
 #include "state.h"
 #include "nfsd.h"
 
-#define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
 #define CURRENT_STATE_ID_FLAG (1<<0)
-- 
2.3.4

