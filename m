Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677224;
	b=WGHX1p6JWSR+PBya/+0kjaj3kzY0beHDJEmdViwo20fnHuczGijxGeXT+Uy7u9mHT0dD
	 MP9akdQAJUE6NyBD7+YueboLcbv7RHasl1xFFWJ6PAYg80WRmlISw2YPKNyqEDkycApMU
	 0HdGh20RNMz/Nktug8qR6J+TShRwotv4UgcNmIrKrRX/FLe6Vyba2UIth6VoSiBRIkDYv
	 XfvtI8P/1P6Pcox6vMWC/fqayAVa4EMzl7aP0F1nFKpqyGN8YCDUtpWb13qbZR389mNjX
	 7DDd84vu8+KepThvgFHfa6180X1AcV7x4jwIVKZiPSnIlfc7JnUUkEBP1vXjjDlAhoA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677224;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=MdpaPJ1N2kP/L0eh96ryje4XCJXnWrvZ5bzdfClkWLU=;
	b=ZmYm+9pxaP1Y0ZzvgyGNhce5nIXfzbOiQqznrXN46y68EfHqCBUx4Qcxfebqx5bFFK3X
	 vnvzxXIch0qkeqi0dIMx1/9kigojLNVbzzB64wqQz+fM1zvQEnJ2y+1rM+ORRPJ2Ydkgk
	 PZqdQ9TEyjO/5MQLXrgXU0LK3wdhDYqJFgMrTGVcF2/ZSyAvAR+NG+C34LGMSWeYhThAb
	 h0JzmcnsZdYZX3+EYgVXlvwaC0dWb6dBDmT7ZXoks50AhHLQIWnVyNXL0XeAppdhUy0lW
	 Bw87J/88aRQ6gMaebfDZMf/X4lZoUsc0wV7JdWQALQ487oidMye2VCpKAOR+HHexGyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eRvRdz5P;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C88160A260D
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eRvRdz5P
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7CF071F000C2;
	Thu, 22 Oct 2026 13:53:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677224;
	bh=MdpaPJ1N2kP/L0eh96ryje4XCJXnWrvZ5bzdfClkWLU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=eRvRdz5PfDT4aj1hvDF1iNFLz4WLsWOYGJSFbOfsPO44FQLHOX0wHDuhdpgFtzV/0
	 DUYCPoMirRZfmGB2gh3n3EekNTNxGYGZ/4pTowj3WwDMjcq/Wtv+YxhsODRkl1C4uT
	 vIob8h7nlDfYRmc8p8IAiilY9gsvVxW9HFOGMGi1/X/XuCmQdEbT//+sx0pNE68XTZ
	 vYKXbzjRLlk09ejRPJtMSL1617QROr/WLM7ZVaf4RwJLCaX2pD66CA+7fXe4m2b4XY
	 QfcyNEDKwvyrBUEfar1fdNZ9K3w8+cbTlNf/38k9I1QStnkKV375zx8Fe33wTscxno
	 Q5uwOY42oZMjg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 02/17] xdrgen: Reject out-of-range short values on decode
Date: Thu, 22 Oct 2026 09:53:26 -0400
Message-ID: <20261022135341.14265-3-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
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

RFC 4506 does not define a 16-bit integer type. xdrgen's "short"
follows rpcgen, whose runtime decodes the type in libtirpc's
xdr_short() by reading one XDR_UNIT as a long and assigning it to a
short with a plain cast. xdrgen_decode_short() mirrors that cast,
so an XDR_UNIT carrying a value outside the sign-extended 16-bit
range decodes as the low sixteen bits of that word. A decoder's
semantic checks on the narrowed value cannot see the discarded high
bits, the same defect xdrgen_decode_unsigned_short() had for the
unsigned type.

Nothing in XDR or rpcgen requires a decoder to accept such a word.
Fail the decode when the wire word, read as a signed 32-bit value,
lies outside S16_MIN to S16_MAX. xdrgen_encode_short() and
libtirpc's xdr_short() sign-extend an s16 to fill the XDR_UNIT, so
a conforming peer never sends such a word.

No NFS specification uses a signed short, so no generated decoder
calls xdrgen_decode_short() today. The check keeps the signed and
unsigned builtins consistent.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xdrgen/_builtins.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xdrgen/_builtins.h b/include/linux/sunrpc/xdrgen/_builtins.h
index 6b389181dc7b..55c514bae5d1 100644
--- a/include/linux/sunrpc/xdrgen/_builtins.h
+++ b/include/linux/sunrpc/xdrgen/_builtins.h
@@ -48,18 +48,20 @@ xdrgen_encode_bool(struct xdr_stream *xdr, bool val)
 
 /*
  * De facto (non-standard but commonly implemented) signed short type:
- *  - Wire sends sign-extended 32-bit value (e.g., 0xFFFFFFFF)
- *  - be32_to_cpup() returns u32 (0xFFFFFFFF)
- *  - Explicit (s16) cast truncates to 16 bits (0xFFFF = -1)
+ * 16-bit integer sign-extended to fill one XDR_UNIT.
  */
 static inline bool
 xdrgen_decode_short(struct xdr_stream *xdr, s16 *ptr)
 {
 	__be32 *p = xdr_inline_decode(xdr, XDR_UNIT);
+	s32 val;
 
 	if (unlikely(!p))
 		return false;
-	*ptr = (s16)be32_to_cpup(p);
+	val = be32_to_cpup(p);
+	if (unlikely(val < S16_MIN || val > S16_MAX))
+		return false;
+	*ptr = val;
 	return true;
 }
 
-- 
2.56.0

