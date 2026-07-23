Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D09839A071
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 18:20:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784830856; cv=none; b=LlTAaEQZXOBEHXVbnIpGgtLnddbuYB89v6CKIQizFBVYklaTZgUVT9wY6wegKg/qvftxeVCwP15CBc/B7j9lcEq7j4wQiBJguRN4Uz8cZZCVSfRbFPFMBoBN+8SrT2s9Dt8QqlQwL2R8EHMWldmHdXrTNrHYB1EuzlutnA3Xzho=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784830856; c=relaxed/simple;
	bh=3vvTKf8In4PO0EjoOgGaPfQs8EZLuV+ICS1haJlUtG8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hsfG0R9c9OZC1TjI99jmZdsPo7ifmR3TCukU9CALamkaw8cRac2tzyWYrRD5/BL2bcdy7mEOcxZzZ4983QVqXjUmkspDaFgvyqnIXf/n5p6h5SmWjsoGGxkRE+DTnxot/uOWf6iBPj2+alGGpwHuzkk799sEF3jK5tNDX8Ubk5g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2840F1F00A3D;
	Thu, 23 Jul 2026 18:20:46 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] NFSD: Replace nfsd_write()'s "stable" argument with "iocb_flags"
Date: Thu, 23 Jul 2026 14:20:43 -0400
Message-ID: <20260723182043.990391-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260723182043.990391-1-cel@kernel.org>
References: <20260723182043.990391-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The current nfsd_write() API is not NFS version-agnostic, as it
relies on callers to pass an NFSv3 stable_how value to determine
the persistence of the requested WRITE. NFSv2 does not use a
stable-how value on the wire, and NFSv4 has its own stable_how4
(though stable_how and stable_how4 happen to share the same
numeric values).

To remove the dependence on NFSv3-specific XDR values from NFSD's
generic VFS APIs, replace nfsd_write()'s stable argument with an
argument that passes a set of IOCB flags instead of an XDR-defined
value.

The NFSv4 WRITE and COPY paths had been borrowing the NFSv3
stable_how constants for their own on-the-wire stable values,
relying on the numeric coincidence noted above. Convert those
sites to the stable_how4 enumerators so the v4 code expresses
its own protocol's values directly, with no change in behavior.

While here, bound-check the decoded NFSv3 WRITE stable value, as
the NFSv4 WRITE decoder already does, and make the nfsd3_writeargs
stable field unsigned to suit.

The larger benefit is one less NFSv4 dependency on nfs3.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c   | 17 ++++++++++++++++-
 fs/nfsd/nfs3xdr.c    |  2 ++
 fs/nfsd/nfs4proc.c   | 18 ++++++++++++++++--
 fs/nfsd/nfs4xdr.c    |  2 +-
 fs/nfsd/nfsproc.c    |  2 +-
 fs/nfsd/vfs.c        | 30 ++++++++++--------------------
 fs/nfsd/vfs.h        |  6 ++++--
 fs/nfsd/xdr3.h       |  2 +-
 include/linux/nfs4.h |  6 ++++++
 9 files changed, 57 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 4b3075c05b97..19ab0a713d82 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -49,6 +49,20 @@ static bool nfsd3_time_in_range(const struct iattr *iap)
 	return true;
 }
 
+static int nfsd3_iocb_flags(enum nfs3_stable_how how)
+{
+	switch (how) {
+	case NFS_FILE_SYNC:
+		/* persist data and timestamps */
+		return IOCB_DSYNC | IOCB_SYNC;
+	case NFS_DATA_SYNC:
+		/* persist data only */
+		return IOCB_DSYNC;
+	default:
+		return 0;
+	}
+}
+
 static __be32 nfsd3_map_status(__be32 status)
 {
 	switch (status) {
@@ -261,7 +275,8 @@ nfsd3_proc_write(struct svc_rqst *rqstp)
 	resp->committed = argp->stable;
 	resp->status = nfsd_write(rqstp, &resp->fh, argp->offset,
 				  &argp->payload, &cnt,
-				  resp->committed, resp->verf);
+				  nfsd3_iocb_flags(resp->committed),
+				  resp->verf);
 	resp->count = cnt;
 	resp->status = nfsd3_map_status(resp->status);
 	return rpc_success;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 196bcc6edebb..090cea8e545d 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -557,6 +557,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		return false;
 	if (xdr_stream_decode_u32(xdr, &args->stable) < 0)
 		return false;
+	if (args->stable > NFS_FILE_SYNC)
+		return false;
 
 	/* opaque data */
 	if (xdr_stream_decode_u32(xdr, &args->len) < 0)
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a39880208761..a2ff1c8f415b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -72,6 +72,20 @@ MODULE_PARM_DESC(nfsd4_ssc_umount_timeout,
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+static int nfsd4_iocb_flags(enum stable_how4 how)
+{
+	switch (how) {
+	case FILE_SYNC4:
+		/* persist data and timestamps */
+		return IOCB_DSYNC | IOCB_SYNC;
+	case DATA_SYNC4:
+		/* persist data only */
+		return IOCB_DSYNC;
+	default:
+		return 0;
+	}
+}
+
 static u32 nfsd_attrmask[] = {
 	NFSD_WRITEABLE_ATTRS_WORD0,
 	NFSD_WRITEABLE_ATTRS_WORD1,
@@ -1417,7 +1431,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	write->wr_how_written = write->wr_stable_how;
 	status = nfsd_vfs_write(rqstp, &cstate->current_fh, nf,
 				write->wr_offset, &write->wr_payload,
-				&cnt, write->wr_how_written,
+				&cnt, nfsd4_iocb_flags(write->wr_how_written),
 				(__be32 *)write->wr_verifier.data);
 	nfsd_file_put(nf);
 
@@ -2001,7 +2015,7 @@ static void nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
 {
 	copy->cp_res.wr_stable_how =
 		test_bit(NFSD4_COPY_F_COMMITTED, &copy->cp_flags) ?
-			NFS_FILE_SYNC : NFS_UNSTABLE;
+			FILE_SYNC4 : UNSTABLE4;
 	nfsd4_copy_set_sync(copy, sync);
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7ccc7c897b00..a47eb544b99f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1607,7 +1607,7 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, union nfsd4_op_u *u)
 		return nfserr_bad_xdr;
 	if (xdr_stream_decode_u32(argp->xdr, &write->wr_stable_how) < 0)
 		return nfserr_bad_xdr;
-	if (write->wr_stable_how > NFS_FILE_SYNC)
+	if (write->wr_stable_how > FILE_SYNC4)
 		return nfserr_bad_xdr;
 	if (xdr_stream_decode_u32(argp->xdr, &write->wr_buflen) < 0)
 		return nfserr_bad_xdr;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 919acfba356a..48541ef7644f 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -266,7 +266,7 @@ nfsd_proc_write(struct svc_rqst *rqstp)
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->status = nfsd_write(rqstp, &resp->fh, argp->offset,
-				  &argp->payload, &cnt, NFS_DATA_SYNC, NULL);
+				  &argp->payload, &cnt, IOCB_DSYNC, NULL);
 	if (resp->status == nfs_ok)
 		resp->status = fh_getattr(&resp->fh, &resp->stat);
 	else if (resp->status == nfserr_jukebox)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fdfcd95971db..edb08c006a23 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1433,7 +1433,7 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: Byte offset of start
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
- * @stable: An NFS stable_how value
+ * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1445,7 +1445,7 @@ __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	       struct nfsd_file *nf, loff_t offset,
 	       const struct xdr_buf *payload, unsigned long *cnt,
-	       int stable, __be32 *verf)
+	       int iocb_flags, __be32 *verf)
 {
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct file		*file = nf->nf_file;
@@ -1482,21 +1482,11 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	exp = fhp->fh_export;
 
 	if (!EX_ISSYNC(exp))
-		stable = NFS_UNSTABLE;
+		iocb_flags = 0;
 	init_sync_kiocb(&kiocb, file);
 	kiocb.ki_pos = offset;
-	if (likely(!fhp->fh_use_wgather)) {
-		switch (stable) {
-		case NFS_FILE_SYNC:
-			/* persist data and timestamps */
-			kiocb.ki_flags |= IOCB_DSYNC | IOCB_SYNC;
-			break;
-		case NFS_DATA_SYNC:
-			/* persist data only */
-			kiocb.ki_flags |= IOCB_DSYNC;
-			break;
-		}
-	}
+	if (likely(!fhp->fh_use_wgather))
+		kiocb.ki_flags |= iocb_flags;
 
 	nvecs = xdr_buf_to_bvec(rqstp->rq_bvec, rqstp->rq_maxpages, payload);
 	if (nvecs < 0) {
@@ -1537,7 +1527,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out_nfserr;
 	}
 
-	if (stable && fhp->fh_use_wgather) {
+	if (iocb_flags && fhp->fh_use_wgather) {
 		host_err = wait_for_concurrent_writes(file);
 		if (host_err < 0)
 			commit_reset_write_verifier(nn, rqstp, host_err);
@@ -1628,7 +1618,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: Byte offset of start
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
- * @stable: An NFS stable_how value
+ * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1638,8 +1628,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  */
 __be32
 nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
-	   const struct xdr_buf *payload, unsigned long *cnt, int stable,
-	   __be32 *verf)
+	   const struct xdr_buf *payload, unsigned long *cnt,
+	   int iocb_flags, __be32 *verf)
 {
 	struct nfsd_file *nf;
 	__be32 err;
@@ -1651,7 +1641,7 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
 		goto out;
 
 	err = nfsd_vfs_write(rqstp, fhp, nf, offset, payload, cnt,
-			     stable, verf);
+			     iocb_flags, verf);
 	nfsd_file_put(nf);
 out:
 	trace_nfsd_write_done(rqstp, fhp, offset, *cnt);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5554878781f4..aa7679d4c54a 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -135,11 +135,13 @@ __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				u32 *eof);
 __be32		nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, const struct xdr_buf *payload,
-				unsigned long *cnt, int stable, __be32 *verf);
+				unsigned long *cnt, int iocb_flags,
+				__be32 *verf);
 __be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
 				const struct xdr_buf *payload,
-				unsigned long *cnt, int stable, __be32 *verf);
+				unsigned long *cnt, int iocb_flags,
+				__be32 *verf);
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 344203874b4c..cad875d14231 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -39,7 +39,7 @@ struct nfsd3_writeargs {
 	svc_fh			fh;
 	__u64			offset;
 	__u32			count;
-	int			stable;
+	__u32			stable;
 	__u32			len;
 	struct xdr_buf		payload;
 };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 44e5e9fa12e1..9333f2716b4d 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -263,6 +263,12 @@ enum why_no_delegation4 { /* new to v4.1 */
 	WND4_IS_DIR = 8,
 };
 
+enum stable_how4 {
+	UNSTABLE4	= 0,
+	DATA_SYNC4	= 1,
+	FILE_SYNC4	= 2,
+};
+
 enum lock_type4 {
 	NFS4_UNLOCK_LT = 0,
 	NFS4_READ_LT = 1,
-- 
2.54.0

