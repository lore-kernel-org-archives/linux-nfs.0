Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47874 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbaCWBM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 17/50] nfsd4: use xdr_reserve_space in attribute encoding
Date: Sat, 22 Mar 2014 21:11:48 -0400
Message-Id: <1395537141-10389-18-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is a cosmetic change for now; no change in behavior.

Note we're just depending on xdr_reserve_space to do the bounds checking
for us, we're not really depending on its adjustment of iovec or xdr_buf
lengths yet, as those are fixed up by as necessary after the fact by
read-link operations and by nfs4svc_encode_compoundres.  However we do
have to update xdr->iov on read-like operations to prevent
xdr_reserve_space from messing with the already-fixed-up length of the
the head.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/acl.h       |   2 +-
 fs/nfsd/idmap.h     |   4 +-
 fs/nfsd/nfs4acl.c   |  11 +--
 fs/nfsd/nfs4idmap.c |  38 ++++----
 fs/nfsd/nfs4proc.c  |   1 +
 fs/nfsd/nfs4xdr.c   | 274 ++++++++++++++++++++++++++++++----------------------
 6 files changed, 186 insertions(+), 144 deletions(-)

diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index b481e1f..a986ceb 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -49,7 +49,7 @@ struct svc_rqst;
 
 struct nfs4_acl *nfs4_acl_new(int);
 int nfs4_acl_get_whotype(char *, u32);
-__be32 nfs4_acl_write_who(int who, __be32 **p, int *len);
+__be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who);
 
 int nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 		struct nfs4_acl **acl);
diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index 66e58db..a3f3490 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -56,7 +56,7 @@ static inline void nfsd_idmap_shutdown(struct net *net)
 
 __be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, kuid_t *);
 __be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, kgid_t *);
-__be32 nfsd4_encode_user(struct svc_rqst *, kuid_t, __be32 **, int *);
-__be32 nfsd4_encode_group(struct svc_rqst *, kgid_t, __be32 **, int *);
+__be32 nfsd4_encode_user(struct xdr_stream *, struct svc_rqst *, kuid_t);
+__be32 nfsd4_encode_group(struct xdr_stream *, struct svc_rqst *, kgid_t);
 
 #endif /* LINUX_NFSD_IDMAP_H */
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index d190e33..02229b5 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -914,20 +914,19 @@ nfs4_acl_get_whotype(char *p, u32 len)
 	return NFS4_ACL_WHO_NAMED;
 }
 
-__be32 nfs4_acl_write_who(int who, __be32 **p, int *len)
+__be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
 {
+	__be32 *p;
 	int i;
-	int bytes;
 
 	for (i = 0; i < ARRAY_SIZE(s2t_map); i++) {
 		if (s2t_map[i].type != who)
 			continue;
-		bytes = 4 + (XDR_QUADLEN(s2t_map[i].stringlen) << 2);
-		if (bytes > *len)
+		p = xdr_reserve_space(xdr, s2t_map[i].stringlen + 4);
+		if (!p)
 			return nfserr_resource;
-		*p = xdr_encode_opaque(*p, s2t_map[i].string,
+		p = xdr_encode_opaque(p, s2t_map[i].string,
 					s2t_map[i].stringlen);
-		*len -= bytes;
 		return 0;
 	}
 	WARN_ON_ONCE(1);
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index c0dfde6..43afc90 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -551,44 +551,42 @@ idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen
 	return 0;
 }
 
-static __be32 encode_ascii_id(u32 id, __be32 **p, int *buflen)
+static __be32 encode_ascii_id(struct xdr_stream *xdr, u32 id)
 {
 	char buf[11];
 	int len;
-	int bytes;
+	__be32 *p;
 
 	len = sprintf(buf, "%u", id);
-	bytes = 4 + (XDR_QUADLEN(len) << 2);
-	if (bytes > *buflen)
+	p = xdr_reserve_space(xdr, len + 4);
+	if (!p)
 		return nfserr_resource;
-	*p = xdr_encode_opaque(*p, buf, len);
-	*buflen -= bytes;
+	p = xdr_encode_opaque(p, buf, len);
 	return 0;
 }
 
-static __be32 idmap_id_to_name(struct svc_rqst *rqstp, int type, u32 id, __be32 **p, int *buflen)
+static __be32 idmap_id_to_name(struct xdr_stream *xdr, struct svc_rqst *rqstp, int type, u32 id)
 {
 	struct ent *item, key = {
 		.id = id,
 		.type = type,
 	};
+	__be32 *p;
 	int ret;
-	int bytes;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	strlcpy(key.authname, rqst_authname(rqstp), sizeof(key.authname));
 	ret = idmap_lookup(rqstp, idtoname_lookup, &key, nn->idtoname_cache, &item);
 	if (ret == -ENOENT)
-		return encode_ascii_id(id, p, buflen);
+		return encode_ascii_id(xdr, id);
 	if (ret)
 		return nfserrno(ret);
 	ret = strlen(item->name);
 	WARN_ON_ONCE(ret > IDMAP_NAMESZ);
-	bytes = 4 + (XDR_QUADLEN(ret) << 2);
-	if (bytes > *buflen)
+	p = xdr_reserve_space(xdr, ret + 4);
+	if (!p)
 		return nfserr_resource;
-	*p = xdr_encode_opaque(*p, item->name, ret);
-	*buflen -= bytes;
+	p = xdr_encode_opaque(p, item->name, ret);
 	cache_put(&item->h, nn->idtoname_cache);
 	return 0;
 }
@@ -622,11 +620,11 @@ do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u
 	return idmap_name_to_id(rqstp, type, name, namelen, id);
 }
 
-static __be32 encode_name_from_id(struct svc_rqst *rqstp, int type, u32 id, __be32 **p, int *buflen)
+static __be32 encode_name_from_id(struct xdr_stream *xdr, struct svc_rqst *rqstp, int type, u32 id)
 {
 	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
-		return encode_ascii_id(id, p, buflen);
-	return idmap_id_to_name(rqstp, type, id, p, buflen);
+		return encode_ascii_id(xdr, id);
+	return idmap_id_to_name(xdr, rqstp, type, id);
 }
 
 __be32
@@ -655,14 +653,14 @@ nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 	return status;
 }
 
-__be32 nfsd4_encode_user(struct svc_rqst *rqstp, kuid_t uid,  __be32 **p, int *buflen)
+__be32 nfsd4_encode_user(struct xdr_stream *xdr, struct svc_rqst *rqstp, kuid_t uid)
 {
 	u32 id = from_kuid(&init_user_ns, uid);
-	return encode_name_from_id(rqstp, IDMAP_TYPE_USER, id, p, buflen);
+	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_USER, id);
 }
 
-__be32 nfsd4_encode_group(struct svc_rqst *rqstp, kgid_t gid, __be32 **p, int *buflen)
+__be32 nfsd4_encode_group(struct xdr_stream *xdr, struct svc_rqst *rqstp, kgid_t gid)
 {
 	u32 id = from_kgid(&init_user_ns, gid);
-	return encode_name_from_id(rqstp, IDMAP_TYPE_GROUP, id, p, buflen);
+	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_GROUP, id);
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a61f492..9e7cb05 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1219,6 +1219,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres
 	struct kvec *head = buf->head;
 
 	xdr->buf = buf;
+	xdr->iov = head;
 	xdr->p   = head->iov_base + head->iov_len;
 	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ed486e7..6025713 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1756,18 +1756,18 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
  */
-static __be32 nfsd4_encode_components_esc(char sep, char *components,
-				   __be32 **pp, int *buflen,
-				   char esc_enter, char esc_exit)
+static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep, char *components, char esc_enter, char esc_exit)
 {
-	__be32 *p = *pp;
-	__be32 *countp = p;
+	__be32 *p;
+	__be32 *countp;
 	int strlen, count=0;
 	char *str, *end, *next;
 
 	dprintk("nfsd4_encode_components(%s)\n", components);
-	if ((*buflen -= 4) < 0)
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
 		return nfserr_resource;
+	countp = p;
 	WRITE32(0); /* We will fill this in with @count later */
 	end = str = components;
 	while (*end) {
@@ -1790,7 +1790,8 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
 
 		strlen = end - str;
 		if (strlen) {
-			if ((*buflen -= ((XDR_QUADLEN(strlen) << 2) + 4)) < 0)
+			p = xdr_reserve_space(xdr, strlen + 4);
+			if (!p)
 				return nfserr_resource;
 			WRITE32(strlen);
 			WRITEMEM(str, strlen);
@@ -1800,7 +1801,6 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
 			end++;
 		str = end;
 	}
-	*pp = p;
 	p = countp;
 	WRITE32(count);
 	return 0;
@@ -1809,40 +1809,35 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
 /* Encode as an array of strings the string given with components
  * separated @sep.
  */
-static __be32 nfsd4_encode_components(char sep, char *components,
-				   __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_components(struct xdr_stream *xdr, char sep, char *components)
 {
-	return nfsd4_encode_components_esc(sep, components, pp, buflen, 0, 0);
+	return nfsd4_encode_components_esc(xdr, sep, components, 0, 0);
 }
 
 /*
  * encode a location element of a fs_locations structure
  */
-static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
-				    __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_fs_location4(struct xdr_stream *xdr, struct nfsd4_fs_location *location)
 {
 	__be32 status;
-	__be32 *p = *pp;
 
-	status = nfsd4_encode_components_esc(':', location->hosts, &p, buflen,
+	status = nfsd4_encode_components_esc(xdr, ':', location->hosts,
 						'[', ']');
 	if (status)
 		return status;
-	status = nfsd4_encode_components('/', location->path, &p, buflen);
+	status = nfsd4_encode_components(xdr, '/', location->path);
 	if (status)
 		return status;
-	*pp = p;
 	return 0;
 }
 
 /*
  * Encode a path in RFC3530 'pathname4' format
  */
-static __be32 nfsd4_encode_path(const struct path *root,
-		const struct path *path, __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_path(struct xdr_stream *xdr, const struct path *root, const struct path *path)
 {
 	struct path cur = *path;
-	__be32 *p = *pp;
+	__be32 *p;
 	struct dentry **components = NULL;
 	unsigned int ncomponents = 0;
 	__be32 err = nfserr_jukebox;
@@ -1873,9 +1868,9 @@ static __be32 nfsd4_encode_path(const struct path *root,
 		components[ncomponents++] = cur.dentry;
 		cur.dentry = dget_parent(cur.dentry);
 	}
-
-	*buflen -= 4;
-	if (*buflen < 0)
+	err = nfserr_resource;
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
 		goto out_free;
 	WRITE32(ncomponents);
 
@@ -1885,8 +1880,8 @@ static __be32 nfsd4_encode_path(const struct path *root,
 
 		spin_lock(&dentry->d_lock);
 		len = dentry->d_name.len;
-		*buflen -= 4 + (XDR_QUADLEN(len) << 2);
-		if (*buflen < 0) {
+		p = xdr_reserve_space(xdr, len + 4);
+		if (!p) {
 			spin_unlock(&dentry->d_lock);
 			goto out_free;
 		}
@@ -1898,7 +1893,6 @@ static __be32 nfsd4_encode_path(const struct path *root,
 		ncomponents--;
 	}
 
-	*pp = p;
 	err = 0;
 out_free:
 	dprintk(")\n");
@@ -1909,8 +1903,7 @@ out_free:
 	return err;
 }
 
-static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
-		const struct path *path, __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_fsloc_fsroot(struct xdr_stream *xdr, struct svc_rqst *rqstp, const struct path *path)
 {
 	struct svc_export *exp_ps;
 	__be32 res;
@@ -1918,7 +1911,7 @@ static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
 	exp_ps = rqst_find_fsidzero_export(rqstp);
 	if (IS_ERR(exp_ps))
 		return nfserrno(PTR_ERR(exp_ps));
-	res = nfsd4_encode_path(&exp_ps->ex_path, path, pp, buflen);
+	res = nfsd4_encode_path(xdr, &exp_ps->ex_path, path);
 	exp_put(exp_ps);
 	return res;
 }
@@ -1926,28 +1919,25 @@ static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
 /*
  *  encode a fs_locations structure
  */
-static __be32 nfsd4_encode_fs_locations(struct svc_rqst *rqstp,
-				     struct svc_export *exp,
-				     __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_fs_locations(struct xdr_stream *xdr, struct svc_rqst *rqstp, struct svc_export *exp)
 {
 	__be32 status;
 	int i;
-	__be32 *p = *pp;
+	__be32 *p;
 	struct nfsd4_fs_locations *fslocs = &exp->ex_fslocs;
 
-	status = nfsd4_encode_fsloc_fsroot(rqstp, &exp->ex_path, &p, buflen);
+	status = nfsd4_encode_fsloc_fsroot(xdr, rqstp, &exp->ex_path);
 	if (status)
 		return status;
-	if ((*buflen -= 4) < 0)
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
 		return nfserr_resource;
 	WRITE32(fslocs->locations_count);
 	for (i=0; i<fslocs->locations_count; i++) {
-		status = nfsd4_encode_fs_location4(&fslocs->locations[i],
-						   &p, buflen);
+		status = nfsd4_encode_fs_location4(xdr, &fslocs->locations[i]);
 		if (status)
 			return status;
 	}
-	*pp = p;
 	return 0;
 }
 
@@ -1966,15 +1956,14 @@ static u32 nfs4_file_type(umode_t mode)
 }
 
 static inline __be32
-nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
-		__be32 **p, int *buflen)
+nfsd4_encode_aclname(struct xdr_stream *xdr, struct svc_rqst *rqstp, struct nfs4_ace *ace)
 {
 	if (ace->whotype != NFS4_ACL_WHO_NAMED)
-		return nfs4_acl_write_who(ace->whotype, p, buflen);
+		return nfs4_acl_write_who(xdr, ace->whotype);
 	else if (ace->flag & NFS4_ACE_IDENTIFIER_GROUP)
-		return nfsd4_encode_group(rqstp, ace->who_gid, p, buflen);
+		return nfsd4_encode_group(xdr, rqstp, ace->who_gid);
 	else
-		return nfsd4_encode_user(rqstp, ace->who_uid, p, buflen);
+		return nfsd4_encode_user(xdr, rqstp, ace->who_uid);
 }
 
 #define WORD0_ABSENT_FS_ATTRS (FATTR4_WORD0_FS_LOCATIONS | FATTR4_WORD0_FSID | \
@@ -1983,31 +1972,26 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 static inline __be32
-nfsd4_encode_security_label(struct svc_rqst *rqstp, void *context, int len, __be32 **pp, int *buflen)
+nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp, void *context, int len)
 {
 	__be32 *p = *pp;
 
-	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4))
+	p = xdr_reserve_space(xdr, len + 4 + 4 + 4);
+	if (!p)
 		return nfserr_resource;
 
 	/*
 	 * For now we use a 0 here to indicate the null translation; in
 	 * the future we may place a call to translation code here.
 	 */
-	if ((*buflen -= 8) < 0)
-		return nfserr_resource;
-
 	WRITE32(0); /* lfs */
 	WRITE32(0); /* pi */
 	p = xdr_encode_opaque(p, context, len);
-	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
-
-	*pp = p;
 	return 0;
 }
 #else
 static inline __be32
-nfsd4_encode_security_label(struct svc_rqst *rqstp, void *context, int len, __be32 **pp, int *buflen)
+nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp, void *context, int len)
 { return 0; }
 #endif
 
@@ -2058,8 +2042,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 	struct kstat stat;
 	struct svc_fh *tempfh = NULL;
 	struct kstatfs statfs;
-	__be32 *p = xdr->p;
-	int buflen = xdr->buf->buflen;
+	__be32 *p;
+	__be32 *start = xdr->p;
 	__be32 *attrlenp;
 	u32 dummy;
 	u64 dummy64;
@@ -2144,24 +2128,30 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
 
 	if (bmval2) {
-		if ((buflen -= 16) < 0)
+		p = xdr_reserve_space(xdr, 16);
+		if (!p)
 			goto out_resource;
 		WRITE32(3);
 		WRITE32(bmval0);
 		WRITE32(bmval1);
 		WRITE32(bmval2);
 	} else if (bmval1) {
-		if ((buflen -= 12) < 0)
+		p = xdr_reserve_space(xdr, 12);
+		if (!p)
 			goto out_resource;
 		WRITE32(2);
 		WRITE32(bmval0);
 		WRITE32(bmval1);
 	} else {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 		WRITE32(bmval0);
 	}
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		goto out_resource;
 	attrlenp = p++;                /* to be backfilled later */
 
 	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
@@ -2174,13 +2164,15 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		if (!contextsupport)
 			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
 		if (!word2) {
-			if ((buflen -= 12) < 0)
+			p = xdr_reserve_space(xdr, 12);
+			if (!p)
 				goto out_resource;
 			WRITE32(2);
 			WRITE32(word0);
 			WRITE32(word1);
 		} else {
-			if ((buflen -= 16) < 0)
+			p = xdr_reserve_space(xdr, 16);
+			if (!p)
 				goto out_resource;
 			WRITE32(3);
 			WRITE32(word0);
@@ -2189,7 +2181,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		}
 	}
 	if (bmval0 & FATTR4_WORD0_TYPE) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		dummy = nfs4_file_type(stat.mode);
 		if (dummy == NF4BAD) {
@@ -2199,7 +2192,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		WRITE32(dummy);
 	}
 	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
 			WRITE32(NFS4_FH_PERSISTENT);
@@ -2207,32 +2201,38 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		write_change(&p, &stat, dentry->d_inode);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64(stat.size);
 	}
 	if (bmval0 & FATTR4_WORD0_LINK_SUPPORT) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_SYMLINK_SUPPORT) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_NAMED_ATTR) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_FSID) {
-		if ((buflen -= 16) < 0)
+		p = xdr_reserve_space(xdr, 16);
+		if (!p)
 			goto out_resource;
 		if (exp->ex_fslocs.migrated) {
 			WRITE64(NFS4_REFERRAL_FSID_MAJOR);
@@ -2254,17 +2254,20 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		}
 	}
 	if (bmval0 & FATTR4_WORD0_UNIQUE_HANDLES) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_LEASE_TIME) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(nn->nfsd4_lease);
 	}
 	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(rdattr_err);
 	}
@@ -2272,198 +2275,229 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		struct nfs4_ace *ace;
 
 		if (acl == NULL) {
-			if ((buflen -= 4) < 0)
+			p = xdr_reserve_space(xdr, 4);
+			if (!p)
 				goto out_resource;
 
 			WRITE32(0);
 			goto out_acl;
 		}
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(acl->naces);
 
 		for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
-			if ((buflen -= 4*3) < 0)
+			p = xdr_reserve_space(xdr, 4*3);
+			if (!p)
 				goto out_resource;
 			WRITE32(ace->type);
 			WRITE32(ace->flag);
 			WRITE32(ace->access_mask & NFS4_ACE_MASK_ALL);
-			status = nfsd4_encode_aclname(rqstp, ace, &p, &buflen);
+			status = nfsd4_encode_aclname(xdr, rqstp, ace);
 			if (status)
 				goto out;
 		}
 	}
 out_acl:
 	if (bmval0 & FATTR4_WORD0_ACLSUPPORT) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(aclsupport ?
 			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_INSENSITIVE) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_PRESERVING) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_CHOWN_RESTRICTED) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEHANDLE) {
-		buflen -= (XDR_QUADLEN(fhp->fh_handle.fh_size) << 2) + 4;
-		if (buflen < 0)
+		p = xdr_reserve_space(xdr, fhp->fh_handle.fh_size + 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(fhp->fh_handle.fh_size);
 		WRITEMEM(&fhp->fh_handle.fh_base, fhp->fh_handle.fh_size);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEID) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64(stat.ino);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_AVAIL) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64((u64) statfs.f_ffree);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_FREE) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64((u64) statfs.f_ffree);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_TOTAL) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64((u64) statfs.f_files);
 	}
 	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
-		status = nfsd4_encode_fs_locations(rqstp, exp, &p, &buflen);
+		status = nfsd4_encode_fs_locations(xdr, rqstp, exp);
 		if (status)
 			goto out;
 	}
 	if (bmval0 & FATTR4_WORD0_HOMOGENEOUS) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXFILESIZE) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64(exp->ex_path.mnt->mnt_sb->s_maxbytes);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXLINK) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(255);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXNAME) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(statfs.f_namelen);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXREAD) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64((u64) svc_max_payload(rqstp));
 	}
 	if (bmval0 & FATTR4_WORD0_MAXWRITE) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE64((u64) svc_max_payload(rqstp));
 	}
 	if (bmval1 & FATTR4_WORD1_MODE) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(stat.mode & S_IALLUGO);
 	}
 	if (bmval1 & FATTR4_WORD1_NO_TRUNC) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(1);
 	}
 	if (bmval1 & FATTR4_WORD1_NUMLINKS) {
-		if ((buflen -= 4) < 0)
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
 			goto out_resource;
 		WRITE32(stat.nlink);
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER) {
-		status = nfsd4_encode_user(rqstp, stat.uid, &p, &buflen);
+		status = nfsd4_encode_user(xdr, rqstp, stat.uid);
 		if (status)
 			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER_GROUP) {
-		status = nfsd4_encode_group(rqstp, stat.gid, &p, &buflen);
+		status = nfsd4_encode_group(xdr, rqstp, stat.gid);
 		if (status)
 			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_RAWDEV) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		WRITE32((u32) MAJOR(stat.rdev));
 		WRITE32((u32) MINOR(stat.rdev));
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_AVAIL) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		dummy64 = (u64)statfs.f_bavail * (u64)statfs.f_bsize;
 		WRITE64(dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_FREE) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		dummy64 = (u64)statfs.f_bfree * (u64)statfs.f_bsize;
 		WRITE64(dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_TOTAL) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		dummy64 = (u64)statfs.f_blocks * (u64)statfs.f_bsize;
 		WRITE64(dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_USED) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
 			goto out_resource;
 		dummy64 = (u64)stat.blocks << 9;
 		WRITE64(dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_ACCESS) {
-		if ((buflen -= 12) < 0)
+		p = xdr_reserve_space(xdr, 12);
+		if (!p)
 			goto out_resource;
 		WRITE64((s64)stat.atime.tv_sec);
 		WRITE32(stat.atime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_DELTA) {
-		if ((buflen -= 12) < 0)
+		p = xdr_reserve_space(xdr, 12);
+		if (!p)
 			goto out_resource;
 		WRITE32(0);
 		WRITE32(1);
 		WRITE32(0);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_METADATA) {
-		if ((buflen -= 12) < 0)
+		p = xdr_reserve_space(xdr, 12);
+		if (!p)
 			goto out_resource;
 		WRITE64((s64)stat.ctime.tv_sec);
 		WRITE32(stat.ctime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_MODIFY) {
-		if ((buflen -= 12) < 0)
+		p = xdr_reserve_space(xdr, 12);
+		if (!p)
 			goto out_resource;
 		WRITE64((s64)stat.mtime.tv_sec);
 		WRITE32(stat.mtime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
-		if ((buflen -= 8) < 0)
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
                 	goto out_resource;
 		/*
 		 * Get parent's attributes if not ignoring crossmount
@@ -2475,13 +2509,13 @@ out_acl:
 		WRITE64(stat.ino);
 	}
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
-		status = nfsd4_encode_security_label(rqstp, context,
-				contextlen, &p, &buflen);
+		status = nfsd4_encode_security_label(xdr, rqstp, context, contextlen);
 		if (status)
 			goto out;
 	}
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
-		if ((buflen -= 16) < 0)
+		p = xdr_reserve_space(xdr, 16);
+		if (!p)
 			goto out_resource;
 		WRITE32(3);
 		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
@@ -2489,8 +2523,7 @@ out_acl:
 		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
 	}
 
-	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
-	xdr->p = p;
+	*attrlenp = htonl((char *)xdr->p - (char *)attrlenp - 4);
 	status = nfs_ok;
 
 out:
@@ -2501,6 +2534,13 @@ out:
 	kfree(acl);
 	if (tempfh)
 		fh_put(tempfh);
+	if (status) {
+		int nbytes = (char *)xdr->p - (char *)start;
+		/* open code what *should* be xdr_truncate(xdr, len); */
+		xdr->iov->iov_len -= nbytes;
+		xdr->buf->len -= nbytes;
+		xdr->p = start;
+	}
 	return status;
 out_nfserr:
 	status = nfserrno(err);
@@ -2764,13 +2804,10 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 {
 	struct svc_fh *fhp = getattr->ga_fhp;
 	struct xdr_stream *xdr = &resp->xdr;
-	struct xdr_buf *buf = resp->xdr.buf;
 
 	if (nfserr)
 		return nfserr;
 
-	buf->buflen = (void *)resp->xdr.end - (void *)resp->xdr.p
-			- COMPOUND_ERR_SLACK_SPACE;
 	nfserr = nfsd4_encode_fattr(xdr, fhp, fhp->fh_export, fhp->fh_dentry,
 				    getattr->ga_bmval,
 				    resp->rqstp, 0);
@@ -2967,6 +3004,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	int v;
 	struct page *page;
 	unsigned long maxcount; 
+	struct xdr_stream *xdr = &resp->xdr;
 	long len;
 	__be32 *p;
 
@@ -3013,6 +3051,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
+	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
 	resp->xdr.buf->tail[0].iov_base = p;
@@ -3031,6 +3070,7 @@ static __be32
 nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_readlink *readlink)
 {
 	int maxcount;
+	struct xdr_stream *xdr = &resp->xdr;
 	char *page;
 	__be32 *p;
 
@@ -3063,6 +3103,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
+	xdr->iov = xdr->buf->tail;
 
 	/* Use rest of head for padding and remaining ops: */
 	resp->xdr.buf->tail[0].iov_base = p;
@@ -3082,6 +3123,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 {
 	int maxcount;
 	loff_t offset;
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *page, *savep, *tailbase;
 	__be32 *p;
 
@@ -3144,6 +3186,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	resp->xdr.buf->page_len = ((char*)p) -
 		(char*)page_address(*(resp->rqstp->rq_next_page-1));
 
+	xdr->iov = xdr->buf->tail;
+
 	/* Use rest of head for padding and remaining ops: */
 	resp->xdr.buf->tail[0].iov_base = tailbase;
 	resp->xdr.buf->tail[0].iov_len = 0;
-- 
1.8.5.3

