Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 902F250AC37
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:51:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540663; cv=none; b=eO/Fpk8APVXhoJo9oNbhG3GZt1/N0GcBbyDORcm7fSSuCN1dOSygxZbRe/yi0ox1O90+IihQtRqw8Rabe5JpR8BbLtXcmZhk+a0vENXqAnfsl8dUwO1Lsa/v8qz6wk5LI1yaOBua8ZDIxNgT8w+KYKkRg9Pz+x1jKHrAa4IYyoI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540663; c=relaxed/simple;
	bh=XW8eM11mMhc8AFyD6TFCppOd2YssBpv/vORbs252a8U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iLFyEMMtwa8h54j8xfPYTQWu6bdzFK/zL3FV/Osh1Un85866G7g2F1r6F1/D/JQl9RRb38MZLw3coa/OjVnosw5WbQF6EwI4vmcR2MjJ/VvULSam6EnToI0ZhNp7YU2bTsVtL6nTH448WwoPuNN7PtNtDN+l6Y9E3igpELDhlYs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kf0ai0+N; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kf0ai0+N"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E8E621F00A3E;
	Fri,  4 Sep 2026 16:51:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540661;
	bh=edOZlu8v2OB/NK0z6CqgdGrmp24owrIdMGSps6zPAHU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kf0ai0+NH4SwwCmvifPFxbzEQQ866dHUSvEzh6d2EXa9g7S9T6nrTJO4CT8TRAQ1J
	 qcv3mfFhQvyPKRwmbhtt9PQ9Vq7d8olWlgsd/BiGxxFuZ7ok/GWyDx/VKq88WNB38B
	 mi/HdEVGoGgAqXaesioYsPdqjhr8l1TbD4fjQX8w/9CXopH46lP8zW1/6gw4XsmhYh
	 u61N/g3YErETGxzgk7Jb/Cngo6+XNrtqlyrsUZLmawwysUV6syOR2+Y128s5Lc+afF
	 9smCj+lLLqfDMtGZUWwYoy9L0x3aC5e9ydLEG/M6xDcDk1mEN0r34bu3Q5vC4/wy9Q
	 s+VCgXyFpfT4A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 09/10] xdrgen: Extend the aggregate codec to optional-data list members
Date: Fri,  4 Sep 2026 12:50:51 -0400
Message-ID: <20260904165052.153327-10-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260904165052.153327-1-cel@kernel.org>
References: <20260904165052.153327-1-cel@kernel.org>
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
 tools/net/sunrpc/xdrgen/README                | 35 +++++++---
 tools/net/sunrpc/xdrgen/generators/struct.py  | 42 +++++++++++
 .../C/struct/decoder/aggregate_optional.j2    | 31 +++++++++
 .../C/struct/encoder/aggregate_optional.j2    | 31 +++++++++
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 69 ++++++++++++++-----
 5 files changed, 180 insertions(+), 28 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2

diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 6044fca0c4ee..15c6f6b0762a 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -163,13 +163,26 @@ wasted work. This directive marks such a member so that xdrgen emits a
 codec that owns only the wire framing (the length prefix, the bound
 check, and the per-element codec) and drives the application
 through begin/item/end hooks, processing one element at a time with
-no staged array. The marked member must be a variable-length
-array member of a struct; xdrgen rejects a directive naming
-anything else, and generates the codec for the server side only.
-The generated decoder hands each element to the ordinary element
-decoder from a local variable, so the element type may not contain
-a variable-length array or an optional-data member at any depth;
-xdrgen rejects a directive whose element type does.
+no staged array. The marked member must be a struct member
+declared either as a variable-length array or as an optional-data
+list ("type *name"); xdrgen rejects a directive naming anything
+else, and generates the codec for the server side only.
+
+The two forms differ only in framing. A variable-length array
+carries a u32 element count, so the framing writes that count and
+bound-checks it. Its generated decoder hands each element to the
+ordinary element decoder from a local variable, so the element
+type may not contain a variable-length array or an optional-data
+member at any depth; xdrgen rejects a directive whose element type
+does. An optional-data list carries no count: each
+element is prefixed by a value-follows TRUE and the sequence is
+closed by a FALSE, which the framing writes after the last
+element. The element type must therefore be a pointer type, whose
+codec owns that framing; xdrgen rejects any other element type.
+For the optional-data form xdrgen generates a working
+encoder only; the decoder it emits does not decode the list, so
+xdrgen also rejects the directive when the struct is reachable
+from an RPC argument.
 
 For example:
 
@@ -189,9 +202,11 @@ member:
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
index 5fcbbfaf1522..4a259cbec1cc 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -1335,28 +1335,61 @@ def check_aggregate_directives(root: "Specification") -> None:
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
-            # The generated decoder hands each element to the ordinary
-            # element decoder from a zero-filled local, so a nested
-            # variable-length array or optional-data member, which that
-            # decoder fills through a pointer the caller was to supply,
-            # would be written through NULL.
-            nested = _unsized_member(field.spec.type_name, named_types, set())
-            if nested is not None:
-                raise XdrSemanticError(
-                    f"'{value.name}.{marked[1]}' has element type"
-                    f" '{field.spec.type_name}', which reaches the"
-                    f" variable-length or optional-data member '{nested}';"
-                    " the aggregate decoder has no storage for it",
-                    meta,
+            if isinstance(field, _XdrVariableLengthArray):
+                # The generated decoder hands each element to the
+                # ordinary element decoder from a zero-filled local, so
+                # a nested variable-length array or optional-data
+                # member, which that decoder fills through a pointer
+                # the caller was to supply, would be written through
+                # NULL.
+                nested = _unsized_member(
+                    field.spec.type_name, named_types, set()
                 )
+                if nested is not None:
+                    raise XdrSemanticError(
+                        f"'{value.name}.{marked[1]}' has element type"
+                        f" '{field.spec.type_name}', which reaches the"
+                        f" variable-length or optional-data member"
+                        f" '{nested}'; the aggregate decoder has no"
+                        " storage for it",
+                        meta,
+                    )
+            else:
+                # The optional-data encoder passes each element by
+                # address and closes the list by encoding NULL, so the
+                # element codec must be one that takes a pointer and
+                # writes the value-follows framing itself.
+                if not isinstance(
+                    named_types.get(field.spec.type_name), _XdrPointer
+                ):
+                    raise XdrSemanticError(
+                        f"'{value.name}.{marked[1]}' has element type"
+                        f" '{field.spec.type_name}', which is not a pointer"
+                        " type; an optional-data aggregate needs an element"
+                        " codec that writes the value-follows framing",
+                        meta,
+                    )
+                # The emitted optional-data decoder is a placeholder
+                # that consumes nothing, so an argument type carrying
+                # one would decode its later members from the wrong
+                # stream position.
+                if value.name in argument_types:
+                    raise XdrSemanticError(
+                        f"'{value.name}' is reachable from an RPC argument,"
+                        f" and the optional-data aggregate '{marked[1]}'"
+                        " cannot be decoded",
+                        meta,
+                    )
             if element_type is None:
                 element_type = field.spec.type_name
             elif field.spec.type_name != element_type:
-- 
2.55.0

