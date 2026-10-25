Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792946521;
	b=lk57HTl1Ue9KrCqel01sFYk6kHjvPwWj/nj84s9OkyzYQi01yu4QginuDXGBAI+SYWYN
	 zdynpnH1IT+S7Iu3/1B2+okXuALzPr8/7kjdC9b8CiDWaCc2nec4k6XM13/1rR6VRSE5s
	 mPM4UYFxxRVJK04/t5OfO6qMJL3LPFcEpEszil6LEw6IwKSNfZnqvyXpAc5t6WdteKgsH
	 TXaQ3KIdqBs92LrTb13Q4YGsMJ85mMet4VoYwjXNKhxGdLH5MDn2VJxoeVLD81S5ruCjw
	 NrBXmI1q4LkPWofp54UxR/RaqpFKJza7nODbFL2/JR61y0J+pDPg4mitpL2SldvrLJg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792946521;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=HyJpl2AhDy+O5EMOk+PWmlo/mwzEC/li8Yvh3Hma95U=;
	b=wVa+ylwhN3CnBnb5N5nokqCR1xTpDFTdAAnjdii8+JxetXwF+ZMnrHMKXISgvfZBA7Kw
	 TDDSIySdM64YLiObyH2i0KGG4CySq+qzo36oPvoFPe30dY0uy9TzOwXu06iVjyfwxNLIq
	 Qlw68jUpvIscL4Rt8f85+flSTDs0TGN5u0i8jO7ZxyyPbQfhVeNO19zzmeXZt9Mi1zdZ/
	 NzbORKYF8mjsfdPZ7SdqAvRrEXa2LnVMHtejiXSR/FP2JwcWTh2Pp9UCFlhW8L40WWG/d
	 RKbTO1NJ7PeCekvIMKXywPTqx/jemZLZi4e4QTykyoHDvTmiBEa/qcbsgf8nA3qr/8w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tzj0aTgM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83B07606A31A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 16:42:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tzj0aTgM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6DE7F1F031E4;
	Sun, 25 Oct 2026 16:42:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792946521;
	bh=HyJpl2AhDy+O5EMOk+PWmlo/mwzEC/li8Yvh3Hma95U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Tzj0aTgMjoCW+htfwX9Mfoz6QTY88dIA3jEQyibag6izeW7leuTi2vgtu+IBb60aR
	 fwZ2cuRFL84IrJeuZ1E9m6Kr2mOMnRuo74204yo41zbXyVonHdzApnIxhmUeVX89lk
	 x6g1c3shuDXI53F0jj8WZY0VyGQ73Dklv0Zy7mzNKaA28vO+5ki7ld++A8Tuf2TPKr
	 7IdiYwJWUffrB8smeCzZDoUP6Jt3d8PLbA5M1RoU/sHtxS1lqixI95O203vb5uEIE+
	 cEWjFgtg8zsZOrAHX7lPIELnFMynl7hCjhPpIN2lPMXmcYapDERVJw0w/Tga5DzI2+
	 wMNWtsnXvxl3A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/4] xdrgen: Key the width tables by type name only
Date: Sat, 24 Oct 2026 21:46:14 -0400
Message-ID: <20261025014616.22236-3-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025014616.22236-1-cel@kernel.org>
References: <20261025014616.22236-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Every declaration class registers its width in max_widths and
symbolic_widths under its own name, and a declaration's name is the
field name when it appears inside a struct or a union. Those tables
are otherwise keyed by type name, so a field named after a type
overwrites that type's entry. In nfs_acl2.x, "unsigned int uid" in
struct fattr replaces the entry for the "uid" typedef, and the
generated NFS_ACL2_aclent_sz sizes the aclent id as XDR_unsigned_int
rather than NFS_ACL2_uid_sz. In nfs3.x, the "time_how set_it"
discriminant of set_atime replaces the entry a "bool set_it"
discriminant registered, so the generated set_mode3, set_uid3,
set_gid3, and set_size3 size macros count a time_how in place of a
bool. The macros evaluate to the right value only because the
colliding types happen to share a width.

Register a declaration's width under its name only when the
declaration is a typedef, where the name is the new type's name, and
compute a union discriminant's width from the discriminant itself
rather than looking it up by name. Regenerate the affected headers;
only size macros change.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xdrgen/nfs3.h     |  8 +++----
 include/linux/sunrpc/xdrgen/nfs_acl2.h |  2 +-
 tools/net/sunrpc/xdrgen/xdr_ast.py     | 32 +++-----------------------
 3 files changed, 8 insertions(+), 34 deletions(-)

diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 734f60f502c6..4e0b0afe8227 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -885,13 +885,13 @@ enum {
 	(XDR_bool + NFS3_nfs_fh3_sz)
 #define NFS3_time_how_sz                (XDR_int)
 #define NFS3_set_mode3_sz               \
-	(NFS3_time_how_sz + NFS3_mode3_sz)
+	(XDR_bool + NFS3_mode3_sz)
 #define NFS3_set_uid3_sz                \
-	(NFS3_time_how_sz + NFS3_uid3_sz)
+	(XDR_bool + NFS3_uid3_sz)
 #define NFS3_set_gid3_sz                \
-	(NFS3_time_how_sz + NFS3_gid3_sz)
+	(XDR_bool + NFS3_gid3_sz)
 #define NFS3_set_size3_sz               \
-	(NFS3_time_how_sz + NFS3_size3_sz)
+	(XDR_bool + NFS3_size3_sz)
 #define NFS3_set_atime_sz               \
 	(NFS3_time_how_sz + NFS3_nfstime3_sz)
 #define NFS3_set_mtime_sz               \
diff --git a/include/linux/sunrpc/xdrgen/nfs_acl2.h b/include/linux/sunrpc/xdrgen/nfs_acl2.h
index cc0b0db4c738..98dcada4786c 100644
--- a/include/linux/sunrpc/xdrgen/nfs_acl2.h
+++ b/include/linux/sunrpc/xdrgen/nfs_acl2.h
@@ -232,7 +232,7 @@ enum {
 #define NFS_ACL2_o_mode_sz              \
 	(XDR_unsigned_short)
 #define NFS_ACL2_aclent_sz              \
-	(XDR_int + XDR_unsigned_int + NFS_ACL2_o_mode_sz)
+	(XDR_int + NFS_ACL2_uid_sz + NFS_ACL2_o_mode_sz)
 #define NFS_ACL2_secattr_sz             \
 	(XDR_unsigned_int + XDR_int + XDR_unsigned_int + (NFS_ACL_MAX_ENTRIES * (NFS_ACL2_aclent_sz)) + XDR_int + XDR_unsigned_int + (NFS_ACL_MAX_ENTRIES * (NFS_ACL2_aclent_sz)))
 #define NFS_ACL2_ftype_sz               (XDR_int)
diff --git a/tools/net/sunrpc/xdrgen/xdr_ast.py b/tools/net/sunrpc/xdrgen/xdr_ast.py
index 537f056a0c27..a3595aa40a57 100644
--- a/tools/net/sunrpc/xdrgen/xdr_ast.py
+++ b/tools/net/sunrpc/xdrgen/xdr_ast.py
@@ -186,10 +186,6 @@ class _XdrFixedLengthOpaque(_XdrDeclaration):
         """Return list containing XDR width of type's components"""
         return ["XDR_QUADLEN(" + self.size + ")"]
 
-    def __post_init__(self):
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
-
 
 @dataclass
 class _XdrVariableLengthOpaque(_XdrDeclaration):
@@ -210,10 +206,6 @@ class _XdrVariableLengthOpaque(_XdrDeclaration):
             widths.append("XDR_QUADLEN(" + self.maxsize + ")")
         return widths
 
-    def __post_init__(self):
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
-
 
 @dataclass
 class _XdrString(_XdrDeclaration):
@@ -234,10 +226,6 @@ class _XdrString(_XdrDeclaration):
             widths.append("XDR_QUADLEN(" + self.maxsize + ")")
         return widths
 
-    def __post_init__(self):
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
-
 
 @dataclass
 class _XdrFixedLengthArray(_XdrDeclaration):
@@ -257,10 +245,6 @@ class _XdrFixedLengthArray(_XdrDeclaration):
         item_width = " + ".join(symbolic_widths[self.spec.type_name])
         return ["(" + self.size + " * (" + item_width + "))"]
 
-    def __post_init__(self):
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
-
 
 @dataclass
 class _XdrVariableLengthArray(_XdrDeclaration):
@@ -283,10 +267,6 @@ class _XdrVariableLengthArray(_XdrDeclaration):
             widths.append("(" + self.maxsize + " * (" + item_width + "))")
         return widths
 
-    def __post_init__(self):
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
-
 
 @dataclass
 class _XdrOptionalData(_XdrDeclaration):
@@ -307,8 +287,6 @@ class _XdrOptionalData(_XdrDeclaration):
     def __post_init__(self):
         structs.add(self.name)
         pass_by_reference.add(self.name)
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
 
 
 @dataclass
@@ -327,10 +305,6 @@ class _XdrBasic(_XdrDeclaration):
         """Return list containing XDR width of type's components"""
         return symbolic_widths[self.spec.type_name]
 
-    def __post_init__(self):
-        max_widths[self.name] = self.max_width()
-        symbolic_widths[self.name] = self.symbolic_width()
-
 
 @dataclass
 class _XdrVoid(_XdrDeclaration):
@@ -475,8 +449,8 @@ class _XdrTypedef(_XdrAst):
                     varlen_object_typedefs[new_type.name] = varlen_object_typedefs[
                         new_type.spec.type_name
                     ]
-                max_widths[new_type.name] = self.max_width()
-                symbolic_widths[new_type.name] = self.symbolic_width()
+        max_widths[self.declaration.name] = self.max_width()
+        symbolic_widths[self.declaration.name] = self.symbolic_width()
 
 
 def pages_member_maxsize(field: _XdrDeclaration):
@@ -555,7 +529,7 @@ class _XdrUnion(_XdrAst):
             if self.default.arm.max_width() > max_width:
                 max_width = self.default.arm.max_width()
                 width = self.default.arm.symbolic_width()
-        return symbolic_widths[self.discriminant.name] + width
+        return self.discriminant.symbolic_width() + width
 
     def __post_init__(self):
         structs.add(self.name)
-- 
2.56.0

