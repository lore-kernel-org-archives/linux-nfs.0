Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47932 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbaCWBMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 47/50] nfsd4: kill WRITE32
Date: Sat, 22 Mar 2014 21:12:18 -0400
Message-Id: <1395537141-10389-48-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These macros just obsucre what's going on.  Adopt the convention of the
client-side code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 303 +++++++++++++++++++++++++++---------------------------
 1 file changed, 151 insertions(+), 152 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d92dd1b..7a827c1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1700,7 +1700,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_TAIL;
 }
 
-#define WRITE32(n)               *p++ = htonl(n)
 #define WRITE64(n)               do {				\
 	*p++ = htonl((u32)((n) >> 32));				\
 	*p++ = htonl((u32)(n));					\
@@ -1789,7 +1788,7 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep, char
 			p = xdr_reserve_space(xdr, strlen + 4);
 			if (!p)
 				return nfserr_resource;
-			WRITE32(strlen);
+			*p++ = cpu_to_be32(strlen);
 			WRITEMEM(str, strlen);
 			count++;
 		}
@@ -1868,7 +1867,7 @@ static __be32 nfsd4_encode_path(struct xdr_stream *xdr, const struct path *root,
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		goto out_free;
-	WRITE32(ncomponents);
+	*p++ = cpu_to_be32(ncomponents);
 
 	while (ncomponents) {
 		struct dentry *dentry = components[ncomponents - 1];
@@ -1881,7 +1880,7 @@ static __be32 nfsd4_encode_path(struct xdr_stream *xdr, const struct path *root,
 			spin_unlock(&dentry->d_lock);
 			goto out_free;
 		}
-		WRITE32(len);
+		*p++ = cpu_to_be32(len);
 		WRITEMEM(dentry->d_name.name, len);
 		dprintk("/%s", dentry->d_name.name);
 		spin_unlock(&dentry->d_lock);
@@ -1928,7 +1927,7 @@ static __be32 nfsd4_encode_fs_locations(struct xdr_stream *xdr, struct svc_rqst
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		return nfserr_resource;
-	WRITE32(fslocs->locations_count);
+	*p++ = cpu_to_be32(fslocs->locations_count);
 	for (i=0; i<fslocs->locations_count; i++) {
 		status = nfsd4_encode_fs_location4(xdr, &fslocs->locations[i]);
 		if (status)
@@ -1980,8 +1979,8 @@ nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp, void
 	 * For now we use a 0 here to indicate the null translation; in
 	 * the future we may place a call to translation code here.
 	 */
-	WRITE32(0); /* lfs */
-	WRITE32(0); /* pi */
+	*p++ = cpu_to_be32(0); /* lfs */
+	*p++ = cpu_to_be32(0); /* pi */
 	p = xdr_encode_opaque(p, context, len);
 	return 0;
 }
@@ -2128,23 +2127,23 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		p = xdr_reserve_space(xdr, 16);
 		if (!p)
 			goto out_resource;
-		WRITE32(3);
-		WRITE32(bmval0);
-		WRITE32(bmval1);
-		WRITE32(bmval2);
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(bmval0);
+		*p++ = cpu_to_be32(bmval1);
+		*p++ = cpu_to_be32(bmval2);
 	} else if (bmval1) {
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
-		WRITE32(2);
-		WRITE32(bmval0);
-		WRITE32(bmval1);
+		*p++ = cpu_to_be32(2);
+		*p++ = cpu_to_be32(bmval0);
+		*p++ = cpu_to_be32(bmval1);
 	} else {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
-		WRITE32(bmval0);
+		*p++ = cpu_to_be32(1);
+		*p++ = cpu_to_be32(bmval0);
 	}
 
 	attrlen_offset = xdr->buf->len;
@@ -2166,17 +2165,17 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 			p = xdr_reserve_space(xdr, 12);
 			if (!p)
 				goto out_resource;
-			WRITE32(2);
-			WRITE32(word0);
-			WRITE32(word1);
+			*p++ = cpu_to_be32(2);
+			*p++ = cpu_to_be32(word0);
+			*p++ = cpu_to_be32(word1);
 		} else {
 			p = xdr_reserve_space(xdr, 16);
 			if (!p)
 				goto out_resource;
-			WRITE32(3);
-			WRITE32(word0);
-			WRITE32(word1);
-			WRITE32(word2);
+			*p++ = cpu_to_be32(3);
+			*p++ = cpu_to_be32(word0);
+			*p++ = cpu_to_be32(word1);
+			*p++ = cpu_to_be32(word2);
 		}
 	}
 	if (bmval0 & FATTR4_WORD0_TYPE) {
@@ -2188,16 +2187,16 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 			status = nfserr_serverfault;
 			goto out;
 		}
-		WRITE32(dummy);
+		*p++ = cpu_to_be32(dummy);
 	}
 	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
 		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
-			WRITE32(NFS4_FH_PERSISTENT);
+			*p++ = cpu_to_be32(NFS4_FH_PERSISTENT);
 		else
-			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
+			*p++ = cpu_to_be32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2215,19 +2214,19 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_SYMLINK_SUPPORT) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_NAMED_ATTR) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_FSID) {
 		p = xdr_reserve_space(xdr, 16);
@@ -2242,10 +2241,10 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 			WRITE64((u64)0);
 			break;
 		case FSIDSOURCE_DEV:
-			WRITE32(0);
-			WRITE32(MAJOR(stat.dev));
-			WRITE32(0);
-			WRITE32(MINOR(stat.dev));
+			*p++ = cpu_to_be32(0);
+			*p++ = cpu_to_be32(MAJOR(stat.dev));
+			*p++ = cpu_to_be32(0);
+			*p++ = cpu_to_be32(MINOR(stat.dev));
 			break;
 		case FSIDSOURCE_UUID:
 			WRITEMEM(exp->ex_uuid, 16);
@@ -2256,19 +2255,19 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_LEASE_TIME) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(nn->nfsd4_lease);
+		*p++ = cpu_to_be32(nn->nfsd4_lease);
 	}
 	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(rdattr_err);
+		*p++ = cpu_to_be32(rdattr_err);
 	}
 	if (bmval0 & FATTR4_WORD0_ACL) {
 		struct nfs4_ace *ace;
@@ -2278,21 +2277,21 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 			if (!p)
 				goto out_resource;
 
-			WRITE32(0);
+			*p++ = cpu_to_be32(0);
 			goto out_acl;
 		}
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(acl->naces);
+		*p++ = cpu_to_be32(acl->naces);
 
 		for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
 			p = xdr_reserve_space(xdr, 4*3);
 			if (!p)
 				goto out_resource;
-			WRITE32(ace->type);
-			WRITE32(ace->flag);
-			WRITE32(ace->access_mask & NFS4_ACE_MASK_ALL);
+			*p++ = cpu_to_be32(ace->type);
+			*p++ = cpu_to_be32(ace->flag);
+			*p++ = cpu_to_be32(ace->access_mask & NFS4_ACE_MASK_ALL);
 			status = nfsd4_encode_aclname(xdr, rqstp, ace);
 			if (status)
 				goto out;
@@ -2303,38 +2302,38 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(aclsupport ?
+		*p++ = cpu_to_be32(aclsupport ?
 			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_INSENSITIVE) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_PRESERVING) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_CHOWN_RESTRICTED) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEHANDLE) {
 		p = xdr_reserve_space(xdr, fhp->fh_handle.fh_size + 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(fhp->fh_handle.fh_size);
+		*p++ = cpu_to_be32(fhp->fh_handle.fh_size);
 		WRITEMEM(&fhp->fh_handle.fh_base, fhp->fh_handle.fh_size);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEID) {
@@ -2370,7 +2369,7 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXFILESIZE) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2382,13 +2381,13 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(255);
+		*p++ = cpu_to_be32(255);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXNAME) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(statfs.f_namelen);
+		*p++ = cpu_to_be32(statfs.f_namelen);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXREAD) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2406,19 +2405,19 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(stat.mode & S_IALLUGO);
+		*p++ = cpu_to_be32(stat.mode & S_IALLUGO);
 	}
 	if (bmval1 & FATTR4_WORD1_NO_TRUNC) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(1);
+		*p++ = cpu_to_be32(1);
 	}
 	if (bmval1 & FATTR4_WORD1_NUMLINKS) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		WRITE32(stat.nlink);
+		*p++ = cpu_to_be32(stat.nlink);
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER) {
 		status = nfsd4_encode_user(xdr, rqstp, stat.uid);
@@ -2434,8 +2433,8 @@ out_acl:
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE32((u32) MAJOR(stat.rdev));
-		WRITE32((u32) MINOR(stat.rdev));
+		*p++ = cpu_to_be32((u32) MAJOR(stat.rdev));
+		*p++ = cpu_to_be32((u32) MINOR(stat.rdev));
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_AVAIL) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2470,29 +2469,29 @@ out_acl:
 		if (!p)
 			goto out_resource;
 		WRITE64((s64)stat.atime.tv_sec);
-		WRITE32(stat.atime.tv_nsec);
+		*p++ = cpu_to_be32(stat.atime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_DELTA) {
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
-		WRITE32(0);
-		WRITE32(1);
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(1);
+		*p++ = cpu_to_be32(0);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_METADATA) {
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
 		WRITE64((s64)stat.ctime.tv_sec);
-		WRITE32(stat.ctime.tv_nsec);
+		*p++ = cpu_to_be32(stat.ctime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_MODIFY) {
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
 		WRITE64((s64)stat.mtime.tv_sec);
-		WRITE32(stat.mtime.tv_nsec);
+		*p++ = cpu_to_be32(stat.mtime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2516,10 +2515,10 @@ out_acl:
 		p = xdr_reserve_space(xdr, 16);
 		if (!p)
 			goto out_resource;
-		WRITE32(3);
-		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
-		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD1);
-		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
+		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD1);
+		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
 	}
 
 	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
@@ -2749,7 +2748,7 @@ nfsd4_encode_stateid(struct xdr_stream *xdr, stateid_t *sid)
 	p = xdr_reserve_space(xdr, sizeof(stateid_t));
 	if (!p)
 		return nfserr_resource;
-	WRITE32(sid->si_generation);
+	*p++ = cpu_to_be32(sid->si_generation);
 	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
 	return 0;
 }
@@ -2764,8 +2763,8 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(access->ac_supported);
-		WRITE32(access->ac_resp_access);
+		*p++ = cpu_to_be32(access->ac_supported);
+		*p++ = cpu_to_be32(access->ac_resp_access);
 	}
 	return nfserr;
 }
@@ -2780,9 +2779,9 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		if (!p)
 			return nfserr_resource;
 		WRITEMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
-		WRITE32(bcts->dir);
+		*p++ = cpu_to_be32(bcts->dir);
 		/* Sorry, we do not yet support RDMA over 4.1: */
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 	}
 	return nfserr;
 }
@@ -2825,9 +2824,9 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		if (!p)
 			return nfserr_resource;
 		write_cinfo(&p, &create->cr_cinfo);
-		WRITE32(2);
-		WRITE32(create->cr_bmval[0]);
-		WRITE32(create->cr_bmval[1]);
+		*p++ = cpu_to_be32(2);
+		*p++ = cpu_to_be32(create->cr_bmval[0]);
+		*p++ = cpu_to_be32(create->cr_bmval[1]);
 	}
 	return nfserr;
 }
@@ -2860,7 +2859,7 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 		p = xdr_reserve_space(xdr, len + 4);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(len);
+		*p++ = cpu_to_be32(len);
 		WRITEMEM(&fhp->fh_handle.fh_base, len);
 	}
 	return nfserr;
@@ -2892,14 +2891,14 @@ again:
 	}
 	WRITE64(ld->ld_start);
 	WRITE64(ld->ld_length);
-	WRITE32(ld->ld_type);
+	*p++ = cpu_to_be32(ld->ld_type);
 	if (conf->len) {
 		WRITEMEM(&ld->ld_clientid, 8);
-		WRITE32(conf->len);
+		*p++ = cpu_to_be32(conf->len);
 		WRITEMEM(conf->data, conf->len);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
 		WRITE64((u64)0); /* clientid */
-		WRITE32(0); /* length of owner name */
+		*p++ = cpu_to_be32(0); /* length of owner name */
 	}
 	return nfserr_denied;
 }
@@ -2971,11 +2970,11 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	if (!p)
 		return nfserr_resource;
 	write_cinfo(&p, &open->op_cinfo);
-	WRITE32(open->op_rflags);
-	WRITE32(2);
-	WRITE32(open->op_bmval[0]);
-	WRITE32(open->op_bmval[1]);
-	WRITE32(open->op_delegate_type);
+	*p++ = cpu_to_be32(open->op_rflags);
+	*p++ = cpu_to_be32(2);
+	*p++ = cpu_to_be32(open->op_bmval[0]);
+	*p++ = cpu_to_be32(open->op_bmval[1]);
+	*p++ = cpu_to_be32(open->op_delegate_type);
 
 	switch (open->op_delegate_type) {
 	case NFS4_OPEN_DELEGATE_NONE:
@@ -2987,15 +2986,15 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		p = xdr_reserve_space(xdr, 20);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(open->op_recall);
+		*p++ = cpu_to_be32(open->op_recall);
 
 		/*
 		 * TODO: ACE's in delegations
 		 */
-		WRITE32(NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE);
-		WRITE32(0);
-		WRITE32(0);
-		WRITE32(0);   /* XXX: is NULL principal ok? */
+		*p++ = cpu_to_be32(NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);   /* XXX: is NULL principal ok? */
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
 		nfserr = nfsd4_encode_stateid(xdr, &open->op_delegate_stateid);
@@ -3004,22 +3003,22 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		p = xdr_reserve_space(xdr, 32);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 
 		/*
 		 * TODO: space_limit's in delegations
 		 */
-		WRITE32(NFS4_LIMIT_SIZE);
-		WRITE32(~(u32)0);
-		WRITE32(~(u32)0);
+		*p++ = cpu_to_be32(NFS4_LIMIT_SIZE);
+		*p++ = cpu_to_be32(~(u32)0);
+		*p++ = cpu_to_be32(~(u32)0);
 
 		/*
 		 * TODO: ACE's in delegations
 		 */
-		WRITE32(NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE);
-		WRITE32(0);
-		WRITE32(0);
-		WRITE32(0);   /* XXX: is NULL principal ok? */
+		*p++ = cpu_to_be32(NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);   /* XXX: is NULL principal ok? */
 		break;
 	case NFS4_OPEN_DELEGATE_NONE_EXT: /* 4.1 */
 		switch (open->op_why_no_deleg) {
@@ -3028,14 +3027,14 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 			p = xdr_reserve_space(xdr, 8);
 			if (!p)
 				return nfserr_resource;
-			WRITE32(open->op_why_no_deleg);
-			WRITE32(0);	/* deleg signaling not supported yet */
+			*p++ = cpu_to_be32(open->op_why_no_deleg);
+			*p++ = cpu_to_be32(0);	/* deleg signaling not supported yet */
 			break;
 		default:
 			p = xdr_reserve_space(xdr, 4);
 			if (!p)
 				return nfserr_resource;
-			WRITE32(open->op_why_no_deleg);
+			*p++ = cpu_to_be32(open->op_why_no_deleg);
 		}
 		break;
 	default:
@@ -3304,8 +3303,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		return nfserr_resource;
 
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
-	WRITE32(0);
-	WRITE32(0);
+	*p++ = cpu_to_be32(0);
+	*p++ = cpu_to_be32(0);
 	resp->xdr.buf->head[0].iov_len = ((char*)resp->xdr.p)
 				- (char*)resp->xdr.buf->head[0].iov_base;
 
@@ -3453,17 +3452,17 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 			p = xdr_reserve_space(xdr, 4 + 4 + XDR_LEN(info.oid.len) + 4 + 4);
 			if (!p)
 				goto out;
-			WRITE32(RPC_AUTH_GSS);
-			WRITE32(info.oid.len);
+			*p++ = cpu_to_be32(RPC_AUTH_GSS);
+			*p++ = cpu_to_be32(info.oid.len);
 			WRITEMEM(info.oid.data, info.oid.len);
-			WRITE32(info.qop);
-			WRITE32(info.service);
+			*p++ = cpu_to_be32(info.qop);
+			*p++ = cpu_to_be32(info.service);
 		} else if (pf < RPC_AUTH_MAXFLAVOR) {
 			supported++;
 			p = xdr_reserve_space(xdr, 4);
 			if (!p)
 				goto out;
-			WRITE32(pf);
+			*p++ = cpu_to_be32(pf);
 		} else {
 			if (report)
 				pr_warn("NFS: SECINFO: security flavor %u "
@@ -3513,16 +3512,16 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	if (!p)
 		return nfserr_resource;
 	if (nfserr) {
-		WRITE32(3);
-		WRITE32(0);
-		WRITE32(0);
-		WRITE32(0);
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);
 	}
 	else {
-		WRITE32(3);
-		WRITE32(setattr->sa_bmval[0]);
-		WRITE32(setattr->sa_bmval[1]);
-		WRITE32(setattr->sa_bmval[2]);
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(setattr->sa_bmval[0]);
+		*p++ = cpu_to_be32(setattr->sa_bmval[1]);
+		*p++ = cpu_to_be32(setattr->sa_bmval[2]);
 	}
 	return nfserr;
 }
@@ -3544,8 +3543,8 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(0);
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(0);
 	}
 	return nfserr;
 }
@@ -3560,8 +3559,8 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 		p = xdr_reserve_space(xdr, 16);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(write->wr_bytes_written);
-		WRITE32(write->wr_how_written);
+		*p++ = cpu_to_be32(write->wr_bytes_written);
+		*p++ = cpu_to_be32(write->wr_how_written);
 		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
 	}
 	return nfserr;
@@ -3604,10 +3603,10 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		return nfserr_resource;
 
 	WRITEMEM(&exid->clientid, 8);
-	WRITE32(exid->seqid);
-	WRITE32(exid->flags);
+	*p++ = cpu_to_be32(exid->seqid);
+	*p++ = cpu_to_be32(exid->flags);
 
-	WRITE32(exid->spa_how);
+	*p++ = cpu_to_be32(exid->spa_how);
 
 	switch (exid->spa_how) {
 	case SP4_NONE:
@@ -3619,11 +3618,11 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 			return nfserr_resource;
 
 		/* spo_must_enforce bitmap: */
-		WRITE32(2);
-		WRITE32(nfs4_minimal_spo_must_enforce[0]);
-		WRITE32(nfs4_minimal_spo_must_enforce[1]);
+		*p++ = cpu_to_be32(2);
+		*p++ = cpu_to_be32(nfs4_minimal_spo_must_enforce[0]);
+		*p++ = cpu_to_be32(nfs4_minimal_spo_must_enforce[1]);
 		/* empty spo_must_allow bitmap: */
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 
 		break;
 	default:
@@ -3643,15 +3642,15 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	/* The server_owner struct */
 	WRITE64(minor_id);      /* Minor id */
 	/* major id */
-	WRITE32(major_id_sz);
+	*p++ = cpu_to_be32(major_id_sz);
 	WRITEMEM(major_id, major_id_sz);
 
 	/* Server scope */
-	WRITE32(server_scope_sz);
+	*p++ = cpu_to_be32(server_scope_sz);
 	WRITEMEM(server_scope, server_scope_sz);
 
 	/* Implementation id */
-	WRITE32(0);	/* zero length nfs_impl_id4 array */
+	*p++ = cpu_to_be32(0);	/* zero length nfs_impl_id4 array */
 	return 0;
 }
 
@@ -3669,43 +3668,43 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (!p)
 		return nfserr_resource;
 	WRITEMEM(sess->sessionid.data, NFS4_MAX_SESSIONID_LEN);
-	WRITE32(sess->seqid);
-	WRITE32(sess->flags);
+	*p++ = cpu_to_be32(sess->seqid);
+	*p++ = cpu_to_be32(sess->flags);
 
 	p = xdr_reserve_space(xdr, 28);
 	if (!p)
 		return nfserr_resource;
-	WRITE32(0); /* headerpadsz */
-	WRITE32(sess->fore_channel.maxreq_sz);
-	WRITE32(sess->fore_channel.maxresp_sz);
-	WRITE32(sess->fore_channel.maxresp_cached);
-	WRITE32(sess->fore_channel.maxops);
-	WRITE32(sess->fore_channel.maxreqs);
-	WRITE32(sess->fore_channel.nr_rdma_attrs);
+	*p++ = cpu_to_be32(0); /* headerpadsz */
+	*p++ = cpu_to_be32(sess->fore_channel.maxreq_sz);
+	*p++ = cpu_to_be32(sess->fore_channel.maxresp_sz);
+	*p++ = cpu_to_be32(sess->fore_channel.maxresp_cached);
+	*p++ = cpu_to_be32(sess->fore_channel.maxops);
+	*p++ = cpu_to_be32(sess->fore_channel.maxreqs);
+	*p++ = cpu_to_be32(sess->fore_channel.nr_rdma_attrs);
 
 	if (sess->fore_channel.nr_rdma_attrs) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(sess->fore_channel.rdma_attrs);
+		*p++ = cpu_to_be32(sess->fore_channel.rdma_attrs);
 	}
 
 	p = xdr_reserve_space(xdr, 28);
 	if (!p)
 		return nfserr_resource;
-	WRITE32(0); /* headerpadsz */
-	WRITE32(sess->back_channel.maxreq_sz);
-	WRITE32(sess->back_channel.maxresp_sz);
-	WRITE32(sess->back_channel.maxresp_cached);
-	WRITE32(sess->back_channel.maxops);
-	WRITE32(sess->back_channel.maxreqs);
-	WRITE32(sess->back_channel.nr_rdma_attrs);
+	*p++ = cpu_to_be32(0); /* headerpadsz */
+	*p++ = cpu_to_be32(sess->back_channel.maxreq_sz);
+	*p++ = cpu_to_be32(sess->back_channel.maxresp_sz);
+	*p++ = cpu_to_be32(sess->back_channel.maxresp_cached);
+	*p++ = cpu_to_be32(sess->back_channel.maxops);
+	*p++ = cpu_to_be32(sess->back_channel.maxreqs);
+	*p++ = cpu_to_be32(sess->back_channel.nr_rdma_attrs);
 
 	if (sess->back_channel.nr_rdma_attrs) {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			return nfserr_resource;
-		WRITE32(sess->back_channel.rdma_attrs);
+		*p++ = cpu_to_be32(sess->back_channel.rdma_attrs);
 	}
 	return 0;
 }
@@ -3724,12 +3723,12 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (!p)
 		return nfserr_resource;
 	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
-	WRITE32(seq->seqid);
-	WRITE32(seq->slotid);
+	*p++ = cpu_to_be32(seq->seqid);
+	*p++ = cpu_to_be32(seq->slotid);
 	/* Note slotid's are numbered from zero: */
-	WRITE32(seq->maxslots - 1); /* sr_highest_slotid */
-	WRITE32(seq->maxslots - 1); /* sr_target_highest_slotid */
-	WRITE32(seq->status_flags);
+	*p++ = cpu_to_be32(seq->maxslots - 1); /* sr_highest_slotid */
+	*p++ = cpu_to_be32(seq->maxslots - 1); /* sr_target_highest_slotid */
+	*p++ = cpu_to_be32(seq->status_flags);
 
 	resp->cstate.data_offset = xdr->buf->len; /* DRC cache data pointer */
 	return 0;
@@ -3876,7 +3875,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 		WARN_ON_ONCE(1);
 		return;
 	}
-	WRITE32(op->opnum);
+	*p++ = cpu_to_be32(op->opnum);
 	post_err_offset = xdr->buf->len;
 
 	if (op->opnum == OP_ILLEGAL)
@@ -3954,7 +3953,7 @@ nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
 		WARN_ON_ONCE(1);
 		return;
 	}
-	WRITE32(op->opnum);
+	*p++ = cpu_to_be32(op->opnum);
 	*p++ = rp->rp_status;  /* already xdr'ed */
 
 	WRITEMEM(rp->rp_buf, rp->rp_buflen);
-- 
1.8.5.3

