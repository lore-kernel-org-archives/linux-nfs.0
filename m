Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94C134C8FE9
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 15:03:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788447841; cv=none; b=sbYRviM5h8cfdu+00/VN/U+Tl1k065amDpv9luhC2r1eVTO8tTlUoum32CdQJzw1/IzRtr934pCU0U/UpoQzs2TSkzhze27wA0lHtDzj4D5bqf/XCdtjTBrtfkIq3hQ2CBKOus3HwymjOCYxzlFVMrPXOqrZhuMG0TmvAkUWF/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788447841; c=relaxed/simple;
	bh=LxxVpqtU8yFCsz2MX6hbC52LwtiG2KVJY0YuZFd0hxw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hhKJ8Uph+Y9e8nmgCfEtkBRGapAuIFFaeEMF3vvVCV7mbQEt00+i09i2n9op4zs6f9tExwrQmpwYZAjW+fF3zAYqEwTwlI+6pcMMGF5rEqh1vPmknjGi+Q6USyZOm78yL7Rcsd9y/oKjRR7JERk8pIjEIJefHAmNbh+V9i8iles=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SxoNpSUw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SxoNpSUw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EEE231F00AC4;
	Thu,  3 Sep 2026 15:03:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788447839;
	bh=P4VU8v0OOhyn35arCwjPrNzyYJ7TjGiBg2VUtqZbclA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SxoNpSUwgh7CgHQk5rXutXYzQrZvfrlwsS5EruZW6aojDP4YVSVS+iAduHkNLxWzP
	 +n9HOWbIwJkT7MMtqN3Izmt1R+Mmnw0fRjlwF7aKLGkZmfopxHzs42i5wylBaMak09
	 ZlixGTK4AQEI24P1XqeS/haYw6VuMci7UWeTMm0ZWftvdfLYXmJYQLJhayKc9QeqLa
	 hHrYkET6DuJbYJxUQ6Nj1ceqlx6G0umZr90FqpknfuQg3T659aOLYNy4VwrcdFPwhN
	 UWO9F2R2kxy2EZ5Ohuw0WDos8kyOyJWwQVgZrUIgNz0uLodtmtYvBVAqClr2bpCQ7G
	 07VCI6jB88drw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 08/10] xdrgen: Add hook-driven aggregate codec for variable-length arrays
Date: Thu,  3 Sep 2026 11:03:49 -0400
Message-ID: <20260903150351.9572-9-cel@kernel.org>
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

A generated variable-length array codec stages the wire array
as a C array and walks it. When the in-kernel object is not that
array, building that array is wasted memory traffic. The NFS_ACLv2
secattr aclent<> list is one such case: it is a Solaris wire form of
the kernel's posix_acl. The hand-rolled codec that performs that
transform forces its containing types to keep external linkage
(pragma public), and that linkage collides at link time with the
same generated types in a sibling program.

Add a per-member "pragma aggregate <struct> <member>" directive. For
a marked member the generated code owns only the wire framing and
calls hand-written begin, item, and end hooks that handle one
element at a time. Interior codec signatures do not change.

The framing-owned loop follows xdr_encode_array2(), whose only
remaining user is fs/nfs_common/nfsacl.c, and seq_file's
start/show/stop, where a guaranteed stop() releases what start()
took. Those APIs take an ops vtable because one loop serves
consumers chosen at run time. Here the consumer is known at
generation time, so the hooks bind by name at link time, as the
ASN.1 compiler's actions do. A missing hook is a link error, the
emitted prototypes enforce the element type, and no indirect call
is added per element.

The item hooks return only success or failure, with no early "no
more elements" return, so that the same hook contract can later
frame the RFC 4506 optional-data idiom, where the application
pushes entries into generated framing.

The front end resolves each marker against the specification and
reports one it cannot honor against its own source position, rather
than degrading silently to the array-walking codec or surfacing as a
traceback from whichever emitter reached it. Absent the marker the
generator emits byte-identical output.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xdrgen/_defs.h           | 19 ++++
 tools/net/sunrpc/xdrgen/README                | 60 ++++++++++++-
 tools/net/sunrpc/xdrgen/generators/struct.py  | 89 ++++++++++++++++++-
 tools/net/sunrpc/xdrgen/grammars/xdr.lark     |  2 +
 .../C/struct/declaration/aggregate_hooks.j2   | 14 +++
 .../C/struct/decoder/aggregate_array.j2       | 35 ++++++++
 .../C/struct/encoder/aggregate_array.j2       | 39 ++++++++
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 80 +++++++++++++++++
 8 files changed, 335 insertions(+), 3 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/declaration/aggregate_hooks.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_array.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_array.j2

diff --git a/include/linux/sunrpc/xdrgen/_defs.h b/include/linux/sunrpc/xdrgen/_defs.h
index 1e183b9d1c1d..f4375d73c5ca 100644
--- a/include/linux/sunrpc/xdrgen/_defs.h
+++ b/include/linux/sunrpc/xdrgen/_defs.h
@@ -29,6 +29,25 @@ typedef struct {
 	u8 *data;
 } opaque;
 
+/*
+ * Cursor a hook-driven aggregate codec hands to its application hooks,
+ * one element at a time, in place of a materialized C array. The
+ * generated framing owns it. @xdr is the RPC layer's stream; @ctx is
+ * that stream's xdrgen_ctx, the svc_rqst on the server. @index is
+ * the current element and @count the wire array length: a decoder
+ * fills @count from the wire before the begin hook runs, an
+ * encoder's begin hook sets it. @member_id selects among a type's
+ * marked members. The begin/item/end contract is under "Pragma
+ * aggregate" in tools/net/sunrpc/xdrgen/README.
+ */
+struct xdrgen_aggregate_cursor {
+	struct xdr_stream	*xdr;
+	u32			index;
+	u32			count;
+	unsigned int		member_id;
+	void			*ctx;
+};
+
 #define XDR_void		(0)
 #define XDR_bool		(1)
 #define XDR_short		(1)
diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 40bfa1c27f04..92578671b5e9 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -147,8 +147,64 @@ Pragmas
 -------
 
 Pragma directives specify exceptions to the normal generation of
-encoding and decoding functions. Currently one directive is
-implemented: "public".
+encoding and decoding functions. The directives are described
+below.
+
+Pragma aggregate
+------ ---------
+
+  pragma aggregate <struct> <member> ;
+
+A variable-length array member is normally encoded and decoded by
+staging it in a C array and walking that array. When the application
+object is not that array -- for instance when the member is a wire
+projection of a different in-kernel structure -- building it is
+wasted work. This directive marks such a member so that xdrgen emits a
+codec that owns only the wire framing (the length prefix, the bound
+check, and the per-element codec) and drives the application
+through begin/item/end hooks, processing one element at a time with
+no staged array. The marked member must be a variable-length
+array member of a struct; xdrgen rejects a directive naming
+anything else, and generates the codec for the server side only.
+
+For example:
+
+  pragma aggregate secattr aclent;
+  pragma aggregate secattr dfaclent;
+
+The hooks are supplied by hand. Their names derive from the pragma
+header and the containing struct, so that two programs sharing a
+type name resolve to distinct symbols. All marked members of one
+struct share a hook set; the cursor's member_id field selects the
+member:
+
+  nfs_acl2_secattr_encode_begin()
+  nfs_acl2_secattr_encode()
+  nfs_acl2_secattr_encode_end()
+  nfs_acl2_secattr_decode_begin()
+  nfs_acl2_secattr_decode()
+  nfs_acl2_secattr_decode_end()
+
+A decoder fills the cursor's count from the wire before calling the
+begin hook; an encoder's begin hook sets that count, and the framing
+then bound-checks it and emits the length prefix. Once a begin hook
+has succeeded its end hook runs, so that it can release what begin
+took; the end hook receives the running success flag.
+
+For each marked member xdrgen emits an enumeration constant -- the
+pragma header, struct, and member joined by underscores and
+upper-cased -- in the generated header, and the generated framing
+initializes the cursor's member_id with it. The hooks compare
+member_id against these constants rather than bare integers:
+
+  NFS_ACL2_SECATTR_ACLENT
+  NFS_ACL2_SECATTR_DFACLENT
+
+The hooks reach their application state through the xdr_stream's
+xdrgen_ctx pointer: svcxdr_init_decode() and svcxdr_init_encode()
+bind it to the svc_rqst, and the generated framing copies it into
+the cursor's ctx field, from which a hook reaches rq_argp or
+rq_resp. xdrgen emits the hook prototypes in the generated header.
 
 Pragma big_endian
 ------ ----------
diff --git a/tools/net/sunrpc/xdrgen/generators/struct.py b/tools/net/sunrpc/xdrgen/generators/struct.py
index e71f8126806d..41030403b759 100644
--- a/tools/net/sunrpc/xdrgen/generators/struct.py
+++ b/tools/net/sunrpc/xdrgen/generators/struct.py
@@ -12,15 +12,58 @@ from xdr_ast import _XdrBasic, _XdrString
 from xdr_ast import _XdrFixedLengthOpaque, _XdrVariableLengthOpaque
 from xdr_ast import _XdrFixedLengthArray, _XdrVariableLengthArray
 from xdr_ast import _XdrOptionalData, _XdrStruct, _XdrDeclaration
-from xdr_ast import public_apis, get_header_name
+from xdr_ast import public_apis, get_header_name, aggregate_members
 from xdr_ast import pages_members, pages_member_maxsize, pages_member_is_decoded
 
 
+def aggregate_hook_base(struct_name: str) -> str:
+    """Return the application hook base name for a struct's aggregate members.
+
+    The pragma header name prefixes it so two programs that share a
+    type name (nfs_acl2 vs nfs_acl3) derive distinct external hook
+    symbols. All marked members of one struct share a hook set; the
+    cursor's member_id tells them apart.
+    """
+    return "_".join((get_header_name(), struct_name))
+
+
+def aggregate_member_symbol(struct_name: str, member_name: str) -> str:
+    """Return the symbolic member id for one marked aggregate member.
+
+    The generated framing sets the cursor's member_id to this constant
+    and the hooks compare against it. The enum in aggregate_hooks.j2
+    assigns the values implicitly in field order, so a hook that
+    compared against the bare integer would silently bind to the
+    wrong member once the specification's members were reordered.
+    """
+    return "_".join((aggregate_hook_base(struct_name), member_name)).upper()
+
+
 def emit_struct_declaration(environment: Environment, node: _XdrStruct) -> None:
     """Emit one declaration pair for an XDR struct type"""
     if node.name in public_apis:
         template = get_jinja2_template(environment, "declaration", "close")
         print(template.render(name=node.name))
+    marked = [
+        field
+        for field in node.fields
+        if (node.name, field.name) in aggregate_members
+    ]
+    if marked:
+        template = get_jinja2_template(
+            environment, "declaration", "aggregate_hooks"
+        )
+        print(
+            template.render(
+                hook=aggregate_hook_base(node.name),
+                c_type=kernel_c_type(marked[0].spec),
+                classifier=marked[0].spec.c_classifier,
+                members=[
+                    aggregate_member_symbol(node.name, field.name)
+                    for field in marked
+                ],
+            )
+        )
 
 
 def emit_struct_member_definition(
@@ -113,6 +156,28 @@ def emit_struct_member_decoder(
             )
         )
         return
+    if isinstance(field, _XdrVariableLengthArray) and (
+        (struct_name, field.name) in aggregate_members
+    ):
+        if peer != "server":
+            raise NotImplementedError(
+                "pragma aggregate is server-side only; "
+                + peer
+                + " generation is not yet supported"
+            )
+        template = get_jinja2_template(environment, "decoder", "aggregate_array")
+        print(
+            template.render(
+                name=field.name,
+                type=field.spec.type_name,
+                c_type=kernel_c_type(field.spec),
+                classifier=field.spec.c_classifier,
+                maxsize=field.maxsize,
+                hook=aggregate_hook_base(struct_name),
+                member_sym=aggregate_member_symbol(struct_name, field.name),
+            )
+        )
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "decoder", field.template)
         print(
@@ -198,6 +263,28 @@ def emit_struct_member_encoder(
     peer: str,
 ) -> None:
     """Emit an encoder for one field in an XDR struct"""
+    if isinstance(field, _XdrVariableLengthArray) and (
+        (struct_name, field.name) in aggregate_members
+    ):
+        if peer != "server":
+            raise NotImplementedError(
+                "pragma aggregate is server-side only; "
+                + peer
+                + " generation is not yet supported"
+            )
+        template = get_jinja2_template(environment, "encoder", "aggregate_array")
+        print(
+            template.render(
+                name=field.name,
+                type=field.spec.type_name,
+                c_type=kernel_c_type(field.spec),
+                classifier=field.spec.c_classifier,
+                maxsize=field.maxsize,
+                hook=aggregate_hook_base(struct_name),
+                member_sym=aggregate_member_symbol(struct_name, field.name),
+            )
+        )
+        return
     if (struct_name, field.name) in pages_members:
         if peer != "server":
             raise NotImplementedError(
diff --git a/tools/net/sunrpc/xdrgen/grammars/xdr.lark b/tools/net/sunrpc/xdrgen/grammars/xdr.lark
index 1d2afff98ac5..64cd73df412c 100644
--- a/tools/net/sunrpc/xdrgen/grammars/xdr.lark
+++ b/tools/net/sunrpc/xdrgen/grammars/xdr.lark
@@ -100,6 +100,7 @@ directive               : big_endian_directive
                         | pages_directive
                         | public_directive
                         | skip_directive
+                        | aggregate_directive
 
 big_endian_directive    : "big_endian"
 exclude_directive       : "exclude"
@@ -107,6 +108,7 @@ header_directive        : "header"
 pages_directive         : "pages"
 public_directive        : "public"
 skip_directive          : "skip"
+aggregate_directive     : "aggregate"
 
 //
 // XDR language primitives
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/declaration/aggregate_hooks.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/declaration/aggregate_hooks.j2
new file mode 100644
index 000000000000..b8b2b0766f8a
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/declaration/aggregate_hooks.j2
@@ -0,0 +1,14 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+
+enum {
+{% for member in members %}
+	{{ member }},
+{% endfor %}
+};
+
+bool {{ hook }}_encode_begin(struct xdrgen_aggregate_cursor *c);
+bool {{ hook }}_encode(struct xdrgen_aggregate_cursor *c, {{ classifier }}{{ c_type }} *out);
+bool {{ hook }}_encode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+bool {{ hook }}_decode_begin(struct xdrgen_aggregate_cursor *c);
+bool {{ hook }}_decode(struct xdrgen_aggregate_cursor *c, const {{ classifier }}{{ c_type }} *in);
+bool {{ hook }}_decode_end(struct xdrgen_aggregate_cursor *c, bool ok);
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_array.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_array.j2
new file mode 100644
index 000000000000..9550e9cef30d
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/aggregate_array.j2
@@ -0,0 +1,35 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (aggregate array) */
+{% endif %}
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = {{ member_sym }},
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (xdr_stream_decode_u32(xdr, &cursor.count) < 0)
+			return false;
+{% if maxsize != "0" %}
+		if (cursor.count > {{ maxsize }})
+			return false;
+{% endif %}
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
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_array.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_array.j2
new file mode 100644
index 000000000000..1fccd1771bd3
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_array.j2
@@ -0,0 +1,39 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (aggregate array) */
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
+{% if maxsize != "0" %}
+		if (cursor.count > {{ maxsize }})
+			ok = false;
+{% endif %}
+		if (ok && xdr_stream_encode_u32(xdr, cursor.count) != XDR_UNIT)
+			ok = false;
+		for (cursor.index = 0; ok && cursor.index < cursor.count; cursor.index++) {
+			{{ classifier }}{{ c_type }} element = {};
+
+			if (!{{ hook }}_encode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+{% if type in pass_by_reference %}
+			if (!xdrgen_encode_{{ type }}(xdr, &element)) {
+{% else %}
+			if (!xdrgen_encode_{{ type }}(xdr, element)) {
+{% endif %}
+				ok = false;
+				break;
+			}
+		}
+		if (!{{ hook }}_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index c50c738ea131..680a87e3bb39 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -19,6 +19,15 @@ public_apis = []
 structs = set()
 pass_by_reference = set()
 
+# (type_name, member_name) pairs whose variable-length array member is
+# marked "pragma aggregate" -- codec emission streams the member through
+# application hooks instead of iterating a materialized C array.
+aggregate_members = set()
+
+# Source position of each "pragma aggregate" marker, so a directive
+# that cannot be honored is reported where it was written.
+aggregate_member_meta = {}
+
 # (type_name, member_name) pairs marked "pragma pages": the member's
 # content resides in the pages of the Receive or Reply buffer, so
 # the emitted codec captures or inserts those pages by reference
@@ -849,6 +858,15 @@ class ParseToAst(Transformer):
                 header_name = children[1].symbol
             case "public_directive":
                 public_apis.append(children[1].symbol)
+            case "aggregate_directive":
+                if children[2] is None:
+                    raise XdrSemanticError(
+                        "pragma aggregate requires a type name and a member name",
+                        children[1],
+                    )
+                marked = (children[1].symbol, children[2].symbol)
+                aggregate_members.add(marked)
+                aggregate_member_meta[marked] = children[2]
             case "pages_directive":
                 if children[2] is None:
                     raise XdrSemanticError(
@@ -1155,6 +1173,67 @@ def check_pages_directives(root: "Specification") -> None:
         )
 
 
+def check_aggregate_directives(root: "Specification") -> None:
+    """Reject a "pragma aggregate" directive that cannot be honored.
+
+    As with the pages checks, this runs in the front end so a directive
+    naming a missing type or member, or a member with no hook-driven
+    codec, is reported at its own source position. Left to the
+    emitters, an unbound directive would degrade silently to the
+    materializing codec, and a malformed one would surface as a
+    traceback from whichever emitter reached it.
+    """
+    if aggregate_members and header_name == "none":
+        raise XdrSemanticError(
+            "pragma aggregate derives its external hook symbols from the"
+            " pragma header name, which this specification does not set",
+            aggregate_member_meta.get(min(aggregate_members)),
+        )
+
+    resolved = set()
+    for definition in root.definitions:
+        value = definition.value
+        if not isinstance(value, _XdrStruct):
+            continue
+        fields = dict((field.name, field) for field in value.fields)
+        element_type = None
+        for marked in sorted(aggregate_members):
+            if marked[0] != value.name:
+                continue
+            meta = aggregate_member_meta.get(marked)
+            if marked[1] not in fields:
+                raise XdrSemanticError(
+                    f"type '{value.name}' has no member '{marked[1]}'",
+                    meta,
+                )
+            field = fields[marked[1]]
+            # Only the counted-array framing is generated, so any other
+            # member form would emit hook prototypes that nothing calls.
+            if not isinstance(field, _XdrVariableLengthArray):
+                raise XdrSemanticError(
+                    f"'{value.name}.{marked[1]}' is not a variable-length"
+                    " array",
+                    meta,
+                )
+            if element_type is None:
+                element_type = field.spec.type_name
+            elif field.spec.type_name != element_type:
+                raise XdrSemanticError(
+                    f"'{value.name}.{marked[1]}' has element type"
+                    f" '{field.spec.type_name}', but '{value.name}' already"
+                    f" marks a member of element type '{element_type}';"
+                    " one hook set serves all of a type's marked members",
+                    meta,
+                )
+            resolved.add(marked)
+
+    for marked in sorted(aggregate_members - resolved):
+        raise XdrSemanticError(
+            f"pragma aggregate names unknown struct '{marked[0]}'",
+            aggregate_member_meta.get(marked),
+        )
+
+
 def _referenced_type_names(value) -> set:
     """Return the type names an aggregate references through its
     members."""
@@ -1214,6 +1293,7 @@ def transform_parse_tree(parse_tree):
     # the nested aggregates before the directives are validated.
     _expand_argument_types(ast)
     check_pages_directives(ast)
+    check_aggregate_directives(ast)
     return ast
 
 
-- 
2.55.0

