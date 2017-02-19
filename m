Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35525 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbdBSVIr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 16:08:47 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so8864452ith.2
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 13:08:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 8/8] NFSv4: Clean up owner/group attribute decode
Date: Sun, 19 Feb 2017 16:08:32 -0500
Message-Id: <20170219210832.61213-9-trond.myklebust@primarydata.com>
In-Reply-To: <20170219210832.61213-8-trond.myklebust@primarydata.com>
References: <20170219210832.61213-1-trond.myklebust@primarydata.com>
 <20170219210832.61213-2-trond.myklebust@primarydata.com>
 <20170219210832.61213-3-trond.myklebust@primarydata.com>
 <20170219210832.61213-4-trond.myklebust@primarydata.com>
 <20170219210832.61213-5-trond.myklebust@primarydata.com>
 <20170219210832.61213-6-trond.myklebust@primarydata.com>
 <20170219210832.61213-7-trond.myklebust@primarydata.com>
 <20170219210832.61213-8-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4xdr.c | 117 +++++++++++++++++++++++++++----------------------------
 1 file changed, 57 insertions(+), 60 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ec0d76712e43..3268a2393512 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3875,45 +3875,50 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 	return -EIO;
 }
 
+static ssize_t decode_nfs4_string(struct xdr_stream *xdr,
+		struct nfs4_string *name, gfp_t gfp_flags)
+{
+	ssize_t ret;
+
+	ret = xdr_stream_decode_string_dup(xdr, &name->data,
+			XDR_MAX_NETOBJ, gfp_flags);
+	name->len = 0;
+	if (ret > 0)
+		name->len = ret;
+	return ret;
+}
+
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 		const struct nfs_server *server, kuid_t *uid,
 		struct nfs4_string *owner_name)
 {
-	uint32_t len;
-	__be32 *p;
-	int ret = 0;
+	ssize_t len;
+	char *p;
 
 	*uid = make_kuid(&init_user_ns, -2);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
 		return -EIO;
-	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
-		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p))
-			goto out_overflow;
-		len = be32_to_cpup(p);
-		p = xdr_inline_decode(xdr, len);
-		if (unlikely(!p))
-			goto out_overflow;
-		if (owner_name != NULL) {
-			owner_name->data = kmemdup(p, len, GFP_NOWAIT);
-			if (owner_name->data != NULL) {
-				owner_name->len = len;
-				ret = NFS_ATTR_FATTR_OWNER_NAME;
-			}
-		} else if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_name_to_uid(server, (char *)p, len, uid) == 0)
-				ret = NFS_ATTR_FATTR_OWNER;
-			else
-				dprintk("%s: nfs_map_name_to_uid failed!\n",
-						__func__);
-		} else
-			dprintk("%s: name too long (%u)!\n",
-					__func__, len);
-		bitmap[1] &= ~FATTR4_WORD1_OWNER;
+	if (!(bitmap[1] & FATTR4_WORD1_OWNER))
+		return 0;
+	bitmap[1] &= ~FATTR4_WORD1_OWNER;
+
+	if (owner_name != NULL) {
+		len = decode_nfs4_string(xdr, owner_name, GFP_NOWAIT);
+		if (len <= 0)
+			goto out;
+		dprintk("%s: name=%s\n", __func__, owner_name->data);
+		return NFS_ATTR_FATTR_OWNER_NAME;
+	} else {
+		len = xdr_stream_decode_opaque_inline(xdr, (void **)&p,
+				XDR_MAX_NETOBJ);
+		if (len <= 0 || nfs_map_name_to_uid(server, p, len, uid) != 0)
+			goto out;
+		dprintk("%s: uid=%d\n", __func__, (int)from_kuid(&init_user_ns, *uid));
+		return NFS_ATTR_FATTR_OWNER;
 	}
-	dprintk("%s: uid=%d\n", __func__, (int)from_kuid(&init_user_ns, *uid));
-	return ret;
-out_overflow:
+out:
+	if (len != -EBADMSG)
+		return 0;
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
@@ -3922,41 +3927,33 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		const struct nfs_server *server, kgid_t *gid,
 		struct nfs4_string *group_name)
 {
-	uint32_t len;
-	__be32 *p;
-	int ret = 0;
+	ssize_t len;
+	char *p;
 
 	*gid = make_kgid(&init_user_ns, -2);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
 		return -EIO;
-	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
-		p = xdr_inline_decode(xdr, 4);
-		if (unlikely(!p))
-			goto out_overflow;
-		len = be32_to_cpup(p);
-		p = xdr_inline_decode(xdr, len);
-		if (unlikely(!p))
-			goto out_overflow;
-		if (group_name != NULL) {
-			group_name->data = kmemdup(p, len, GFP_NOWAIT);
-			if (group_name->data != NULL) {
-				group_name->len = len;
-				ret = NFS_ATTR_FATTR_GROUP_NAME;
-			}
-		} else if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_group_to_gid(server, (char *)p, len, gid) == 0)
-				ret = NFS_ATTR_FATTR_GROUP;
-			else
-				dprintk("%s: nfs_map_group_to_gid failed!\n",
-						__func__);
-		} else
-			dprintk("%s: name too long (%u)!\n",
-					__func__, len);
-		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
+	if (!(bitmap[1] & FATTR4_WORD1_OWNER_GROUP))
+		return 0;
+	bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
+
+	if (group_name != NULL) {
+		len = decode_nfs4_string(xdr, group_name, GFP_NOWAIT);
+		if (len <= 0)
+			goto out;
+		dprintk("%s: name=%s\n", __func__, group_name->data);
+		return NFS_ATTR_FATTR_OWNER_NAME;
+	} else {
+		len = xdr_stream_decode_opaque_inline(xdr, (void **)&p,
+				XDR_MAX_NETOBJ);
+		if (len <= 0 || nfs_map_group_to_gid(server, p, len, gid) != 0)
+			goto out;
+		dprintk("%s: gid=%d\n", __func__, (int)from_kgid(&init_user_ns, *gid));
+		return NFS_ATTR_FATTR_GROUP;
 	}
-	dprintk("%s: gid=%d\n", __func__, (int)from_kgid(&init_user_ns, *gid));
-	return ret;
-out_overflow:
+out:
+	if (len != -EBADMSG)
+		return 0;
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
-- 
2.9.3

