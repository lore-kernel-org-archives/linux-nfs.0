Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:39092 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbeCTVDr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:47 -0400
Received: by mail-it0-f66.google.com with SMTP id e98-v6so4162275itd.4
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] NFSv4: Add a helper to encode/decode struct timespec
Date: Tue, 20 Mar 2018 17:03:10 -0400
Message-Id: <20180320210313.94429-7-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-6-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
 <20180320210313.94429-4-trond.myklebust@primarydata.com>
 <20180320210313.94429-5-trond.myklebust@primarydata.com>
 <20180320210313.94429-6-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 45 ++++++++++++++++++++++++++++++---------------
 1 file changed, 30 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3d088230c975..79f1774b9d68 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -99,6 +99,7 @@ static int nfs4_stat_to_errno(int);
 				((3+NFS4_FHSIZE) >> 2))
 #define nfs4_fattr_bitmap_maxsz 4
 #define encode_getattr_maxsz    (op_encode_hdr_maxsz + nfs4_fattr_bitmap_maxsz)
+#define nfstime4_maxsz		(3)
 #define nfs4_name_maxsz		(1 + ((3 + NFS4_MAXNAMLEN) >> 2))
 #define nfs4_path_maxsz		(1 + ((3 + NFS4_MAXPATHLEN) >> 2))
 #define nfs4_owner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
@@ -113,7 +114,8 @@ static int nfs4_stat_to_errno(int);
 #define decode_mdsthreshold_maxsz (1 + 1 + nfs4_fattr_bitmap_maxsz + 1 + 8)
 /* This is based on getfattr, which uses the most attributes: */
 #define nfs4_fattr_value_maxsz	(1 + (1 + 2 + 2 + 4 + 2 + 1 + 1 + 2 + 2 + \
-				3 + 3 + 3 + nfs4_owner_maxsz + \
+				3*nfstime4_maxsz + \
+				nfs4_owner_maxsz + \
 				nfs4_group_maxsz + nfs4_label_maxsz + \
 				 decode_mdsthreshold_maxsz))
 #define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
@@ -124,7 +126,8 @@ static int nfs4_stat_to_errno(int);
 				nfs4_owner_maxsz + \
 				nfs4_group_maxsz + \
 				nfs4_label_maxsz + \
-				4 + 4)
+				1 + nfstime4_maxsz + \
+				1 + nfstime4_maxsz)
 #define encode_savefh_maxsz     (op_encode_hdr_maxsz)
 #define decode_savefh_maxsz     (op_decode_hdr_maxsz)
 #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
@@ -1041,6 +1044,14 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
 	encode_opaque_fixed(xdr, verf->data, NFS4_VERIFIER_SIZE);
 }
 
+static __be32 *
+xdr_encode_nfstime4(__be32 *p, const struct timespec *t)
+{
+	p = xdr_encode_hyper(p, (__s64)t->tv_sec);
+	*p++ = cpu_to_be32(t->tv_nsec);
+	return p;
+}
+
 static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 				const struct nfs4_label *label,
 				const umode_t *umask,
@@ -1100,7 +1111,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	if (attrmask[1] & FATTR4_WORD1_TIME_ACCESS_SET) {
 		if (iap->ia_valid & ATTR_ATIME_SET) {
 			bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
-			len += 16;
+			len += 4 + (nfstime4_maxsz << 2);
 		} else if (iap->ia_valid & ATTR_ATIME) {
 			bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
 			len += 4;
@@ -1109,7 +1120,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	if (attrmask[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
 		if (iap->ia_valid & ATTR_MTIME_SET) {
 			bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
-			len += 16;
+			len += 4 + (nfstime4_maxsz << 2);
 		} else if (iap->ia_valid & ATTR_MTIME) {
 			bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
 			len += 4;
@@ -1135,16 +1146,14 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	if (bmval[1] & FATTR4_WORD1_TIME_ACCESS_SET) {
 		if (iap->ia_valid & ATTR_ATIME_SET) {
 			*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
-			p = xdr_encode_hyper(p, (s64)iap->ia_atime.tv_sec);
-			*p++ = cpu_to_be32(iap->ia_atime.tv_nsec);
+			p = xdr_encode_nfstime4(p, &iap->ia_atime);
 		} else
 			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
 	if (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
 		if (iap->ia_valid & ATTR_MTIME_SET) {
 			*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
-			p = xdr_encode_hyper(p, (s64)iap->ia_mtime.tv_sec);
-			*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
+			p = xdr_encode_nfstime4(p, &iap->ia_mtime);
 		} else
 			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
@@ -4129,19 +4138,25 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	return -EIO;
 }
 
+static __be32 *
+xdr_decode_nfstime4(__be32 *p, struct timespec *t)
+{
+	__u64 sec;
+
+	p = xdr_decode_hyper(p, &sec);
+	t-> tv_sec = (time_t)sec;
+	t->tv_nsec = be32_to_cpup(p++);
+	return p;
+}
+
 static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 {
 	__be32 *p;
-	uint64_t sec;
-	uint32_t nsec;
 
-	p = xdr_inline_decode(xdr, 12);
+	p = xdr_inline_decode(xdr, nfstime4_maxsz << 2);
 	if (unlikely(!p))
 		goto out_overflow;
-	p = xdr_decode_hyper(p, &sec);
-	nsec = be32_to_cpup(p);
-	time->tv_sec = (time_t)sec;
-	time->tv_nsec = (long)nsec;
+	xdr_decode_nfstime4(p, time);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-- 
2.14.3

