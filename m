Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43521 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826AbaEVTct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 49/52] nfsd4: kill WRITE64
Date: Thu, 22 May 2014 15:32:24 -0400
Message-Id: <1400787148-25941-50-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 52 ++++++++++++++++++++++++----------------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 71071ae..46fc861 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1683,10 +1683,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_TAIL;
 }
 
-#define WRITE64(n)               do {				\
-	*p++ = htonl((u32)((n) >> 32));				\
-	*p++ = htonl((u32)(n));					\
-} while (0)
 #define WRITEMEM(ptr,nbytes)     do { if (nbytes > 0) {		\
 	*(p + XDR_QUADLEN(nbytes) -1) = 0;                      \
 	memcpy(p, ptr, nbytes);					\
@@ -2204,7 +2200,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64(stat.size);
+		p = xdr_encode_hyper(p, stat.size);
 	}
 	if (bmval0 & FATTR4_WORD0_LINK_SUPPORT) {
 		p = xdr_reserve_space(xdr, 4);
@@ -2229,12 +2225,12 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		if (!p)
 			goto out_resource;
 		if (exp->ex_fslocs.migrated) {
-			WRITE64(NFS4_REFERRAL_FSID_MAJOR);
-			WRITE64(NFS4_REFERRAL_FSID_MINOR);
+			p = xdr_encode_hyper(p, NFS4_REFERRAL_FSID_MAJOR);
+			p = xdr_encode_hyper(p, NFS4_REFERRAL_FSID_MINOR);
 		} else switch(fsid_source(fhp)) {
 		case FSIDSOURCE_FSID:
-			WRITE64((u64)exp->ex_fsid);
-			WRITE64((u64)0);
+			p = xdr_encode_hyper(p, (u64)exp->ex_fsid);
+			p = xdr_encode_hyper(p, (u64)0);
 			break;
 		case FSIDSOURCE_DEV:
 			*p++ = cpu_to_be32(0);
@@ -2337,25 +2333,25 @@ out_acl:
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64(stat.ino);
+		p = xdr_encode_hyper(p, stat.ino);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_AVAIL) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64((u64) statfs.f_ffree);
+		p = xdr_encode_hyper(p, (u64) statfs.f_ffree);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_FREE) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64((u64) statfs.f_ffree);
+		p = xdr_encode_hyper(p, (u64) statfs.f_ffree);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_TOTAL) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64((u64) statfs.f_files);
+		p = xdr_encode_hyper(p, (u64) statfs.f_files);
 	}
 	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
 		status = nfsd4_encode_fs_locations(xdr, rqstp, exp);
@@ -2372,7 +2368,7 @@ out_acl:
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64(exp->ex_path.mnt->mnt_sb->s_maxbytes);
+		p = xdr_encode_hyper(p, exp->ex_path.mnt->mnt_sb->s_maxbytes);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXLINK) {
 		p = xdr_reserve_space(xdr, 4);
@@ -2390,13 +2386,13 @@ out_acl:
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64((u64) svc_max_payload(rqstp));
+		p = xdr_encode_hyper(p, (u64) svc_max_payload(rqstp));
 	}
 	if (bmval0 & FATTR4_WORD0_MAXWRITE) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
-		WRITE64((u64) svc_max_payload(rqstp));
+		p = xdr_encode_hyper(p, (u64) svc_max_payload(rqstp));
 	}
 	if (bmval1 & FATTR4_WORD1_MODE) {
 		p = xdr_reserve_space(xdr, 4);
@@ -2438,34 +2434,34 @@ out_acl:
 		if (!p)
 			goto out_resource;
 		dummy64 = (u64)statfs.f_bavail * (u64)statfs.f_bsize;
-		WRITE64(dummy64);
+		p = xdr_encode_hyper(p, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_FREE) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
 		dummy64 = (u64)statfs.f_bfree * (u64)statfs.f_bsize;
-		WRITE64(dummy64);
+		p = xdr_encode_hyper(p, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_TOTAL) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
 		dummy64 = (u64)statfs.f_blocks * (u64)statfs.f_bsize;
-		WRITE64(dummy64);
+		p = xdr_encode_hyper(p, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_SPACE_USED) {
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
 			goto out_resource;
 		dummy64 = (u64)stat.blocks << 9;
-		WRITE64(dummy64);
+		p = xdr_encode_hyper(p, dummy64);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_ACCESS) {
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
-		WRITE64((s64)stat.atime.tv_sec);
+		p = xdr_encode_hyper(p, (s64)stat.atime.tv_sec);
 		*p++ = cpu_to_be32(stat.atime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_DELTA) {
@@ -2480,14 +2476,14 @@ out_acl:
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
-		WRITE64((s64)stat.ctime.tv_sec);
+		p = xdr_encode_hyper(p, (s64)stat.ctime.tv_sec);
 		*p++ = cpu_to_be32(stat.ctime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_MODIFY) {
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
-		WRITE64((s64)stat.mtime.tv_sec);
+		p = xdr_encode_hyper(p, (s64)stat.mtime.tv_sec);
 		*p++ = cpu_to_be32(stat.mtime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
@@ -2501,7 +2497,7 @@ out_acl:
 		if (ignore_crossmnt == 0 &&
 		    dentry == exp->ex_path.mnt->mnt_root)
 			get_parent_attributes(exp, &stat);
-		WRITE64(stat.ino);
+		p = xdr_encode_hyper(p, stat.ino);
 	}
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
 		status = nfsd4_encode_security_label(xdr, rqstp, context,
@@ -2892,15 +2888,15 @@ again:
 		}
 		return nfserr_resource;
 	}
-	WRITE64(ld->ld_start);
-	WRITE64(ld->ld_length);
+	p = xdr_encode_hyper(p, ld->ld_start);
+	p = xdr_encode_hyper(p, ld->ld_length);
 	*p++ = cpu_to_be32(ld->ld_type);
 	if (conf->len) {
 		WRITEMEM(&ld->ld_clientid, 8);
 		*p++ = cpu_to_be32(conf->len);
 		WRITEMEM(conf->data, conf->len);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
-		WRITE64((u64)0); /* clientid */
+		p = xdr_encode_hyper(p, (u64)0); /* clientid */
 		*p++ = cpu_to_be32(0); /* length of owner name */
 	}
 	return nfserr_denied;
@@ -3652,7 +3648,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		return nfserr_resource;
 
 	/* The server_owner struct */
-	WRITE64(minor_id);      /* Minor id */
+	p = xdr_encode_hyper(p, minor_id);      /* Minor id */
 	/* major id */
 	*p++ = cpu_to_be32(major_id_sz);
 	WRITEMEM(major_id, major_id_sz);
-- 
1.9.0

