Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 590CB50C2A3
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:51:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540663; cv=none; b=FuAvu+kPRTbWCTLhoDeK/XSDY4/LOE+mX5Cw/kPqDERKPhRfRuO0twilnBvZAti8wrKaQJpP6zMq/PxiirdfuoaYsv9ZcLmRJVWwv6ceX4ojCP4X1q1FgqVhLdZIib6cyhM1VunY2eTHIZHP1RdUL/qfFZufRgwTLUHCMoyqQ5U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540663; c=relaxed/simple;
	bh=nVQPiYSA/W+nTWr/nB8jYaSHFmbuDH+e8Wms0APuJD0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Nu8FCCirHj9YP3/6avm4UAkApYhj54sdnVQU3KFjMqfLvDzWQ4WgqpJIKU+OU+B+OCMx6QFZR+uyAw8gVDc9csCD8EsKcEJcdhAqcGiSRbtZZrfavSjBWhkzIYMWpMoaxhX6PNxwsp9VB1723jRy6RH+cL1fxWD0ZhSgA8AloP0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RSwAz5Hu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RSwAz5Hu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B32CC1F00AC4;
	Fri,  4 Sep 2026 16:51:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788540662;
	bh=BoWjZ4BTKVGrVlHDnmFYzvk0W4XPWydQSdDUz9D7kIA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RSwAz5Huj37BpBaR2XcnX9JbvFNXvPmKhr40qFa7LfNJcqd5d/cj347F+EztdHNcv
	 2FXOCK5igPxBZx2m/W3sIZ9+HeGi4AyWih/d4rm+zwOwER8r9iv3Uu22st79C8wUak
	 L4hriBbxiH434dm4D0jayHCXa0OshYegjaNFQ8knqZHxkxJqsuYCZDtWPlPMWR6KHe
	 9YTFVezAEznY4GHtNfOGp/nVZ7VE/YClegnYnTtyHcjGJtS11/6PyigMmPmpXVEmR1
	 zsjPSDhO3xsaWZtbSG7lwlilSkHd+pc5EFh1uj2D20o9khnvMUfF3DFLEAXqfOG8UJ
	 sYFevXugScHJg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 10/10] xdrgen: Stream optional-data aggregate lists during encode
Date: Fri,  4 Sep 2026 12:50:52 -0400
Message-ID: <20260904165052.153327-11-cel@kernel.org>
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

The optional-data aggregate encoder loops cursor.count times, so the
begin hook must report the element count before the first element is
written.  A producer that reads its elements while the reply is
encoded -- NFSv2 READDIR streaming directory entries straight into the
send buffer -- does not know that count in advance, and would have to
materialize the whole list just to satisfy the loop bound.

An optional-data list carries no count on the wire, so nothing forces
one on the encoder.  Drive it from the item hook instead: a false
return ends the list, and the framing writes the terminator.

The counted-array form and its hook contract are unchanged.  No
in-tree spec marks an optional-data member yet, so no generated code
changes here.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xdrgen/_defs.h           | 27 ++++++++++++-------
 tools/net/sunrpc/xdrgen/README                | 11 ++++++--
 .../C/struct/encoder/aggregate_optional.j2    |  6 ++---
 3 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/xdrgen/_defs.h b/include/linux/sunrpc/xdrgen/_defs.h
index f4375d73c5ca..d767206feea4 100644
--- a/include/linux/sunrpc/xdrgen/_defs.h
+++ b/include/linux/sunrpc/xdrgen/_defs.h
@@ -30,15 +30,24 @@ typedef struct {
 } opaque;
 
 /*
- * Cursor a hook-driven aggregate codec hands to its application hooks,
- * one element at a time, in place of a materialized C array. The
- * generated framing owns it. @xdr is the RPC layer's stream; @ctx is
- * that stream's xdrgen_ctx, the svc_rqst on the server. @index is
- * the current element and @count the wire array length: a decoder
- * fills @count from the wire before the begin hook runs, an
- * encoder's begin hook sets it. @member_id selects among a type's
- * marked members. The begin/item/end contract is under "Pragma
- * aggregate" in tools/net/sunrpc/xdrgen/README.
+ * Cursor a hook-driven aggregate codec hands to its begin/item/end
+ * hooks, one element at a time, in place of a materialized C array.
+ * The generated framing owns it. @xdr is the RPC layer's stream and
+ * @ctx its xdrgen_ctx, the svc_rqst on the server. @index is the
+ * current element; @member_id selects among a type's marked members.
+ * For a counted array @count is the wire length: a decoder fills it
+ * before the begin hook runs, an encoder's begin hook sets it. The
+ * hook contract is under "Pragma aggregate" in
+ * tools/net/sunrpc/xdrgen/README.
+ *
+ * An optional-data list ("type *name") carries no count. Its encoder
+ * pulls elements until the item hook returns false. False ends the
+ * list rather than failing the encode: the framing writes the
+ * value-follows terminator, so a producer that stops early leaves a
+ * valid truncated list on the wire. A producer that stops for a
+ * mid-list error records it in the application state @ctx reaches,
+ * and either returns false from the end hook, which fails the
+ * encode, or reports it in the procedure status.
  */
 struct xdrgen_aggregate_cursor {
 	struct xdr_stream	*xdr;
diff --git a/tools/net/sunrpc/xdrgen/README b/tools/net/sunrpc/xdrgen/README
index 15c6f6b0762a..0714808194ed 100644
--- a/tools/net/sunrpc/xdrgen/README
+++ b/tools/net/sunrpc/xdrgen/README
@@ -179,7 +179,14 @@ element is prefixed by a value-follows TRUE and the sequence is
 closed by a FALSE, which the framing writes after the last
 element. The element type must therefore be a pointer type, whose
 codec owns that framing; xdrgen rejects any other element type.
-For the optional-data form xdrgen generates a working
+That form has no count to loop on, so its encoder pulls
+elements until the item hook returns false. False ends the list
+rather than failing the encode: a producer stops when its source
+is exhausted or when a reply budget fills. A producer that stops
+for an error records it in its own state and either fails the
+encode from the end hook or reports it in the procedure status.
+For the optional-data
+form xdrgen generates a working
 encoder only; the decoder it emits does not decode the list, so
 xdrgen also rejects the directive when the struct is reachable
 from an RPC argument.
@@ -205,7 +212,7 @@ member:
 For a variable-length array, a decoder fills the cursor's count from
 the wire before calling the begin hook, and an encoder's begin hook
 sets that count for the framing to bound-check and emit. An
-optional-data list's encoder begin hook sets the count as well; its
+optional-data list's encoder does not read the count and its
 decoder never fills it. Once a begin hook
 has succeeded its end hook runs, so that it can release what begin
 took; the end hook receives the running success flag.
diff --git a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2 b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2
index d45b823225f7..4f35b6976109 100644
--- a/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2
+++ b/tools/net/sunrpc/xdrgen/templates/C/struct/encoder/aggregate_optional.j2
@@ -12,13 +12,11 @@
 
 		if (!{{ hook }}_encode_begin(&cursor))
 			return false;
-		for (cursor.index = 0; cursor.index < cursor.count; cursor.index++) {
+		for (cursor.index = 0; ; cursor.index++) {
 			{{ classifier }}{{ c_type }} element = {};
 
-			if (!{{ hook }}_encode(&cursor, &element)) {
-				ok = false;
+			if (!{{ hook }}_encode(&cursor, &element))
 				break;
-			}
 			if (!xdrgen_encode_{{ type }}(xdr, &element)) {
 				ok = false;
 				break;
-- 
2.55.0

