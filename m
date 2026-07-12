Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11AEB369D45
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 19:31:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783884689; cv=none; b=EOPWsmYqm1Q2SyiF2k1i/p0l4GgTc/SpuvIkJxCYO+oZB0aVaPPCJSR2X7kXT+rQKC5jwXl0mckLYL1NKPd2h68u6G3QofBQjftzyeZzADhnU6EfU8GESVFRjgivb6d7ad+wZk86eu0ob3S+uh2Axq2aDCW3S3WZQmlJCb125xE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783884689; c=relaxed/simple;
	bh=lngkuuHP5o27dKmFUap3pTm8VOjSH6aaUyr+uw7/xS4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EC1MxVbDh6RgymeMe1MEJnEy4KG5ya3LFnfjLXeH2ByB9FpJdmSpo4qQ9Vb28xgxRrZG1Zn8BOuA+jbXlGRVGH1lSZ2mlCJY9tgcvjW+X2tj1jV5F6Y4PRkdG+ajZxvf/bVEvvV6KS83G7iQHsOD4p21BD/VwRoRhUyMun14MI0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KBoCz+eY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KBoCz+eY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 76C441F000E9;
	Sun, 12 Jul 2026 19:31:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783884688;
	bh=fRI7yE9PGulYCXpbCHTnY3p1vuPJ5HpwvVaALNE1Agc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KBoCz+eY5CtGm0IppzybLZnYpdjRFkU/yXtXTEd9zAtpuHMt6aqgntbc8RSIbz9af
	 HFkPUgKUV7JIKkqYrVUUdhjB8JXkdATP0rSZWzMatrqb3GMiyuCGUhNAQoAyPi9wNO
	 +oJ6CD7BROK+PwDlPK2Z1AOJ6K9j3rEel2CUpUpN79SpqEyvwJDD5ShJ8D4bxvTHv4
	 OuRRAWyiQuQAWYlhPd7/1wn67PoHSHMP6wtGbfPTTilBx/Ry2GNZ+KqXwJSy6h5SE5
	 onCXgttb7fR4dYGcyAFxpyvhuNvug+CQh216pJ9tl4OulXfgdAUO9EKwD4JZaBNe2x
	 RNXAOxPr+C/dg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/5] xdrgen: Fix opaque and string encoders for unbounded members
Date: Sun, 12 Jul 2026 15:31:22 -0400
Message-ID: <20260712193122.116845-6-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260712193122.116845-1-cel@kernel.org>
References: <20260712193122.116845-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The variable-length opaque and string encoder templates emit an
unconditional bound check, "if (value->NAME.len > MAXSIZE) return
false". XDR represents an unbounded specifier (opaque foo<>, string
foo<>) as a maxsize of 0, so for an unbounded member the check
degenerates to "len > 0" and the generated encoder refuses every
non-empty value.

The decoder does not share this defect. It delegates to
xdrgen_decode_opaque() and xdrgen_decode_string(), which treat a
maxlen of 0 as unbounded and skip the length check. The sibling
variable-length array templates already guard their bound check
with maxsize != "0".

Guard the bound check the same way in each affected template -- the
struct and pointer forms of both the opaque and string encoders --
so an unbounded member encodes a payload of any length while a
bounded member keeps its limit.

An explicit zero-length bound (foo<0>) parses to the same maxsize of
0 and so also skips the check; xdrgen does not distinguish it from
the unbounded form, matching the decoder and the array encoders.

Fixes: 4b132aacb076 ("tools: Add xdrgen")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/string.j2   | 2 ++
 .../templates/C/pointer/encoder/variable_length_opaque.j2       | 2 ++
 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/string.j2    | 2 ++
 .../xdrgen/templates/C/struct/encoder/variable_length_opaque.j2 | 2 ++
 4 files changed, 8 insertions(+)

diff --git a/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/string.j2 b/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/string.j2
index cf65b71eaef3..7ddc2bf3edac 100644
--- a/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/string.j2
+++ b/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/string.j2
@@ -2,7 +2,9 @@
 {% if annotate %}
 	/* member {{ name }} (variable-length string) */
 {% endif %}
+{% if maxsize != "0" %}
 	if (value->{{ name }}.len > {{ maxsize }})
 		return false;
+{% endif %}
 	if (xdr_stream_encode_opaque(xdr, value->{{ name }}.data, value->{{ name }}.len) < 0)
 		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/variable_length_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/variable_length_opaque.j2
index 1d477c2d197a..5bf00070ae95 100644
--- a/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/variable_length_opaque.j2
+++ b/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/variable_length_opaque.j2
@@ -2,7 +2,9 @@
 {% if annotate %}
 	/* member {{ name }} (variable-length opaque) */
 {% endif %}
+{% if maxsize != "0" %}
 	if (value->{{ name }}.len > {{ maxsize }})
 		return false;
+{% endif %}
 	if (xdr_stream_encode_opaque(xdr, value->{{ name }}.data, value->{{ name }}.len) < 0)
 		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/string.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/string.j2
index cf65b71eaef3..7ddc2bf3edac 100644
--- a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/string.j2
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/string.j2
@@ -2,7 +2,9 @@
 {% if annotate %}
 	/* member {{ name }} (variable-length string) */
 {% endif %}
+{% if maxsize != "0" %}
 	if (value->{{ name }}.len > {{ maxsize }})
 		return false;
+{% endif %}
 	if (xdr_stream_encode_opaque(xdr, value->{{ name }}.data, value->{{ name }}.len) < 0)
 		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/variable_length_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/variable_length_opaque.j2
index 1d477c2d197a..5bf00070ae95 100644
--- a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/variable_length_opaque.j2
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/variable_length_opaque.j2
@@ -2,7 +2,9 @@
 {% if annotate %}
 	/* member {{ name }} (variable-length opaque) */
 {% endif %}
+{% if maxsize != "0" %}
 	if (value->{{ name }}.len > {{ maxsize }})
 		return false;
+{% endif %}
 	if (xdr_stream_encode_opaque(xdr, value->{{ name }}.data, value->{{ name }}.len) < 0)
 		return false;
-- 
2.54.0

