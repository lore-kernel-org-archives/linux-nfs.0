From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/2] nfsd4: delete obsolete xdr comments
Date: Thu, 23 Apr 2009 17:31:57 -0400
Message-ID: <1240522317-1834-3-git-send-email-bfields@fieldses.org>
References: <1240522317-1834-1-git-send-email-bfields@fieldses.org>
 <1240522317-1834-2-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46950 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424AbZDWVb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 17:31:58 -0400
In-Reply-To: <1240522317-1834-2-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We don't need comments to tell us these macros are ugly.  And we're long
past trying to share any of this code with the BSD's.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4xdr.c |   27 ---------------------------
 1 files changed, 0 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fe46ede..4a71fcd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -83,16 +83,6 @@ check_filename(char *str, int len, __be32 err)
 	return 0;
 }
 
-/*
- * START OF "GENERIC" DECODE ROUTINES.
- *   These may look a little ugly since they are imported from a "generic"
- * set of XDR encode/decode routines which are intended to be shared by
- * all of our NFSv4 implementations (OpenBSD, MacOS X...).
- *
- * If the pain of reading these is too great, it should be a straightforward
- * task to translate them into Linux-specific versions which are more
- * consistent with the style used in NFSv2/v3...
- */
 #define DECODE_HEAD				\
 	__be32 *p;				\
 	__be32 status
@@ -1489,20 +1479,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 
 	DECODE_TAIL;
 }
-/*
- * END OF "GENERIC" DECODE ROUTINES.
- */
 
-/*
- * START OF "GENERIC" ENCODE ROUTINES.
- *   These may look a little ugly since they are imported from a "generic"
- * set of XDR encode/decode routines which are intended to be shared by
- * all of our NFSv4 implementations (OpenBSD, MacOS X...).
- *
- * If the pain of reading these is too great, it should be a straightforward
- * task to translate them into Linux-specific versions which are more
- * consistent with the style used in NFSv2/v3...
- */
 #define WRITE32(n)               *p++ = htonl(n)
 #define WRITE64(n)               do {				\
 	*p++ = htonl((u32)((n) >> 32));				\
@@ -3252,10 +3229,6 @@ nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	ADJUST_ARGS();
 }
 
-/*
- * END OF "GENERIC" ENCODE ROUTINES.
- */
-
 int
 nfs4svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 {
-- 
1.6.0.4

