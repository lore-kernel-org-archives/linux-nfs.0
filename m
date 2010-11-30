Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043Ab0K3C5v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 21:57:51 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4: cleanup idmapper functions to take an nfs_server argument
Date: Mon, 29 Nov 2010 21:57:42 -0500
Message-Id: <1291085863-3234-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291085863-3234-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291085863-3234-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291085863-3234-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

...instead of the nfs_client.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c            |   24 ++++++++++++------------
 fs/nfs/nfs4xdr.c          |   18 ++++++++----------
 include/linux/nfs_idmap.h |    8 ++++----
 3 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 9bf5921..114de76 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -241,21 +241,21 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen,
 	return ret;
 }
 
-int nfs_map_name_to_uid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *uid)
+int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
 {
 	if (nfs_map_string_to_numeric(name, namelen, uid))
 		return 0;
 	return nfs_idmap_lookup_id(name, namelen, "uid", uid);
 }
 
-int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *gid)
+int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *gid)
 {
 	if (nfs_map_string_to_numeric(name, namelen, gid))
 		return 0;
 	return nfs_idmap_lookup_id(name, namelen, "gid", gid);
 }
 
-int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
+int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
 {
 	int ret;
 	ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
@@ -263,7 +263,7 @@ int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buf
 		ret = nfs_map_numeric_to_string(uid, buf, buflen);
 	return ret;
 }
-int nfs_map_gid_to_group(struct nfs_client *clp, __u32 gid, char *buf, size_t buflen)
+int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
 {
 	int ret;
 
@@ -729,27 +729,27 @@ static unsigned int fnvhash32(const void *buf, size_t buflen)
 	return hash;
 }
 
-int nfs_map_name_to_uid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *uid)
+int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
 {
-	struct idmap *idmap = clp->cl_idmap;
+	struct idmap *idmap = server->nfs_client->cl_idmap;
 
 	if (nfs_map_string_to_numeric(name, namelen, uid))
 		return 0;
 	return nfs_idmap_id(idmap, &idmap->idmap_user_hash, name, namelen, uid);
 }
 
-int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *uid)
+int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
 {
-	struct idmap *idmap = clp->cl_idmap;
+	struct idmap *idmap = server->nfs_client->cl_idmap;
 
 	if (nfs_map_string_to_numeric(name, namelen, uid))
 		return 0;
 	return nfs_idmap_id(idmap, &idmap->idmap_group_hash, name, namelen, uid);
 }
 
-int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
+int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
 {
-	struct idmap *idmap = clp->cl_idmap;
+	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret;
 
 	ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
@@ -757,9 +757,9 @@ int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buf
 		ret = nfs_map_numeric_to_string(uid, buf, buflen);
 	return ret;
 }
-int nfs_map_gid_to_group(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
+int nfs_map_gid_to_group(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
 {
-	struct idmap *idmap = clp->cl_idmap;
+	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret;
 
 	ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9f1826b..0be0277 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -844,7 +844,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	if (iap->ia_valid & ATTR_MODE)
 		len += 4;
 	if (iap->ia_valid & ATTR_UID) {
-		owner_namelen = nfs_map_uid_to_name(server->nfs_client, iap->ia_uid, owner_name, IDMAP_NAMESZ);
+		owner_namelen = nfs_map_uid_to_name(server, iap->ia_uid, owner_name, IDMAP_NAMESZ);
 		if (owner_namelen < 0) {
 			dprintk("nfs: couldn't resolve uid %d to string\n",
 					iap->ia_uid);
@@ -856,7 +856,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		len += 4 + (XDR_QUADLEN(owner_namelen) << 2);
 	}
 	if (iap->ia_valid & ATTR_GID) {
-		owner_grouplen = nfs_map_gid_to_group(server->nfs_client, iap->ia_gid, owner_group, IDMAP_NAMESZ);
+		owner_grouplen = nfs_map_gid_to_group(server, iap->ia_gid, owner_group, IDMAP_NAMESZ);
 		if (owner_grouplen < 0) {
 			dprintk("nfs: couldn't resolve gid %d to string\n",
 					iap->ia_gid);
@@ -3460,7 +3460,7 @@ out_overflow:
 }
 
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
-		struct nfs_client *clp, uint32_t *uid, int may_sleep)
+		const struct nfs_server *server, uint32_t *uid, int may_sleep)
 {
 	uint32_t len;
 	__be32 *p;
@@ -3480,7 +3480,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 		if (!may_sleep) {
 			/* do nothing */
 		} else if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
+			if (nfs_map_name_to_uid(server, (char *)p, len, uid) == 0)
 				ret = NFS_ATTR_FATTR_OWNER;
 			else
 				dprintk("%s: nfs_map_name_to_uid failed!\n",
@@ -3498,7 +3498,7 @@ out_overflow:
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
-		struct nfs_client *clp, uint32_t *gid, int may_sleep)
+		const struct nfs_server *server, uint32_t *gid, int may_sleep)
 {
 	uint32_t len;
 	__be32 *p;
@@ -3518,7 +3518,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		if (!may_sleep) {
 			/* do nothing */
 		} else if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
+			if (nfs_map_group_to_gid(server, (char *)p, len, gid) == 0)
 				ret = NFS_ATTR_FATTR_GROUP;
 			else
 				dprintk("%s: nfs_map_group_to_gid failed!\n",
@@ -4017,14 +4017,12 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
-	status = decode_attr_owner(xdr, bitmap, server->nfs_client,
-			&fattr->uid, may_sleep);
+	status = decode_attr_owner(xdr, bitmap, server, &fattr->uid, may_sleep);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
 
-	status = decode_attr_group(xdr, bitmap, server->nfs_client,
-			&fattr->gid, may_sleep);
+	status = decode_attr_group(xdr, bitmap, server, &fattr->gid, may_sleep);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index e8352dc..ee97767 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -96,10 +96,10 @@ void nfs_idmap_delete(struct nfs_client *);
 
 #endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
 
-int nfs_map_name_to_uid(struct nfs_client *, const char *, size_t, __u32 *);
-int nfs_map_group_to_gid(struct nfs_client *, const char *, size_t, __u32 *);
-int nfs_map_uid_to_name(struct nfs_client *, __u32, char *, size_t);
-int nfs_map_gid_to_group(struct nfs_client *, __u32, char *, size_t);
+int nfs_map_name_to_uid(const struct nfs_server *, const char *, size_t, __u32 *);
+int nfs_map_group_to_gid(const struct nfs_server *, const char *, size_t, __u32 *);
+int nfs_map_uid_to_name(const struct nfs_server *, __u32, char *, size_t);
+int nfs_map_gid_to_group(const struct nfs_server *, __u32, char *, size_t);
 
 extern unsigned int nfs_idmap_cache_timeout;
 #endif /* __KERNEL__ */
-- 
1.7.3.2

