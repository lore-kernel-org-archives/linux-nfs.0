Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79F234C77D1
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 15:03:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788447837; cv=none; b=Q1o6Y0VWRmUOX9KNf+PAlmJNSLKiAI0tPQXvJINVTJLYV+T4RMjgmUR8w4eckEYj3uHxsMMNm9UDlJN/MTFnJTpSk2NBV0opKxF80vs0UbdSor1m8PKNKnDRXTWUKx/Ivimmkm92vcM9G1naW2foPIIqa8vfO1vMFBgLhz6bURE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788447837; c=relaxed/simple;
	bh=gOLw9mMQ32Oh7i3jpmuaizl8jKlxPTnokTPz8c1ZKH0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qsvg+2GQvaC9lzfB5cKpsfCITNcyRZ5sbeWbK004RkITb7wBfIYQY+vJ4VMuZjL5PKAcC8fxfeASoJ2kpLPUxLtmxiTmFruWmF7+NnNHNmYMUVfXyZViApn8bNh8U+A8qIKBlyRIG1hqdcaC/41M0YXFbO7iTGxO4qnRh6NkxkY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iA48w1FY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iA48w1FY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C6BD11F00A3E;
	Thu,  3 Sep 2026 15:03:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788447836;
	bh=zga0gUOPadxsG8lFfcoKgne/7RmkjlFB8dq4EQjkcaE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iA48w1FY4XnBYGqmidk5b3hs06SmHyd9fjMo/F4L1mJKS3Uwhv8zXYK+CkQd3z88q
	 hQoj2BCWkpKVA1ZcGkBLoRYyOgTmLYQ8v71nHWg5eQoP3VQ93egkAYoFEaV7PrpPif
	 rhN7a3qD8HRd69j5Enf0ZKwWgt2uCY+4bRYmJ6D13ld08R+U4g2t5JC3xsu3qYao4D
	 bHYAz4FR5QYWfe4cSYgucNhTFedeTgXvmGVWgGiNxImlo8oHWQGZqCNPJj6FfNw2pp
	 qyJp+CAw8xfPCjF5nG7r1xUOGkPNukObUs8frhm+VROnbI/Iec2guYQ17NG36xx3Iz
	 XfV2kjHispXSA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 04/10] xdrgen: Pass the containing struct name to member codec emitters
Date: Thu,  3 Sep 2026 11:03:45 -0400
Message-ID: <20260903150351.9572-5-cel@kernel.org>
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

