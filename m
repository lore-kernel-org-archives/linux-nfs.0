Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77CAE3B4E9B
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 20:34:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783888500; cv=none; b=jvQ/Wl9t1diPuYJu6wjKyD29WFA24R8RlFGWJ51/+pXltcHKKjcrbSS9X77H0EzszNc/dEkGEhLkN+vxDWzn7JJ5J0jTLMW7byg9hPX1sW5pn87zBpo9O05tbPn4UGUywAYoS511HYQdP+68N75Ax2xCBk+4YBuHPdEaVtJHR3I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783888500; c=relaxed/simple;
	bh=AlPt3n44yORsLtouawUDRGmQplvqLTn0fq3RZbD6JiI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ltkwokvEyMGc3HTjCG9upTcabxpH+nV1BXlDtFlLHvnz4CXxtpEM57Y2zlSZTkLLgrwrGjeo00z2BrRcyWxZ0slzzDgagb7R/6s7y7qSznWof9OXjkq7KDDrliiHz2N7lUY/fRmvYVd4iHRUnPIZqE4yscRc4C2erWZbeqAGi2g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ispxDPVK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ispxDPVK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CF9E01F00A3F;
	Sun, 12 Jul 2026 20:34:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783888494;
	bh=ni2UxQZDtewcSNO5j+T7RMkBrR3rRvTJiOAT2U6ce04=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ispxDPVKcbYgD8KyX1e+LF9drYxu3nELt4vKnsBLdcnB/826tZ0JqMsZNE4OC4uKu
	 ZoRa6RF8sQ7mpqKGp7U/pGGFp186JQjtKZUyVFwvrIIeMKIQy2sx9gjFnRQt1R6HRN
	 LJhDrqt84vCZpajVwr0vvQ0cz5TtdxL2UT3T7Hm8o+LawuczAvMSLotlBKPN1H75Jw
	 y/ptRcKjF9cFlPmM8Pl5IH4vab+WuZ6JkG5UzPouWfXdU1Dr8Q1mCJpQsDOg4Pbu55
	 XjrodAHEM2PsxxvxJALoz7M/oVOuad+JeIZbjd5rkrhAxDnvRYt+10wkZ1aYcMFv3o
	 vlYX2EHJbDHhA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/5] xdrgen: Record the source position of each declared identifier
Date: Sun, 12 Jul 2026 16:34:48 -0400
Message-ID: <20260712203451.124902-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260712203451.124902-1-cel@kernel.org>
References: <20260712203451.124902-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In preparation for semantic checks that reject a malformed
specification, record where each declared identifier appears in the
source so a diagnostic can point at the name in error.

The transformer keeps each identifier's spelling but discards its
position, retaining only the position of the enclosing definition.
A caret built from that position falls on the definition keyword
rather than on the identifier, because the definition production
begins at the keyword.

Store the identifier's own line and column on every named
construct: constants, enumerated types and their enumerators,
structs, unions, pointers, typedef declarations, and RPC program,
version, and procedure names. The fields live on the AST base node
and are keyword-only, so lark's positional construction of each
node is unaffected; a construct whose position is not recorded
leaves them zero.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/xdr_ast.py | 116 +++++++++++++++++++++--------
 1 file changed, 83 insertions(+), 33 deletions(-)

diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index 14bff9477473..15d2c6c40dd9 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -5,7 +5,7 @@
 
 import sys
 from typing import List
-from dataclasses import dataclass
+from dataclasses import dataclass, KW_ONLY
 
 from lark import ast_utils, Transformer
 from lark.tree import Meta
@@ -65,6 +65,16 @@ max_widths = {
 class _XdrAst(ast_utils.Ast):
     """Base class for the XDR abstract syntax tree"""
 
+    # Source position of the construct's declared identifier, when
+    # the transformer records one, so semantic diagnostics can point
+    # at the exact declaration. The KW_ONLY marker makes the fields
+    # keyword-only, so they never disturb the positional child
+    # ordering lark uses to build each node; 0 means the position was
+    # not recorded.
+    _: KW_ONLY
+    line: int = 0
+    column: int = 0
+
 
 @dataclass
 class _XdrIdentifier(_XdrAst):
@@ -543,7 +553,8 @@ class ParseToAst(Transformer):
 
     def identifier(self, children):
         """Instantiate one _XdrIdentifier object"""
-        return _XdrIdentifier(children[0].value)
+        token = children[0]
+        return _XdrIdentifier(token.value, line=token.line, column=token.column)
 
     def value(self, children):
         """Instantiate one _XdrValue object"""
@@ -573,84 +584,103 @@ class ParseToAst(Transformer):
 
     def constant_def(self, children):
         """Instantiate one _XdrConstant object"""
-        name = children[0].symbol
+        ident = children[0]
         value = children[1].value
-        return _XdrConstant(name, value)
+        return _XdrConstant(ident.symbol, value, line=ident.line, column=ident.column)
 
     def enum(self, children):
         """Instantiate one _XdrEnum object"""
-        enum_name = children[0].symbol
+        name_ident = children[0]
 
         i = 0
         enumerators = []
         body = children[1]
         while i < len(body.children):
-            name = body.children[i].symbol
+            ident = body.children[i]
             value = body.children[i + 1].value
-            enumerators.append(_XdrEnumerator(name, value))
+            enumerators.append(
+                _XdrEnumerator(
+                    ident.symbol, value, line=ident.line, column=ident.column
+                )
+            )
             i = i + 2
 
-        return _XdrEnum(enum_name, enumerators)
+        return _XdrEnum(
+            name_ident.symbol,
+            enumerators,
+            line=name_ident.line,
+            column=name_ident.column,
+        )
 
     def fixed_length_opaque(self, children):
         """Instantiate one _XdrFixedLengthOpaque declaration object"""
-        name = children[0].symbol
+        ident = children[0]
         size = children[1].value
 
-        return _XdrFixedLengthOpaque(name, size)
+        return _XdrFixedLengthOpaque(
+            ident.symbol, size, line=ident.line, column=ident.column
+        )
 
     def variable_length_opaque(self, children):
         """Instantiate one _XdrVariableLengthOpaque declaration object"""
-        name = children[0].symbol
+        ident = children[0]
         if children[1] is not None:
             maxsize = children[1].value
         else:
             maxsize = "0"
 
-        return _XdrVariableLengthOpaque(name, maxsize)
+        return _XdrVariableLengthOpaque(
+            ident.symbol, maxsize, line=ident.line, column=ident.column
+        )
 
     def string(self, children):
         """Instantiate one _XdrString declaration object"""
-        name = children[0].symbol
+        ident = children[0]
         if children[1] is not None:
             maxsize = children[1].value
         else:
             maxsize = "0"
 
-        return _XdrString(name, maxsize)
+        return _XdrString(ident.symbol, maxsize, line=ident.line, column=ident.column)
 
     def fixed_length_array(self, children):
         """Instantiate one _XdrFixedLengthArray declaration object"""
         spec = children[0]
-        name = children[1].symbol
+        ident = children[1]
         size = children[2].value
 
-        return _XdrFixedLengthArray(name, spec, size)
+        return _XdrFixedLengthArray(
+            ident.symbol, spec, size, line=ident.line, column=ident.column
+        )
 
     def variable_length_array(self, children):
         """Instantiate one _XdrVariableLengthArray declaration object"""
         spec = children[0]
-        name = children[1].symbol
+        ident = children[1]
         if children[2] is not None:
             maxsize = children[2].value
         else:
             maxsize = "0"
 
-        return _XdrVariableLengthArray(name, spec, maxsize)
+        return _XdrVariableLengthArray(
+            ident.symbol, spec, maxsize, line=ident.line, column=ident.column
+        )
 
     def optional_data(self, children):
         """Instantiate one _XdrOptionalData declaration object"""
         spec = children[0]
-        name = children[1].symbol
+        ident = children[1]
 
-        return _XdrOptionalData(name, spec)
+        return _XdrOptionalData(
+            ident.symbol, spec, line=ident.line, column=ident.column
+        )
 
     def basic(self, children):
         """Instantiate one _XdrBasic object"""
         spec = children[0]
-        name = children[1].symbol
+        ident = children[1]
 
-        return _XdrBasic(name, spec)
+        return _XdrBasic(ident.symbol, spec, line=ident.line, column=ident.column)
 
     def void(self, children):
         """Instantiate one _XdrVoid declaration object"""
@@ -659,17 +689,19 @@ class ParseToAst(Transformer):
 
     def struct(self, children):
         """Instantiate one _XdrStruct object"""
-        name = children[0].symbol
+        ident = children[0]
+        name = ident.symbol
         fields = children[1].children
+        pos = {"line": ident.line, "column": ident.column}
 
         last_field = fields[-1]
         if (
             isinstance(last_field, _XdrOptionalData)
             and name == last_field.spec.type_name
         ):
-            return _XdrPointer(name, fields)
+            return _XdrPointer(name, fields, **pos)
 
-        return _XdrStruct(name, fields)
+        return _XdrStruct(name, fields, **pos)
 
     def typedef(self, children):
         """Instantiate one _XdrTypedef object"""
@@ -694,39 +726,57 @@ class ParseToAst(Transformer):
 
     def union(self, children):
         """Instantiate one _XdrUnion object"""
-        name = children[0].symbol
+        ident = children[0]
 
         body = children[1]
         discriminant = body.children[0].children[0]
         cases = body.children[1:-1]
         default = body.children[-1]
 
-        return _XdrUnion(name, discriminant, cases, default)
+        return _XdrUnion(
+            ident.symbol,
+            discriminant,
+            cases,
+            default,
+            line=ident.line,
+            column=ident.column,
+        )
 
     def procedure_def(self, children):
         """Instantiate one _RpcProcedure object"""
         result = children[0]
-        name = children[1].symbol
+        ident = children[1]
         argument = children[2]
         number = children[3].value
 
-        return _RpcProcedure(name, number, argument, result)
+        return _RpcProcedure(
+            ident.symbol,
+            number,
+            argument,
+            result,
+            line=ident.line,
+            column=ident.column,
+        )
 
     def version_def(self, children):
         """Instantiate one _RpcVersion object"""
-        name = children[0].symbol
+        ident = children[0]
         number = children[-1].value
         procedures = children[1:-1]
 
-        return _RpcVersion(name, number, procedures)
+        return _RpcVersion(
+            ident.symbol, number, procedures, line=ident.line, column=ident.column
+        )
 
     def program_def(self, children):
         """Instantiate one _RpcProgram object"""
-        name = children[0].symbol
+        ident = children[0]
         number = children[-1].value
         versions = children[1:-1]
 
-        return _RpcProgram(name, number, versions)
+        return _RpcProgram(
+            ident.symbol, number, versions, line=ident.line, column=ident.column
+        )
 
     def pragma_def(self, children):
         """Instantiate one _Pragma object"""
-- 
2.54.0

