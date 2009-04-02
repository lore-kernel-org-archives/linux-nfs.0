From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 22/67] NFS: use decode_change_info_maxsz for xdr maxsz calculations
Date: Thu,  2 Apr 2009 16:53:11 +0300
Message-ID: <1238680391-14088-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2149 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755793AbZDBNxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:53:21 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e448e33..487a197 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -192,12 +192,16 @@ static int nfs4_stat_to_errno(int);
 				 decode_verifier_maxsz)
 #define encode_remove_maxsz	(op_encode_hdr_maxsz + \
 				nfs4_name_maxsz)
+#define decode_remove_maxsz	(op_decode_hdr_maxsz + \
+				 decode_change_info_maxsz)
 #define encode_rename_maxsz	(op_encode_hdr_maxsz + \
 				2 * nfs4_name_maxsz)
-#define decode_rename_maxsz	(op_decode_hdr_maxsz + 5 + 5)
+#define decode_rename_maxsz	(op_decode_hdr_maxsz + \
+				 decode_change_info_maxsz + \
+				 decode_change_info_maxsz)
 #define encode_link_maxsz	(op_encode_hdr_maxsz + \
 				nfs4_name_maxsz)
-#define decode_link_maxsz	(op_decode_hdr_maxsz + 5)
+#define decode_link_maxsz	(op_decode_hdr_maxsz + decode_change_info_maxsz)
 #define encode_lock_maxsz	(op_encode_hdr_maxsz + \
 				 7 + \
 				 1 + encode_stateid_maxsz + 8)
@@ -414,7 +418,7 @@ static int nfs4_stat_to_errno(int);
 				encode_getattr_maxsz)
 #define NFS4_dec_remove_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 5 + \
+				decode_remove_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_rename_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-- 
1.6.2.1

