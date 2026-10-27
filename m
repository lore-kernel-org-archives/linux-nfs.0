Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119539;
	b=BJQ0T2cu5tpboaDzBGjkniUHlN+2dj5c++YuleesJyHV8ux4lZL41WTeBkN1k6yvpbR9
	 3C67HMWf8NdvwlcgMrAkThph7i7J/zVI8sRoEsIhqHwoXI6dvhZ5KJfa5pQ2cPCLjZ5TS
	 jQvybIgtB4as558ZCqu1Brmg5AQc/GumOPxY1mrM7gp1ywHL7UwKuaODom0LmgB+vd5P3
	 srJEH+1DT8URGIxTi/c/0zqVJuz/cPMwWtW2xnyS3Y8gLeithbXD5Lc5LJub4A4UTQgPL
	 aCtNQN9xMu3ihDxj1DkqTVdlRUzzRb4F/sQ+XOmPpL1cUi9nFI7S7oEO+LcmpzXlejA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119539;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=EDF7Sfz8pAZF8wfG0fhK2KgtiFpQj/vLigaRZX1+1eQ=;
	b=jwUlniOVUv9J0ySQIi4ouhAmGbECyAU9he6dv3mpC6e+XSzJL//MIpx+NNwN0qycyZD+
	 +UFjnnGGwfUr4tpQ/cVbgKFUyEPYakd44/mXfxDhJeG33BeySarSoAdFw0Sij4Vhziojz
	 z6VYgez6JYxV1J0gP0MRTy9E+C4apbZ8WPZ5ggijzBKwGYc7R6g5MyAmEfwCIUbZxZGRb
	 FANyAI39YzT+GmEcZwSJ7pWFHKkgDfEWMkjjuxoXJIAwgQOHMblv+S6iVfGCjxlCE6zdK
	 qemv8HDusR74P9zsqxcjqQxyUzfe2shBNwToMlCCg9QgjcQu4WK0iwuOCkIDgMBHGZg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cGB5jJ+E;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB647606A32E;
	Tue, 27 Oct 2026 16:45:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cGB5jJ+E
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E38F1F01828;
	Tue, 27 Oct 2026 16:45:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119538;
	bh=EDF7Sfz8pAZF8wfG0fhK2KgtiFpQj/vLigaRZX1+1eQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cGB5jJ+ETG7b+/Hhhnj0s/MRou3L2n42fRM3AkqSnnmMcn+0+7w7cggw4N7cmTvRI
	 VJMPz8+hYlwuXU47qIrqz6MSim5r3Ut/HSnKTxezpIPXG8P+ZkqyMTDjD3PkA2PLjf
	 kGDUAC+0bBq/mmJ5dAO3kSdwazNdMN3QQpz6NNKwgLMWefQzGzzPt9gb6UVE3Fns8k
	 oB91mFTFmiJtwhhSPkzeNQDAGMMdB5IFf2gsQn9/Sp6xHok0gGbFaQXOQPbN5p4Gyw
	 Xj+bSpepqAxKpkvVKRwx+ChzEfVqmwRXTftnlxmQCWcu6Ih+eMWtctjBFMbhMVG1+N
	 creQgZI1Gk2/g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:45:25 -0400
Subject: [PATCH 2/6] NFSD: Apply per-export I/O modes to READ and WRITE
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261027-export-iomode-v1-2-262ed932a036@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
In-Reply-To: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, Mike Snitzer <snitzer@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Jakub Kicinski <kuba@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5517; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=W06iSDfE36gkgtT9sFvbZeiD5kvhlk+d8CDqjJ4QEWg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NUrfKN/ULYCLcA8G+jOeX8EsDY3kz29+Mkhn
 0ran40TqwWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDVKwAKCRAADmhBGVaC
 FUrXD/4kDfw+B5zwec9+tHKMjFPlv5faRsPuf40kYYWOa7OD3STGlRW9/QTIDfBKA/oGqAt0tI/
 LpefPLbpoKp3gIbP/seuk7cx1q1jMgu+1JbyugTNu1r+44VJgGO2f2JGo4SUY6hBpqJ4T/zM4CR
 pip8iU6/6Rd4BWkdd8aGSPR/7T0Vu6Uhd6aFVrzcYQb4TOo4ZUgyXbo25Vb52gVG3XyJZNDHBeJ
 9/Kr8Z4D4ZqDrV5wn/t0+adayFGoZ5ue1VcrdJIujaokexzk8sdYoqxc0DUuQi7rq+WSSXSqxQC
 A0IsJLgx6qfnIjMSpvrq1x6nwFB/BprPQ1v1C5oFo+Nk+s3oJ8hNmsiH+0EA3pvZwUNerWnaZm8
 nPb3r47vjMpy9OTNUanOZowQr7gOqX9BEB9iqm3Kj4zMNXYCihHtZc6rbzJSswosUuiuX16eL7s
 dmMFC1Nlzp6LRFWCRVG9194HjDarAGIgHCqqRcLx6DfWBhsjlTPWBa1R+/V1YAZb6XIdIQVHHPb
 vv2/6gJbUvEom7EM/E8qCCfMS0J2F4gAt8CLGicW83XnHW7wUv4LVoGH9+sIfRvOtBvj/2TXOJC
 Bh2kzbyayq2pv35GDQLmJQdT2K5HV0tSTg1qkt5VcrcHtCGfoe9m3UcsVr4xExK+TwkfBVA85GY
 65Sn8RA3im0X34A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Resolve each export's effective I/O mode (explicit setting, else the
global io_cache_read/write knob) in nfsd_iter_read and nfsd_vfs_write,
and skip splice for reads on exports whose effective read mode is not
buffered. Update the debugfs knob comments to match.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/debugfs.c |  6 ++++--
 fs/nfsd/nfs4xdr.c |  6 ++++--
 fs/nfsd/vfs.c     | 39 ++++++++++++++++++++++++++++++++++++---
 fs/nfsd/vfs.h     |  2 ++
 4 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 4af1e6b8b212..a10159db3b60 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -47,7 +47,8 @@ DEFINE_DEBUGFS_ATTRIBUTE(nfsd_dsr_fops, nfsd_dsr_get, nfsd_dsr_set, "%llu\n");
  *   %2: NFS READ will use direct IO
  *
  * This setting takes immediate effect for all NFS versions,
- * all exports, and in all NFSD net namespaces.
+ * all exports without an explicit riomode= setting, and in all
+ * NFSD net namespaces.
  */
 
 static int nfsd_io_cache_read_get(void *data, u64 *val)
@@ -92,7 +93,8 @@ DEFINE_DEBUGFS_ATTRIBUTE(nfsd_io_cache_read_fops, nfsd_io_cache_read_get,
  *   %1: NFS WRITE will use dontcache (buffered IO w/ dropbehind)
  *
  * This setting takes immediate effect for all NFS versions,
- * all exports, and in all NFSD net namespaces.
+ * all exports without an explicit wiomode= setting, and in all
+ * NFSD net namespaces.
  */
 
 static int nfsd_io_cache_write_get(void *data, u64 *val)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4d983444604a..9215feeeb0ba 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5366,7 +5366,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, read->rd_length,
 			 (xdr->buf->buflen - xdr->buf->len));
 
-	if (file->f_op->splice_read && splice_ok)
+	if (file->f_op->splice_read && splice_ok &&
+	    nfsd_read_iomode(read->rd_fhp->fh_export) == NFSD_IO_BUFFERED)
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, maxcount);
@@ -6264,7 +6265,8 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp,
 	maxcount = min_t(unsigned long, read->rd_length,
 			 (xdr->buf->buflen - xdr->buf->len));
 
-	if (file->f_op->splice_read && splice_ok)
+	if (file->f_op->splice_read && splice_ok &&
+	    nfsd_read_iomode(read->rd_fhp->fh_export) == NFSD_IO_BUFFERED)
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, maxcount);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7f9ec6c4af6d..15613b6df290 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1266,6 +1266,38 @@ static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return true;
 }
 
+/**
+ * nfsd_read_iomode - effective NFS READ I/O mode for an export
+ * @exp: export being accessed
+ *
+ * An export without an explicit riomode= setting follows the global
+ * nfsd_io_cache_read knob.
+ *
+ * Returns one of NFSD_IO_BUFFERED, NFSD_IO_DONTCACHE, or NFSD_IO_DIRECT.
+ */
+int nfsd_read_iomode(struct svc_export *exp)
+{
+	if (exp->ex_riomode == NFSD_IO_DEFAULT)
+		return nfsd_io_cache_read;
+	return exp->ex_riomode;
+}
+
+/**
+ * nfsd_write_iomode - effective NFS WRITE I/O mode for an export
+ * @exp: export being accessed
+ *
+ * An export without an explicit wiomode= setting follows the global
+ * nfsd_io_cache_write knob.
+ *
+ * Returns one of NFSD_IO_BUFFERED, NFSD_IO_DONTCACHE, or NFSD_IO_DIRECT.
+ */
+int nfsd_write_iomode(struct svc_export *exp)
+{
+	if (exp->ex_wiomode == NFSD_IO_DEFAULT)
+		return nfsd_io_cache_write;
+	return exp->ex_wiomode;
+}
+
 /**
  * nfsd_iter_read - Perform a VFS read using an iterator
  * @rqstp: RPC transaction context
@@ -1300,7 +1332,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	init_sync_kiocb(&kiocb, file);
 
-	switch (nfsd_io_cache_read) {
+	switch (nfsd_read_iomode(fhp->fh_export)) {
 	case NFSD_IO_BUFFERED:
 		break;
 	case NFSD_IO_DIRECT:
@@ -1746,7 +1778,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (verf)
 		nfsd_copy_write_verifier(verf, nn);
 
-	switch (nfsd_io_cache_write) {
+	switch (nfsd_write_iomode(exp)) {
 	case NFSD_IO_DIRECT:
 		host_err = nfsd_direct_write(rqstp, fhp, nf, nvecs,
 					     cnt, &kiocb);
@@ -1853,7 +1885,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		return err;
 
 	file = nf->nf_file;
-	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
+	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp) &&
+	    nfsd_read_iomode(fhp->fh_export) == NFSD_IO_BUFFERED)
 		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
 	else
 		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, eof);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 1f05c83a3ea6..e95611b79397 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -184,6 +184,8 @@ __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
 				unsigned long *count, u32 *eof);
 bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
+int		nfsd_read_iomode(struct svc_export *exp);
+int		nfsd_write_iomode(struct svc_export *exp);
 __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, unsigned long *count,
 				u32 *eof);

-- 
2.56.0

