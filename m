Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1F4C54937D
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 13:42:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788874990; cv=none; b=k+tXVhSRYKzNiTJGX2UZnLeP6+jzY/l/vPE+BFZkgvsUItX1tKzZiOedHWQzPK8QK7cOoBPkG5KebNSQC8jMwYsaximQy6BwlGXlNOeqHcQ7ZJdJ0TaERtQL+q/X5wJjBO+E03qpMPFcKpHcA+HornWSTx6WWuc+CXHtAZFF95E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788874990; c=relaxed/simple;
	bh=JWAk7GE/ci2TvrcNse3in1rlfO01UDIIKmJkJhSdGtM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bT2UafXSffU0ytVXjJvC0KGMsK3hyggw/j+ey1uj+FWzwPgEQtM0BT0Rx8BR88NxZ39zm/n8fhFatgY9m+iWq81edVopBgdb/4AO7u+So+PRKpHWYar8Zq+NV7a5SaWeYe5k5qLGCdPx1vwkuk3yTEVHIYfmNJ9CREHRLn00rUo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 151E41F01558;
	Tue,  8 Sep 2026 13:42:43 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 07/10] xdrgen: Extend the pages directive to page-resident arguments
Date: Tue,  8 Sep 2026 09:42:31 -0400
Message-ID: <20260908134234.512312-8-cel@kernel.org>
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

The pages directive so far drives only the encoder. A bulk argument
such as the payload of an NFS WRITE arrives in the pages of the
server's Receive buffer, but the generated opaque decoder copies it
into a contiguous data pointer. The copy wastes memory bandwidth and
forces the containing procedure decoder to be hand-rolled.

Let the directive drive the decoder as well. Whether a marked member
is decoded in place or encoded by reference follows from whether its
containing type is reachable from an RPC procedure argument. Record
that set during parsing, then close it over nested aggregates and
typedef aliases before the directives are checked. A decoded
page-resident member is represented as a struct xdr_buf so that the
payload can be handed on without a copy. A marked union arm of an
argument type is rejected, since the union generator still emits
only the copying decoder. A marked type reachable from both an
argument and a result is rejected as well: the two representations
differ, and a type carries only one.

Signed-off-by: Chuck Lever <cel@kernel.org>
Acked-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/xdrgen/_defs.h           |   6 +
 tools/net/sunrpc/xdrgen/README                |  36 ++++--
 tools/net/sunrpc/xdrgen/generators/pointer.py |  39 +++++--
 tools/net/sunrpc/xdrgen/generators/struct.py  |  39 +++++--
 tools/net/sunrpc/xdrgen/generators/union.py   |   2 +-
 .../C/pointer/decoder/pages_opaque.j2         |   6 +
 .../C/pointer/definition/pages_opaque.j2      |   5 +
 .../C/struct/decoder/pages_opaque.j2          |   6 +
 .../C/struct/definition/pages_opaque.j2       |   5 +
 tools/net/sunrpc/xdrgen/xdr_ast.py            | 108 +++++++++++++++++-
 10 files changed, 223 insertions(+), 29 deletions(-)
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/pointer/decoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/pointer/definition/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/decoder/pages_opaque.j2
 create mode 100644 tools/net/sunrpc/xdrgen/templates/C/struct/definition/pages_opaque.j2

diff --git a/include/linux/sunrpc/xdrgen/_defs.h b/include/linux/sunrpc/xdrgen/_defs.h
index 8f3776ef3229..1e183b9d1c1d 100644
--- a/include/linux/sunrpc/xdrgen/_defs.h
+++ b/include/linux/sunrpc/xdrgen/_defs.h
@@ -5,11 +5,17 @@
  * This header defines XDR data type primitives specified in
  * Section 4 of RFC 4506, used by RPC programs implemented
  * in the Linux kernel.
+ *
+ * A generated definition can also embed a struct xdr_buf, which
+ * carries a page-resident payload captured by reference, so this
+ * header pulls in the kernel's XDR types as well.
  */
 
 #ifndef _SUNRPC_XDRGEN__DEFS_H_
 #define _SUNRPC_XDRGEN__DEFS_H_
 
+#include <linux/sunrpc/xdr.h>
+
 #define TRUE	(true)
 #define FALSE	(false)
 
diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 5af9cf506637..cba2e20e9629 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -259,13 +259,35 @@ The first marks the opaque data member of struct READ3resok; the
 second marks the path arm of union readlinkres, where path is
 "typedef string path<NFS_MAXPATHLEN>".
 
+Whether the directive drives the encoder or the decoder follows
+from how the containing type is used. A server decodes arguments
+and encodes results, so the directive on a member of a result type
+(such as READ3resok) marks a payload to encode by reference, while
+the directive on a member of an argument type (such as the data
+member of an NFS WRITE argument) marks a payload to decode in place.
+
+An argument type here is the struct named as an RPC procedure
+argument, any aggregate reachable from it, and any typedef alias of
+either; a result type is defined the same way. A decoded member
+and an encoded one take different C representations, so a marked
+type that is reachable from both an argument and a result is
+rejected. The directive on a union arm of an argument type is
+rejected as well:
+the union generator emits only the ordinary copying decoder, so a
+page-resident union arm needs generator support that does not yet
+exist.
+
 The emitted encoder reads only the marked member's length field to
 determine how many octets of page content to insert; the member's
-data pointer is not read. The server and client manage payload
-pages differently, so this directive applies only to server-side
-code generation, and so far only to the encoding direction.
-Decode-side handling of a page-resident argument (for example, the
-payload of an NFS WRITE) remains hand-coded.
+data pointer is not read. The emitted decoder reads the length
+prefix and captures the payload octets by reference, leaving them in
+the pages of the Receive buffer. A decoded page-resident member is
+represented as a struct xdr_buf so that a later stage can hand the
+payload to the server's file system without a copy.
+
+The server and client manage payload pages differently, so this
+directive applies only to server-side code generation. Client-side
+handling of a page-resident member remains future work.
 
 
 Future Work
@@ -282,8 +304,8 @@ Add more pragma directives:
   * @skip -- do not decode, but rather skip, the specified argument
     field
 
-Extend pragma pages to the decoding direction and to
-client-side code generation
+Extend pragma pages to client-side code generation, and to union
+arms of RPC procedure arguments
 
 Enable something like a #include to dynamically insert the content
 of other specification files
diff --git a/tools/net/sunrpc/xdrgen/generators/pointer.py b/tools/net/sunrpc/xdrgen/generators/pointer.py
index 448ebd684212..aae78b42d717 100644
--- a/tools/net/sunrpc/xdrgen/generators/pointer.py
+++ b/tools/net/sunrpc/xdrgen/generators/pointer.py
@@ -13,7 +13,7 @@ from xdr_ast import _XdrFixedLengthOpaque, _XdrVariableLengthOpaque
 from xdr_ast import _XdrFixedLengthArray, _XdrVariableLengthArray
 from xdr_ast import _XdrOptionalData, _XdrPointer, _XdrDeclaration
 from xdr_ast import public_apis, get_header_name
-from xdr_ast import pages_members, pages_member_maxsize
+from xdr_ast import pages_members, pages_member_maxsize, pages_member_is_decoded
 
 
 def emit_pointer_declaration(environment: Environment, node: _XdrPointer) -> None:
@@ -24,9 +24,13 @@ def emit_pointer_declaration(environment: Environment, node: _XdrPointer) -> Non
 
 
 def emit_pointer_member_definition(
-    environment: Environment, field: _XdrDeclaration
+    environment: Environment, field: _XdrDeclaration, struct_name: str, peer: str
 ) -> None:
     """Emit a definition for one field in an XDR struct"""
+    if peer == "server" and pages_member_is_decoded(struct_name, field.name):
+        template = get_jinja2_template(environment, "definition", "pages_opaque")
+        print(template.render(name=field.name))
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "definition", field.template)
         print(
@@ -79,13 +83,15 @@ def emit_pointer_member_definition(
         )
 
 
-def emit_pointer_definition(environment: Environment, node: _XdrPointer) -> None:
+def emit_pointer_definition(
+    environment: Environment, node: _XdrPointer, peer: str
+) -> None:
     """Emit a definition for an XDR pointer type"""
     template = get_jinja2_template(environment, "definition", "open")
     print(template.render(name=node.name))
 
     for field in node.fields[0:-1]:
-        emit_pointer_member_definition(environment, field)
+        emit_pointer_member_definition(environment, field, node.name, peer)
 
     template = get_jinja2_template(environment, "definition", "close")
     print(template.render(name=node.name))
@@ -95,8 +101,18 @@ def emit_pointer_member_decoder(
     environment: Environment,
     field: _XdrDeclaration,
     struct_name: str,
+    peer: str,
 ) -> None:
     """Emit a decoder for one field in an XDR pointer"""
+    if peer == "server" and pages_member_is_decoded(struct_name, field.name):
+        template = get_jinja2_template(environment, "decoder", "pages_opaque")
+        print(
+            template.render(
+                name=field.name,
+                maxsize=pages_member_maxsize(field),
+            )
+        )
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "decoder", field.template)
         print(
@@ -161,13 +177,15 @@ def emit_pointer_member_decoder(
         )
 
 
-def emit_pointer_decoder(environment: Environment, node: _XdrPointer) -> None:
+def emit_pointer_decoder(
+    environment: Environment, node: _XdrPointer, peer: str
+) -> None:
     """Emit one decoder function for an XDR pointer type"""
     template = get_jinja2_template(environment, "decoder", "open")
     print(template.render(name=node.name))
 
     for field in node.fields[0:-1]:
-        emit_pointer_member_decoder(environment, field, node.name)
+        emit_pointer_member_decoder(environment, field, node.name, peer)
 
     template = get_jinja2_template(environment, "decoder", "close")
     print(template.render())
@@ -183,10 +201,13 @@ def emit_pointer_member_encoder(
     if (struct_name, field.name) in pages_members:
         if peer != "server":
             raise NotImplementedError(
-                "pragma pages is server-side encode-only; "
+                "pragma pages is server-side only; "
                 + peer
                 + " generation is not yet supported"
             )
+        # Both representations carry the length field, which is all the
+        # pages encoder reads, so pages_member_is_decoded() does not
+        # gate this site.
         template = get_jinja2_template(environment, "encoder", "pages_opaque")
         print(
             template.render(
@@ -296,11 +317,11 @@ class XdrPointerGenerator(SourceGenerator):
 
     def emit_definition(self, node: _XdrPointer) -> None:
         """Emit one declaration for an XDR pointer type"""
-        emit_pointer_definition(self.environment, node)
+        emit_pointer_definition(self.environment, node, self.peer)
 
     def emit_decoder(self, node: _XdrPointer) -> None:
         """Emit one decoder function for an XDR pointer type"""
-        emit_pointer_decoder(self.environment, node)
+        emit_pointer_decoder(self.environment, node, self.peer)
 
     def emit_encoder(self, node: _XdrPointer) -> None:
         """Emit one encoder function for an XDR pointer type"""
diff --git a/tools/net/sunrpc/xdrgen/generators/struct.py b/tools/net/sunrpc/xdrgen/generators/struct.py
index 76fd3afbeea0..e71f8126806d 100644
--- a/tools/net/sunrpc/xdrgen/generators/struct.py
+++ b/tools/net/sunrpc/xdrgen/generators/struct.py
@@ -13,7 +13,7 @@ from xdr_ast import _XdrFixedLengthOpaque, _XdrVariableLengthOpaque
 from xdr_ast import _XdrFixedLengthArray, _XdrVariableLengthArray
 from xdr_ast import _XdrOptionalData, _XdrStruct, _XdrDeclaration
 from xdr_ast import public_apis, get_header_name
-from xdr_ast import pages_members, pages_member_maxsize
+from xdr_ast import pages_members, pages_member_maxsize, pages_member_is_decoded
 
 
 def emit_struct_declaration(environment: Environment, node: _XdrStruct) -> None:
@@ -24,9 +24,13 @@ def emit_struct_declaration(environment: Environment, node: _XdrStruct) -> None:
 
 
 def emit_struct_member_definition(
-    environment: Environment, field: _XdrDeclaration
+    environment: Environment, field: _XdrDeclaration, struct_name: str, peer: str
 ) -> None:
     """Emit a definition for one field in an XDR struct"""
+    if peer == "server" and pages_member_is_decoded(struct_name, field.name):
+        template = get_jinja2_template(environment, "definition", "pages_opaque")
+        print(template.render(name=field.name))
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "definition", field.template)
         print(
@@ -79,13 +83,15 @@ def emit_struct_member_definition(
         )
 
 
-def emit_struct_definition(environment: Environment, node: _XdrStruct) -> None:
+def emit_struct_definition(
+    environment: Environment, node: _XdrStruct, peer: str
+) -> None:
     """Emit one definition for an XDR struct type"""
     template = get_jinja2_template(environment, "definition", "open")
     print(template.render(name=node.name))
 
     for field in node.fields:
-        emit_struct_member_definition(environment, field)
+        emit_struct_member_definition(environment, field, node.name, peer)
 
     template = get_jinja2_template(environment, "definition", "close")
     print(template.render(name=node.name))
@@ -95,8 +101,18 @@ def emit_struct_member_decoder(
     environment: Environment,
     field: _XdrDeclaration,
     struct_name: str,
+    peer: str,
 ) -> None:
     """Emit a decoder for one field in an XDR struct"""
+    if peer == "server" and pages_member_is_decoded(struct_name, field.name):
+        template = get_jinja2_template(environment, "decoder", "pages_opaque")
+        print(
+            template.render(
+                name=field.name,
+                maxsize=pages_member_maxsize(field),
+            )
+        )
+        return
     if isinstance(field, _XdrBasic):
         template = get_jinja2_template(environment, "decoder", field.template)
         print(
@@ -161,13 +177,15 @@ def emit_struct_member_decoder(
         )
 
 
-def emit_struct_decoder(environment: Environment, node: _XdrStruct) -> None:
+def emit_struct_decoder(
+    environment: Environment, node: _XdrStruct, peer: str
+) -> None:
     """Emit one decoder function for an XDR struct type"""
     template = get_jinja2_template(environment, "decoder", "open")
     print(template.render(name=node.name))
 
     for field in node.fields:
-        emit_struct_member_decoder(environment, field, node.name)
+        emit_struct_member_decoder(environment, field, node.name, peer)
 
     template = get_jinja2_template(environment, "decoder", "close")
     print(template.render())
@@ -183,10 +201,13 @@ def emit_struct_member_encoder(
     if (struct_name, field.name) in pages_members:
         if peer != "server":
             raise NotImplementedError(
-                "pragma pages is server-side encode-only; "
+                "pragma pages is server-side only; "
                 + peer
                 + " generation is not yet supported"
             )
+        # Both representations carry the length field, which is all the
+        # pages encoder reads, so pages_member_is_decoded() does not
+        # gate this site.
         template = get_jinja2_template(environment, "encoder", "pages_opaque")
         print(
             template.render(
@@ -294,11 +315,11 @@ class XdrStructGenerator(SourceGenerator):
 
     def emit_definition(self, node: _XdrStruct) -> None:
         """Emit one definition for an XDR struct type"""
-        emit_struct_definition(self.environment, node)
+        emit_struct_definition(self.environment, node, self.peer)
 
     def emit_decoder(self, node: _XdrStruct) -> None:
         """Emit one decoder function for an XDR struct type"""
-        emit_struct_decoder(self.environment, node)
+        emit_struct_decoder(self.environment, node, self.peer)
 
     def emit_encoder(self, node: _XdrStruct) -> None:
         """Emit one encoder function for an XDR struct type"""
diff --git a/tools/net/sunrpc/xdrgen/generators/union.py b/tools/net/sunrpc/xdrgen/generators/union.py
index 47d63236f88f..e1e7d38fdf44 100644
--- a/tools/net/sunrpc/xdrgen/generators/union.py
+++ b/tools/net/sunrpc/xdrgen/generators/union.py
@@ -227,7 +227,7 @@ def emit_union_pages_arm_encoder(
         return False
     if peer != "server":
         raise NotImplementedError(
-            "pragma pages is server-side encode-only; "
+            "pragma pages is server-side only; "
             + peer
             + " generation is not yet supported"
         )
diff --git a/tools/net/sunrpc/xdrgen/templates/C/pointer/decoder/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/pointer/decoder/pages_opaque.j2
new file mode 100644
index 000000000000..3b5ca6a5d977
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/pointer/decoder/pages_opaque.j2
@@ -0,0 +1,6 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+	if (!svcxdr_decode_opaque_payload(xdr, &ptr->{{ name }}, {{ maxsize }}))
+		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/pointer/definition/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/pointer/definition/pages_opaque.j2
new file mode 100644
index 000000000000..6e1a344d6665
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/pointer/definition/pages_opaque.j2
@@ -0,0 +1,5 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+	struct xdr_buf {{ name }};
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/pages_opaque.j2
new file mode 100644
index 000000000000..3b5ca6a5d977
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/decoder/pages_opaque.j2
@@ -0,0 +1,6 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+	if (!svcxdr_decode_opaque_payload(xdr, &ptr->{{ name }}, {{ maxsize }}))
+		return false;
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/definition/pages_opaque.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/definition/pages_opaque.j2
new file mode 100644
index 000000000000..6e1a344d6665
--- /dev/null
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/definition/pages_opaque.j2
@@ -0,0 +1,5 @@
+{# SPDX-License-Identifier: GPL-2.0 #}
+{% if annotate %}
+	/* member {{ name }} (page-resident variable-length opaque) */
+{% endif %}
+	struct xdr_buf {{ name }};
diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index c29555b695a9..e8397017e4cb 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -20,14 +20,26 @@ structs = set()
 pass_by_reference = set()
 
 # (type_name, member_name) pairs marked "pragma pages": the member's
-# content resides in the pages of the Reply buffer, so the emitted
-# encoder inserts those pages by reference instead of copying.
+# content resides in the pages of the Receive or Reply buffer, so
+# the emitted codec captures or inserts those pages by reference
+# instead of copying.
 pages_members = set()
 
 # The same pairs, keyed to the directive's identifier node so a
 # diagnostic can point at the directive rather than at the type.
 pages_member_meta = {}
 
+# Names of types reachable from an RPC procedure argument, closed over
+# the types their members reach. A "pragma pages" member of one is
+# decoded in place rather than encoded by reference, and the two need
+# different C representations; see pages_member_is_decoded().
+argument_types = set()
+
+# Names of types reachable from an RPC procedure result, closed the
+# same way. A marked member of a type in both sets would need both
+# representations at once, so the front end rejects it.
+result_types = set()
+
 # Typedefs of a variable-length opaque or string, mapped to the length
 # bound. A "pragma pages" member declared through one ("path data;"
 # with "typedef string path<NFS_MAXPATHLEN>") reaches the AST as a
@@ -470,6 +482,20 @@ def pages_member_maxsize(field: _XdrDeclaration):
     return None
 
 
+def pages_member_is_decoded(struct_name: str, member_name: str) -> bool:
+    """Return True when a "pragma pages" member is decoded in place.
+
+    A server decodes arguments and encodes results. A page-resident
+    member of an argument type is decoded from the pages of the
+    Receive buffer into an xdr_buf that captures the content by
+    reference; one of a result type is encoded from the Reply buffer's
+    pages and keeps the ordinary opaque or string representation.
+    """
+    return (struct_name, member_name) in pages_members and (
+        struct_name in argument_types
+    )
+
+
 @dataclass
 class _XdrCaseSpec(_XdrAst):
     """One case in an XDR union"""
@@ -783,6 +809,8 @@ class ParseToAst(Transformer):
         argument = children[2]
         number = children[3].value
 
+        argument_types.add(argument.type_name)
+        result_types.add(result.type_name)
         return _RpcProcedure(
             ident.symbol,
             number,
@@ -1062,7 +1090,7 @@ def check_pages_directives(root: "Specification") -> None:
     Run in the front end so the diagnostic carries the directive's own
     source position rather than surfacing as a traceback from whichever
     emitter reaches the member. A directive that binds to nothing would
-    otherwise degrade silently to the copying encoder.
+    otherwise degrade silently to the copying codec.
     """
     payloads = {}
     resolved = set()
@@ -1093,6 +1121,26 @@ def check_pages_directives(root: "Specification") -> None:
                     " declare it through a typedef instead",
                     meta,
                 )
+            # A decoded member and an encoded one take different C
+            # representations, and a type carries only one.
+            if type_name in argument_types and type_name in result_types:
+                raise XdrSemanticError(
+                    f"'{type_name}' is reachable from both an RPC"
+                    " argument and an RPC result; a page-resident"
+                    " member needs distinct argument and result types",
+                    meta,
+                )
+            # The union generator does not consult
+            # pages_member_is_decoded(), so a marked arm would reach the
+            # copying decoder and pull the payload through the bounded
+            # scratch buffer.
+            if isinstance(container, _XdrUnion) and type_name in argument_types:
+                raise XdrSemanticError(
+                    f"union arm '{type_name}.{marked[1]}' cannot be"
+                    " decoded in place; declare a page-resident member"
+                    " of an argument type in a struct instead",
+                    meta,
+                )
             if pages_member_maxsize(field) is None:
                 raise XdrSemanticError(
                     f"'{type_name}.{marked[1]}' is neither a"
@@ -1198,12 +1246,66 @@ def _check_pages_containment(root: "Specification", payloads: dict) -> None:
             )
 
 
+def _referenced_type_names(value) -> set:
+    """Return the type names an aggregate references through its
+    members."""
+    if isinstance(value, (_XdrStruct, _XdrPointer)):
+        fields = value.fields
+    elif isinstance(value, _XdrUnion):
+        fields = [case.arm for case in value.cases]
+        if value.default:
+            fields.append(value.default.arm)
+    else:
+        return set()
+    names = set()
+    for field in fields:
+        spec = getattr(field, "spec", None)
+        if spec is not None:
+            names.add(spec.type_name)
+    return names
+
+
+def _expand_procedure_types(root: "Specification") -> None:
+    """Close argument_types and result_types over the types reachable
+    from an RPC argument or result.
+
+    A "pragma pages" member decoded in place can sit in a struct nested
+    within an argument type (symlinkdata3 within SYMLINK3args), so the
+    top-level argument types alone do not suffice.
+    """
+    references = {}
+    for definition in root.definitions:
+        value = definition.value
+        name = getattr(value, "name", None)
+        if name is not None:
+            references[name] = _referenced_type_names(value)
+        elif isinstance(value, _XdrTypedef):
+            # An argument named through an alias reaches whatever
+            # aggregate the alias resolves to.
+            declaration = value.declaration
+            spec = getattr(declaration, "spec", None)
+            if spec is not None:
+                references[declaration.name] = {spec.type_name}
+
+    for types in (argument_types, result_types):
+        worklist = list(types)
+        while worklist:
+            for referenced in references.get(worklist.pop(), ()):
+                if referenced in references and referenced not in types:
+                    types.add(referenced)
+                    worklist.append(referenced)
+
+
 def transform_parse_tree(parse_tree):
     """Transform productions into an abstract syntax tree"""
     ast = transformer.transform(parse_tree)
     ast.definitions = _merge_consecutive_passthru(ast.definitions)
     check_duplicate_definitions(ast)
     check_rpc_number_range(ast)
+    # The pages checks consult argument_types and result_types, so
+    # close those sets over the nested aggregates before the
+    # directives are validated.
+    _expand_procedure_types(ast)
     check_pages_directives(ast)
     return ast
 
-- 
2.55.0

