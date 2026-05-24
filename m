Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66DFD2E413
	for <linux-nfs@vger.kernel.org>; Sun, 24 May 2026 01:02:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779584540; cv=none; b=UkFoAZhG8oly+5Nm86KTsV8sGrG6XsVqLVpGjb9oXF2w1q8XVZVTEvOrt+266Vbu1xKF7fbQ0aaOAYnSdHPqsFuPybs4IWVngEA4lQPkFsAoWZWMI6oOG5Z5xKG/sMP/iaRhCUQC/NvHuD7mj/KDmPtcvflux0eM5np6lNfDqqo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779584540; c=relaxed/simple;
	bh=Vt2MTrL0q2Nu/HT7TxSbgd/VL0vB0TqFQ1hf33ZXcFw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mJhdOgB5BWfSy0UC+kf3FFnxa+26wdHznUfGtTum29hacJrgBXUtMZhdPtyhJmW61FlHcdTk8y1KlU3aLtAVYwHkbuIiaRL77QhdCTL/yNgVPritipfzDVuSF/zB7wtPy2UNrbCbW+t9tJTJ7uWZW7Pf9d/ExnuoldComiUX8ok=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TKQdyUvD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TKQdyUvD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 429B01F00A3E;
	Sun, 24 May 2026 01:02:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779584539;
	bh=iI4j/BtG1eCYmLkkPsjZi7qKoj2uyh6zIr+5gDjsoyw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TKQdyUvDR7b8jG92aIlOwmeuld/PnxnWEYj4wXCS4NGRpS5er0nV60xsEVNpH79Cm
	 R5maIp4ixQ/AJgx08QROZWEPQc8Z7tJA8RoY52pArwiZ5kJ/796fVmdEtIC3DWx7EZ
	 aMo+vZIk+ezAAvnYeJx0NlQcmt2TV6jm8vbYGsgapIEuKKMJhm6dVNah4md3ibm06R
	 EcdgKdVmcPlku9vkDDrYU1/cMtMVjxzzZBfNAwS6Hqc8wl/ZMRrMB/UNVtbkhokRWd
	 EuR7TXNOPU0Huiub2pAh6uRKHjJ3j2gxSNU8eEbzpoeJgxTt7jmtYk0E1cWCpNWmsM
	 GeSFGa/l21hpg==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>,
	NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chris Mason <clm@meta.com>
Subject: [PATCH 3/4] SUNRPC: xdr_buf_trim: clamp buf->len to avoid underflow
Date: Sat, 23 May 2026 21:02:12 -0400
Message-ID: <20260524010213.557424-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260524010213.557424-1-cel@kernel.org>
References: <20260524010213.557424-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chris Mason <clm@meta.com>

xdr_buf_trim() trims `len` bytes from the tail of an xdr_buf by
walking the tail, pages, and head iovecs.  Each per-section step
uses min_t() so it never removes more bytes than that section
holds, but the final accounting at the fix_len label subtracts the
total bytes actually consumed from buf->len without any clamp:

    fix_len:
            buf->len -= (len - trim);

When the caller has set buf->len to a value smaller than the sum
of the iov_lens, (len - trim) can exceed buf->len and the unsigned
subtraction wraps to near UINT_MAX.  gss_krb5_unwrap_v2() reaches
xdr_buf_trim() in exactly that state:

    buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
    buf->len = len - (GSS_KRB5_TOK_HDR_LEN + headskip);
    xdr_buf_trim(buf, ec + GSS_KRB5_TOK_HDR_LEN + tailskip);

buf->len is a small wire-derived value while the iov_lens are at
page scale, so the per-section loops legitimately consume far more
bytes than buf->len records.  The wrapped buf->len then propagates
as the authoritative stream bound into every downstream XDR
decoder.

Fix by clamping the decrement so buf->len bottoms out at zero:

    buf->len -= min_t(unsigned int, buf->len, len - trim);

On the normal path where the iov_lens sum to buf->len, (len - trim)
is always <= buf->len and the result is identical to before.  No
callers change behavior outside the underflow case.

Fixes: 0a8e7b7d0846 ("SUNRPC: Revert 241b1f419f0e (\"SUNRPC: Remove xdr_buf_trim()\")")
Assisted-by: kres (claude-opus-4-7)
Signed-off-by: Chris Mason <clm@meta.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index fa6a30b5f046..cb2ef428651f 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -2049,7 +2049,7 @@ void xdr_buf_trim(struct xdr_buf *buf, unsigned int len)
 		trim -= cur;
 	}
 fix_len:
-	buf->len -= (len - trim);
+	buf->len -= min_t(unsigned int, buf->len, len - trim);
 }
 EXPORT_SYMBOL_GPL(xdr_buf_trim);
 
-- 
2.54.0

