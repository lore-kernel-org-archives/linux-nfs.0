Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792946522;
	b=HWdwSbeKO1YRIpgsbPSnwL9FueVYyQbfUWElFmQ74x7T0BncmSf0Loa639JLFWyxIldd
	 gO4INiq8pZQ/MttpoEE8rz1MgJVRUIl0iGJNI1CZEjnYXlGiZbrGVpQH/30iuVUPfMwHu
	 BzO2W4LiQ/NSSS0rmNH04snsTr3mRNwiJp/qCsNRktSeE5FefhoQIj3Xm9IrBtx/HXFbq
	 xb75L6CevWyVJoF9PdQbBP4Z/xaUGUCJQtVYMMabXuIJKOckekZRqnsucNYWAHZ3coxnO
	 TJraR5MszR4LuFhs/e0OSmkZPz5WY6+uSlbdHtPiEAp7hKGZbAH67r489/b6BBp0KYg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792946522;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=R28ph1Ish2Cs0gByviBCdFaQObHhcWEur1syLF/Xw60=;
	b=NTrRwYxg/3ilFKTZtJ8rppA1iHRgq+sy0IUy8fl0HzdpHjo9H7KpX9nm2de/ya+fdRJT
	 ccW0GkSYN17gvE7zvFPcXHvTerUDgHQioctT2oyKJEnRRu88ziej1yok/5zhGjDpjoHQm
	 5eoZfJ+XDUNwDqjzrDtv33EPdYSxF6ENy+PMwXpnSz+/kog1hZ8rR6gt9fg0v8thS4QHY
	 xSmOqmwFJ/BzgONmk9Qeuf835ExqSc1a2cXXxz0CyuQYIo684RjWwKF+QXvp7pxkf6w21
	 xRyI6yisrU0ofBGzdm5TP2krTPlb1av54takKbMmvo7AhIFN3nfk4XUrm1rl1dj+0uw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SO5EVwXi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92F54606A31A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 16:42:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SO5EVwXi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74A241F01828;
	Sun, 25 Oct 2026 16:42:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792946522;
	bh=R28ph1Ish2Cs0gByviBCdFaQObHhcWEur1syLF/Xw60=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SO5EVwXi6/GYNJ62IeWVg9X4HZsV5/hMxt3MNx1DBehejs4J4uIlUUlFVwK+LKDAe
	 mnlaIZuh3BjH1xz21O+FpEaaKXtZkFT5czFI/S7QD2S9tVpownijIeziNym8wviVra
	 FLKwmcUTb928Ow9StFtDvBO+ShhZn1L5I6PyLie+o0VSx48AoMX/A7fIspRnya01VV
	 GnZ7ims7o9TM5b3FSy4Ny3/RFoF0ZggGooVHl9f/Wk+4Tml4QvMD6+/tNoefdGouQF
	 ghfPYzcInvSxvT80PZr0m+xfvJfB2/KPVRF6ZksyjTh2az5h9CxY3JKBwTdRm6MKEx
	 jVPFCisMDUqeA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 3/4] xdrgen: Register optional-data names only for typedefs
Date: Sat, 24 Oct 2026 21:46:15 -0400
Message-ID: <20261025014616.22236-4-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025014616.22236-1-cel@kernel.org>
References: <20261025014616.22236-1-cel@kernel.org>
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

_XdrOptionalData adds its name to structs and to pass_by_reference
when it is constructed, and that name is the field name when the
declaration is a member of a struct or a union. Both sets are
otherwise keyed by type name: _XdrDefinedType consults structs to
emit a "struct" classifier, and the encoder templates consult
pass_by_reference to pass an argument by address. A field named
after a scalar typedef turns every later reference to that typedef
into a struct passed by reference, and the generated C does not
compile. No in-tree .x file declares such a field, so the generated
headers do not change.

Add the name only when the optional-data declaration is a typedef,
beside the width registration in _XdrTypedef.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/xdr_ast.py | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index a3595aa40a57..6b012f0f7a42 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -284,10 +284,6 @@ class _XdrOptionalData(_XdrDeclaration):
         """Return list containing XDR width of type's components"""
         return ["XDR_bool"]
 
-    def __post_init__(self):
-        structs.add(self.name)
-        pass_by_reference.add(self.name)
-
 
 @dataclass
 class _XdrBasic(_XdrDeclaration):
@@ -440,6 +436,9 @@ class _XdrTypedef(_XdrAst):
     def __post_init__(self):
         if isinstance(self.declaration, (_XdrVariableLengthOpaque, _XdrString)):
             varlen_object_typedefs[self.declaration.name] = self.declaration.maxsize
+        if isinstance(self.declaration, _XdrOptionalData):
+            structs.add(self.declaration.name)
+            pass_by_reference.add(self.declaration.name)
         if isinstance(self.declaration, _XdrBasic):
             new_type = self.declaration
             if isinstance(new_type.spec, _XdrDefinedType):
-- 
2.56.0

