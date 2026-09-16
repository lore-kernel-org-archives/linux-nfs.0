Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A771E592204
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576163; cv=none; b=BWoRBcz72hpitl4dWW8aqRAPlyDkxXoY3fnUwgEPL42RYSIQun7bbBK1wJowFGk5JRGAMf+UeIYZtjGxu9oLjkBGzMhWlNWqWIdRFCcSVRLNnESc51aLInSbCmso1UQZtGd1hrpwEuEMmBIWG0+nCGTS8XuKCA6C/3wQzbJ5stY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576163; c=relaxed/simple;
	bh=Jck+r9NfjaAl46q4Ve9Ox2d7rD5v44YNRUxP0q/jW7U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=U+Sr74MQQQQ30ieO29BN96t7Ja8+dEVuP7dnqNpNT6NKhrqGK/UWTK5lOcMA5WM+mZer70bECejoW9hbarQksS2YfonS7AedxasR9weUF3447rG/ReyNSJDd9eGsJUShR1dMRQS0L9attpn+yOjHbQ0oSXaCm+BT8mRihht8j2I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HY8rO0a2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HY8rO0a2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B8781F000FF;
	Wed, 16 Sep 2026 16:29:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576159;
	bh=53DXHpYo5JgtP4DphuumHBXaNCrwLeKoANX6LXJSog0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HY8rO0a2zzW1ghsEm+mm7J2OYsyksLkdV1dRBB47lWcl0Ws3cr/8Lt6bUFsIHIzsD
	 MBRiQYNc0cEFStlru/Ypfc1c+O0iCjWB5/u8SqqpEH7JLy1BfPbFsrUFqcGgzazCmK
	 Q91qyTDHr6pbkw8+nnp3p9nibbItw2fVUO3x4mxwhKLZT1zT6GyyDmlzsOyz5qJJsS
	 wc5VKWXtoGXRfgQ9Za9IGxW72gFpaOEHqteWMf1LeXrBKh7CRlNzHpLb1TI9bXOHrU
	 DGpYGFSnHAfzTrdJJi1ccTY0jK7OiusjwjUDLV5+e4qWzrLfp0mrm8GtDxiiJTsWNQ
	 3VhrzuFDH7NrQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 14/27] NFSD: Use xdrgen XDR functions for NFSv2 WRITE procedure
Date: Wed, 16 Sep 2026 12:28:45 -0400
Message-ID: <20260916162859.2051-17-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

The NFSv2 WRITE argument decoder could not be generated because
the write payload must be directed into the server's page cache
and decoded in place; a materializing decoder would copy every
write. The "pages" directive now expresses this: it represents
the payload as a struct xdr_buf and decodes it with
svcxdr_decode_opaque_payload(), which subsegments the source
stream in place rather than copying it.

Annotate the data member of writeargs with "pragma pages" and
replace the NFSPROC_WRITE entry in nfsd_procedures2 with the
generated nfs_svc_decode_writeargs and nfs_svc_encode_attrstat. A
wrapper structure bridges the generated writeargs type and the
svc_fh the NFSD VFS layer still uses; the result reuses the
attrstat wrapper from the GETATTR conversion.

The pc_argzero field is now set to zero for the NFSv2 WRITE
procedure. The generated decoder initializes every argument in
the argp->xdrgen field, making the early defensive memset
unnecessary.

This refactor replaces the use of svcxdr_encode_fattr(), so the
reference to the file handle can be released directly by
nfsd_proc_write(). A separate ->pc_release callback is thus no
longer needed. This makes it straightforward to confirm that the
file handle is properly released during every error flow.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |  1 +
 fs/nfsd/nfs2xdr_gen.c              |  6 +--
 fs/nfsd/nfs2xdr_gen.h              |  2 +-
 fs/nfsd/nfsproc.c                  | 76 ++++++++++++++++++------------
 fs/nfsd/nfsxdr.c                   | 26 ----------
 fs/nfsd/xdr.h                      |  8 ----
 include/linux/sunrpc/xdrgen/nfs2.h |  4 +-
 7 files changed, 54 insertions(+), 69 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index b64b939f11f8..b2ed52bd1631 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -156,6 +156,7 @@ struct writeargs {
 	unsigned int	totalcount;
 	opaque		data<NFS_MAXDATA>;
 };
+pragma pages writeargs data;
 
 struct createargs {
 	diropargs	where;
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
index abde6fa8e510..3c2f78c802a6 100644
--- a/fs/nfsd/nfs2xdr_gen.c
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
-// XDR specification modification time: Tue Sep  8 11:25:45 2026
+// XDR specification modification time: Tue Sep  8 11:26:00 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -282,7 +282,7 @@ xdrgen_decode_writeargs(struct xdr_stream *xdr, struct writeargs *ptr)
 		return false;
 	if (!xdrgen_decode_unsigned_int(xdr, &ptr->totalcount))
 		return false;
-	if (!xdrgen_decode_opaque(xdr, &ptr->data, NFS_MAXDATA))
+	if (!svcxdr_decode_opaque_payload(xdr, &ptr->data, NFS_MAXDATA))
 		return false;
 	return true;
 }
@@ -811,7 +811,7 @@ xdrgen_encode_writeargs(struct xdr_stream *xdr, const struct writeargs *value)
 		return false;
 	if (value->data.len > NFS_MAXDATA)
 		return false;
-	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+	if (!svcxdr_encode_opaque_payload(xdr, value->data.len))
 		return false;
 	return true;
 }
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
index e8ff072e32e5..8f7d17e8e483 100644
--- a/fs/nfsd/nfs2xdr_gen.h
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:25:45 2026 */
+/* XDR specification modification time: Tue Sep  8 11:26:00 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DECL_H
 #define _LINUX_XDRGEN_NFS2_DECL_H
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 71b792c8d78f..4d09da326070 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -70,6 +70,13 @@ struct readargs_wrapper {
 
 static_assert(offsetof(struct readargs_wrapper, xdrgen) == 0);
 
+struct writeargs_wrapper {
+	struct writeargs	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct writeargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -581,29 +588,41 @@ static __be32 nfsd_proc_writecache(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Write data to a file
- * N.B. After this call resp->fh needs an fh_put
+/**
+ * nfsd_proc_write - WRITE: Write to file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   attrstat NFSPROC_WRITE(writeargs) = 8;
  */
-static __be32
-nfsd_proc_write(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_write(struct svc_rqst *rqstp)
 {
-	struct nfsd_writeargs *argp = rqstp->rq_argp;
-	struct nfsd_attrstat *resp = rqstp->rq_resp;
-	unsigned long cnt = argp->len;
+	struct writeargs_wrapper *argp = rqstp->rq_argp;
+	struct attrstat_wrapper *resp = rqstp->rq_resp;
+	struct kstat *statp = &resp->stat;
+	unsigned long count = argp->xdrgen.data.len;
+	struct svc_fh *fhp = &argp->fh;
 
-	dprintk("nfsd: WRITE    %s %u bytes at %d\n",
-		SVCFH_fmt(&argp->fh),
-		argp->len, argp->offset);
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen.file);
 
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = nfsd_write(rqstp, &resp->fh, argp->offset,
-				  &argp->payload, &cnt, IOCB_DSYNC, NULL);
-	if (resp->status == nfs_ok)
-		resp->status = fh_getattr(&resp->fh, &resp->stat);
-	else if (resp->status == nfserr_jukebox)
+	resp->xdrgen.status = nfsd_write(rqstp, fhp, argp->xdrgen.offset,
+					 &argp->xdrgen.data, &count,
+					 IOCB_DSYNC, NULL);
+	if (resp->xdrgen.status == nfs_ok) {
+		resp->xdrgen.status = fh_getattr(fhp, statp);
+		if (resp->xdrgen.status == nfs_ok)
+			nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.attributes,
+					   statp, fhp);
+	}
+	if (resp->xdrgen.status == nfserr_jukebox)
 		set_bit(RQ_DROPME, &rqstp->rq_flags);
-	resp->status = nfsd_map_io_status(resp->status);
+	if (resp->xdrgen.status != nfs_ok)
+		resp->xdrgen.status = nfsd_map_io_status(resp->xdrgen.status);
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1076,16 +1095,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "WRITECACHE",
 	},
 	[NFSPROC_WRITE] = {
-		.pc_func = nfsd_proc_write,
-		.pc_decode = nfssvc_decode_writeargs,
-		.pc_encode = nfssvc_encode_attrstatres,
-		.pc_release = nfssvc_release_attrstat,
-		.pc_argsize = sizeof(struct nfsd_writeargs),
-		.pc_argzero = sizeof(struct nfsd_writeargs),
-		.pc_ressize = sizeof(struct nfsd_attrstat),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+AT,
-		.pc_name = "WRITE",
+		.pc_func	= nfsd_proc_write,
+		.pc_decode	= nfs_svc_decode_writeargs,
+		.pc_encode	= nfs_svc_encode_attrstat,
+		.pc_argsize	= sizeof(struct writeargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct attrstat_wrapper),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS2_attrstat_sz,
+		.pc_name	= "WRITE",
 	},
 	[NFSPROC_CREATE] = {
 		.pc_func = nfsd_proc_create,
@@ -1197,7 +1215,7 @@ union nfsd_xdrstore {
 	struct sattrargs_wrapper	sattrargs;
 	struct diropargs_wrapper	diropargs;
 	struct readargs_wrapper		readargs;
-	struct nfsd_writeargs	write;
+	struct writeargs_wrapper	writeargs;
 	struct nfsd_createargs	create;
 	struct nfsd_renameargs	rename;
 	struct nfsd_linkargs	link;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 1b79f9534af6..33b3fb73053e 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -311,32 +311,6 @@ nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfssvc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_writeargs *args = rqstp->rq_argp;
-	u32 beginoffset, totalcount;
-
-	if (!svcxdr_decode_fhandle(xdr, &args->fh))
-		return false;
-	/* beginoffset is ignored */
-	if (xdr_stream_decode_u32(xdr, &beginoffset) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->offset) < 0)
-		return false;
-	/* totalcount is ignored */
-	if (xdr_stream_decode_u32(xdr, &totalcount) < 0)
-		return false;
-
-	/* opaque data */
-	if (xdr_stream_decode_u32(xdr, &args->len) < 0)
-		return false;
-	if (args->len > NFS_MAXDATA)
-		return false;
-
-	return xdr_stream_subsegment(xdr, &args->payload, args->len);
-}
-
 bool
 nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 9d9150760a0b..75f40bef6614 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -14,13 +14,6 @@ struct nfsd_diropargs {
 	unsigned int		len;
 };
 
-struct nfsd_writeargs {
-	svc_fh			fh;
-	__u32			offset;
-	__u32			len;
-	struct xdr_buf		payload;
-};
-
 struct nfsd_createargs {
 	struct svc_fh		fh;
 	char *			name;
@@ -96,7 +89,6 @@ struct nfsd_statfsres {
 
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_linkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
index eeb8b9ded65f..7a469ac4b772 100644
--- a/include/linux/sunrpc/xdrgen/nfs2.h
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:25:45 2026 */
+/* XDR specification modification time: Tue Sep  8 11:26:00 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DEF_H
 #define _LINUX_XDRGEN_NFS2_DEF_H
@@ -152,7 +152,7 @@ struct writeargs {
 	u32 beginoffset;
 	u32 offset;
 	u32 totalcount;
-	opaque data;
+	struct xdr_buf data;
 };
 
 struct createargs {
-- 
2.55.0

