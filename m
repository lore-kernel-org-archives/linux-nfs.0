Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0BC52D8762
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 13:42:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788874984; cv=none; b=mvRomFPcvsK4232LxCf6DA8+gPhn/9gBKjbBNlWN4d0vY9eggq0BdE8qRWciMmtb/xCCIjwE13IvhAiuFXhPEFxU6pdekPtnFQ67B45HDYIk+4Qo5C0qwBDpdJhoNToRt8KLmB1+4LdW3WPjs7V2nJt1hDbXJqKd/QWrd3nKNAs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788874984; c=relaxed/simple;
	bh=5MHgrJOnusHCcZwKrBn55aFxwHkpC1yJCRRW31Ku/LM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RT6qGkDjM7Fl3p5ScUmOe63EaEE+Osgfodu+yDP3pWqbLacjZmZKJNCJHnKtHqkN/WeU5oehAkX4ecivE+cy6KeZeH2M+6kG65D0J+lSKKoQfnMguRFE9ElHuoPC3Fs7v7rP8gF3brsu/14TnY6VMwK1UoL5M2RSCG5Tan3ND9g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9EA7B1F00ADE;
	Tue,  8 Sep 2026 13:42:44 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 09/10] xdrgen: Extend the aggregate codec to optional-data list members
Date: Tue,  8 Sep 2026 09:42:33 -0400
Message-ID: <20260908134234.512312-10-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260908134234.512312-1-cel@kernel.org>
References: <20260908134234.512312-1-cel@kernel.org>
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

The generated decoder fails outright. Decoding a value-follows list
needs a presence-reporting element decoder, which this change does
not add, and a decoder that consumed nothing would leave the stream
at the list data for the next member to misread. NFSv2 READDIR only
encodes its entry list, so the decode path is never exercised.

Signed-off-by: Chuck Lever <cel@kernel.org>
Acked-by: Jeff Layton <jlayton@kernel.org>
---
 tools/net/sunrpc/xdrgen/README                | 42 ++++++---
 tools/net/sunrpc/xdrgen/generators/struct.py  | 48 ++++++++++
 .../C/struct/decoder/aggregate_optional.j2    | 10 +++
 .../C/struct/encoder/aggregate_optional.j2    | 31 +++++++
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 88 +++++++++++++------
 5 files changed, 177 insertions(+), 42 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2

diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 8718762290d2..2e230c43de2f 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -163,17 +163,29 @@ wasted work. This directive marks such a member so that xdrgen emits a
 codec that owns only the wire framing (the length prefix, the bound
 check, and the per-element codec) and drives the application
 through begin/item/end hooks, processing one element at a time with
-no staged array. The marked member must be a variable-length
-array member of a struct; xdrgen rejects a directive naming
-anything else, and generates the codec for the server side only.
-The generated decoder hands each element to the ordinary element
-decoder from a local variable, so the element type may not contain
-a variable-length array or an optional-data member at any depth;
-xdrgen rejects a directive whose element type does. The array must
-declare a maximum size: the decoder hands the wire count to the
-begin hook before it decodes any element, and only the declared
-bound limits that count. xdrgen rejects a directive naming an
-unbounded array.
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
+does. The array must declare a maximum size: the decoder hands the
+wire count to the begin hook before it decodes any element, and
+only the declared bound limits that count. xdrgen rejects a
+directive naming an unbounded array. An optional-data list carries
+no count: each element is prefixed by a value-follows TRUE and the
+sequence is closed by a FALSE, which the framing writes after the
+last element. The element type must therefore be a pointer type,
+whose codec owns that framing; xdrgen rejects any other element
+type. For the optional-data form xdrgen generates a working
+encoder only; the decoder it emits fails without consuming the
+list, so xdrgen also rejects the directive when the struct is
+reachable from an RPC argument.
 
 For example:
 
@@ -193,9 +205,11 @@ member:
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
index 41030403b759..e703a75fa27d 100644
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
@@ -251,6 +272,12 @@ def emit_struct_decoder(
 
     for field in node.fields:
         emit_struct_member_decoder(environment, field, node.name, peer)
+        # The optional-data aggregate decoder fails and closes the
+        # function; the members after it are never decoded.
+        if isinstance(field, _XdrOptionalData) and (
+            (node.name, field.name) in aggregate_members
+        ):
+            return
 
     template = get_jinja2_template(environment, "decoder", "close")
     print(template.render())
@@ -285,6 +312,27 @@ def emit_struct_member_encoder(
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
index 000000000000..4837482daac7
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_optional.j2
@@ -0,0 +1,10 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{# The element decoder does not report presence, so the value-follows
+   framing cannot be decoded. Failing here keeps a caller from decoding
+   the members that follow from the list's own data. This closes the
+   function, so the struct decoder emits nothing after it. #}
+{% if annotate %}
+	/* member {{ name }} (aggregate list): not decodable */
+{% endif %}
+	return false;
+}
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
index 324ebc9d473e..2d51add317f7 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -1352,38 +1352,70 @@ def check_aggregate_directives(root: "Specification") -> None:
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
-                )
-            # The decoder hands the wire count to the begin hook before
-            # any element is decoded, and a begin hook may size storage
-            # from it, so the count needs a bound the framing enforces.
-            if field.maxsize == "0":
-                raise XdrSemanticError(
-                    f"'{value.name}.{marked[1]}' declares no maximum size;"
-                    " the aggregate decoder hands the element count to"
-                    " the begin hook unbounded",
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
+                # The decoder hands the wire count to the begin hook
+                # before any element is decoded, and a begin hook may
+                # size storage from it, so the count needs a bound the
+                # framing enforces.
+                if field.maxsize == "0":
+                    raise XdrSemanticError(
+                        f"'{value.name}.{marked[1]}' declares no maximum"
+                        " size; the aggregate decoder hands the element"
+                        " count to the begin hook unbounded",
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
+                # The emitted optional-data decoder fails outright, so
+                # an argument type carrying one could never be decoded.
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

