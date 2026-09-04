Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 530EF50AC39
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:50:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540660; cv=none; b=C2utadt/tXtE+aAbLV7DRVvOAROqdQ9bdcyYVCV4dp46SS3i2nTs6hRcm9y7zUsHZJh2oFwAWvUvdMbwcWGG1rpQpQVbWEGm7B68+z55YMq6A1KnQAkJB5sxjIzkFsuCUXjfVO9Qs2/+74ILWc6EdPS7qa27R5WxftpYoD40hZY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540660; c=relaxed/simple;
	bh=XIlM3dX3eiXYwVhhwxbWEGy36b2Adq0o5HBBKqwwKtw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LppBCpPUrrshnA3XHsWsX9kVC0szaM+MOEcs2lX7q2XIctbRtZeFA8mSquF6wM1T3W6o7lR1v3Q8jYyJcZ2zBaXHh1bQ1JJ81KBHId/1HoupNO5roroKozuFlBHZD2+NJ3V6wpe1MfHflRJJ3qv0aaY1fAbkh++xSmddHaMjgRY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F7hxqj9A; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F7hxqj9A"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9DE0F1F00AC4;
	Fri,  4 Sep 2026 16:50:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540658;
	bh=/LLhER6eLxxsNe88ULEAzwPXRgYoE1WD71992yyP9SE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=F7hxqj9AqAzqKanGoq641SnDxamCef93FkRpmV50LwRcIErQmuS4/5dVxnGRmUs68
	 rWNaYFYRPIRzoW5Z17VDr2Aj0AfRvvvYRpcPkmnIzAy/knOxNcDEKz4yD3x94SWHMM
	 HY2BwO4ia8N3ojCSCgHXccXhEneu9pVt1oSyS4IsLIgehpBDKPlSpDoi/psxn9bf7B
	 QPpiP8RoUzBCuW717y+iQjms6Dm6jYvFVl1oEHLYo5L8z0eLi1P+XDj76NJ7pwP/J5
	 7bDRxXchfedixQibyJrEn4U9EVQvsKTAIWIsht+i8KWSBZuaUmGcnmSkD3YVR+UZjF
	 jIdg71BifbU9A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 05/10] xdrgen: Add a "pragma pages" directive
Date: Fri,  4 Sep 2026 12:50:47 -0400
Message-ID: <20260904165052.153327-6-cel@kernel.org>
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

The generated encoder for a variable-length opaque or string
member copies its content into the Reply buffer via
xdr_stream_encode_opaque(). A bulk payload such as an NFS READ
result never resides at the member's data pointer: the server
deposits it directly in the pages of the Reply buffer. Until now
the containing procedure encoder had to be hand-rolled.

Add a per-member directive that makes the emitted encoder call
svcxdr_encode_opaque_payload() for the marked member. The README
documents its syntax and the members it may name. Beyond the
struct and union cases described there, the directive also applies
to a member of a self-referential struct, which xdrgen generates
as an XDR pointer type.

A directive that binds to nothing would degrade silently to the
copying encoder, so the front end rejects one that names an
undeclared type or member, or a member that cannot carry a
payload. It also rejects a second marked member of the same type,
and a type whose members reach more than one marked member:
svcxdr_encode_opaque_payload() consumes the whole page vector and
moves the stream into the tail, so one encoder carries at most one
payload.

Generated code is unchanged until a specification applies the
directive.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/README                |  42 +++-
 tools/net/sunrpc/xdrgen/generators/pointer.py |  25 ++-
 tools/net/sunrpc/xdrgen/generators/struct.py  |  23 +-
 tools/net/sunrpc/xdrgen/generators/union.py   |  69 ++++--
 .../C/pointer/encoder/pages_opaque.j2         |  10 +
 .../C/struct/encoder/pages_opaque.j2          |  10 +
 .../templates/C/union/encoder/pages_opaque.j2 |  10 +
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 205 ++++++++++++++++++
 8 files changed, 372 insertions(+), 22 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/encoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/union/encoder/pages_opaque.j2

diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 2cf05d1e4cd9..5af9cf506637 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -230,6 +230,43 @@ Adds these prototypes in the generated header:
 And, in the generated source code, both of these functions appear
 without the "static __maybe_unused" modifiers.
 
+Pragma pages
+------ -----
+
+  pragma pages <type> <member> ;
+
+A variable-length opaque or string member is normally encoded by
+copying its content into the Reply buffer. When the member carries
+a bulk payload that a server-side read operation has already
+deposited in the pages of the Reply buffer, that copy is wasted
+work, and it prevents a transport capable of direct data placement
+from conveying the payload separately from the rest of the Reply.
+This directive marks such a member so that the emitted encoder
+inserts the payload pages into the encoding stream by reference and
+marks the byte range as a result payload.
+
+The marked member may be a member of a struct or an arm of a union,
+and its type may be named directly or reached through a typedef. A
+union arm declared directly as a string is the one exception: xdrgen
+generates such an arm as a char *, which carries no length field, so
+the directive is rejected there and the arm has to be declared
+through a typedef. For example:
+
+  pragma pages READ3resok data;
+  pragma pages readlinkres data;
+
+The first marks the opaque data member of struct READ3resok; the
+second marks the path arm of union readlinkres, where path is
+"typedef string path<NFS_MAXPATHLEN>".
+
+The emitted encoder reads only the marked member's length field to
+determine how many octets of page content to insert; the member's
+data pointer is not read. The server and client manage payload
+pages differently, so this directive applies only to server-side
+code generation, and so far only to the encoding direction.
+Decode-side handling of a page-resident argument (for example, the
+payload of an NFS WRITE) remains hand-coded.
+
 
 Future Work
 -----------
@@ -242,11 +279,12 @@ Expand the README into a user guide similar to rpcgen(1)
 
 Add more pragma directives:
 
-  * @pages -- use xdr_read/write_pages() for the specified opaque
-    field
   * @skip -- do not decode, but rather skip, the specified argument
     field
 
+Extend pragma pages to the decoding direction and to
+client-side code generation
+
 Enable something like a #include to dynamically insert the content
 of other specification files
 
diff --git a/tools/net/sunrpc/xdrgen/generators/pointer.py b/tools/net/sunrpc/xdrgen/generators/pointer.py
index 9a540e125786..448ebd684212 100644
--- a/tools/net/sunrpc/xdrgen/generators/pointer.py
+++ b/tools/net/sunrpc/xdrgen/generators/pointer.py
@@ -13,6 +13,7 @@ from xdr_ast import _XdrFixedLengthOpaque, _XdrVariableLengthOpaque
 from xdr_ast import _XdrFixedLengthArray, _XdrVariableLengthArray
 from xdr_ast import _XdrOptionalData, _XdrPointer, _XdrDeclaration
 from xdr_ast import public_apis, get_header_name
+from xdr_ast import pages_members, pages_member_maxsize
 
 
 def emit_pointer_declaration(environment: Environment, node: _XdrPointer) -> None:
@@ -176,8 +177,24 @@ def emit_pointer_member_encoder(
     environment: Environment,
     field: _XdrDeclaration,
     struct_name: str,
+    peer: str,
 ) -> None:
     """Emit an encoder for one field in a XDR pointer"""
+    if (struct_name, field.name) in pages_members:
+        if peer != "server":
+            raise NotImplementedError(
+                "pragma pages is server-side encode-only; "
+                + peer
+                + " generation is not yet supported"
+            )
+        template = get_jinja2_template(environment, "encoder", "pages_opaque")
+        print(
+            template.render(
+                name=field.name,
+                maxsize=pages_member_maxsize(field),
+            )
+        )
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "encoder", field.template)
         print(
@@ -239,13 +256,15 @@ def emit_pointer_member_encoder(
         )
 
 
-def emit_pointer_encoder(environment: Environment, node: _XdrPointer) -> None:
+def emit_pointer_encoder(
+    environment: Environment, node: _XdrPointer, peer: str
+) -> None:
     """Emit one encoder function for an XDR pointer type"""
     template = get_jinja2_template(environment, "encoder", "open")
     print(template.render(name=node.name))
 
     for field in node.fields[0:-1]:
-        emit_pointer_member_encoder(environment, field, node.name)
+        emit_pointer_member_encoder(environment, field, node.name, peer)
 
     template = get_jinja2_template(environment, "encoder", "close")
     print(template.render())
@@ -285,7 +304,7 @@ class XdrPointerGenerator(SourceGenerator):
 
     def emit_encoder(self, node: _XdrPointer) -> None:
         """Emit one encoder function for an XDR pointer type"""
-        emit_pointer_encoder(self.environment, node)
+        emit_pointer_encoder(self.environment, node, self.peer)
 
     def emit_maxsize(self, node: _XdrPointer) -> None:
         """Emit one maxsize macro for an XDR pointer type"""
diff --git a/tools/net/sunrpc/xdrgen/generators/struct.py b/tools/net/sunrpc/xdrgen/generators/struct.py
index 91da3863c166..76fd3afbeea0 100644
--- a/tools/net/sunrpc/xdrgen/generators/struct.py
+++ b/tools/net/sunrpc/xdrgen/generators/struct.py
@@ -13,6 +13,7 @@ from xdr_ast import _XdrFixedLengthOpaque, _XdrVariableLengthOpaque
 from xdr_ast import _XdrFixedLengthArray, _XdrVariableLengthArray
 from xdr_ast import _XdrOptionalData, _XdrStruct, _XdrDeclaration
 from xdr_ast import public_apis, get_header_name
+from xdr_ast import pages_members, pages_member_maxsize
 
 
 def emit_struct_declaration(environment: Environment, node: _XdrStruct) -> None:
@@ -176,8 +177,24 @@ def emit_struct_member_encoder(
     environment: Environment,
     field: _XdrDeclaration,
     struct_name: str,
+    peer: str,
 ) -> None:
     """Emit an encoder for one field in an XDR struct"""
+    if (struct_name, field.name) in pages_members:
+        if peer != "server":
+            raise NotImplementedError(
+                "pragma pages is server-side encode-only; "
+                + peer
+                + " generation is not yet supported"
+            )
+        template = get_jinja2_template(environment, "encoder", "pages_opaque")
+        print(
+            template.render(
+                name=field.name,
+                maxsize=pages_member_maxsize(field),
+            )
+        )
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "encoder", field.template)
         print(
@@ -239,13 +256,13 @@ def emit_struct_member_encoder(
         )
 
 
-def emit_struct_encoder(environment: Environment, node: _XdrStruct) -> None:
+def emit_struct_encoder(environment: Environment, node: _XdrStruct, peer: str) -> None:
     """Emit one encoder function for an XDR struct type"""
     template = get_jinja2_template(environment, "encoder", "open")
     print(template.render(name=node.name))
 
     for field in node.fields:
-        emit_struct_member_encoder(environment, field, node.name)
+        emit_struct_member_encoder(environment, field, node.name, peer)
 
     template = get_jinja2_template(environment, "encoder", "close")
     print(template.render())
@@ -285,7 +302,7 @@ class XdrStructGenerator(SourceGenerator):
 
     def emit_encoder(self, node: _XdrStruct) -> None:
         """Emit one encoder function for an XDR struct type"""
-        emit_struct_encoder(self.environment, node)
+        emit_struct_encoder(self.environment, node, self.peer)
 
     def emit_maxsize(self, node: _XdrStruct) -> None:
         """Emit one maxsize macro for an XDR struct type"""
diff --git a/tools/net/sunrpc/xdrgen/generators/union.py b/tools/net/sunrpc/xdrgen/generators/union.py
index d15837dae651..47d63236f88f 100644
--- a/tools/net/sunrpc/xdrgen/generators/union.py
+++ b/tools/net/sunrpc/xdrgen/generators/union.py
@@ -9,7 +9,8 @@ from generators import SourceGenerator
 from generators import create_jinja2_environment, get_jinja2_template
 
 from xdr_ast import _XdrBasic, _XdrUnion, _XdrVoid, _XdrString, get_header_name
-from xdr_ast import _XdrDeclaration, _XdrCaseSpec, public_apis, big_endian
+from xdr_ast import _XdrDeclaration, _XdrCaseSpec
+from xdr_ast import public_apis, big_endian, pages_members, pages_member_maxsize
 
 
 def emit_union_declaration(environment: Environment, node: _XdrUnion) -> None:
@@ -214,13 +215,41 @@ def emit_union_switch_spec_encoder(
     print(template.render(name=node.name, type=node.spec.type_name))
 
 
+def emit_union_pages_arm_encoder(
+    environment: Environment, union_name: str, arm: _XdrDeclaration, peer: str
+) -> bool:
+    """Emit a page-resident encoder for a "pragma pages" union arm
+
+    Return True when the arm is pages-marked and was emitted here, so
+    the caller skips the ordinary arm encoder.
+    """
+    if (union_name, arm.name) not in pages_members:
+        return False
+    if peer != "server":
+        raise NotImplementedError(
+            "pragma pages is server-side encode-only; "
+            + peer
+            + " generation is not yet supported"
+        )
+    template = get_jinja2_template(environment, "encoder", "pages_opaque")
+    print(
+        template.render(
+            name=arm.name,
+            maxsize=pages_member_maxsize(arm),
+        )
+    )
+    return True
+
+
 def emit_union_arm_encoder(
-    environment: Environment, node: _XdrCaseSpec
+    environment: Environment, node: _XdrCaseSpec, union_name: str, peer: str
 ) -> None:
     """Emit encoder for an XDR union's arm (data only, no case/break)"""
 
     if isinstance(node.arm, _XdrVoid):
         return
+    if emit_union_pages_arm_encoder(environment, union_name, node.arm, peer):
+        return
     if isinstance(node.arm, _XdrString):
         type_name = "char *"
     else:
@@ -237,7 +266,11 @@ def emit_union_arm_encoder(
 
 
 def emit_union_case_spec_encoder(
-    environment: Environment, node: _XdrCaseSpec, big_endian_discriminant: bool
+    environment: Environment,
+    node: _XdrCaseSpec,
+    big_endian_discriminant: bool,
+    union_name: str,
+    peer: str,
 ) -> None:
     """Emit encoder functions for an XDR union's case arm"""
 
@@ -254,19 +287,22 @@ def emit_union_case_spec_encoder(
     for case in node.values:
         print(template.render(case=case))
 
-    template = get_jinja2_template(environment, "encoder", node.arm.template)
-    print(
-        template.render(
-            name=node.arm.name,
-            type=type_name,
+    if not emit_union_pages_arm_encoder(environment, union_name, node.arm, peer):
+        template = get_jinja2_template(environment, "encoder", node.arm.template)
+        print(
+            template.render(
+                name=node.arm.name,
+                type=type_name,
+            )
         )
-    )
 
     template = get_jinja2_template(environment, "encoder", "break")
     print(template.render())
 
 
-def emit_union_default_spec_encoder(environment: Environment, node: _XdrUnion) -> None:
+def emit_union_default_spec_encoder(
+    environment: Environment, node: _XdrUnion, peer: str
+) -> None:
     """Emit an encoder function for an XDR union's default arm"""
     default_case = node.default
 
@@ -282,6 +318,9 @@ def emit_union_default_spec_encoder(environment: Environment, node: _XdrUnion) -
         print(template.render())
         return
 
+    if emit_union_pages_arm_encoder(environment, node.name, default_case.arm, peer):
+        return
+
     template = get_jinja2_template(environment, "encoder", default_case.arm.template)
     print(
         template.render(
@@ -291,7 +330,7 @@ def emit_union_default_spec_encoder(environment: Environment, node: _XdrUnion) -
     )
 
 
-def emit_union_encoder(environment, node: _XdrUnion) -> None:
+def emit_union_encoder(environment, node: _XdrUnion, peer: str) -> None:
     """Emit one XDR union encoder"""
     template = get_jinja2_template(environment, "encoder", "open")
     print(template.render(name=node.name))
@@ -304,7 +343,7 @@ def emit_union_encoder(environment, node: _XdrUnion) -> None:
         # Find and emit the TRUE case
         for case in node.cases:
             if case.values and case.values[0] == "TRUE":
-                emit_union_arm_encoder(environment, case)
+                emit_union_arm_encoder(environment, case, node.name, peer)
                 break
 
         template = get_jinja2_template(environment, "encoder", "close")
@@ -317,9 +356,11 @@ def emit_union_encoder(environment, node: _XdrUnion) -> None:
                 environment,
                 case,
                 node.discriminant.spec.type_name in big_endian,
+                node.name,
+                peer,
             )
 
-        emit_union_default_spec_encoder(environment, node)
+        emit_union_default_spec_encoder(environment, node, peer)
 
         template = get_jinja2_template(environment, "encoder", "close")
         print(template.render())
@@ -359,7 +400,7 @@ class XdrUnionGenerator(SourceGenerator):
 
     def emit_encoder(self, node: _XdrUnion) -> None:
         """Emit one encoder function for an XDR union"""
-        emit_union_encoder(self.environment, node)
+        emit_union_encoder(self.environment, node, self.peer)
 
     def emit_maxsize(self, node: _XdrUnion) -> None:
         """Emit one maxsize macro for an XDR union"""
diff --git a/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/pages_opaque.j2
new file mode 100644
index 000000000000..e868220a59f6
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/pointer/encoder/pages_opaque.j2
@@ -0,0 +1,10 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+{% if maxsize != "0" %}
+	if (value->{{ name }}.len > {{ maxsize }})
+		return false;
+{% endif %}
+	if (!svcxdr_encode_opaque_payload(xdr, value->{{ name }}.len))
+		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/pages_opaque.j2
new file mode 100644
index 000000000000..e868220a59f6
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/pages_opaque.j2
@@ -0,0 +1,10 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+{% if maxsize != "0" %}
+	if (value->{{ name }}.len > {{ maxsize }})
+		return false;
+{% endif %}
+	if (!svcxdr_encode_opaque_payload(xdr, value->{{ name }}.len))
+		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/union/encoder/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/union/encoder/pages_opaque.j2
new file mode 100644
index 000000000000..7fe3108a44c0
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/union/encoder/pages_opaque.j2
@@ -0,0 +1,10 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+		/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+{% if maxsize != "0" %}
+		if (ptr->u.{{ name }}.len > {{ maxsize }})
+			return false;
+{% endif %}
+		if (!svcxdr_encode_opaque_payload(xdr, ptr->u.{{ name }}.len))
+			return false;
diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index 9dab8bc545b0..044b697a55ef 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -19,6 +19,21 @@ public_apis = []
 structs = set()
 pass_by_reference = set()
 
+# (type_name, member_name) pairs marked "pragma pages": the member's
+# content resides in the pages of the Reply buffer, so the emitted
+# encoder inserts those pages by reference instead of copying.
+pages_members = set()
+
+# The same pairs, keyed to the directive's identifier node so a
+# diagnostic can point at the directive rather than at the type.
+pages_member_meta = {}
+
+# Typedefs of a variable-length opaque or string, mapped to the length
+# bound. A "pragma pages" member declared through one ("path data;"
+# with "typedef string path<NFS_MAXPATHLEN>") reaches the AST as a
+# basic type reference, so the bound must be recovered from here.
+varlen_object_typedefs = {}
+
 constants = {}
 
 
@@ -427,15 +442,34 @@ class _XdrTypedef(_XdrAst):
         return self.declaration.symbolic_width()
 
     def __post_init__(self):
+        if isinstance(self.declaration, (_XdrVariableLengthOpaque, _XdrString)):
+            varlen_object_typedefs[self.declaration.name] = self.declaration.maxsize
         if isinstance(self.declaration, _XdrBasic):
             new_type = self.declaration
             if isinstance(new_type.spec, _XdrDefinedType):
                 if new_type.spec.type_name in pass_by_reference:
                     pass_by_reference.add(new_type.name)
+                if new_type.spec.type_name in varlen_object_typedefs:
+                    varlen_object_typedefs[new_type.name] = varlen_object_typedefs[
+                        new_type.spec.type_name
+                    ]
                 max_widths[new_type.name] = self.max_width()
                 symbolic_widths[new_type.name] = self.symbolic_width()
 
 
+def pages_member_maxsize(field: _XdrDeclaration):
+    """Return the length bound of a "pragma pages" member.
+
+    Return None when FIELD is neither a variable-length opaque nor a
+    string, whether declared inline or through a typedef.
+    """
+    if isinstance(field, (_XdrVariableLengthOpaque, _XdrString)):
+        return field.maxsize
+    if isinstance(field, _XdrBasic) and field.spec.type_name in varlen_object_typedefs:
+        return varlen_object_typedefs[field.spec.type_name]
+    return None
+
+
 @dataclass
 class _XdrCaseSpec(_XdrAst):
     """One case in an XDR union"""
@@ -791,6 +825,15 @@ class ParseToAst(Transformer):
                 header_name = children[1].symbol
             case "public_directive":
                 public_apis.append(children[1].symbol)
+            case "pages_directive":
+                if children[2] is None:
+                    raise XdrSemanticError(
+                        "pragma pages requires a type name and a member name",
+                        children[1],
+                    )
+                marked = (children[1].symbol, children[2].symbol)
+                pages_members.add(marked)
+                pages_member_meta[marked] = children[2]
             case _:
                 raise NotImplementedError("Directive not supported")
         return _Pragma()
@@ -990,12 +1033,174 @@ def check_rpc_number_range(root: "Specification") -> None:
                 )
 
 
+def _pages_candidate_members(value):
+    """Yield (member_name, declaration, container) for a type's members.
+
+    CONTAINER is the AST node holding the declaration; it decides how
+    the member is rendered in the target language.
+    """
+    if isinstance(value, _XdrStruct):
+        for field in value.fields:
+            yield field.name, field, value
+    elif isinstance(value, _XdrPointer):
+        # The trailing field is the self-reference that makes this an
+        # XDR pointer type; the emitter does not encode it.
+        for field in value.fields[0:-1]:
+            yield field.name, field, value
+    elif isinstance(value, _XdrUnion):
+        cases = list(value.cases)
+        if value.default is not None:
+            cases.append(value.default)
+        for case in cases:
+            if not isinstance(case.arm, _XdrVoid):
+                yield case.arm.name, case.arm, value
+
+
+def check_pages_directives(root: "Specification") -> None:
+    """Reject a "pragma pages" directive that cannot be honored.
+
+    Run in the front end so the diagnostic carries the directive's own
+    source position rather than surfacing as a traceback from whichever
+    emitter reaches the member. A directive that binds to nothing would
+    otherwise degrade silently to the copying encoder.
+    """
+    payloads = {}
+    resolved = set()
+    for definition in root.definitions:
+        value = definition.value
+        type_name = getattr(value, "name", None)
+        members = dict(
+            (name, (field, container))
+            for name, field, container in _pages_candidate_members(value)
+        )
+        for marked in sorted(pages_members):
+            if marked[0] != type_name:
+                continue
+            meta = pages_member_meta.get(marked)
+            if marked[1] not in members:
+                raise XdrSemanticError(
+                    f"type '{type_name}' has no member '{marked[1]}'",
+                    meta,
+                )
+            field, container = members[marked[1]]
+            # A union arm declared directly as a string is generated as
+            # a char *, with no length field for the page encoder to
+            # read; inside a struct it becomes a { len, data } object.
+            if isinstance(container, _XdrUnion) and isinstance(field, _XdrString):
+                raise XdrSemanticError(
+                    f"union arm '{type_name}.{marked[1]}' is declared"
+                    " directly as a string and carries no length field;"
+                    " declare it through a typedef instead",
+                    meta,
+                )
+            if pages_member_maxsize(field) is None:
+                raise XdrSemanticError(
+                    f"'{type_name}.{marked[1]}' is neither a"
+                    " variable-length opaque nor a string",
+                    meta,
+                )
+            # svcxdr_encode_opaque_payload() consumes the whole page
+            # vector and moves the stream into the tail; a second
+            # payload would overwrite the first one's framing.
+            first = payloads.get(type_name)
+            if first is not None:
+                raise XdrSemanticError(
+                    f"'{type_name}' already marks member '{first}' as"
+                    " page-resident; an encoder emits at most one"
+                    " page-resident payload",
+                    meta,
+                )
+            payloads[type_name] = marked[1]
+            resolved.add(marked)
+
+    for marked in sorted(pages_members - resolved):
+        raise XdrSemanticError(
+            f"pragma pages names unknown type '{marked[0]}'",
+            pages_member_meta.get(marked),
+        )
+
+    _check_pages_containment(root, payloads)
+
+
+def _member_type_names(value) -> list:
+    """Return the type names a definition's members reference, one
+    entry per member so a type used twice is counted twice."""
+    if isinstance(value, _XdrStruct):
+        fields = value.fields
+    elif isinstance(value, _XdrPointer):
+        # The trailing self-reference is list framing that the
+        # caller's loop walks, not a member the pointer's own
+        # encoder emits.
+        fields = value.fields[0:-1]
+    elif isinstance(value, _XdrUnion):
+        fields = [case.arm for case in value.cases]
+        if value.default:
+            fields.append(value.default.arm)
+    elif isinstance(value, _XdrTypedef):
+        fields = [value.declaration]
+    else:
+        return []
+    names = []
+    for field in fields:
+        spec = getattr(field, "spec", None)
+        if spec is not None:
+            names.append(spec.type_name)
+    return names
+
+
+def _reachable_payloads(type_name, members, payloads, active) -> list:
+    """Return the marked members an encoder for TYPE_NAME emits, one
+    entry per path that reaches one, so a marked type held by two
+    members appears twice."""
+    if type_name in active:
+        return []
+    active.add(type_name)
+    found = []
+    if type_name in payloads:
+        found.append((type_name, payloads[type_name]))
+    for member_type in members.get(type_name, ()):
+        found += _reachable_payloads(member_type, members, payloads, active)
+    active.discard(type_name)
+    return found
+
+
+def _check_pages_containment(root: "Specification", payloads: dict) -> None:
+    """Reject a type whose encoder reaches more than one page-resident
+    payload through the types its members contain.
+
+    The one-payload check in check_pages_directives() sees only the
+    directly marked type. A type that holds two members of a marked
+    type, or members of two marked types, would call
+    svcxdr_encode_opaque_payload() once per member and overwrite the
+    first payload's framing just as a second marked member would.
+    """
+    members = {}
+    for definition in root.definitions:
+        value = definition.value
+        name = getattr(value, "name", None)
+        if name is None and isinstance(value, _XdrTypedef):
+            name = value.declaration.name
+        if name is not None:
+            members[name] = _member_type_names(value)
+
+    for name in members:
+        reached = _reachable_payloads(name, members, payloads, set())
+        if len(reached) > 1:
+            raise XdrSemanticError(
+                f"'{name}' reaches {len(reached)} page-resident payloads"
+                " through its members; an encoder emits at most one"
+                " page-resident payload",
+                pages_member_meta.get(reached[1]),
+            )
+
+
 def transform_parse_tree(parse_tree):
     """Transform productions into an abstract syntax tree"""
     ast = transformer.transform(parse_tree)
     ast.definitions = _merge_consecutive_passthru(ast.definitions)
     check_duplicate_definitions(ast)
     check_rpc_number_range(ast)
+    check_pages_directives(ast)
     return ast
 
 
-- 
2.55.0

