Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25471 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750756Ab0IBH7J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 03:59:09 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SQUASHME: pnfs-submit: fix getdevicelist decode sizing
Date: Thu,  2 Sep 2010 10:59:07 +0300
Message-Id: <1283414347-14910-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C7F58F9.4080306@panasas.com>
References: <4C7F58F9.4080306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

it looks like we forgot to adjust hdr->replen in
encode_getdevicelist.

spell out the fields for decode_getdevicelist_maxsz.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c422964..398951e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -318,10 +318,15 @@ static int nfs4_stat_to_errno(int);
 #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
 #define encode_getdevicelist_maxsz (op_encode_hdr_maxsz + 4 + \
 				encode_verifier_maxsz)
-#define decode_getdevicelist_maxsz (op_decode_hdr_maxsz + 2 + 1 + 1 +  \
-				decode_verifier_maxsz +             \
-				XDR_QUADLEN(NFS4_PNFS_GETDEVLIST_MAXNUM *  \
-				NFS4_PNFS_DEVICEID4_SIZE))
+#define decode_getdevicelist_maxsz (op_decode_hdr_maxsz + \
+				2 /* nfs_cookie4 gdlr_cookie */ + \
+				decode_verifier_maxsz \
+				  /* verifier4 gdlr_verifier */ + \
+				1 /* gdlr_deviceid_list count */ + \
+				XDR_QUADLEN(NFS4_PNFS_GETDEVLIST_MAXNUM * \
+					    NFS4_PNFS_DEVICEID4_SIZE) \
+				  /* gdlr_deviceid_list */ + \
+				1 /* bool gdlr_eof */)
 #define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
 				XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE))
 #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
@@ -1868,6 +1873,7 @@ encode_getdevicelist(struct xdr_stream *xdr,
 	xdr_encode_hyper(p, 0ULL);                          /* cookie */
 	encode_nfs4_verifier(xdr, &dummy);
 	hdr->nops++;
+	hdr->replen += decode_getdevicelist_maxsz;
 }
 
 static void
-- 
1.7.2.2

