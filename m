Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58102 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752584Ab3AWWzl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:41 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMtffU000612
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:41 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] nfsd4: rewrite xdr encoding of attributes
Date: Wed, 23 Jan 2013 17:55:36 -0500
Message-Id: <1358981738-5649-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Write xdr encoding primitives that can handle crossing page boundaries,
and use them in nfsd4_encode_fattr.

The main practical advantage for now is that we can return arbitrarily
large ACLs (well, up to our maximum rpc size).  However, compounds with
other operations following such a getattr may fail.

Eventually we plan to use the same xdr code through v4 at least.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   6 +-
 fs/nfsd/nfs4xdr.c  | 705 +++++++++++++++++++++++++++++++++++------------------
 fs/nfsd/xdr4.h     |  18 +-
 3 files changed, 483 insertions(+), 246 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6b5c20c..f62e139 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -994,10 +994,10 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 
 	p = buf;
-	status = nfsd4_encode_fattr(&cstate->current_fh,
+	status = nfsd4_encode_fattr_to_buffer(&p, count, &cstate->current_fh,
 				    cstate->current_fh.fh_export,
-				    cstate->current_fh.fh_dentry, &p,
-				    count, verify->ve_bmval,
+				    cstate->current_fh.fh_dentry,
+				    verify->ve_bmval,
 				    rqstp, 0);
 
 	/* this means that nfsd4_encode_fattr() ran out of space */
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a7876f7..19f773e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1644,18 +1644,237 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	p += XDR_QUADLEN(nbytes);				\
 }} while (0)
 
-static void write32(__be32 **p, u32 n)
+static void next_page(struct svcxdr_ptr *ptr)
 {
-	*(*p)++ = htonl(n);
+	struct page *page;
+
+	page = *(ptr->next_page++);
+	WARN_ON(!page);
+	ptr->p = page_address(page);
+	ptr->end = ptr->p + PAGE_SIZE / 4;
+}
+
+static __be32 svcxdr_stream_init_from_resp(struct svcxdr_stream *xdr, struct nfsd4_compoundres *resp)
+{
+	struct svc_rqst *rqstp = resp->rqstp;
+	struct xdr_buf *buf = &rqstp->rq_res;
+
+	/*
+	 * Fail if we've moved past encoding the head.  (Arbitrary
+	 * restriction for now, to be lifted later.)
+	 */
+	if ((void *)resp->p < buf->head[0].iov_base
+			|| (void *)resp->p >= buf->head[0].iov_base + PAGE_SIZE)
+		return nfserr_resource;
+	buf->head[0].iov_len = (char *)resp->p - (char *)buf->head[0].iov_base;
+	buf->len = buf->head[0].iov_len;
+
+	xdr->buf = buf;
+	xdr->this_iov = buf->head;
+	xdr->ptr.p = resp->p;
+	xdr->ptr.end = resp->end;
+	xdr->ptr.next_page = rqstp->rq_next_page;
+	xdr->last_commit = xdr->ptr;
+	return nfs_ok;
+}
+
+/* XXX: len is in words not bytes.  This is confusing.  Callers could
+ * probably use more documentation on this point.
+ */
+static void svcxdr_stream_init_from_buffer(struct svcxdr_stream *xdr, __be32 *buf, int len)
+{
+	xdr->ptr.p = buf;
+	xdr->ptr.end = buf + len;
+	xdr->ptr.next_page = NULL;
+	xdr->last_commit = xdr->ptr;
+
+	xdr->buf = NULL;
+	xdr->this_iov = NULL;
+}
+
+static bool svcxdr_seek(struct svcxdr_ptr *res, unsigned int bytes)
+{
+	struct svcxdr_ptr ptr = *res;
+	unsigned int avail, this;
+
+	bytes = roundup(bytes, 4);
+
+	while (bytes) {
+		avail = (char *)ptr.end - (char *)ptr.p;
+		this = min(bytes, avail);
+		bytes -= this;
+		ptr.p += this / 4;
+		if (!bytes)
+			break;
+		if (!ptr.next_page || !*(ptr.next_page))
+			return false;
+		next_page(&ptr);
+	}
+	*res = ptr;
+	return true;
+}
+
+/*
+ * If there's still space to encode "bytes" bytes, then return true,
+ * advance the xdr stream and the end of the xdr buf by "bytes", and
+ * set ptr to the previous value of the svcxdr_stream pointer.
+ */
+static bool svcxdr_reserve_space(struct svcxdr_stream *xdr, struct svcxdr_ptr *ptr, int bytes)
+{
+	*ptr = xdr->ptr;
+
+	bytes = roundup(bytes, 4);
+
+	return svcxdr_seek(&xdr->ptr, bytes);
+}
+
+/* XXX: basic idea here:
+ * 	- useful to keep track of reserved space (though could actually
+ * 	  use caller's ptr for that; but this gives some consistency
+ * 	  checks?); hence xdr->ptr.
+ *	- also need to know where last committed, hence xdr->last_commit
+ *	- also need running pointer which is caller's ptr.
+ *	- another alternative would be to just track total reserved so
+ *	  far and re-seek, but re-seeking from start on every
+ *	  reserve seems wasteful.
+ */
+
+/* XXX: need to modify callers. */
+static void svcxdr_commit(struct svcxdr_stream *xdr)
+{
+	struct svcxdr_ptr *ptr = &xdr->ptr;
+	int page_bytes, page_offset;
+
+	if (!xdr->buf) {
+		xdr->last_commit = *ptr;
+		return;
+	}
+	if (xdr->last_commit.next_page == ptr->next_page) {
+		int this = (char *)ptr->p - (char *)xdr->last_commit.p;
+		WARN_ON_ONCE(this > PAGE_SIZE);
+
+		if (xdr->this_iov)
+			xdr->this_iov->iov_len += this;
+		else
+			xdr->buf->page_len += this;
+		xdr->buf->len += this;
+		xdr->last_commit = *ptr;
+		return;
+	}
+	if (xdr->this_iov) {
+		int this = (char *)xdr->last_commit.end
+				- (char *)xdr->last_commit.p;
+
+		xdr->this_iov->iov_len += this;
+		xdr->this_iov = NULL;
+		xdr->buf->len += this;
+	}
+	page_bytes = PAGE_SIZE *
+			(ptr->next_page - xdr->last_commit.next_page - 1);
+	page_offset = (void *)ptr->p - page_address(*(ptr->next_page - 1));
+
+	xdr->buf->page_len += page_bytes + page_offset;
+	xdr->buf->len += page_bytes + page_offset;
+	xdr->last_commit = *ptr;
+	return;
+}
+
+static void svcxdr_stream_update_resp(struct svcxdr_stream *xdr, struct nfsd4_compoundres *resp)
+{
+	struct svc_rqst *rqstp = resp->rqstp;
+
+	svcxdr_commit(xdr);
+	resp->p = xdr->last_commit.p;
+	resp->end = xdr->last_commit.end;
+	if (xdr->ptr.next_page)
+		rqstp->rq_next_page = xdr->ptr.next_page;
+}
+
+static void svcxdr_stream_update_buffer(struct svcxdr_stream *xdr, __be32 **p)
+{
+	svcxdr_commit(xdr);
+	*p = xdr->last_commit.p;
 }
 
-static void write64(__be32 **p, u64 n)
+static bool svcxdr_ptr_misordered(struct svcxdr_ptr *from, struct svcxdr_ptr *to)
 {
-	write32(p, (n >> 32));
-	write32(p, (u32)n);
+	unsigned long bytes;
+
+	if (from->next_page > to->next_page)
+		return true;
+	if (from->next_page < to->next_page)
+		return false;
+	bytes = (void *)to->p - (void *)from->p;
+	return bytes > PAGE_SIZE;
 }
 
-static void write_change(__be32 **p, struct kstat *stat, struct inode *inode)
+static int svcxdr_byte_offset(struct svcxdr_ptr *from, struct svcxdr_ptr *to)
+{
+	struct svcxdr_ptr ptr = *from;
+	int bytes = 0;
+	int final_bytes;
+
+	BUG_ON(svcxdr_ptr_misordered(from, to));
+	while (ptr.next_page < to->next_page) {
+		bytes += (void *)ptr.end - (void *)ptr.p;
+		next_page(&ptr);
+	}
+	final_bytes = (void *)to->p - (void *)ptr.p;
+	bytes += final_bytes;
+	return bytes;
+}
+
+static void svcxdr_reset(struct svcxdr_stream *xdr, struct svcxdr_ptr *to)
+{
+	WARN_ON_ONCE(svcxdr_ptr_misordered(&xdr->last_commit, to));
+	xdr->ptr = *to;
+}
+
+static void writemem(struct svcxdr_ptr *ptr, const void *data, int nbytes)
+{
+	int this, avail;
+	int paddedlen = roundup(nbytes, 4);
+	int padding = paddedlen - nbytes;
+
+	while (nbytes) {
+		avail = (char *)ptr->end - (char *)ptr->p;
+		this = min(nbytes, avail);
+		memcpy(ptr->p, data, this);
+		nbytes -= this;
+		if (!nbytes)
+			break;
+		next_page(ptr);
+		paddedlen -= this;
+		data += this;
+	}
+	ptr->p += paddedlen / 4;
+	memset((char *)ptr->p - padding, 0, padding);
+}
+
+static void write32(struct svcxdr_ptr *ptr, u32 n)
+{
+	__be32 i = htonl(n);
+	writemem(ptr, &i, sizeof(i));
+}
+
+static void write64(struct svcxdr_ptr *ptr, u64 n)
+{
+	__be32 i[2] = { htonl(n >> 32), htonl((u32)n) };
+	writemem(ptr, i, sizeof(i));
+}
+
+static bool write_opaque(struct svcxdr_stream *xdr, const void *data, int len)
+{
+	struct svcxdr_ptr ptr;
+
+	if (!svcxdr_reserve_space(xdr, &ptr, 4 + len))
+		return false;
+	write32(&ptr, len);
+	writemem(&ptr, data, len);
+	return true;
+}
+
+static void write_change(struct svcxdr_ptr *p, struct kstat *stat, struct inode *inode)
 {
 	if (IS_I_VERSION(inode)) {
 		write64(p, inode->i_version);
@@ -1665,18 +1884,21 @@ static void write_change(__be32 **p, struct kstat *stat, struct inode *inode)
 	}
 }
 
-static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
+static void write_cinfo(__be32 **pp, struct nfsd4_change_info *c)
 {
-	write32(p, c->atomic);
+	__be32 *p = *pp;
+
+	WRITE32(c->atomic);
 	if (c->change_supported) {
-		write64(p, c->before_change);
-		write64(p, c->after_change);
+		WRITE64(c->before_change);
+		WRITE64(c->after_change);
 	} else {
-		write32(p, c->before_ctime_sec);
-		write32(p, c->before_ctime_nsec);
-		write32(p, c->after_ctime_sec);
-		write32(p, c->after_ctime_nsec);
+		WRITE32(c->before_ctime_sec);
+		WRITE32(c->before_ctime_nsec);
+		WRITE32(c->after_ctime_sec);
+		WRITE32(c->after_ctime_nsec);
 	}
+	*pp = p;
 }
 
 #define RESERVE_SPACE(nbytes)	do {				\
@@ -1718,19 +1940,19 @@ static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, _
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
  */
-static __be32 nfsd4_encode_components_esc(char sep, char *components,
-				   __be32 **pp, int *buflen,
+static __be32 nfsd4_encode_components_esc(struct svcxdr_stream *xdr, char sep, char *components,
 				   char esc_enter, char esc_exit)
 {
-	__be32 *p = *pp;
-	__be32 *countp = p;
+	struct svcxdr_ptr p;
+	struct svcxdr_ptr countp;
 	int strlen, count=0;
 	char *str, *end, *next;
 
 	dprintk("nfsd4_encode_components(%s)\n", components);
-	if ((*buflen -= 4) < 0)
+	if (!svcxdr_reserve_space(xdr, &p, 4))
 		return nfserr_resource;
-	WRITE32(0); /* We will fill this in with @count later */
+	countp = p;
+	write32(&p, 0); /* We will fill this in with @count later */
 	end = str = components;
 	while (*end) {
 		bool found_esc = false;
@@ -1752,62 +1974,52 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
 
 		strlen = end - str;
 		if (strlen) {
-			if ((*buflen -= ((XDR_QUADLEN(strlen) << 2) + 4)) < 0)
+			if (!write_opaque(xdr, str, strlen))
 				return nfserr_resource;
-			WRITE32(strlen);
-			WRITEMEM(str, strlen);
 			count++;
-		}
-		else
+		} else
 			end++;
 		str = end;
 	}
-	*pp = p;
-	p = countp;
-	WRITE32(count);
+	write32(&countp, count);
 	return 0;
 }
 
 /* Encode as an array of strings the string given with components
  * separated @sep.
  */
-static __be32 nfsd4_encode_components(char sep, char *components,
-				   __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_components(struct svcxdr_stream *xdr, char sep, char *components)
 {
-	return nfsd4_encode_components_esc(sep, components, pp, buflen, 0, 0);
+	return nfsd4_encode_components_esc(xdr, sep, components, 0, 0);
 }
 
 /*
  * encode a location element of a fs_locations structure
  */
-static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
-				    __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_fs_location4(struct svcxdr_stream *xdr, struct nfsd4_fs_location *location)
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
+static __be32 nfsd4_encode_path(struct svcxdr_stream *xdr, const struct path *root, const struct path *path)
 {
 	struct path cur = {
 		.mnt = path->mnt,
 		.dentry = path->dentry,
 	};
-	__be32 *p = *pp;
+	struct svcxdr_ptr p;
 	struct dentry **components = NULL;
 	unsigned int ncomponents = 0;
 	__be32 err = nfserr_jukebox;
@@ -1839,26 +2051,22 @@ static __be32 nfsd4_encode_path(const struct path *root,
 		cur.dentry = dget_parent(cur.dentry);
 	}
 
-	*buflen -= 4;
-	if (*buflen < 0)
+	err = nfserr_resource;
+	if (!svcxdr_reserve_space(xdr, &p, 4))
 		goto out_free;
-	WRITE32(ncomponents);
+	write32(&p, ncomponents);
 
 	while (ncomponents) {
 		struct dentry *dentry = components[ncomponents - 1];
 		unsigned int len = dentry->d_name.len;
 
-		*buflen -= 4 + (XDR_QUADLEN(len) << 2);
-		if (*buflen < 0)
+		if (!write_opaque(xdr, dentry->d_name.name, len))
 			goto out_free;
-		WRITE32(len);
-		WRITEMEM(dentry->d_name.name, len);
 		dprintk("/%s", dentry->d_name.name);
 		dput(dentry);
 		ncomponents--;
 	}
 
-	*pp = p;
 	err = 0;
 out_free:
 	dprintk(")\n");
@@ -1869,8 +2077,7 @@ out_free:
 	return err;
 }
 
-static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
-		const struct path *path, __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_fsloc_fsroot(struct svcxdr_stream *xdr, struct svc_rqst *rqstp, const struct path *path)
 {
 	struct svc_export *exp_ps;
 	__be32 res;
@@ -1878,7 +2085,7 @@ static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
 	exp_ps = rqst_find_fsidzero_export(rqstp);
 	if (IS_ERR(exp_ps))
 		return nfserrno(PTR_ERR(exp_ps));
-	res = nfsd4_encode_path(&exp_ps->ex_path, path, pp, buflen);
+	res = nfsd4_encode_path(xdr, &exp_ps->ex_path, path);
 	exp_put(exp_ps);
 	return res;
 }
@@ -1886,28 +2093,24 @@ static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
 /*
  *  encode a fs_locations structure
  */
-static __be32 nfsd4_encode_fs_locations(struct svc_rqst *rqstp,
-				     struct svc_export *exp,
-				     __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_fs_locations(struct svcxdr_stream *xdr, struct svc_rqst *rqstp, struct svc_export *exp)
 {
 	__be32 status;
+	struct svcxdr_ptr ptr;
 	int i;
-	__be32 *p = *pp;
 	struct nfsd4_fs_locations *fslocs = &exp->ex_fslocs;
 
-	status = nfsd4_encode_fsloc_fsroot(rqstp, &exp->ex_path, &p, buflen);
+	status = nfsd4_encode_fsloc_fsroot(xdr, rqstp, &exp->ex_path);
 	if (status)
 		return status;
-	if ((*buflen -= 4) < 0)
+	if (!svcxdr_reserve_space(xdr, &ptr, 4))
 		return nfserr_resource;
-	WRITE32(fslocs->locations_count);
+	write32(&ptr, fslocs->locations_count);
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
 
@@ -1926,44 +2129,40 @@ static u32 nfs4_file_type(umode_t mode)
 }
 
 static __be32
-nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
-			__be32 **p, int *buflen)
+nfsd4_encode_name(struct svcxdr_stream *xdr, struct svc_rqst *rqstp, int whotype, uid_t id, int group)
 {
+	char buf[IDMAP_NAMESZ]; /* XXX: fix mapping fns to write to xdr */
 	int status;
 
-	if (*buflen < (XDR_QUADLEN(IDMAP_NAMESZ) << 2) + 4)
-		return nfserr_resource;
 	if (whotype != NFS4_ACL_WHO_NAMED)
-		status = nfs4_acl_write_who(whotype, (u8 *)(*p + 1));
+		status = nfs4_acl_write_who(whotype, buf);
 	else if (group)
-		status = nfsd_map_gid_to_name(rqstp, id, (u8 *)(*p + 1));
+		status = nfsd_map_gid_to_name(rqstp, id, buf);
 	else
-		status = nfsd_map_uid_to_name(rqstp, id, (u8 *)(*p + 1));
+		status = nfsd_map_uid_to_name(rqstp, id, buf);
 	if (status < 0)
 		return nfserrno(status);
-	*p = xdr_encode_opaque(*p, NULL, status);
-	*buflen -= (XDR_QUADLEN(status) << 2) + 4;
-	BUG_ON(*buflen < 0);
-	return 0;
+	if (!write_opaque(xdr, buf, status))
+		return nfserr_resource;
+	return nfs_ok;
 }
 
 static inline __be32
-nfsd4_encode_user(struct svc_rqst *rqstp, uid_t uid, __be32 **p, int *buflen)
+nfsd4_encode_user(struct svcxdr_stream *xdr, struct svc_rqst *rqstp, uid_t uid)
 {
-	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, uid, 0, p, buflen);
+	return nfsd4_encode_name(xdr, rqstp, NFS4_ACL_WHO_NAMED, uid, 0);
 }
 
 static inline __be32
-nfsd4_encode_group(struct svc_rqst *rqstp, uid_t gid, __be32 **p, int *buflen)
+nfsd4_encode_group(struct svcxdr_stream *xdr, struct svc_rqst *rqstp, uid_t gid)
 {
-	return nfsd4_encode_name(rqstp, NFS4_ACL_WHO_NAMED, gid, 1, p, buflen);
+	return nfsd4_encode_name(xdr, rqstp, NFS4_ACL_WHO_NAMED, gid, 1);
 }
 
 static inline __be32
-nfsd4_encode_aclname(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
-		__be32 **p, int *buflen)
+nfsd4_encode_aclname(struct svcxdr_stream *xdr, struct svc_rqst *rqstp, int whotype, uid_t id, int group)
 {
-	return nfsd4_encode_name(rqstp, whotype, id, group, p, buflen);
+	return nfsd4_encode_name(xdr, rqstp, whotype, id, group);
 }
 
 #define WORD0_ABSENT_FS_ATTRS (FATTR4_WORD0_FS_LOCATIONS | FATTR4_WORD0_FSID | \
@@ -2008,9 +2207,9 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
  *
  * countp is the buffer size in _words_
  */
-__be32
-nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		struct dentry *dentry, __be32 **buffer, int count, u32 *bmval,
+static __be32
+nfsd4_encode_fattr(struct svcxdr_stream *xdr, struct svc_fh *fhp,
+		struct svc_export *exp, struct dentry *dentry, u32 *bmval,
 		struct svc_rqst *rqstp, int ignore_crossmnt)
 {
 	u32 bmval0 = bmval[0];
@@ -2019,14 +2218,15 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	struct kstat stat;
 	struct svc_fh tempfh;
 	struct kstatfs statfs;
-	int buflen = count << 2;
-	__be32 *attrlenp;
+	struct svcxdr_ptr attrlenp;
+	struct svcxdr_ptr ptr;
+	struct svcxdr_ptr start = xdr->ptr;
 	u32 dummy;
 	u64 dummy64;
 	u32 rdattr_err = 0;
-	__be32 *p = *buffer;
 	__be32 status;
 	int err;
+	int attrlen;
 	int aclsupport = 0;
 	struct nfs4_acl *acl = NULL;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
@@ -2083,25 +2283,28 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	}
 
 	if (bmval2) {
-		if ((buflen -= 16) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 16))
 			goto out_resource;
-		WRITE32(3);
-		WRITE32(bmval0);
-		WRITE32(bmval1);
-		WRITE32(bmval2);
+		write32(&ptr, 3);
+		write32(&ptr, bmval0);
+		write32(&ptr, bmval1);
+		write32(&ptr, bmval2);
 	} else if (bmval1) {
-		if ((buflen -= 12) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 12))
 			goto out_resource;
-		WRITE32(2);
-		WRITE32(bmval0);
-		WRITE32(bmval1);
+		write32(&ptr, 2);
+		write32(&ptr, bmval0);
+		write32(&ptr, bmval1);
 	} else {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE32(1);
-		WRITE32(bmval0);
+		write32(&ptr, 1);
+		write32(&ptr, bmval0);
 	}
-	attrlenp = p++;                /* to be backfilled later */
+	attrlenp = ptr;
+	if (!svcxdr_reserve_space(xdr, &ptr, 4))
+		goto out_resource;
+	write32(&ptr, 0); /* to be filled in later */
 
 	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
 		u32 word0 = nfsd_suppattrs0(minorversion);
@@ -2111,301 +2314,299 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
 		if (!word2) {
-			if ((buflen -= 12) < 0)
+			if (!svcxdr_reserve_space(xdr, &ptr, 12))
 				goto out_resource;
-			WRITE32(2);
-			WRITE32(word0);
-			WRITE32(word1);
+			write32(&ptr, 2);
+			write32(&ptr, word0);
+			write32(&ptr, word1);
 		} else {
-			if ((buflen -= 16) < 0)
+			if (!svcxdr_reserve_space(xdr, &ptr, 16))
 				goto out_resource;
-			WRITE32(3);
-			WRITE32(word0);
-			WRITE32(word1);
-			WRITE32(word2);
+			write32(&ptr, 3);
+			write32(&ptr, word0);
+			write32(&ptr, word1);
+			write32(&ptr, word2);
 		}
 	}
 	if (bmval0 & FATTR4_WORD0_TYPE) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
 		dummy = nfs4_file_type(stat.mode);
 		if (dummy == NF4BAD) {
 			status = nfserr_serverfault;
 			goto out;
 		}
-		WRITE32(dummy);
+		write32(&ptr, dummy);
 	}
 	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
 		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
-			WRITE32(NFS4_FH_PERSISTENT);
+			write32(&ptr, NFS4_FH_PERSISTENT);
 		else
-			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
+			write32(&ptr, NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		write_change(&p, &stat, dentry->d_inode);
+		write_change(&ptr, &stat, dentry->d_inode);
 	}
 	if (bmval0 & FATTR4_WORD0_SIZE) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64(stat.size);
+		write64(&ptr, stat.size);
 	}
 	if (bmval0 & FATTR4_WORD0_LINK_SUPPORT) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval0 & FATTR4_WORD0_SYMLINK_SUPPORT) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval0 & FATTR4_WORD0_NAMED_ATTR) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(0);
+		write32(&ptr, 0);
 	}
 	if (bmval0 & FATTR4_WORD0_FSID) {
-		if ((buflen -= 16) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 16))
 			goto out_resource;
 		if (exp->ex_fslocs.migrated) {
-			WRITE64(NFS4_REFERRAL_FSID_MAJOR);
-			WRITE64(NFS4_REFERRAL_FSID_MINOR);
+			write64(&ptr, NFS4_REFERRAL_FSID_MAJOR);
+			write64(&ptr, NFS4_REFERRAL_FSID_MINOR);
 		} else switch(fsid_source(fhp)) {
 		case FSIDSOURCE_FSID:
-			WRITE64((u64)exp->ex_fsid);
-			WRITE64((u64)0);
+			write64(&ptr, (u64)exp->ex_fsid);
+			write64(&ptr, 0);
 			break;
 		case FSIDSOURCE_DEV:
-			WRITE32(0);
-			WRITE32(MAJOR(stat.dev));
-			WRITE32(0);
-			WRITE32(MINOR(stat.dev));
+			write32(&ptr, 0);
+			write32(&ptr, MAJOR(stat.dev));
+			write32(&ptr, 0);
+			write32(&ptr, MINOR(stat.dev));
 			break;
 		case FSIDSOURCE_UUID:
-			WRITEMEM(exp->ex_uuid, 16);
+			writemem(&ptr, exp->ex_uuid, 16);
 			break;
 		}
 	}
 	if (bmval0 & FATTR4_WORD0_UNIQUE_HANDLES) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(0);
+		write32(&ptr, 0);
 	}
 	if (bmval0 & FATTR4_WORD0_LEASE_TIME) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(nn->nfsd4_lease);
+		write32(&ptr, nn->nfsd4_lease);
 	}
 	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(rdattr_err);
+		write32(&ptr, rdattr_err);
 	}
 	if (bmval0 & FATTR4_WORD0_ACL) {
 		struct nfs4_ace *ace;
 
 		if (acl == NULL) {
-			if ((buflen -= 4) < 0)
+			if (!svcxdr_reserve_space(xdr, &ptr, 4))
 				goto out_resource;
 
-			WRITE32(0);
+			write32(&ptr, 0);
 			goto out_acl;
 		}
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(acl->naces);
+		write32(&ptr, acl->naces);
 
 		for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
-			if ((buflen -= 4*3) < 0)
+			if (!svcxdr_reserve_space(xdr, &ptr, 4*3))
 				goto out_resource;
-			WRITE32(ace->type);
-			WRITE32(ace->flag);
-			WRITE32(ace->access_mask & NFS4_ACE_MASK_ALL);
-			status = nfsd4_encode_aclname(rqstp, ace->whotype,
-				ace->who, ace->flag & NFS4_ACE_IDENTIFIER_GROUP,
-				&p, &buflen);
+			write32(&ptr, ace->type);
+			write32(&ptr, ace->flag);
+			write32(&ptr, ace->access_mask & NFS4_ACE_MASK_ALL);
+			status = nfsd4_encode_aclname(xdr, rqstp, ace->whotype,
+				ace->who, ace->flag & NFS4_ACE_IDENTIFIER_GROUP);
 			if (status)
 				goto out;
 		}
 	}
 out_acl:
 	if (bmval0 & FATTR4_WORD0_ACLSUPPORT) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(aclsupport ?
+		write32(&ptr, aclsupport ?
 			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_INSENSITIVE) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(0);
+		write32(&ptr, 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_PRESERVING) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval0 & FATTR4_WORD0_CHOWN_RESTRICTED) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEHANDLE) {
-		buflen -= (XDR_QUADLEN(fhp->fh_handle.fh_size) << 2) + 4;
-		if (buflen < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, (XDR_QUADLEN(fhp->fh_handle.fh_size) << 2) + 4))
 			goto out_resource;
-		WRITE32(fhp->fh_handle.fh_size);
-		WRITEMEM(&fhp->fh_handle.fh_base, fhp->fh_handle.fh_size);
+		write32(&ptr, fhp->fh_handle.fh_size);
+		writemem(&ptr, &fhp->fh_handle.fh_base, fhp->fh_handle.fh_size);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEID) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64(stat.ino);
+		write64(&ptr, stat.ino);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_AVAIL) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64((u64) statfs.f_ffree);
+		write64(&ptr, (u64) statfs.f_ffree);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_FREE) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64((u64) statfs.f_ffree);
+		write64(&ptr, (u64) statfs.f_ffree);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_TOTAL) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64((u64) statfs.f_files);
+		write64(&ptr, (u64) statfs.f_files);
 	}
 	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
-		status = nfsd4_encode_fs_locations(rqstp, exp, &p, &buflen);
+		status = nfsd4_encode_fs_locations(xdr, rqstp, exp);
 		if (status)
 			goto out;
 	}
 	if (bmval0 & FATTR4_WORD0_HOMOGENEOUS) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXFILESIZE) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64(~(u64)0);
+		write64(&ptr, ~(u64)0);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXLINK) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(255);
+		write32(&ptr, 255);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXNAME) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(statfs.f_namelen);
+		write32(&ptr, statfs.f_namelen);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXREAD) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64((u64) svc_max_payload(rqstp));
+		write64(&ptr, (u64) svc_max_payload(rqstp));
 	}
 	if (bmval0 & FATTR4_WORD0_MAXWRITE) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE64((u64) svc_max_payload(rqstp));
+		write64(&ptr, (u64) svc_max_payload(rqstp));
 	}
 	if (bmval1 & FATTR4_WORD1_MODE) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(stat.mode & S_IALLUGO);
+		write32(&ptr, stat.mode & S_IALLUGO);
 	}
 	if (bmval1 & FATTR4_WORD1_NO_TRUNC) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(1);
+		write32(&ptr, 1);
 	}
 	if (bmval1 & FATTR4_WORD1_NUMLINKS) {
-		if ((buflen -= 4) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 4))
 			goto out_resource;
-		WRITE32(stat.nlink);
+		write32(&ptr, stat.nlink);
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
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
-		WRITE32((u32) MAJOR(stat.rdev));
-		WRITE32((u32) MINOR(stat.rdev));
+		write32(&ptr, (u32) MAJOR(stat.rdev));
+		write32(&ptr, (u32) MINOR(stat.rdev));
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_AVAIL) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
 		dummy64 = (u64)statfs.f_bavail * (u64)statfs.f_bsize;
-		WRITE64(dummy64);
+		write64(&ptr, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_FREE) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
 		dummy64 = (u64)statfs.f_bfree * (u64)statfs.f_bsize;
-		WRITE64(dummy64);
+		write64(&ptr, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_TOTAL) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
 		dummy64 = (u64)statfs.f_blocks * (u64)statfs.f_bsize;
-		WRITE64(dummy64);
+		write64(&ptr, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_USED) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
 			goto out_resource;
 		dummy64 = (u64)stat.blocks << 9;
-		WRITE64(dummy64);
+		write64(&ptr, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_ACCESS) {
-		if ((buflen -= 12) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 12))
 			goto out_resource;
-		WRITE32(0);
-		WRITE32(stat.atime.tv_sec);
-		WRITE32(stat.atime.tv_nsec);
+		write32(&ptr, 0);
+		write32(&ptr, stat.atime.tv_sec);
+		write32(&ptr, stat.atime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_DELTA) {
-		if ((buflen -= 12) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 12))
 			goto out_resource;
-		WRITE32(0);
-		WRITE32(1);
-		WRITE32(0);
+		write32(&ptr, 0);
+		write32(&ptr, 1);
+		write32(&ptr, 0);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_METADATA) {
-		if ((buflen -= 12) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 12))
 			goto out_resource;
-		WRITE32(0);
-		WRITE32(stat.ctime.tv_sec);
-		WRITE32(stat.ctime.tv_nsec);
+		write32(&ptr, 0);
+		write32(&ptr, stat.ctime.tv_sec);
+		write32(&ptr, stat.ctime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_MODIFY) {
-		if ((buflen -= 12) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 12))
 			goto out_resource;
-		WRITE32(0);
-		WRITE32(stat.mtime.tv_sec);
-		WRITE32(stat.mtime.tv_nsec);
+		write32(&ptr, 0);
+		write32(&ptr, stat.mtime.tv_sec);
+		write32(&ptr, stat.mtime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
-		if ((buflen -= 8) < 0)
+		if (!svcxdr_reserve_space(xdr, &ptr, 8))
                 	goto out_resource;
 		/*
 		 * Get parent's attributes if not ignoring crossmount
@@ -2414,30 +2615,43 @@ out_acl:
 		if (ignore_crossmnt == 0 &&
 		    dentry == exp->ex_path.mnt->mnt_root)
 			get_parent_attributes(exp, &stat);
-		WRITE64(stat.ino);
+		write64(&ptr, stat.ino);
 	}
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
-		WRITE32(3);
-		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
-		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD1);
-		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
+		write32(&ptr, 3);
+		write32(&ptr, NFSD_SUPPATTR_EXCLCREAT_WORD0);
+		write32(&ptr, NFSD_SUPPATTR_EXCLCREAT_WORD1);
+		write32(&ptr, NFSD_SUPPATTR_EXCLCREAT_WORD2);
 	}
 
-	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
-	*buffer = p;
+	attrlen = svcxdr_byte_offset(&attrlenp, &xdr->ptr) - 4;
+	write32(&attrlenp, attrlen);
 	status = nfs_ok;
-
 out:
 	kfree(acl);
 	if (fhp == &tempfh)
 		fh_put(&tempfh);
 	return status;
+out_reset:
+	svcxdr_reset(xdr, &start);
+	goto out;
 out_nfserr:
 	status = nfserrno(err);
-	goto out;
+	goto out_reset;
 out_resource:
 	status = nfserr_resource;
-	goto out;
+	goto out_reset;
+}
+
+__be32 nfsd4_encode_fattr_to_buffer(__be32 **p, int count, struct svc_fh *fh, struct svc_export *exp, struct dentry *dentry, u32 *bmval, struct svc_rqst *rqstp, int ignore_crossmnt)
+{
+	struct svcxdr_stream xdr;
+	__be32 nfserr;
+
+	svcxdr_stream_init_from_buffer(&xdr, *p, count);
+	nfserr = nfsd4_encode_fattr(&xdr, fh, exp, dentry, bmval, rqstp, ignore_crossmnt);
+	svcxdr_stream_update_buffer(&xdr, p);
+	return nfserr;
 }
 
 static inline int attributes_need_mount(u32 *bmval)
@@ -2503,7 +2717,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 
 	}
 out_encode:
-	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
+	nfserr = nfsd4_encode_fattr_to_buffer(p, buflen, NULL, exp, dentry, cd->rd_bmval,
 					cd->rd_rqstp, ignore_crossmnt);
 out_put:
 	dput(dentry);
@@ -2676,15 +2890,18 @@ static __be32
 nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_getattr *getattr)
 {
 	struct svc_fh *fhp = getattr->ga_fhp;
-	int buflen;
+	struct svcxdr_stream xdr;
 
 	if (nfserr)
 		return nfserr;
 
-	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
-	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
-				    &resp->p, buflen, getattr->ga_bmval,
+	nfserr = svcxdr_stream_init_from_resp(&xdr, resp);
+	if (nfserr)
+		return nfserr;
+	nfserr = nfsd4_encode_fattr(&xdr, fhp, fhp->fh_export, fhp->fh_dentry,
+				    getattr->ga_bmval,
 				    resp->rqstp, 0);
+	svcxdr_stream_update_resp(&xdr, resp);
 	return nfserr;
 }
 
@@ -3629,6 +3846,11 @@ nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_comp
 	return !nfsd4_decode_compound(args);
 }
 
+static bool in_same_page(void *p, void *q)
+{
+	return ((unsigned long)p & PAGE_MASK) == ((unsigned long)q & PAGE_MASK);
+}
+
 int
 nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compoundres *resp)
 {
@@ -3636,19 +3858,22 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	 * All that remains is to write the tag and operation count...
 	 */
 	struct nfsd4_compound_state *cs = &resp->cstate;
-	struct kvec *iov;
+	struct kvec *iov = NULL;
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
 	memcpy(p, resp->tag, resp->taglen);
 	p += XDR_QUADLEN(resp->taglen);
 	*p++ = htonl(resp->opcnt);
 
-	if (rqstp->rq_res.page_len) 
+	/* Hacky: detect whether resp->p is in head or tail, fix up
+	 * length accordingly: */
+	if (in_same_page(resp->p, rqstp->rq_res.tail[0].iov_base))
 		iov = &rqstp->rq_res.tail[0];
-	else
+	else if (in_same_page(resp->p, rqstp->rq_res.head[0].iov_base))
 		iov = &rqstp->rq_res.head[0];
-	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
-	BUG_ON(iov->iov_len > PAGE_SIZE);
+	if (iov)
+		iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
+	BUG_ON(iov && iov->iov_len > PAGE_SIZE);
 	if (nfsd4_has_session(cs)) {
 		if (cs->status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 546f898..4d9c82b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -43,6 +43,19 @@
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
+struct svcxdr_ptr {
+	__be32 *p;
+	__be32 *end;
+	struct page **next_page;
+};
+
+struct svcxdr_stream {
+	struct svcxdr_ptr last_commit;
+	struct svcxdr_ptr ptr;
+	struct xdr_buf *buf;
+	struct kvec *this_iov;
+};
+
 #define CURRENT_STATE_ID_FLAG (1<<0)
 #define SAVED_STATE_ID_FLAG (1<<1)
 
@@ -562,9 +575,8 @@ int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
-__be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		       struct dentry *dentry, __be32 **buffer, int countp,
-		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
+
+__be32 nfsd4_encode_fattr_to_buffer(__be32 **, int, struct svc_fh *, struct svc_export *, struct dentry *, u32 *, struct svc_rqst *, int);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.7.11.7

