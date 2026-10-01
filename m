Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 483903B8D41
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830514; cv=none; b=bFa1HpGo5TZEeqr7Z9g/EGPs6fGQ0eyDuODQOqGLscDEdlNmM2bUg7jhmkDAgT0wsY+vg2PL2yGB+u7IucZ/pKRzYp04x0Bdx4gqA6oFb6u0WIZcL/jb61oH+Tkim/ljXjXbzqx9c+HARoLwa0uhBW7CwTO5jQXCSiW34Fulugo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830514; c=relaxed/simple;
	bh=1zO0/c3gzlgs45wmSzbHy63Yz57eiaOQP5MgwobtpdQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ryunx5aqdGoNR8puaLoD2hMFzLPxSkSAy1i9nO37PhBy8laWHGQHXQafZkjxqXj6+ognEITvOg2a7xB9v1SLCK1MHFW2GHDjEmEpSd9RUWQNQ1JL1iXxRgthTTOOhNCxARxeDq2F2gs9UanG/eyM7zeIJcEpFcfLDuELxuf75jc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l/gRwxth; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l/gRwxth"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 010EA1F000FF;
	Thu,  1 Oct 2026 04:55:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830513;
	bh=MDv99G0B68I3OgBK9MXgNWJlqwRbDpL555iJyLN+r6c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=l/gRwxthu0Ugi01/Q+o7OA6AKJVu4Sot7GD0DiAQNRT27GrSXCZYEefMfhDKud/mg
	 44B64/F5hgL+Ho69IJfMjHE5UmCq19hwHL7jt+NNvEFZYsKBAAUiM+2Q4LTlHxX4Fs
	 PX/zMs0jbNca0wNPC4lR9W1uJFTzoBHNjbh9IMDyZeYbess9Z8Yx21qEx7fb1Yyh03
	 LFwVdDPRupa8+I7eyB0ZLg9HTTFNmT0vcC4ws78sDD4/MnzLk+5NkUvbcMFVsmwaas
	 o1wY14+hIvBSH1mZbg1rBLKg+oUyW2duWacFIvafzXQnNhizdhELvT3HXpy8HRkHqc
	 /zXx53cHkTiiA==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 8/9] NFSD: Enable return of an updated stable_how to NFS clients
Date: Thu,  1 Oct 2026 00:55:01 -0400
Message-ID: <20261001045502.48381-9-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261001045502.48381-1-snitzer@kernel.org>
References: <20261001045502.48381-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

NFSv3 and newer protocols enable clients to perform a two-phase
WRITE. A client requests an UNSTABLE WRITE, which sends dirty data
to the NFS server, but does not persist it. The server replies that
it performed the UNSTABLE WRITE, and the client is then obligated to
follow up with a COMMIT request before it can remove the dirty data
from its own page cache. The COMMIT reply is the client's guarantee
that the written data has been persisted on the server.

The purpose of this protocol design is to enable clients to send
a large amount of data via multiple WRITE requests to a server, and
then wait for persistence just once. The server is able to start
persisting the data as soon as it gets it, to shorten the length of
time the client has to wait for the final COMMIT to complete.

It's also possible for the server to respond to an UNSTABLE WRITE
request in a way that indicates that the data was persisted anyway.
In that case, the client can skip the COMMIT and remove the dirty
data from its memory immediately. NetApp filers, for example, do
this because they have a battery-backed cache and can guarantee that
written data is persisted quickly and immediately.

NFSD has never implemented this kind of promotion. UNSTABLE WRITE
requests are unconditionally treated as UNSTABLE. However, in a
subsequent patch, nfsd_vfs_write() will be able to promote an
UNSTABLE WRITE to be a FILE_SYNC WRITE, when NFSD is configured to
persist each WRITE it services with O_DIRECT before replying. The
FILE_SYNC WRITE response indicates to the client that no follow-up
COMMIT is necessary.

This patch prepares for that change by making the @iocb_flags
argument of nfsd_write() and nfsd_vfs_write() bi-directional. A
caller passes in the IOCB_* flags that express the stability its
client asked for; on return the argument holds the stability to
report. NFSv3 and NFSv4 convert the result back to their on-the-wire
stable_how with the new nfsd3_stable_how() and nfsd4_stable_how()
helpers. This keeps NFS stable_how values out of NFSD's VFS API.
NFSv2 has no stable_how in its reply and ignores the result.

No behavior change is expected. In particular, a WRITE to an export
with the async option is still issued without IOCB_DSYNC and still
reported at the stability the client requested.

[snitzer: reworked onto the @iocb_flags argument introduced by
commit 6dcddbb70b08 ("NFSD: Replace nfsd_write()'s "stable" argument with "iocb_flags""),
which was applied after this patch was first posted. The original
passed a "u32 *stable_how" instead. Carrying the value as IOCB_* flags
keeps the NFSv3 XDR value out of the VFS API, and lets a later commit
raise the reported stability with a plain bitwise OR. The async
export option clears the flags on a local copy only, so the reply to
a FILE_SYNC or DATA_SYNC WRITE is never lowered (RFC 1813 section
3.3.7, RFC 8881 section 18.32.3). O_DIRECT alone does not persist
data, so the description no longer says it does. The Reviewed-by
tags from the original posting are dropped because the argument's
type and direction changed.]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/nfs3proc.c | 16 +++++++++++++---
 fs/nfsd/nfs4proc.c | 15 +++++++++++++--
 fs/nfsd/nfsproc.c  |  3 ++-
 fs/nfsd/vfs.c      | 17 ++++++++++-------
 fs/nfsd/vfs.h      |  4 ++--
 fs/nfsd/xdr3.h     |  2 +-
 6 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 60cd01b6a37d2..f06573759ad6f 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -102,6 +102,15 @@ static int nfsd3_iocb_flags(enum nfs3_stable_how how)
 	}
 }
 
+static enum nfs3_stable_how nfsd3_stable_how(int iocb_flags)
+{
+	if (iocb_flags & IOCB_SYNC)
+		return NFS_FILE_SYNC;
+	if (iocb_flags & IOCB_DSYNC)
+		return NFS_DATA_SYNC;
+	return NFS_UNSTABLE;
+}
+
 static __be32 nfsd3_map_status(__be32 status)
 {
 	switch (status) {
@@ -299,6 +308,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp)
 	struct nfsd3_writeargs *argp = rqstp->rq_argp;
 	struct nfsd3_writeres *resp = rqstp->rq_resp;
 	unsigned long cnt = argp->len;
+	int iocb_flags;
 
 	dprintk("nfsd: WRITE(3)    %s %d bytes at %Lu%s\n",
 				SVCFH_fmt(&argp->fh),
@@ -312,11 +322,11 @@ nfsd3_proc_write(struct svc_rqst *rqstp)
 		return rpc_success;
 
 	fh_copy(&resp->fh, &argp->fh);
-	resp->committed = argp->stable;
+	iocb_flags = nfsd3_iocb_flags(argp->stable);
 	resp->status = nfsd_write(rqstp, &resp->fh, argp->offset,
-				  &argp->payload, &cnt,
-				  nfsd3_iocb_flags(resp->committed),
+				  &argp->payload, &cnt, &iocb_flags,
 				  resp->verf);
+	resp->committed = nfsd3_stable_how(iocb_flags);
 	resp->count = cnt;
 	resp->status = nfsd3_map_status(resp->status);
 	return rpc_success;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7df60abfbff14..505c7dadf49b8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -109,6 +109,15 @@ static const struct nfsd_access_maps nfsd4_access_maps = {
 	.other		= nfsd4_otheraccess,
 };
 
+static enum stable_how4 nfsd4_stable_how(int iocb_flags)
+{
+	if (iocb_flags & IOCB_SYNC)
+		return FILE_SYNC4;
+	if (iocb_flags & IOCB_DSYNC)
+		return DATA_SYNC4;
+	return UNSTABLE4;
+}
+
 static int nfsd4_iocb_flags(enum stable_how4 how)
 {
 	switch (how) {
@@ -1442,6 +1451,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd_file *nf = NULL;
 	__be32 status = nfs_ok;
 	unsigned long cnt;
+	int iocb_flags;
 
 	if (write->wr_offset > (u64)OFFSET_MAX ||
 	    write->wr_offset + write->wr_buflen > (u64)OFFSET_MAX)
@@ -1460,11 +1470,12 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		nfs4_put_stid(stid);
 	}
 
-	write->wr_how_written = write->wr_stable_how;
+	iocb_flags = nfsd4_iocb_flags(write->wr_stable_how);
 	status = nfsd_vfs_write(rqstp, &cstate->current_fh, nf,
 				write->wr_offset, &write->wr_payload,
-				&cnt, nfsd4_iocb_flags(write->wr_how_written),
+				&cnt, &iocb_flags,
 				(__be32 *)write->wr_verifier.data);
+	write->wr_how_written = nfsd4_stable_how(iocb_flags);
 	nfsd_file_put(nf);
 
 	write->wr_bytes_written = cnt;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 1f74008bc06ad..6565d301c7e31 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -644,12 +644,13 @@ static __be32 nfsd_proc_write(struct svc_rqst *rqstp)
 	struct kstat *statp = &resp->stat;
 	unsigned long count = argp->xdrgen.data.len;
 	struct svc_fh *fhp = &argp->fh;
+	int iocb_flags = IOCB_DSYNC;
 
 	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen.file);
 
 	resp->xdrgen.status = nfsd_write(rqstp, fhp, argp->xdrgen.offset,
 					 &argp->xdrgen.data, &count,
-					 IOCB_DSYNC, NULL);
+					 &iocb_flags, NULL);
 	if (resp->xdrgen.status == nfs_ok) {
 		resp->xdrgen.status = fh_getattr(fhp, statp);
 		if (resp->xdrgen.status == nfs_ok)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ec52c67c4380d..a8e15193b2160 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1537,7 +1537,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: Byte offset of start
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
- * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
+ * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
+ *             stability; OUT: the stability to report to the client
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1549,11 +1550,12 @@ __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	       struct nfsd_file *nf, loff_t offset,
 	       const struct xdr_buf *payload, unsigned long *cnt,
-	       int iocb_flags, __be32 *verf)
+	       int *iocb_flags, __be32 *verf)
 {
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct file		*file = nf->nf_file;
 	struct super_block	*sb = file_inode(file)->i_sb;
+	int			stable_flags = *iocb_flags;
 	struct kiocb		kiocb;
 	struct svc_export	*exp;
 	struct iov_iter		iter;
@@ -1586,11 +1588,11 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	exp = fhp->fh_export;
 
 	if (!EX_ISSYNC(exp))
-		iocb_flags = 0;
+		stable_flags = 0;
 	init_sync_kiocb(&kiocb, file);
 	kiocb.ki_pos = offset;
 	if (likely(!fhp->fh_use_wgather))
-		kiocb.ki_flags |= iocb_flags;
+		kiocb.ki_flags |= stable_flags;
 
 	nvecs = xdr_buf_to_bvec(rqstp->rq_bvec, rqstp->rq_maxpages, payload);
 	if (nvecs < 0) {
@@ -1631,7 +1633,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out_nfserr;
 	}
 
-	if (iocb_flags && fhp->fh_use_wgather) {
+	if (stable_flags && fhp->fh_use_wgather) {
 		host_err = wait_for_concurrent_writes(file);
 		if (host_err < 0)
 			nfsd_maybe_reset_write_verifier(nn, rqstp, host_err);
@@ -1722,7 +1724,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: Byte offset of start
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
- * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
+ * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
+ *             stability; OUT: the stability to report to the client
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1733,7 +1736,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 __be32
 nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
 	   const struct xdr_buf *payload, unsigned long *cnt,
-	   int iocb_flags, __be32 *verf)
+	   int *iocb_flags, __be32 *verf)
 {
 	struct nfsd_file *nf;
 	__be32 err;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4b352a48a8af2..c3b48c45e10a7 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -189,12 +189,12 @@ __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				u32 *eof);
 __be32		nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, const struct xdr_buf *payload,
-				unsigned long *cnt, int iocb_flags,
+				unsigned long *cnt, int *iocb_flags,
 				__be32 *verf);
 __be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
 				const struct xdr_buf *payload,
-				unsigned long *cnt, int iocb_flags,
+				unsigned long *cnt, int *iocb_flags,
 				__be32 *verf);
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 22272695e451b..eb9d79e57fc9a 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -154,7 +154,7 @@ struct nfsd3_writeres {
 	__be32			status;
 	struct svc_fh		fh;
 	unsigned long		count;
-	int			committed;
+	u32			committed;
 	__be32			verf[2];
 };
 
-- 
2.52.0

