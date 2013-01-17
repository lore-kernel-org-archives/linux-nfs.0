Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f176.google.com ([209.85.217.176]:64839 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680Ab3AQQx2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 11:53:28 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v2 7/8] NFSv4: Add O_DENY* open flags support
Date: Thu, 17 Jan 2013 20:53:03 +0400
Message-Id: <1358441584-8783-7-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

by passing these flags to NFSv4 open request.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/nfs/nfs4xdr.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 40836ee..0a0cd1e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1322,7 +1322,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
+static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
+				int open_flags)
 {
 	__be32 *p;
 
@@ -1340,7 +1341,22 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 	default:
 		*p++ = cpu_to_be32(0);
 	}
-	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
+	if (open_flags & O_DENYMAND) {
+		switch (open_flags & (O_DENYREAD|O_DENYWRITE)) {
+		case O_DENYREAD:
+			*p = cpu_to_be32(NFS4_SHARE_DENY_READ);
+			break;
+		case O_DENYWRITE:
+			*p = cpu_to_be32(NFS4_SHARE_DENY_WRITE);
+			break;
+		case O_DENYREAD|O_DENYWRITE:
+			*p = cpu_to_be32(NFS4_SHARE_DENY_BOTH);
+			break;
+		default:
+			*p = cpu_to_be32(0);
+		}
+	} else
+		*p = cpu_to_be32(0);
 }
 
 static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1351,7 +1367,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, arg->open_flags);
 	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(24);
@@ -1489,7 +1505,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, 0);
 }
 
 static void
-- 
1.8.1.1

