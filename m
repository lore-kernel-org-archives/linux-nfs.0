Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E68E3CD8BF
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:50:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540658; cv=none; b=GwSZtUmSAL5u5mIvA/1fhbhpp079K3ZeinIzJySPpyJ5pwK+GsYVeJdEnBrMNxvCdTh2bbiqhfpv0vbSam/fjAzsD9BLzsY9s8OAenSVD8tPIyNCm26X/Mcm82QT/vrMdxERXkkbOMK+DSC7ufv52JsNrpVlCw5Gv44V1aoBphI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540658; c=relaxed/simple;
	bh=gOLw9mMQ32Oh7i3jpmuaizl8jKlxPTnokTPz8c1ZKH0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oyMzFgdelirbTp7LEzAQxQAWodQQiRlUrz31aI/YnrAnfzdOnauDIfmWzcSSvNssiQ85A6aWHyUZnyskyU9x44Jc/RB+2TmHWJbfaufyBnJjNw+NxtWlnT84MedDPVmZmmpANkhI8xlHh3ClSlfRjsvHGwiqQdV18ETKpnao3lk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VJzuZ4XZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VJzuZ4XZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CEB9D1F00ACF;
	Fri,  4 Sep 2026 16:50:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540657;
	bh=zga0gUOPadxsG8lFfcoKgne/7RmkjlFB8dq4EQjkcaE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VJzuZ4XZmMJzzro36/uQNXPqsihmxSfFAw+WumgYA1NpXlei7D9iAclCMeRcyQUes
	 ognyZkbbavswo9FVqPES5CM7hoNcxVp0aL+7wi7zjkB/0Kbg5ZSxlsVo+j8jJNC/N8
	 VSlB3kfr9qNEYRNZDN3KIJWExVkmJ9NHKs8Qe9pvVip/zhcFdp/bGfGgJVHIa3Balq
	 7YGP5iR6DKHZT0/9rBOnXG+WupeFh7mrZvKyW40ioCoCxdym5HewT3BNXtM28rgFIn
	 SXraPe3jvfdGE2CIHn6rZe65yfgk1AkIGCIj4ojGAxCelKzVlfYIR+DOUwHvEvdXHv
	 LLR/XXqvT/5IA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 04/10] xdrgen: Pass the containing struct name to member codec emitters
Date: Fri,  4 Sep 2026 12:50:46 -0400
Message-ID: <20260904165052.153327-5-cel@kernel.org>
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

A per-member code generation directive keyed on the (struct, member)
pair needs the name of the containing struct, but
emit_struct_member_encoder() and emit_struct_member_decoder()
receive only the member declaration.

Pass the containing struct's name to emit_struct_member_encoder() and
emit_struct_member_decoder(), and to the matching emitters in
pointer.py, as a required argument. A struct whose last field refers
to its own type is an _XdrPointer rather than an _XdrStruct, so
pointer.py takes the same argument. No emitter renders the new value
yet, so generated output is byte-identical. A subsequent patch keys
the "pragma pages" encoder on it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 tools/net/sunrpc/xdrgen/generators/pointer.py | 12 ++++++++----
 tools/net/sunrpc/xdrgen/generators/struct.py  | 12 ++++++++----
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/tools/net/sunrpc/xdrgen/generators/pointer.py b/tools/net/sunrpc/xdrgen/generators/pointer.py
index 6dbda60ad2db..9a540e125786 100644
--- a/tools/net/sunrpc/xdrgen/generators/pointer.py
+++ b/tools/net/sunrpc/xdrgen/generators/pointer.py
@@ -91,7 +91,9 @@ def emit_pointer_definition(environment: Environment, node: _XdrPointer) -> None
 
 
 def emit_pointer_member_decoder(
-    environment: Environment, field: _XdrDeclaration
+    environment: Environment,
+    field: _XdrDeclaration,
+    struct_name: str,
 ) -> None:
     """Emit a decoder for one field in an XDR pointer"""
     if isinstance(field, _XdrBasic):
@@ -164,14 +166,16 @@ def emit_pointer_decoder(environment: Environment, node: _XdrPointer) -> None:
     print(template.render(name=node.name))
 
     for field in node.fields[0:-1]:
-        emit_pointer_member_decoder(environment, field)
+        emit_pointer_member_decoder(environment, field, node.name)
 
     template = get_jinja2_template(environment, "decoder", "close")
     print(template.render())
 
 
 def emit_pointer_member_encoder(
-    environment: Environment, field: _XdrDeclaration
+    environment: Environment,
+    field: _XdrDeclaration,
+    struct_name: str,
 ) -> None:
     """Emit an encoder for one field in a XDR pointer"""
     if isinstance(field, _XdrBasic):
@@ -241,7 +245,7 @@ def emit_pointer_encoder(environment: Environment, node: _XdrPointer) -> None:
     print(template.render(name=node.name))
 
     for field in node.fields[0:-1]:
-        emit_pointer_member_encoder(environment, field)
+        emit_pointer_member_encoder(environment, field, node.name)
 
     template = get_jinja2_template(environment, "encoder", "close")
     print(template.render())
diff --git a/tools/net/sunrpc/xdrgen/generators/struct.py b/tools/net/sunrpc/xdrgen/generators/struct.py
index 64911de46f62..91da3863c166 100644
--- a/tools/net/sunrpc/xdrgen/generators/struct.py
+++ b/tools/net/sunrpc/xdrgen/generators/struct.py
@@ -91,7 +91,9 @@ def emit_struct_definition(environment: Environment, node: _XdrStruct) -> None:
 
 
 def emit_struct_member_decoder(
-    environment: Environment, field: _XdrDeclaration
+    environment: Environment,
+    field: _XdrDeclaration,
+    struct_name: str,
 ) -> None:
     """Emit a decoder for one field in an XDR struct"""
     if isinstance(field, _XdrBasic):
@@ -164,14 +166,16 @@ def emit_struct_decoder(environment: Environment, node: _XdrStruct) -> None:
     print(template.render(name=node.name))
 
     for field in node.fields:
-        emit_struct_member_decoder(environment, field)
+        emit_struct_member_decoder(environment, field, node.name)
 
     template = get_jinja2_template(environment, "decoder", "close")
     print(template.render())
 
 
 def emit_struct_member_encoder(
-    environment: Environment, field: _XdrDeclaration
+    environment: Environment,
+    field: _XdrDeclaration,
+    struct_name: str,
 ) -> None:
     """Emit an encoder for one field in an XDR struct"""
     if isinstance(field, _XdrBasic):
@@ -241,7 +245,7 @@ def emit_struct_encoder(environment: Environment, node: _XdrStruct) -> None:
     print(template.render(name=node.name))
 
     for field in node.fields:
-        emit_struct_member_encoder(environment, field)
+        emit_struct_member_encoder(environment, field, node.name)
 
     template = get_jinja2_template(environment, "encoder", "close")
     print(template.render())
-- 
2.55.0

