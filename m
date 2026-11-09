Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254013;
	b=NzIOZethD5dOrAbYva7WkjYMcTcrdJGmlJ0qjDOtHRPOLTHooWYkRgiFoDlqZiZxlhQe
	 eP/640pdTkHiD9ElCeU5e8O8nOFSEyBkkkzKM0i1J0nqcSFYFSiGWbCdV2MyxNIwfLyDT
	 c28Vn3Ms285oEOyQXgetq5M42CZ2pZBwOzQIroS2LPq7CsKsHFPPB8UJAk2ZlAqVNREqg
	 s/476h52Q5eXh4zSFsS3ovofXvuZuckbyt0V3iH07vAltlZ6qudf6WNjsOdDDNDcKqPaW
	 79QauaambcOSefBeWk0BXf0rv+nuaLHdL3lyCYsVNHwg4cFzasE++wOo1QEhT/ZVhgg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254013;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bzhETL69t2/TVKdPukbOe47oc7zbUMW87yT7EYMiZBg=;
	b=gXxdGlFcMiYMatMKFfwokcWcyeGNIbHn8kJ38duBOxtalQJiGshi/TUGtX62UrseD3xv
	 0mvQwMjQPbn5tl52DY23wjOLUAKCH04+9vbPJJsEVgT1xO1g8ad0ycn18xANxPDvjt5Fh
	 K4rAYq5U8bnACerXBqZE7z6CNexiuooiTjBB/StRIqaHnW+SxONmddtDoBW4+yLnkPMEW
	 vOVx5BB+nsa1QMz1SRxVTaD+v8OSPz55CYJvuzlVixgwau8lbWPptA5D2rGe4KWtHTDtT
	 LNLhOJZCRtSWkYRG8nUZkAVFxh2OkZeLjkYO5sYB8rvdT3PYj7C9tYQf3/LXvjeVReA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uwe9U6sm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CFF0F60A381F
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uwe9U6sm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C7EE1F00901;
	Mon,  9 Nov 2026 19:53:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254012;
	bh=bzhETL69t2/TVKdPukbOe47oc7zbUMW87yT7EYMiZBg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Uwe9U6smCM+oIV8TK10JjobvUXHTpkSdSyyC6oTTiBInIlPay6HAApdq3lZ99v0Lm
	 7y2zRSIbvgq3MvH0lgVa/M5BhjoqP+G2vI2Wdtty3lfIyqxwbjFgbto7WNUy45UpQt
	 FzW2i7GahRCD+GcDqVTD0eX9bCU+fBoOtQP3gJXByKLl9wtaaR+PoIZkxUAiVjFdZt
	 DSWe+8xlq5XJIFY/+Y01E0rheE2CyTqBCH6aN5YDTI5UkGLF4rSRHiw8jmSSC7GY0P
	 Wr2NEaUrFRLmHJ5jfYONJPJ6MezywJPJwUHtzBY2qoHsecTUZFWkzrV2qToRS0sk1X
	 8mGci25D5xVPQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:19 -0500
Subject: [PATCH 03/13] NFSD: Check the Write chunk before inserting a
 spliced READ payload
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
Message-Id: <20261109-xdr-page-base-v1-3-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1757; i=cel@kernel.org;
 h=from:subject:message-id; bh=5JX1ExrjOWPxsR4FGG2nC8ICVrxcdXacitcYqB7nDTc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS3L7oRv/BHHZGpAeFFBjWeOZM9w8XFyBl7O
 jNb1wNyeRiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIktwAKCRAzarMzb2Z/
 l33vD/9Mr0yDZcBlrcrmeMLLSdgWoj5GTtMwVEWFOo4vlTRfHwMriti1EgbnUxcuiuiQw6FJygd
 z1p3mKKb+zyLY6UkEnSynE6ZUPt29CBcfxq/hN5zuSCOPJlAuxZytVvIH5oxf/H+xgq22+7sTro
 KAl33/MJ5SU0jTKh5H2ThFBrJTWGFImzssTGxcpMBJRqJr8j50AK1+ohvtb2ZAFDW3+QZXmxSNl
 hkqwIe5FF7ZYsAFkfyNPDxz65OL0kuCXCEaxTTIEeUY6eQVhwZ0u7MdUNh/EGVHFK+OduOvEUG9
 PDX663824TEQKuMjPUN5ztI15FD8ofwzorpuOuM98Bwv0rk37IHHIY0N2n1MmJH/mXg3tyC54gz
 jdgvnuu0hznrLViVgvukH+AWm9/F28NnULS665v/MSCzXmk1VnKHtZx3dSfPtN7ckpH9i2o0LvW
 3wmblJk0hS+8dFKr36z1gla9FG3+9kb43PHy2R2SQ2kwDdGFU77k6OT2cMwbxZGJQQogSsDEEs/
 qkU9WQyo7yzQhtUp0b3qTsA9FSVU5T2VBulaEFHyRU0LoxB+jamRG1PNRCkWSbeuBRaDK3z60fi
 AK9/7WJChaT2Lzz1vTkjMN9t9+MHbSpIXpTCpi/tPlGuhm58tSj1f5yxdoAmt8oCoJUeYV5vho8
 7Xff+2CbhQMh6Dw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_rdma_result_payload() fails with -E2BIG when the client's Write
chunk is shorter than the READ payload. nfsd4_encode_splice_read()
calls it after the pages and any XDR pad are already in the buffer.
nfsd4_encode_read() then truncates the reply back to the start of the
READ result, and xdr_truncate_encode() hits WARN_ON_ONCE(fraglen)
when it empties the tail. With panic_on_warn set, an RPC/RDMA client
with a short Write chunk and a READ length that is not a multiple of
4 crashes NFSD.

Check the Write chunk first. The payload offset is the same in either
order because svcxdr_encode_opaque_pages() leaves head[0].iov_len
alone.

Fixes: ba21e20b3095 ("NFSD: Use svcxdr_encode_opaque_pages() in nfsd4_encode_splice_read()")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 268f387ff30a..fc14b31616d5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5270,14 +5270,19 @@ static __be32 nfsd4_encode_splice_read(
 	read->rd_length = maxcount;
 	if (nfserr)
 		goto out_err;
-	svcxdr_encode_opaque_pages(read->rd_rqstp, xdr, buf->pages,
-				   buf->page_base, maxcount);
+
+	/*
+	 * Fail before the pages go in: xdr_truncate_encode() in the
+	 * caller warns when it has to drop an XDR pad from the tail.
+	 */
 	status = svc_encode_result_payload(read->rd_rqstp,
 					   buf->head[0].iov_len, maxcount);
 	if (status) {
 		nfserr = nfserrno(status);
 		goto out_err;
 	}
+	svcxdr_encode_opaque_pages(read->rd_rqstp, xdr, buf->pages,
+				   buf->page_base, maxcount);
 
 	/*
 	 * Bound the stream at the space left in the head page so a later

-- 
2.56.0

