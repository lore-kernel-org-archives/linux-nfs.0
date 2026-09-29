Received: from mail-qk2-f40.google.com (mail-qk2-f40.google.com [74.125.230.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A45E52BE2A
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703274; cv=none; b=AZx/Vt6lM9QsaBIofd7OBx3O1GVJAfOeRibTG8oiJw6/rCWvbMvQjWUwpjnD3TGWp9/Zk+xvtI9TWTbQye3gkpTcMVsBrSqSTHdGSw5AvCgRCpTwlbBiODIWLKjClbWNvxrZGKGFfj2NAs5a4qnSvae2YCHD+qOl7qsZh1u9iKc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703274; c=relaxed/simple;
	bh=kuup5VPHiME1hU2flwfwJhVVjj3E02J7zRp+e9UoVj8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PLi76KzycGrUjrhWr2L+yey1I/3UZdC2J7pp+plt5bVvaGwGQz4Uv2IuNzW021XoPkqy2URNkaAqmndqK45yqyaBw4AmbcBE4b5i8EklQi/RRE96YXMst7SgxZkQCBiOpoNMj3H5aAIy22FyGbPz5K2zz1pDOiQqne4Q1bU63dM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=c+RZgYkb; arc=none smtp.client-ip=74.125.230.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="c+RZgYkb"
Received: by mail-qk2-f40.google.com with SMTP id af79cd13be357-93c5f63c54eso270351985a.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703271; x=1791308071; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=m0UbQ1Z3UudNM1koJMk+sAkOqehq5HrrVMQy+nCIZ50=;
        b=c+RZgYkbqV9InlK3p79knMg2GoV2zzUUBl7TofGcald9TGfKIjj+sr0WaYdNZii9DM
         2PU2kdFJF58TuAV9Q/VtgGm6bTl1sTuZm2DtMHFAQ6GLEnXqHQorpyMQYgIbW1HlcgWf
         iDHC7eBsPmk2SzJRcMDjMr+bM5iuJFPrR9hR75aZb+Gmr1GBb+GEkHO4ZphE8yCXtsyO
         Gis6G0kGSqs2Yp6DmUIQ0aOyQpKm6wYePO6EhYFfLWAqPUxQEeIoOVXjE5YBifkz4OLj
         +z/nq7FE4S7rgY2s1E5bJJEj2v/La6hlmwRu8iHiatBClRNUXleZU2BEudFvBOPHnN2D
         WoHg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703271; x=1791308071;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=m0UbQ1Z3UudNM1koJMk+sAkOqehq5HrrVMQy+nCIZ50=;
        b=qO6iCS5uLdfzAb3GU/OdgXfuQ8wgPmWyQFcBk+0eqYeBhGg2hmS3v6YHsfZDy0DLEL
         oseN0mVagQT15Rn0uXSzsVCJ7gsqTJ0WcsbxRvqvnEHf303f6MRHdWFAl9g4UBo7+I3c
         khkQFj4plh4+6pkgWcheBR5nFRYGHkY6yahfv5KCDPICzLGSJ+GP5ccSbJLsl9nczZGm
         AR4/Lnzgef0CMXVG0w6P2vfZ0R1SPOjRzttjANND3T8ZsBEGS7Zshkly04SvwKYpXXr+
         T4DqP57sGSAIhjnnVcFnT2xt7/CL7gyqa47XCmBal9lkanonn43uZTHFDx06wGx0YMOH
         Lmkw==
X-Gm-Message-State: AFuF++k681Av6WrkilnNIljhiNOaNEsl4Vnr2rC/HPChevPNx6J/ZAqw
	suLLbiZxP6vsG0G02pDDacl7OfL263pOQ/wAoMi1chY8+UoTDvnYD8rRfFKahLIJC+k=
X-Gm-Gg: AYBFou29IfGvPmTfxOReBEBftrYh729n2OV831YnVPw+7stMMOFVq5SN9zBqQrMVAPj
	UKrAeMXXCd/aSCN30anTjRP9WwjNBWA0KORf6aSUJEV1DjMe9AiPEDTJaDqKH5Nl4LTDyw7rlD+
	NA9R/sjI1jZtDexUxkXjLKfCdxbxzP+9ND4X3WSsD3BavmxdY1Poh37gRAjZ2m7VilxEzEAf3F1
	4s2nFcowPnIHppagVuDq+Q/ph1obizY10KrtUwSsHDZ04H4lHJpLvkw4f4DYizhd19BQ25/vwpE
	kk0HqePHI9FqzFA8i2h0o69WkqXQPZLTHZyc8i5nmWlsrqh8PYE0oWLANxDYUqhWYjD/judNFI6
	jRX+43w4Jgzj8zc0xCRZq325+sePmBv1Pq4VvKs6eLHdhGw2hA+nagFp5HfMfzTELGqWM+A835x
	dqggVQ7HcaeuxF2bdz7HJQ7FEn8XjVNdhUQWfekQj6SWMIYVH9+dVLV54dmLKX4E7iuGKZWbMpE
	N0EwK2yWDc5Sb/B+McLHi3UIgJgeWn89nM4GWX+C3H1XdJxhHiasQlaK24ljY31i4WiDTC9Ytap
	q5tTtovy
X-Received: by 2002:a05:620a:2787:b0:93c:9d56:a860 with SMTP id af79cd13be357-93c9f87f035mr52719285a.19.1790703270989;
        Tue, 29 Sep 2026 10:34:30 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c9f0ff74bsm25882785a.0.2026.09.29.10.34.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:30 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] NFSD: Enable return of an updated stable_how to NFS clients
Date: Tue, 29 Sep 2026 13:34:18 -0400
Message-ID: <20260929173423.16149-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929173423.16149-1-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
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
UNSTABLE WRITE to be a FILE_SYNC WRITE. This will be because NFSD
will handle some WRITE requests locally with O_DIRECT, which
persists written data immediately. The FILE_SYNC WRITE response
indicates to the client that no follow-up COMMIT is necessary.

This patch prepares for that change by making the @iocb_flags
argument of nfsd_write() and nfsd_vfs_write() bi-directional. A
caller passes in the IOCB_* flags that express the stability its
client asked for; on return the argument holds the flags that were
actually satisfied. Each protocol version maps that result back to
its own on-the-wire value when it encodes the WRITE reply, using the
new nfsd3_stable_how() and nfsd4_stable_how() helpers, so that NFS
stable_how values stay out of NFSD's generic VFS API. No behavior
change is expected.

[snitzer: reworked onto the @iocb_flags argument introduced by
commit 6dcddbb70b08 ("NFSD: Replace nfsd_write()'s "stable" argument with "iocb_flags""),
which was applied after this patch was first posted.
The original passed a "u32 *stable_how" instead. Carrying the value as
IOCB_* flags keeps the NFSv3 XDR value out of the VFS API, and lets a
later patch raise the achieved stability with a plain bitwise OR rather
than an ordering comparison. The Reviewed-by tags from the original
posting are dropped because the argument's type and direction changed.]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/nfs3proc.c | 16 +++++++++++++---
 fs/nfsd/nfs4proc.c | 15 +++++++++++++--
 fs/nfsd/nfsproc.c  |  3 ++-
 fs/nfsd/vfs.c      | 18 +++++++++++-------
 fs/nfsd/vfs.h      |  4 ++--
 fs/nfsd/xdr3.h     |  2 +-
 6 files changed, 42 insertions(+), 16 deletions(-)

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
index bb74eef439388..051d900581609 100644
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
@@ -1432,6 +1441,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd_file *nf = NULL;
 	__be32 status = nfs_ok;
 	unsigned long cnt;
+	int iocb_flags;
 
 	if (write->wr_offset > (u64)OFFSET_MAX ||
 	    write->wr_offset + write->wr_buflen > (u64)OFFSET_MAX)
@@ -1450,11 +1460,12 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
index 09d3608398250..a847b35006781 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -274,6 +274,7 @@ nfsd_proc_write(struct svc_rqst *rqstp)
 	struct nfsd_writeargs *argp = rqstp->rq_argp;
 	struct nfsd_attrstat *resp = rqstp->rq_resp;
 	unsigned long cnt = argp->len;
+	int iocb_flags = IOCB_DSYNC;
 
 	dprintk("nfsd: WRITE    %s %u bytes at %d\n",
 		SVCFH_fmt(&argp->fh),
@@ -281,7 +282,7 @@ nfsd_proc_write(struct svc_rqst *rqstp)
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->status = nfsd_write(rqstp, &resp->fh, argp->offset,
-				  &argp->payload, &cnt, IOCB_DSYNC, NULL);
+				  &argp->payload, &cnt, &iocb_flags, NULL);
 	if (resp->status == nfs_ok)
 		resp->status = fh_getattr(&resp->fh, &resp->stat);
 	else if (resp->status == nfserr_jukebox)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1d2b03cb42963..82eba97656c4e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1444,7 +1444,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: Byte offset of start
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
- * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
+ * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
+ *             stability; OUT: the flags actually satisfied, which may be
+ *             higher than requested
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1456,7 +1458,7 @@ __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	       struct nfsd_file *nf, loff_t offset,
 	       const struct xdr_buf *payload, unsigned long *cnt,
-	       int iocb_flags, __be32 *verf)
+	       int *iocb_flags, __be32 *verf)
 {
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct file		*file = nf->nf_file;
@@ -1493,11 +1495,11 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	exp = fhp->fh_export;
 
 	if (!EX_ISSYNC(exp))
-		iocb_flags = 0;
+		*iocb_flags = 0;
 	init_sync_kiocb(&kiocb, file);
 	kiocb.ki_pos = offset;
 	if (likely(!fhp->fh_use_wgather))
-		kiocb.ki_flags |= iocb_flags;
+		kiocb.ki_flags |= *iocb_flags;
 
 	nvecs = xdr_buf_to_bvec(rqstp->rq_bvec, rqstp->rq_maxpages, payload);
 	if (nvecs < 0) {
@@ -1538,7 +1540,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out_nfserr;
 	}
 
-	if (iocb_flags && fhp->fh_use_wgather) {
+	if (*iocb_flags && fhp->fh_use_wgather) {
 		host_err = wait_for_concurrent_writes(file);
 		if (host_err < 0)
 			nfsd_maybe_reset_write_verifier(nn, rqstp, host_err);
@@ -1629,7 +1631,9 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: Byte offset of start
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
- * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
+ * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
+ *             stability; OUT: the flags actually satisfied, which may be
+ *             higher than requested
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1640,7 +1644,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 __be32
 nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
 	   const struct xdr_buf *payload, unsigned long *cnt,
-	   int iocb_flags, __be32 *verf)
+	   int *iocb_flags, __be32 *verf)
 {
 	struct nfsd_file *nf;
 	__be32 err;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index f0cb184643f2f..6b352ca7f02b7 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -154,12 +154,12 @@ __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
index cad875d142313..a2a980559fb72 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -153,7 +153,7 @@ struct nfsd3_writeres {
 	__be32			status;
 	struct svc_fh		fh;
 	unsigned long		count;
-	int			committed;
+	u32			committed;
 	__be32			verf[2];
 };
 
-- 
2.52.0

