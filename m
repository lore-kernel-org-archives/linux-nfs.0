Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254020;
	b=qmq0fBs386kkAd60qWbzqiagDRPSPeIiInvUHYoix1Kz0Ka2TE48fgueMiKFxtGlIdHB
	 k7wFozUsYgP+2q1hZW5n4wwAXtqoNsSL+pPLl/aVCZevClMw7ltxhborLR9J77+cS3/fD
	 +6lHf73UHdj38AYUr1iBksMnmQqRx+Or+RB5fUowDARgeDhRcudZV4r3A1jA+0CISHjro
	 G5yi8FwiWhIOnw1vIZPkH1nxFGlN/Em8E0V9CXjzjwcZnyeL8gEVfibnNm75Ens/Tmp76
	 GF6GbwmgBxp+s0UjlMzoQz1d+eCxRzyzEIJp307UhktN1DAH2MJ8lJgw6GwtQITMd+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254020;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bZTHelL7xtOFMP0udinX1iX3EPALSPE7b6YLeS3Yz7g=;
	b=pN8kCc9ayRiBAYwALDOrf6ZsHBf9phAmVNprHPRsfZwVsLrULKlkxIQt6MBdhLDzs/UA
	 NsC3weESQ6tOuFuu3wQENBZIOe02XFJ2EN1mUZfZNtxaim/krkfp82P9FtZI3Xba24K9J
	 uKsZRtoWzxBupRaciVe8yEwlRG9QWpfaWEkrQwj0nRZAtKmTwhkiV6m8AewMtrXeKtGXT
	 zHbxd5MnfFeliozZ0f14A472DyzFkFBgCbz5bRqVaRSxTTGg3Uz6BCpTbGaTuDCFc2CHp
	 WvIfwH31WYNRmsPFn4TqXBcLECGbwWjagpr/grN9qZNXqBHMZ3RkbXmHbNPbE6bIOdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EH9dxfON;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C39CD60A2617
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EH9dxfON
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C83EA1F00926;
	Mon,  9 Nov 2026 19:53:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254019;
	bh=bZTHelL7xtOFMP0udinX1iX3EPALSPE7b6YLeS3Yz7g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EH9dxfON5UFkobHHph9zuL3DG7xqUn3+r8qG18EXlssmVd36zH9iYdCppTPlue6kS
	 7O9xbVn2FK+pkeV6l0zsic72I+Luo84728jBq3MbaShZwIefAhnVa/HREw20wWVYl+
	 kg3rJO4hqUe7Z+OvhrcS3V75rF5f187/8p06S/KGs2mDrSUg/gCt0vMAbs18yiDF9w
	 tJEwZHK1iqJd4wvcLcizkX2/QZx061IpKb/+Jd+oJQv5EiYa0Q0ruY8chHS+Ge/ABs
	 6IFbhF7tVvKkBO6uE7zAFwFmADpvtpjxEtomjnoK/gwHZT9ER+N7mc3tPGEbwii+nW
	 NErx+yxHxVlWw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:27 -0500
Subject: [PATCH 11/13] NFSD: Account for page_base in reply-space decisions
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
Message-Id: <20261109-xdr-page-base-v1-11-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=7424; i=cel@kernel.org;
 h=from:subject:message-id; bh=NXdsdeL1rpLpsg/os9vDf71rBg0o3tWaKaBa2fulX2w=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS4zG4yWTMzAdeoEAoMF2rElJ0x1sUkBK3z6
 xWvD1Rmb+SJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 l+fvEAC/hA2srkLpmfBHLhwD917dc1bHSB2NImKrSHa+8rpY2gVSIF8tnN1Ui7Io2jXtS/LhIYd
 N0rsfbRNU41wV2oLYMkorxXClRjwt5OH0HynjOixL2LBswkYp/9J2/s9ih0t45d5qFD2t5NJ74D
 V2x30YjtgXAi1NUmJ6DqA8U8nGh8a+UbnubDo+cy1AAw6pNKGKokBPfnyaTLgIv3Fpih1aCbjut
 CJqQsPyagQniHxetmzi7jr2xlB08urmPDVgYJWTR/PvEbJPlfnPzo0yuEhb+yaZh7hXUjRW8zhB
 n6D/DPFQiQ4K9R+j9fLk86EIomCxx8JsXNb9sssuCKEBc96DmLW+j800tjhzUis/eH2nRI2whv3
 wM2zJ8NU6oIEuwaQ6/YYRnSJSTQnZyJBTHpwp46hOKRGfkvE/f8wr6LIPcTInBjoyvf4dZ69rb+
 2klTLxx9yeRWsYvXdayOT4Giy7gYIgCsuJhcJyxMn5kgwZ3oTgYs2QmPBwmXRKWraOgelLK6iaG
 4bopFMjCRluARxV9t7OHSa0+iozeZtxJ26DjpWaQSfXZSrEo70Dke6tWK+jplJ+f+i9oRJV6Wa8
 dh7AdlIBpEiWvLRP1LdGTvW98FBqQyO47kQrncT1OQucI+M2kYmT/Gzu35iNHvIPzGisWz33PgF
 kyO+WU3Cb0n5nFQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The direct-read admission check ignores the alignment pad that
nfsd_direct_read() records in rq_res.page_base. nfsd4_encode_readv()
restricts buflen for the pad only after the read has placed it, so a
direct READ whose pad and payload do not fit the Reply pages fails
with NFS4ERR_RESOURCE, or NFS4ERR_REP_TOO_BIG under a session, where
a buffered read would succeed. nfsd_iter_read() places a buffered
read at page_len alone. Only the last-operation restriction on direct
READ keeps a later READ from overwriting a direct READ's payload.

Have nfsd4_encode_readv() refuse the direct path, with a new trace
event, for a READ whose aligned count would not fit the Reply pages
behind its pad. Have nfsd_iter_read() locate the next sink page from
page_base + page_len.

Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst |  4 ++
 fs/nfsd/nfs4proc.c                              |  2 +-
 fs/nfsd/nfs4xdr.c                               | 65 ++++++++++++++++++++-----
 fs/nfsd/trace.h                                 |  1 +
 fs/nfsd/vfs.c                                   |  9 ++--
 5 files changed, 63 insertions(+), 18 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 3f3fde8be9ba..29fb0be5af75 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -223,6 +223,10 @@ Tracing:
                                   multiple of four bytes, when the
                                   reply's head has no room for the
                                   payload's XDR pad
+      nfsd_read_dio_reply_full    an NFSv4 READ whose offset is a
+                                  multiple of four bytes, when its
+                                  payload and alignment pad would not
+                                  fit in the reply's pages
       nfsd_read_dio_not_last_op   an NFSv4 READ that is not the last
                                   operation of its COMPOUND
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bd0af3b59c61..954bd32c7607 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1178,7 +1178,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	/* The NFSv4 reply-space checks do not account for rq_res.page_base */
+	/* Nothing is yet encoded behind a direct READ's payload */
 	read->rd_dio_ok = nfsd4_last_compound_op(rqstp);
 	if (!read->rd_dio_ok &&
 	    nfsd_read_io_mode(read->rd_fhp->fh_export) == NFSD_IO_DIRECT)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 38d38176cdad..24e45e3364e0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5327,6 +5327,57 @@ static __be32 nfsd4_encode_splice_read(
 	return nfserr;
 }
 
+/*
+ * Reply-buffer checks that nfsd_direct_read_ok() cannot make: the
+ * payload's placement depends on the alignment pad, and the pad on the
+ * READ offset.
+ */
+static bool nfsd4_direct_read_fits(struct nfsd4_compoundres *resp,
+				   struct nfsd4_read *read,
+				   unsigned long count)
+{
+	struct svc_rqst *rqstp = resp->rqstp;
+	struct xdr_stream *xdr = resp->xdr;
+	u32 offset_align = read->rd_nf->nf_dio_read_offset_align;
+	loff_t offset = read->rd_offset;
+	unsigned int pad;
+
+	/*
+	 * nfsd_iter_read() reads the I/O mode again. Refuse here so that a
+	 * switch to direct mode in between cannot bypass the checks below.
+	 */
+	if (nfsd_read_io_mode(read->rd_fhp->fh_export) != NFSD_IO_DIRECT)
+		return false;
+	/* nfsd_direct_read_ok() refuses and traces these */
+	if (!offset_align || count < offset_align || rqstp->rq_res.page_len)
+		return true;
+
+	pad = offset - round_down(offset, offset_align);
+	if (pad & (XDR_UNIT - 1)) {
+		/*
+		 * The XDR pad goes in the tail, and moving the stream
+		 * there takes a word of room in the head.
+		 */
+		if (!nfsd4_pad_fits_in_head(xdr)) {
+			trace_nfsd_read_dio_head_full(rqstp, read->rd_fhp,
+						      offset, count,
+						      offset_align);
+			return false;
+		}
+	} else {
+		s64 space = (s64)nfsd4_reply_buflen_with_pad(rqstp, pad) -
+			    rqstp->rq_res.len;
+
+		if ((s64)xdr_align_size(count) > space) {
+			trace_nfsd_read_dio_reply_full(rqstp, read->rd_fhp,
+						       offset, count,
+						       offset_align);
+			return false;
+		}
+	}
+	return true;
+}
+
 static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 				 struct nfsd4_read *read,
 				 unsigned long maxcount)
@@ -5337,20 +5388,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
-	/*
-	 * A direct read at an offset that is not a multiple of XDR_UNIT puts
-	 * its XDR pad in the tail. Moving the stream there takes a word of
-	 * room in the head. nfsd_direct_read_ok() traces the other reasons
-	 * a direct read is refused, so test only what it cannot see.
-	 */
-	if (dio_ok && (read->rd_offset & (XDR_UNIT - 1)) &&
-	    nfsd_read_io_mode(read->rd_fhp->fh_export) == NFSD_IO_DIRECT &&
-	    !xdr->buf->page_len && !nfsd4_pad_fits_in_head(xdr)) {
-		trace_nfsd_read_dio_head_full(resp->rqstp, read->rd_fhp,
-					      read->rd_offset, maxcount,
-					      read->rd_nf->nf_dio_read_offset_align);
+	if (dio_ok && !nfsd4_direct_read_fits(resp, read, maxcount))
 		dio_ok = false;
-	}
 
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
 				read->rd_offset, &maxcount, &read->rd_eof,
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index b20d45c7124c..11a6d7d66f6f 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -663,6 +663,7 @@ DEFINE_NFSD_READ_DIO_EVENT(no_alignment);
 DEFINE_NFSD_READ_DIO_EVENT(too_small);
 DEFINE_NFSD_READ_DIO_EVENT(pages_in_use);
 DEFINE_NFSD_READ_DIO_EVENT(head_full);
+DEFINE_NFSD_READ_DIO_EVENT(reply_full);
 DEFINE_NFSD_READ_DIO_EVENT(not_last_op);
 
 DECLARE_EVENT_CLASS(nfsd_err_class,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 00d669e779cd..10ea334cfdab 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1321,8 +1321,8 @@ int nfsd_write_io_mode(struct svc_export *exp)
  *
  * Some filesystems or situations cannot use nfsd_splice_read. This
  * function is the slightly less-performant fallback for those cases.
- * File data lands in @rqstp->rq_res.pages at the offset .page_len
- * records. On return, @rqstp->rq_next_page points past the last page
+ * File data lands in @rqstp->rq_res.pages at offset .page_base +
+ * .page_len. On return, @rqstp->rq_next_page points past the last page
  * offered to the read.
  *
  * A direct read leaves its alignment pad at the front of the pages and
@@ -1338,8 +1338,9 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      u32 *eof, bool dio_ok)
 {
 	struct xdr_buf *buf = &rqstp->rq_res;
-	struct page **page = buf->pages + (buf->page_len >> PAGE_SHIFT);
-	unsigned int base = buf->page_len & ~PAGE_MASK;
+	unsigned int next = buf->page_base + buf->page_len;
+	struct page **page = buf->pages + (next >> PAGE_SHIFT);
+	unsigned int base = next & ~PAGE_MASK;
 	struct file *file = nf->nf_file;
 	u64 storage_start = nfsd_storage_read_bytes();
 	unsigned long v, total;

-- 
2.56.0

