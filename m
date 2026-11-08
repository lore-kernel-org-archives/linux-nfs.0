Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794160504;
	b=DvyHQSRS4TfTziIF1PqyKCSmQ95I7Y0Vz2OXCqyUrCbMAtFpD6RA3uPwj25XNJMXu6De
	 L51wa9Avz+6GN2vLH20TXXcz1M0+9SPEHGXaP7zhfqYtfKCsxe06p8oPeAPVS+wdguTrW
	 SBryNrK99Y6+2ShSy/335RbyZs3THm2YulUyhAfL1XRAB1tBQU87hB/7eUIHJJ2Bz/9yA
	 7aYm/LCl32pNiFV7De/wm61qRAa3uqKAWjftHOIwRYCTzbjSqJ/b9jsqzz+VqUWdn+e/e
	 MNuTDujjDt+V89/0+D1Tkrlzcg502sIhVU/O9OOM1wlP3Hk4jJPYqVKkt4VU2ExTfAg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794160504;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=3v9LBX+D4kL6Cnom17dz7DIT2Ps+o+JK1OZiS9Zr4fw=;
	b=vsJb8fO5UM4Q0c65sBdqbOPktF0vJIUZfyKBx6V81hcRCqUadWyME+blyPD4m7NHzP+y
	 5cjU1Pc+JL4h8+1h8Mvy4y/5mOEFTuYVVbCE1SdMBo85tz86mZeIHck32m2sgRLdFi5In
	 lWG0XDcil4APsk9v3biLBC1F0eo4u5cDZOARoqMOztbmsuGiutKdrNFaZIG1jqh1KRllZ
	 SkeZBoRrLDubQegp90qhrEI8xK4AMYxR2VZchxaab0YY0ZtXMWMc1hrj/05dFxTxjNWCH
	 cRvNfQILhSkmGYWtZVVtCRcsrPhlBvaV+ZDGvs4orTaVUNANaI8g29nsOS8cjAImzUg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ODONZtBC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79759606A31C
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 17:55:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ODONZtBC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6458E1F0089F;
	Sun,  8 Nov 2026 17:55:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794160503;
	bh=3v9LBX+D4kL6Cnom17dz7DIT2Ps+o+JK1OZiS9Zr4fw=;
	h=From:To:Cc:Subject:Date;
	b=ODONZtBCVJrqVC9TstNPquClsSNu0Z2JkVb64l0d3QF9Qsy1G3BG0RsQoEhZOYo9T
	 Suqz7Mz5L/Pk/fLHDefcAd58nB2ZTu6T2WvHnm+wIIa8JM8ix/h+c5q28AKHjAXY/E
	 tWPsHgGNPnIFosRa3nuDoETepGZ3+xmt7so9ssKvF6E1k3IEtF4VHP9Cu3opBrdRej
	 9zvOUea2yx9HquSG4HSkKo+0LFR85QU9KmNXzc1l+Ocgtghb2x3+a4rwqEIzHb86LH
	 IXYejor6rZ55YdeAQWJbNNANSmJw0xJYC0ydCO0Y7WLb5JCqNAprnqnH+zZ0A1QTSk
	 flKbIrKqWTWwQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFSD: Use direct I/O only for the last operation in a COMPOUND
Date: Sun,  8 Nov 2026 12:55:02 -0500
Message-ID: <20261108175502.75385-1-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A direct read widens the requested byte range to the file system's
alignment and leaves the payload at a nonzero rq_res.page_base. The
xdr_stream encoder does not account for page_base:
xdr_reserve_space_vec() sizes each chunk from page_len alone, and
xdr_get_next_encode_buffer() opens each new page at its first byte.
The stream's position lags the end of the payload by page_base
bytes.

An NFSv4 operation encoded after such a READ overwrites the tail of
the payload, and the transport sends alignment padding in place of
that operation's result. The client sees corrupted file data
followed by an undecodable reply. NFSv2 and NFSv3 are unaffected:
their READ encoders pass page_base explicitly, and nothing is
encoded into the pages after the payload.

Have nfsd4_read() permit a direct read only for the last operation
in its COMPOUND, next to the same decision it already makes for
splice reads, and pass the result to nfsd_iter_read() as a new
argument. The NFSv2 and NFSv3 READ path always permits a direct
read. The decision is NFSv4 reply-encoding policy, so it stays out
of fs/nfsd/vfs.c.

Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
Changes in v2:
- Split from the "NFSD short subjects" series and post on its own
- Move NFSv4-specific logic out of fs/nfsd/vfs.c
- Link to v1: https://lore.kernel.org/r/20261004194029.10714-2-cel@kernel.org

 fs/nfsd/nfs4proc.c |  2 ++
 fs/nfsd/nfs4xdr.c  |  3 ++-
 fs/nfsd/vfs.c      | 15 ++++++++++++---
 fs/nfsd/vfs.h      |  3 ++-
 fs/nfsd/xdr4.h     |  1 +
 5 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a50f9dcb3a31..aaca7d3c3e04 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1143,6 +1143,8 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 		argp->splice_ok = false;
 	}
+	/* The xdr_stream encoder does not account for rq_res.page_base */
+	read->rd_dio_ok = nfsd4_last_compound_op(rqstp);
 
 	/* check stateid */
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c4fd840da4d9..feb50abccff4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5308,7 +5308,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 nfserr;
 
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
-				read->rd_offset, &maxcount, &read->rd_eof);
+				read->rd_offset, &maxcount, &read->rd_eof,
+				read->rd_dio_ok);
 	read->rd_length = maxcount;
 	if (nfserr)
 		return nfserr;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index cb4bf7b235b4..97077f18a1b7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1234,6 +1234,8 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @offset: starting byte offset
  * @count: IN: requested number of bytes; OUT: number of bytes read
  * @eof: OUT: set non-zero if operation reached the end of the file
+ * @dio_ok: false forces a buffered read even when the export selects
+ *	    direct I/O
  *
  * Some filesystems or situations cannot use nfsd_splice_read. This
  * function is the slightly less-performant fallback for those cases.
@@ -1241,12 +1243,17 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * records. On return, @rqstp->rq_next_page points past the last page
  * offered to the read.
  *
+ * A direct read leaves its alignment pad at the front of the pages and
+ * records the pad length in @rqstp->rq_res.page_base. The xdr_stream
+ * encoder does not account for page_base, so pass @dio_ok false when
+ * more XDR items follow the payload in the pages.
+ *
  * Returns nfs_ok on success, otherwise an nfserr stat value is
  * returned.
  */
 __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      struct nfsd_file *nf, loff_t offset, unsigned long *count,
-		      u32 *eof)
+		      u32 *eof, bool dio_ok)
 {
 	struct xdr_buf *buf = &rqstp->rq_res;
 	struct page **page = buf->pages + (buf->page_len >> PAGE_SHIFT);
@@ -1265,7 +1272,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	case NFSD_IO_DIRECT:
 		/* When dio_read_offset_align is zero, dio is not supported */
-		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len)
+		if (dio_ok && nf->nf_dio_read_offset_align &&
+		    !rqstp->rq_res.page_len)
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, page, eof);
 		fallthrough;
@@ -1649,7 +1657,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
 		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
 	else
-		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, eof);
+		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, eof,
+				     true);
 
 	nfsd_file_put(nf);
 	trace_nfsd_read_done(rqstp, fhp, offset, *count);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 1f05c83a3ea6..0b0152ba56b3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -182,7 +182,8 @@ __be32		nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				u32 *eof);
 __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
-				unsigned long *count, u32 *eof);
+				unsigned long *count, u32 *eof,
+				bool dio_ok);
 bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
 __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, unsigned long *count,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ec198993429e..61afbabc1773 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -301,6 +301,7 @@ struct nfsd4_read {
 	u32			rd_length;          /* request */
 	int			rd_vlen;
 	struct nfsd_file	*rd_nf;
+	bool			rd_dio_ok;
 
 	struct svc_rqst		*rd_rqstp;          /* response */
 	struct svc_fh		*rd_fhp;            /* response */
-- 
2.56.0

