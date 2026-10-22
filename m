Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677223;
	b=iyqqQ0pNvrmrkl1v+qVq8C3flFwdJxZS850eOv5MLqb0CtI2hy24vWAsfGD0bGILriVi
	 9VlWy7EVYi16+YXTa6jdGw/23b3r3u5zJ9gohuP7wkpFtP3PvwGfc9TZSGScPL4DE1WJT
	 okvY0Uf8YGZgV6KNeCJIWmVMS5AmhLi5K50dVrIVP0caBarHM3JnDBDBdqFF/hmj7nYFR
	 BqvH90ygoGVRykwwFzQFgDoIOm1eFdEJQJfUqWm4Zp+wDvofefZe+eQ1wsXpmOrosHTtx
	 IytKpB9OPGJtXJr/8tqygMYf2+If38atJ8Sye9aPyJBptYiEtUPJGARrPYDeHjHFMmQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677223;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=DTQOyrzO3OVhbZWpLD9Rw+icMl1brPXRU5w3mi+9bgU=;
	b=XB+hqR7xfWdMSRQEMI93oJ15s33DVW2t2NQ1Z0xoLWh6IXttmGrs/1RB+qSpGXUuXS2F
	 6jZZXuni6/o80ipCPDWR8cCO33YMzRylCjw8CQs4MQld+AkSIOEjZ6ZEjx/yt23Yoxwvs
	 oFTZUOABTQkIwb5wPQNBJpsr7/AHaG0mCV2zGgEC8Y9XEWDNoeHxW9rH7l/NMLvoaj4cW
	 qrimmC/qzOb/s7CYP3znSeqSwvQqZO4x1potGUv4OI8frTqT1H4q6ArDRmwzCl0y1husG
	 abh/FJfHJ5gBu7hYVwvtJGmOfKgqM3y/Q57GtmgFyl4AGcesl7s87FdZeR1ZYi1lK/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aGxwwcA3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9744C60A2638
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aGxwwcA3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B496E1F000C8;
	Thu, 22 Oct 2026 13:53:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677223;
	bh=DTQOyrzO3OVhbZWpLD9Rw+icMl1brPXRU5w3mi+9bgU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aGxwwcA3DYrptdnUOuJao2PHlYa5/gfSPE08KLGWMuWsa/vtqo524X2wRK8/2qUFM
	 nX5pTx2aD517QhTZweWk4UiE24okKwHyr4YyavYlhlOJ9sNQGlu9r9CYEQS4ic0r28
	 t4goSHXVpFHIZqsNH0EucHfjFITtKIM8qVPmuiv6oICONk5h3krSqXJxiewITVCrtV
	 qgPYQR61Qx47pFSSwqK/eFl94bBbbJ+ZwLklGcpiQoKUbzVFVnGyiwWJlXi4RNS0L5
	 vG+q0F2ZLrasLrBd+zJnqzwQSyKo9/hx39gkOEesajpa6GB31xIacfpdLYMCBnqgc1
	 RA7Lgk1rienJA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 01/17] xdrgen: Reject out-of-range unsigned short values on decode
Date: Thu, 22 Oct 2026 09:53:25 -0400
Message-ID: <20261022135341.14265-2-cel@kernel.org>
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

RFC 4506 does not define a 16-bit integer type. xdrgen's "unsigned
short" rather follows rpcgen, whose runtime decodes the type in
libtirpc's xdr_u_short() by reading one XDR_UNIT as a u_long and
assigning it to a u_short with a plain cast.

xdrgen_decode_unsigned_short() mirrors that cast, so an XDR_UNIT
carrying a value above U16_MAX decodes as its low sixteen bits. A
decoder's semantic checks on the narrowed value then cannot see the
high bits. NFS_ACLv2 is the first consumer: a SETACL entry whose
perm word is 0x00010007 decodes as perm 7, passes the check for bits
outside rwx, and installs read, write and execute.

Nothing in XDR or rpcgen requires a decoder to accept such a word.
Fail the decode when the wire word exceeds U16_MAX. The server-side
generated code reports the failure as GARBAGE_ARGS, which is the
right verdict for a malformed encoding of a 16-bit type, as opposed
to the ACL2ERR_INVAL that a well-formed but invalid value earns.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xdrgen/_builtins.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xdrgen/_builtins.h b/include/linux/sunrpc/xdrgen/_builtins.h
index c9033eb1c829..6b389181dc7b 100644
--- a/include/linux/sunrpc/xdrgen/_builtins.h
+++ b/include/linux/sunrpc/xdrgen/_builtins.h
@@ -88,10 +88,14 @@ static inline bool
 xdrgen_decode_unsigned_short(struct xdr_stream *xdr, u16 *ptr)
 {
 	__be32 *p = xdr_inline_decode(xdr, XDR_UNIT);
+	u32 val;
 
 	if (unlikely(!p))
 		return false;
-	*ptr = (u16)be32_to_cpup(p);
+	val = be32_to_cpup(p);
+	if (unlikely(val > U16_MAX))
+		return false;
+	*ptr = val;
 	return true;
 }
 
-- 
2.56.0

