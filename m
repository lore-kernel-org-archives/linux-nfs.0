Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254021;
	b=tSYJiZ+xg+6oukiqkSTNHKyc/5i476qdE/FQjFrB/orNAnaG20tF+0DUhG/QclND9v4v
	 bb/p8cdy74omEx6tni7dpQqSS6nwrHqzS3RaLvYOtwW1bQg9oMQPY8Nm5BVdhCCwlLyLw
	 dcoaLXYgzL+Gtnbgi94GG5lPfpNMpy8mjhlU2bsM0I4kPha+no77c+3KIMFwiOQUmZxm5
	 kAZO4y6yJZAuxEVTX/bT5LSY/S4ty9OKHW++QbbrCKmsCv8dpK3bWHo304FyZcNk+a2W0
	 d4r4kMfmVfNqSq07eO51i3aS96QKAZ4RVaMrkt2ZOEAYCp2HvWptiGyXmTrnrOIs0oQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254021;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9mvGOU4nP2OPD9oU5qu6EGpGz9w6nP02TNlxA2JnlA0=;
	b=xFbaE/mvBzghBEPYKExGhvL3Mf+OCmGCeqDxAteyd7nLhdwfKXzYGpUe6QvFqcdg+MX/
	 Ekuf0SxgDi3lzNWyxNoxGES7aj235jhDuiS+JKM5Mjco97OpvphdZ0xk/MRwwoAiWHbfm
	 Kt5vgahGJ38J1UT6f9Xvn7GaAI6j7dvXHWiOEE75C9sYqzaWDvZfdBsiuPvDe6B+KAvwx
	 RflP7X0BQOUZe3tSPAKHYIsY961d7f61HE+yYP6BjwVfQZ6kB9uH4eixEyxTSl9XK/PQF
	 dR609bKdfSD91BrPiP24B/5usa6sNw79Qp3OkW4CefXZb1T79+4pVLZObNmvz1o7o2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BRzW2kFg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAC7360A6F4A
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BRzW2kFg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ABBCE1F00A10;
	Mon,  9 Nov 2026 19:53:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254020;
	bh=9mvGOU4nP2OPD9oU5qu6EGpGz9w6nP02TNlxA2JnlA0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BRzW2kFgZwidd3PHMhh2OmByN/vtchASaIIiutoezguy7R45xGo2PFNwy+HYBOGaz
	 DobthgziomAlIov+ORY+quOEzkMsbDwNt74Yq2eHYJjwff61yrQARBYm4difQ8CkmO
	 MgTi+8ModgBiX/U20XRAAnlzMVBMeGB6hygpTx3owQWMiW7GZXUkABB6phe4WetUYp
	 DPp7XBtVd8wwePVOZhN6KsXT48XApiS+CdIM8xmXfzz3IQhoRrzinxtbw009hTqvx1
	 dZpKycLNQPYGTBYgg/VGB5ltiRjfvF0fL393nSH5yaVHh34YF6nEMVMeZfQSeCoEfe
	 5P+0wtc/Ig21A==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:28 -0500
Subject: [PATCH 12/13] NFSD: Allow a word-aligned direct READ in any
 COMPOUND position
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
Message-Id: <20261109-xdr-page-base-v1-12-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=5624; i=cel@kernel.org;
 h=from:subject:message-id; bh=DTQ5aJQyUFSMKxrYJEGmbkKjtVmBzRMmsfCsPz00tJ8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS4v9FJKLQBBLEVIS3hJh7n6W8dRgG0Ja20z
 QUscRWrK9WJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 l9baEAC/BovPZIigIGZ+lKTuKRK6joN9HIyLnXiONlRJU2tAoX5kx2Ya6TJ6GRKPgcjf+zwjPVd
 r7a/wKX813+D+RWorwdZUbdR6ZIulXsDBK9BSbp4znq+R/+dduPICEwLEITYfnjcuatEf2zZ71J
 yWUsgWAQszJWEG6ajoXnoNmN9LsM31YxPzxRmG5XDYxx0zKCxotYLmZ7FgumKiL35ZkdfVQuzoi
 Sc3wefpsQM4/RsS2wsjK7CTB9R9LWKXyaxbRBELdPGJoAToceByKvojOcrPujx3Ti3TCujBDI/a
 yt0OthBlwho/t7egv9hXyyxae6HY+eBNFRmTnX+sDjV1jU26+e8vgxEwHuxWwRF2tmc/96lKZZJ
 VVj0GheM+0JQLLLwhafIUnOTcqmH5wNLEngD8t09B4OgLMajI4TvKbA0Tme0dYac9I7btz5JFV8
 Hijn2MfnOUkWBALRoStbPggM7MLv211HJwMppoFV4Wx+/nL8LcoWvM+xR+lh5hotgcUWK3CLNoW
 zjgOmzfPWBPz76TuNklIbESKfAbuBIjBJDjo6ZYtuyFlM+jV+QbOrhM+vh49qwwQg7Oj2rGJ5dS
 sZiZvklIgPqZxM8p+dTwfaaebqHSTk7Pxkr7R1vRf6gmONuXc8BegTRkRDYOBvFOQZ10pj8W1J3
 ZLPxHVPZBTIB/vg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_read() sends an NFSv4 READ that is not the last operation of
its COMPOUND to the buffered path, because the encoder,
nfsd_iter_read(), and the reply-space checks ignored the alignment
pad a direct READ leaves in rq_res.page_base. A result encoded after
the READ landed on the payload's tail. All three now honor a
word-multiple page_base.

Behind a pad that is not a word multiple, the stream cannot continue
in the pages. nfsd4_encode_readv() parks the stream in the tail.
Keep the restriction for a READ at such an offset and lift it for
the rest.

The Linux NFS client already positions READ operations last.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 13 ++++++++-----
 fs/nfsd/nfs4proc.c                              | 12 +-----------
 fs/nfsd/nfs4xdr.c                               | 18 +++++++++++-------
 fs/nfsd/xdr4.h                                  |  1 -
 4 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 29fb0be5af75..d57b7916f6c2 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -220,15 +220,18 @@ Tracing:
                                   COMPOUND already put data in the
                                   reply's pages
       nfsd_read_dio_head_full     an NFSv4 READ whose offset is not a
-                                  multiple of four bytes, when the
-                                  reply's head has no room for the
-                                  payload's XDR pad
+                                  multiple of four bytes, when the XDR
+                                  stream has left the reply's head or
+                                  the head has no room for the payload's
+                                  XDR pad
       nfsd_read_dio_reply_full    an NFSv4 READ whose offset is a
                                   multiple of four bytes, when its
                                   payload and alignment pad would not
                                   fit in the reply's pages
-      nfsd_read_dio_not_last_op   an NFSv4 READ that is not the last
-                                  operation of its COMPOUND
+      nfsd_read_dio_not_last_op   an NFSv4 READ whose offset is not a
+                                  multiple of four bytes and that is
+                                  not the last operation of its
+                                  COMPOUND
 
     This combination of trace events is useful for READs::
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 954bd32c7607..03ea955f1fe9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1175,17 +1175,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = &cstate->current_fh;
-	if (status)
-		return status;
-
-	/* Nothing is yet encoded behind a direct READ's payload */
-	read->rd_dio_ok = nfsd4_last_compound_op(rqstp);
-	if (!read->rd_dio_ok &&
-	    nfsd_read_io_mode(read->rd_fhp->fh_export) == NFSD_IO_DIRECT)
-		trace_nfsd_read_dio_not_last_op(rqstp, read->rd_fhp,
-						read->rd_offset, read->rd_length,
-						read->rd_nf->nf_dio_read_offset_align);
-	return nfs_ok;
+	return status;
 }
 
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 24e45e3364e0..a55cb8857a54 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5355,8 +5355,10 @@ static bool nfsd4_direct_read_fits(struct nfsd4_compoundres *resp,
 	pad = offset - round_down(offset, offset_align);
 	if (pad & (XDR_UNIT - 1)) {
 		/*
-		 * The XDR pad goes in the tail, and moving the stream
-		 * there takes a word of room in the head.
+		 * The XDR pad goes in the tail, and moving the stream there
+		 * takes a word of room in the head. Like a splice read, this
+		 * READ has to be the last operation: the stream cannot
+		 * continue in the pages behind such a pad.
 		 */
 		if (!nfsd4_pad_fits_in_head(xdr)) {
 			trace_nfsd_read_dio_head_full(rqstp, read->rd_fhp,
@@ -5364,6 +5366,12 @@ static bool nfsd4_direct_read_fits(struct nfsd4_compoundres *resp,
 						      offset_align);
 			return false;
 		}
+		if (!nfsd4_last_compound_op(rqstp)) {
+			trace_nfsd_read_dio_not_last_op(rqstp, read->rd_fhp,
+							offset, count,
+							offset_align);
+			return false;
+		}
 	} else {
 		s64 space = (s64)nfsd4_reply_buflen_with_pad(rqstp, pad) -
 			    rqstp->rq_res.len;
@@ -5384,16 +5392,12 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 {
 	struct xdr_stream *xdr = resp->xdr;
 	unsigned int starting_len = xdr->buf->len;
-	bool dio_ok = read->rd_dio_ok;
 	__be32 zero = xdr_zero;
 	__be32 nfserr;
 
-	if (dio_ok && !nfsd4_direct_read_fits(resp, read, maxcount))
-		dio_ok = false;
-
 	nfserr = nfsd_iter_read(resp->rqstp, read->rd_fhp, read->rd_nf,
 				read->rd_offset, &maxcount, &read->rd_eof,
-				dio_ok);
+				nfsd4_direct_read_fits(resp, read, maxcount));
 	read->rd_length = maxcount;
 	if (nfserr)
 		return nfserr;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ba409a879cae..4e8d4b957158 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -301,7 +301,6 @@ struct nfsd4_read {
 	u32			rd_length;          /* request */
 	int			rd_vlen;
 	struct nfsd_file	*rd_nf;
-	bool			rd_dio_ok;
 
 	struct svc_rqst		*rd_rqstp;          /* response */
 	struct svc_fh		*rd_fhp;            /* response */

-- 
2.56.0

