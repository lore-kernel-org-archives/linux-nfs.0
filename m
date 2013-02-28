Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f54.google.com ([209.85.215.54]:47610 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760655Ab3B1PW6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2013 10:22:58 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v3 6/7] NFSv4: Add O_DENY* open flags support
Date: Thu, 28 Feb 2013 19:25:32 +0400
Message-Id: <1362065133-9490-7-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

by passing these flags to NFSv4 open request.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/nfs/nfs4xdr.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 26b1439..58ddc74 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1325,7 +1325,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
+static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
+				int open_flags)
 {
 	__be32 *p;
 
@@ -1343,7 +1344,22 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
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
@@ -1354,7 +1370,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, arg->open_flags);
 	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(24);
@@ -1491,7 +1507,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, 0);
 }
 
 static void
-- 
1.8.1.2

