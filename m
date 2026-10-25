Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792946523;
	b=AnNwn65uJBVlXpCSIveZLVKwUtMjH7Op8bRDvBGGnaA2fUXEtqDOSUA0cHcOQ71BH6Vk
	 b23gjRxs6WF4dFMO61yfOJZ05YbygKKgYERZfNQc/4vVFpI+VlVX2OS8q6rdDGxlzZRSy
	 gWvehwzgl+6l4Gr81I7C+hbBJJiZXzh7wBlHGxILfoHwsGTfy7dDQCJumK56xYHJpLFXX
	 9tZhO7G5Bi5MKRRn5k3e9I6s8CcucUBWMyIwb8yWJ+YwsA8ScAO6NjJuqgn/TMIUiwQ3x
	 let1skbQNZ2kNB5RJ9WrsXSmMULj6FFimzEAWNEB3btP3VbJ0dRzlCIzvadGP/8876w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792946523;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=COscxAGOIuXibtlh0AD6N3ax7mwBPtqzu/6HlB+pOQQ=;
	b=eYbCgZTkicWyy9WKW3QgGz4qeutzTTOizMxQpPeaR0nHubA0sjW81jpSdP6pJj091vg2
	 sbQi+rlB1UfIoaf+kPsobPG1ChlPDYn6gXffGn/HqDe+nDJBb9clQw5HuozVgN4k7xvjl
	 9IWnWbP2gidGRexjazvxfUPXEGYLJehmZoRosfFACiChOoKA2iMRqbrRCkFTL2Q7ZUz/C
	 qz+Vcq7KH+LvYF8l2z14XCpF8AJTYskmRuI7bHDtQyyX3dxJ7gEp1ClM73IjaW6nMMwt8
	 dgdBS3vvMTZKBmkEXcnGwFo5+SEPTw1TWaUTu4RvkQkSjxZz3JbzgDvNU9GTCTW7+Fw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ud0kRBDE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FEFE606A31A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 16:42:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ud0kRBDE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 78A221F031E0;
	Sun, 25 Oct 2026 16:42:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792946523;
	bh=COscxAGOIuXibtlh0AD6N3ax7mwBPtqzu/6HlB+pOQQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ud0kRBDEwzquoaFKJ8OTFuyNTjn5hvUpTOBwzPcDYFlDejlxOgfNYjrsZ0aElxcXE
	 AF2vwqqFV6G7/1GR9dhYGElDMPVCEgLROiyfg9+UxtL33xFdZtSmjEgqZ6c/wbFxI3
	 RLsWXZ7xjEHVhgwAGPJjoO1YLdR5OT0n+YCMLsHbylANMMZ24jUSgOKcAvlHyNBVJC
	 QG3ymJFB1HR/zpO/fuulOhLtYtjNLTHCiAjagr/uMHQsnGH9oH3TPH0LID9AMJammu
	 pVWcqPkLpQ0b9GlsaDHa2tmQRmGRo2qOp6k0Xsi0RHkyixKd0UA9fv02pLfR3BiTPr
	 kdN36/re5lMig==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 4/4] xdrgen: Take a union's numeric discriminant width from the declaration
Date: Sat, 24 Oct 2026 21:46:16 -0400
Message-ID: <20261025014616.22236-5-cel@kernel.org>
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

_XdrUnion.max_width() counts the discriminant as one XDR word, while
symbolic_width() takes the discriminant's width from the discriminant
declaration. For a hyper discriminant, or a typedef of one, the _sz
macro therefore emits two words where the numeric width counts one.
program.py compares the numeric widths of each procedure's argument
type to choose the type that the *_MAX_ARGS_SZ macro expands to, so a
union argument with a wide discriminant can lose that comparison to a
narrower type. RFC 4506 restricts the discriminant to int, unsigned
int, bool, and enum, and every in-tree .x file complies, so the
generated headers do not change.

Take the numeric discriminant width from the discriminant declaration
as well, so the two methods agree by construction.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/xdr_ast.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index 6b012f0f7a42..a57b5f42da1f 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -514,7 +514,7 @@ class _XdrUnion(_XdrAst):
         if self.default:
             if self.default.arm.max_width() > max_width:
                 max_width = self.default.arm.max_width()
-        return 1 + max_width
+        return self.discriminant.max_width() + max_width
 
     def symbolic_width(self) -> List:
         """Return list containing XDR width of type's components"""
-- 
2.56.0

