Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FB174C77D1
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 15:04:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788447841; cv=none; b=ReURLzzFHhL4eBVOfSZ9fD3+seXZZYtlf8rKys5dVRVOu5MIgLZEVhGgG7k2tuMLTYYOhnV1CR3RhgwmNz1yzE5XB4WF0CIXZhj1gOoY3tzDE7ze43EsbWH8jwinodoi/HMV9xA41mD20qtUKLOzTqRCRBM5p0jVk/8GfqyRVdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788447841; c=relaxed/simple;
	bh=Aig21jw8e0TW0lZhy9GX7uMhoU3Snx/XF8NRNttiyEY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jzUBRdOK5lpx9liicICt6QVfCdDLmygDLUwWTMPPcZm/3h4ijzwSgrQXiaADY3nkoKP1i41OEJ1For9b+T/sVOWwi6D6yMCgqpSqmTEDUkJMdfBESfCn8ywMyH3T0Xha8eBnuRJkLbWUfLJkJ2HaXVhCgZM4DkUSGbHgKJ+84sU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A/3PA9Mi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A/3PA9Mi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B80931F000E9;
	Thu,  3 Sep 2026 15:03:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788447840;
	bh=kb1vbkloqR6fhhdHUEqI5ATM8COyLLlLgI2lv0cAcd0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=A/3PA9MiXUYiHt4HdLuRvkAX9tg/f174Kcf/hEXNOqF38+EIOLMOUiUTsCUD3xb+j
	 1CThl+1a+14KonwnVSdS643Cg4VZAHhpUgTlTsagiYUrnpebrz5dzsuncwzBICDmHR
	 Hh45OQpBbKgcZIOWH9itFiRsBNALOYOKHxdWRLgnmj3zYAsV8m3MlKIdNuscNqZVH5
	 ly6uJegsdwRn6xC57KHkiNkqZkDh4yH5Ub17eINVB+HU5vRf7P9Lhf9+dtm+pc9rhq
	 eYychla8eIxkfO4ybBiPAmKY6RCCn6WzVyEVBe7CP6wP5tGuCNxmUcs446daeu1+5f
	 mRqSA/beaixWw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 09/10] xdrgen: Extend the aggregate codec to optional-data list members
Date: Thu,  3 Sep 2026 11:03:50 -0400
Message-ID: <20260903150351.9572-10-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260903150351.9572-1-cel@kernel.org>
References: <20260903150351.9572-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The hook-driven aggregate codec emits only the counted-array wire
form. XDR list types built on the optional-data idiom ("type *name")
carry no count and cannot be expressed that way. NFSv2 READDIR's
entry list is one such type.

Accept an optional-data member under "pragma aggregate" and emit
value-follows framing in place of the counted array. The element
type's existing single-node encoder already writes its own
value-follows boolean, so the loop calls it once per element and
once more with a NULL element to write the terminator. The struct C
definitions are untouched; only the marked member's framing changes.

The generated decoder is present for linkage only. Decoding a
value-follows list needs a presence-reporting element decoder, which
this change does not add. NFSv2 READDIR only encodes its entry list,
so the decode path is never exercised.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/README                | 23 +++++++---
 tools/net/sunrpc/xdrgen/generators/struct.py  | 42 +++++++++++++++++++
 .../C/struct/decoder/aggregate_optional.j2    | 31 ++++++++++++++
 .../C/struct/encoder/aggregate_optional.j2    | 31 ++++++++++++++
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 12 +++---
 5 files changed, 128 insertions(+), 11 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2

diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 92578671b5e9..ae8a8050698b 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -163,9 +163,18 @@ wasted work. This directive marks such a member so that xdrgen emits a
 codec that owns only the wire framing (the length prefix, the bound
 check, and the per-element codec) and drives the application
 through begin/item/end hooks, processing one element at a time with
-no staged array. The marked member must be a variable-length
-array member of a struct; xdrgen rejects a directive naming
-anything else, and generates the codec for the server side only.
+no staged array. The marked member must be a struct member
+declared either as a variable-length array or as an optional-data
+list ("type *name"); xdrgen rejects a directive naming anything
+else, and generates the codec for the server side only.
+
+The two forms differ only in framing. A variable-length array
+carries a u32 element count, so the framing writes that count and
+bound-checks it. An optional-data list carries no count: each
+element is prefixed by a value-follows TRUE and the sequence is
+closed by a FALSE, which the framing writes after the last
+element. For the optional-data form xdrgen generates a working
+encoder only; the decoder it emits does not decode the list.
 
 For example:
 
@@ -185,9 +194,11 @@ member:
   nfs_acl2_secattr_decode()
   nfs_acl2_secattr_decode_end()
 
-A decoder fills the cursor's count from the wire before calling the
-begin hook; an encoder's begin hook sets that count, and the framing
-then bound-checks it and emits the length prefix. Once a begin hook
+For a variable-length array, a decoder fills the cursor's count from
+the wire before calling the begin hook, and an encoder's begin hook
+sets that count for the framing to bound-check and emit. An
+optional-data list's encoder begin hook sets the count as well; its
+decoder never fills it. Once a begin hook
 has succeeded its end hook runs, so that it can release what begin
 took; the end hook receives the running success flag.
 
diff --git a/tools/net/sunrpc/xdrgen/generators/struct.py b/tools/net/sunrpc/xdrgen/generators/struct.py
index 41030403b759..945b9c36a701 100644
--- a/tools/net/sunrpc/xdrgen/generators/struct.py
+++ b/tools/net/sunrpc/xdrgen/generators/struct.py
@@ -178,6 +178,27 @@ def emit_struct_member_decoder(
             )
         )
         return
+    if isinstance(field, _XdrOptionalData) and (
+        (struct_name, field.name) in aggregate_members
+    ):
+        if peer != "server":
+            raise NotImplementedError(
+                "pragma aggregate is server-side only; "
+                + peer
+                + " generation is not yet supported"
+            )
+        template = get_jinja2_template(environment, "decoder", "aggregate_optional")
+        print(
+            template.render(
+                name=field.name,
+                type=field.spec.type_name,
+                c_type=kernel_c_type(field.spec),
+                classifier=field.spec.c_classifier,
+                hook=aggregate_hook_base(struct_name),
+                member_sym=aggregate_member_symbol(struct_name, field.name),
+            )
+        )
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "decoder", field.template)
         print(
@@ -285,6 +306,27 @@ def emit_struct_member_encoder(
             )
         )
         return
+    if isinstance(field, _XdrOptionalData) and (
+        (struct_name, field.name) in aggregate_members
+    ):
+        if peer != "server":
+            raise NotImplementedError(
+                "pragma aggregate is server-side only; "
+                + peer
+                + " generation is not yet supported"
+            )
+        template = get_jinja2_template(environment, "encoder", "aggregate_optional")
+        print(
+            template.render(
+                name=field.name,
+                type=field.spec.type_name,
+                c_type=kernel_c_type(field.spec),
+                classifier=field.spec.c_classifier,
+                hook=aggregate_hook_base(struct_name),
+                member_sym=aggregate_member_symbol(struct_name, field.name),
+            )
+        )
+        return
     if (struct_name, field.name) in pages_members:
         if peer != "server":
             raise NotImplementedError(
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
new file mode 100644
index 000000000000..add4813aa803
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
@@ -0,0 +1,31 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{# Placeholder: cannot decode value-follows framing, because the
+   element decoder does not report presence. #}
+{% if annotate %}
+	/* member {{ name }} (aggregate list) */
+{% endif %}
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = {{ member_sym }},
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!{{ hook }}_decode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; cursor.index < cursor.count; cursor.index++) {
+			{{ classifier }}{{ c_type }} element = {};
+
+			if (!xdrgen_decode_{{ type }}(xdr, &element)) {
+				ok = false;
+				break;
+			}
+			if (!{{ hook }}_decode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (!{{ hook }}_decode_end(&cursor, ok) || !ok)
+			return false;
+	}
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2
new file mode 100644
index 000000000000..d45b823225f7
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2
@@ -0,0 +1,31 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (aggregate list) */
+{% endif %}
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = {{ member_sym }},
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!{{ hook }}_encode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; cursor.index < cursor.count; cursor.index++) {
+			{{ classifier }}{{ c_type }} element = {};
+
+			if (!{{ hook }}_encode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+			if (!xdrgen_encode_{{ type }}(xdr, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (ok && !xdrgen_encode_{{ type }}(xdr, NULL))
+			ok = false;
+		if (!{{ hook }}_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index 680a87e3bb39..1fbfae49e0cd 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -1207,12 +1207,14 @@ def check_aggregate_directives(root: "Specification") -> None:
                     meta,
                 )
             field = fields[marked[1]]
-            # Only the counted-array framing is generated, so any other
-            # member form would emit hook prototypes that nothing calls.
-            if not isinstance(field, _XdrVariableLengthArray):
+            # Any other member form would emit hook prototypes that
+            # nothing calls.
+            if not isinstance(
+                field, (_XdrVariableLengthArray, _XdrOptionalData)
+            ):
                 raise XdrSemanticError(
-                    f"'{value.name}.{marked[1]}' is not a variable-length"
-                    " array",
+                    f"'{value.name}.{marked[1]}' is neither a"
+                    " variable-length array nor an optional-data list",
                     meta,
                 )
             if element_type is None:
-- 
2.55.0

