Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57208 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754126Ab3GQV7M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 17:59:12 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andre Heider <a.heider@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>,
        Rick Macklem <rmacklem@uoguelph.ca>
Subject: [PATCH 2/2] NFSv4: encode_attrs should not backfill the bitmap and attribute length
Date: Wed, 17 Jul 2013 17:59:07 -0400
Message-ID: <1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The attribute length is already calculated in advance. There is no
reason why we cannot calculate the bitmap in advance too so that
we don't have to play pointer games.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c | 121 ++++++++++++++++++++++++-------------------------------
 1 file changed, 53 insertions(+), 68 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c74d616..98f937b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -997,12 +997,10 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	int owner_namelen = 0;
 	int owner_grouplen = 0;
 	__be32 *p;
-	__be32 *q;
-	int len;
-	uint32_t bmval_len = 2;
-	uint32_t bmval0 = 0;
-	uint32_t bmval1 = 0;
-	uint32_t bmval2 = 0;
+	unsigned i;
+	uint32_t len = 0;
+	uint32_t bmval_len;
+	uint32_t bmval[3] = { 0 };
 
 	/*
 	 * We reserve enough space to write the entire attribute buffer at once.
@@ -1011,13 +1009,14 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	 * = 40 bytes, plus any contribution from variable-length fields
 	 *            such as owner/group.
 	 */
-	len = 8;
-
-	/* Sigh */
-	if (iap->ia_valid & ATTR_SIZE)
+	if (iap->ia_valid & ATTR_SIZE) {
+		bmval[0] |= FATTR4_WORD0_SIZE;
 		len += 8;
-	if (iap->ia_valid & ATTR_MODE)
+	}
+	if (iap->ia_valid & ATTR_MODE) {
+		bmval[1] |= FATTR4_WORD1_MODE;
 		len += 4;
+	}
 	if (iap->ia_valid & ATTR_UID) {
 		owner_namelen = nfs_map_uid_to_name(server, iap->ia_uid, owner_name, IDMAP_NAMESZ);
 		if (owner_namelen < 0) {
@@ -1028,6 +1027,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 			owner_namelen = sizeof("nobody") - 1;
 			/* goto out; */
 		}
+		bmval[1] |= FATTR4_WORD1_OWNER;
 		len += 4 + (XDR_QUADLEN(owner_namelen) << 2);
 	}
 	if (iap->ia_valid & ATTR_GID) {
@@ -1039,92 +1039,77 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 			owner_grouplen = sizeof("nobody") - 1;
 			/* goto out; */
 		}
+		bmval[1] |= FATTR4_WORD1_OWNER_GROUP;
 		len += 4 + (XDR_QUADLEN(owner_grouplen) << 2);
 	}
-	if (iap->ia_valid & ATTR_ATIME_SET)
+	if (iap->ia_valid & ATTR_ATIME_SET) {
+		bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
 		len += 16;
-	else if (iap->ia_valid & ATTR_ATIME)
+	} else if (iap->ia_valid & ATTR_ATIME) {
+		bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
 		len += 4;
-	if (iap->ia_valid & ATTR_MTIME_SET)
+	}
+	if (iap->ia_valid & ATTR_MTIME_SET) {
+		bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
 		len += 16;
-	else if (iap->ia_valid & ATTR_MTIME)
+	} else if (iap->ia_valid & ATTR_MTIME) {
+		bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
 		len += 4;
+	}
 	if (label) {
 		len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
-		bmval_len = 3;
+		bmval[2] |= FATTR4_WORD2_SECURITY_LABEL;
 	}
 
-	len += bmval_len << 2;
-	p = reserve_space(xdr, len);
+	if (bmval[2] != 0)
+		bmval_len = 3;
+	else if (bmval[1] != 0)
+		bmval_len = 2;
+	else
+		bmval_len = 1;
+
+	p = reserve_space(xdr, 4 + (bmval_len << 2) + 4 + len);
 
 	/*
 	 * We write the bitmap length now, but leave the bitmap and the attribute
 	 * buffer length to be backfilled at the end of this routine.
 	 */
 	*p++ = cpu_to_be32(bmval_len);
-	q = p;
-	/* Skip bitmap entries + attrlen */
-	p += bmval_len + 1;
+	for (i = 0; i < bmval_len; i++)
+		*p++ = cpu_to_be32(bmval[i]);
+	*p++ = cpu_to_be32(len);
 
-	if (iap->ia_valid & ATTR_SIZE) {
-		bmval0 |= FATTR4_WORD0_SIZE;
+	if (bmval[0] & FATTR4_WORD0_SIZE)
 		p = xdr_encode_hyper(p, iap->ia_size);
-	}
-	if (iap->ia_valid & ATTR_MODE) {
-		bmval1 |= FATTR4_WORD1_MODE;
+	if (bmval[1] & FATTR4_WORD1_MODE)
 		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
-	}
-	if (iap->ia_valid & ATTR_UID) {
-		bmval1 |= FATTR4_WORD1_OWNER;
+	if (bmval[1] & FATTR4_WORD1_OWNER)
 		p = xdr_encode_opaque(p, owner_name, owner_namelen);
-	}
-	if (iap->ia_valid & ATTR_GID) {
-		bmval1 |= FATTR4_WORD1_OWNER_GROUP;
+	if (bmval[1] & FATTR4_WORD1_OWNER_GROUP)
 		p = xdr_encode_opaque(p, owner_group, owner_grouplen);
+	if (bmval[1] & FATTR4_WORD1_TIME_ACCESS_SET) {
+		if (iap->ia_valid & ATTR_ATIME_SET) {
+			*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
+			p = xdr_encode_hyper(p, (s64)iap->ia_atime.tv_sec);
+			*p++ = cpu_to_be32(iap->ia_atime.tv_nsec);
+		} else
+			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
-	if (iap->ia_valid & ATTR_ATIME_SET) {
-		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
-		*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
-		p = xdr_encode_hyper(p, (s64)iap->ia_atime.tv_sec);
-		*p++ = cpu_to_be32(iap->ia_atime.tv_nsec);
-	}
-	else if (iap->ia_valid & ATTR_ATIME) {
-		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
-		*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
-	}
-	if (iap->ia_valid & ATTR_MTIME_SET) {
-		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
-		*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
-		p = xdr_encode_hyper(p, (s64)iap->ia_mtime.tv_sec);
-		*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
-	}
-	else if (iap->ia_valid & ATTR_MTIME) {
-		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
-		*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
+	if (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
+		if (iap->ia_valid & ATTR_MTIME_SET) {
+			*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
+			p = xdr_encode_hyper(p, (s64)iap->ia_mtime.tv_sec);
+			*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
+		} else
+			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
-	if (label) {
-		bmval2 |= FATTR4_WORD2_SECURITY_LABEL;
+	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
 		*p++ = cpu_to_be32(label->lfs);
 		*p++ = cpu_to_be32(label->pi);
 		*p++ = cpu_to_be32(label->len);
 		p = xdr_encode_opaque_fixed(p, label->label, label->len);
 	}
 
-	/*
-	 * Now we backfill the bitmap and the attribute buffer length.
-	 */
-	if (len != ((char *)p - (char *)q) + 4) {
-		printk(KERN_ERR "NFS: Attr length error, %u != %Zu\n",
-				len, ((char *)p - (char *)q) + 4);
-		BUG();
-	}
-	len = (char *)p - (char *)q - (bmval_len << 2);
-	*q++ = htonl(bmval0);
-	*q++ = htonl(bmval1);
-	if (bmval_len == 3)
-		*q++ = htonl(bmval2);
-	*q = htonl(len);
-
 /* out: */
 }
 
-- 
1.8.3.1

