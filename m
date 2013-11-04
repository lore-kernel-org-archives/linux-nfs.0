Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:37667 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760Ab3KDUvV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 15:51:21 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
CC: J Bruce Fields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 3/5] NFSv4.2: encode_readdir - only ask for labels when doing readdirplus
Date: Mon, 4 Nov 2013 15:51:10 -0500
Message-ID: <1383598272-17737-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1383598272-17737-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if the server is doing NFSv4.2 and supports labeled NFS, then
our on-the-wire READDIR request ends up asking for the label information,
which is then ignored unless we're doing readdirplus.
This patch ensures that READDIR doesn't ask the server for label information
at all unless the readdir->bitmask contains the FATTR4_WORD2_SECURITY_LABEL
attribute, and the readdir->plus flag is set.

While we're at it, optimise away the 3rd bitmap field if it is zero.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f903389d90f1..5be2868c02f1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -105,12 +105,8 @@ static int nfs4_stat_to_errno(int);
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 /* PI(4 bytes) + LFS(4 bytes) + 1(for null terminator?) + MAXLABELLEN */
 #define	nfs4_label_maxsz	(4 + 4 + 1 + XDR_QUADLEN(NFS4_MAXLABELLEN))
-#define encode_readdir_space 24
-#define encode_readdir_bitmask_sz 3
 #else
 #define	nfs4_label_maxsz	0
-#define encode_readdir_space 20
-#define encode_readdir_bitmask_sz 2
 #endif
 /* We support only one layout type per file system */
 #define decode_mdsthreshold_maxsz (1 + 1 + nfs4_fattr_bitmap_maxsz + 1 + 8)
@@ -1581,6 +1577,8 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	};
 	uint32_t dircount = readdir->count >> 1;
 	__be32 *p, verf[2];
+	uint32_t attrlen = 0;
+	unsigned int i;
 
 	if (readdir->plus) {
 		attrs[0] |= FATTR4_WORD0_TYPE|FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE|
@@ -1589,26 +1587,27 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 			FATTR4_WORD1_OWNER_GROUP|FATTR4_WORD1_RAWDEV|
 			FATTR4_WORD1_SPACE_USED|FATTR4_WORD1_TIME_ACCESS|
 			FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
+		attrs[2] |= FATTR4_WORD2_SECURITY_LABEL;
 		dircount >>= 1;
 	}
 	/* Use mounted_on_fileid only if the server supports it */
 	if (!(readdir->bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID))
 		attrs[0] |= FATTR4_WORD0_FILEID;
+	for (i = 0; i < ARRAY_SIZE(attrs); i++) {
+		attrs[i] &= readdir->bitmask[i];
+		if (attrs[i] != 0)
+			attrlen = i+1;
+	}
 
 	encode_op_hdr(xdr, OP_READDIR, decode_readdir_maxsz, hdr);
 	encode_uint64(xdr, readdir->cookie);
 	encode_nfs4_verifier(xdr, &readdir->verifier);
-	p = reserve_space(xdr, encode_readdir_space);
+	p = reserve_space(xdr, 12 + (attrlen << 2));
 	*p++ = cpu_to_be32(dircount);
 	*p++ = cpu_to_be32(readdir->count);
-	*p++ = cpu_to_be32(encode_readdir_bitmask_sz);
-	*p++ = cpu_to_be32(attrs[0] & readdir->bitmask[0]);
-	*p   = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
-	if (encode_readdir_bitmask_sz > 2) {
-		if (hdr->minorversion > 1)
-			attrs[2] |= FATTR4_WORD2_SECURITY_LABEL;
-		p++, *p++ = cpu_to_be32(attrs[2] & readdir->bitmask[2]);
-	}
+	*p++ = cpu_to_be32(attrlen);
+	for (i = 0; i < attrlen; i++)
+		*p++ = cpu_to_be32(attrs[i]);
 	memcpy(verf, readdir->verifier.data, sizeof(verf));
 
 	dprintk("%s: cookie = %llu, verifier = %08x:%08x, bitmap = %08x:%08x:%08x\n",
-- 
1.8.3.1

