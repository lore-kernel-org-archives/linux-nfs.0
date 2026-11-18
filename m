Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029411;
	b=HbUSFC6TrJ92LeGP0qqlEPv2STzCZOJPkLHaCzAMFz5RF06pXGCNPOsjmxQgFauHqoV7
	 YUSERsFtFIMr1hUWyhzOQYmVvbYLyXNWx1hgm7rskyWcvqB031mONxcWbP8e1Lz3LpA3J
	 HhUOs0Y7qUVZ15KsQ/iZsVUlllIH6Yoklfqa4QFwLFkshzq+WAWLqnNiHZ8emEgpFLlB3
	 IGOV/uwcxIiNoV3wgWKKjTqv0T0VEFJtSjza2J0U1wdKzLJ0GTOPOU0EnOtKiWq3IfLV+
	 HCb08g05gvDnRx+3eKH9EL4xQrOF4Qrhx7WkyKsQqcxHSCFe0yejubKXMmDYjcHbPdA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029411;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YoLCoFyqwitmHbLBbVd06/y61IBhibAM379UDi/WYp8=;
	b=Xrlsbi8jMthVoP9hvnwoZnEwnzCV0x2steVKel07JRpgfZR7traDmxnthLAA4owgo1ND
	 Aep8lINkKLLEfmg0QkmaBz/W2lefL5hnjvXl2IskEBkqld/XrOr9ej0N/gZ8tx3E1rBQT
	 CNNn7V49e206HCTFDjeWYP3s17Jk92kOPTD9MfyOnhBXeNwt4bbEu3uSXZZn0op5fi2hW
	 u09BiH96COqlj+5FkNmxAmCpNk16QhuF65zljoSRYPdu1X5UCmPfxYEvo6vy7JEPZejtQ
	 Bw3qvMZ/D/YS7zweUxZT60mYfkF632NHtLo+RmOXD5GutRs2qt3K6NHVgEDGzCHhgCQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T4sRJVBd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B15EC606A33A
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T4sRJVBd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 73C3F1F000C7;
	Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029411;
	bh=YoLCoFyqwitmHbLBbVd06/y61IBhibAM379UDi/WYp8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=T4sRJVBdjSVUwAy7ub4XVTEGwkW1Ur4kynA5pt+Hus9AhbQ/z0BOe5XgvHex/ot05
	 rtwO7RDk7SH7QaNYewCHO3NNWDlND0smeLRlJS9UxIHc+9JBhPb8NHH68T/M136z8z
	 txulnZQ9xbSil4ZTyatoMxWq4VmZIWIEW38yg9o9bUAG6Ev5BzIUdroUbiWhMfOjzG
	 LsHmp+a7QZ331TrI4D31Z43Bf+serqiu2FRZ4P0S4tuflb50om3BoiUAGW26QitzTt
	 U9zimgUSN7au0JoyeAhUyLMllxvTnLhSdAi7J/UpXY4UlbRAU7v2Yq/PSJ0Xt29fG8
	 ONpQwgphiG4BA==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 18 Nov 2026 11:16:40 -0800
Subject: [PATCH pynfs 1/6] server41tests: factor out sampling the server's
 clock
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261118-delegts-v1-1-9bd252eea637@kernel.org>
References: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
In-Reply-To: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2832; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=goDP96KBpJCJwmuZzCn8ZqcHPsJGTyT5RhhhWebeh+g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmh7VvWJwJKnDEJ7poln7zW7+JyNJRFxA6nY
 OFeWHBEOQKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35oQAKCRAADmhBGVaC
 FSBKD/90zhzW458qFYr7ORnMFUjMtsWpBqCj4ux95zNW+mMZbe6R4uZgue2ERUJA/RZpgSzwVbY
 KvPTf4AdTPAmYCup1763ACm5g05TECWQqtYi2axZcQaYagElGTpmAF001tnypqfdodJBY48zFZK
 7Oc6xTxCbwQQzrAuNZyUpykaNEGubn/SicLySIw3eWQfJJcqRU+ONi4rjoK1kvFo/9Y61AzvbjD
 WzZuxLIaTyTFJS3OXXYMS1bhJSgAZxPrUe1/ONFwdKZIpBDN/TQnklffHOBXKBlAvDm7cNkxq8c
 gy0+d2bVIJ28kwof0r8V7dLLfaA5BclZ8tFokePYaXi8PcVNJr4WB0cz4LRqroec5dtetKDraWq
 4vc95GCFyqwW3QqatkZTarj7/TIEm3cT+vnwXEqMVpjr25lKm/xxfEvVPdszyNqI/FV82InzNxw
 36MVoA79ghGO/uAs1DUE38BgI2Qf8ABpvOggiyLZn/0OLNB5p2ehW/scVzmR30cXailHXLJhuO9
 Ed8GKS4cWb1CUlMIc1pcw2KebO+QH1pUfi9csewDhDviKt/gaqU5s+/h09uv3ZinoCekb04yqQG
 bjI3mg8GZDm80wS/7ZmGkaWG1KDhf1Sf3qW1qFavBS6g+RaAbSgEXkj1Nt2jnBEhlG9b3TKUWyg
 hXfQPI5UF50YJiA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

DELEG27 creates and removes a scratch directory to read the server's
clock. Move that into _server_now() so new delegated-timestamp tests
can share it.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index bfe3f6f8b5da..55e4e3a437bf 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -327,6 +327,23 @@ def testServerSelfConflict3(t, env):
         res = close_file(sess2, fh2, stateid=stateid2)
         check(res)
 
+def _server_now(sess, env, name):
+    """Sample the server's clock
+
+    The server may ignore a proxied time that is before the file's
+    time_modify and clamp one that is past its own clock (RFC 9754,
+    section 5), so use the server's clock rather than this host's:
+    create a scratch directory, take its time_modify, and remove it.
+    """
+    res = sess.compound(env.home + [op.savefh(),
+                                    op.create(createtype4(NF4DIR), name,
+                                              {FATTR4_MODE: 0o755}),
+                                    op.getattr(1<<FATTR4_TIME_MODIFY),
+                                    op.restorefh(),
+                                    op.remove(name)])
+    check(res)
+    return res.resarray[-3].obj_attributes[FATTR4_TIME_MODIFY]
+
 def _testCbGetattr(t, env, change=0, size=0):
     cb = threading.Event()
     cbattrs = {}
@@ -559,20 +576,7 @@ def testCbGetattrAfterSyncWrite(t, env):
     check(res)
 
     if delegtype == OPEN_DELEGATE_WRITE_ATTRS_DELEG:
-        # The server may ignore a proxied time that is before the
-        # file's time_modify and clamp one that is past its own clock
-        # (RFC 9754, section 5), so sample the server's clock rather
-        # than this host's: create a scratch directory, take its
-        # time_modify, and remove it.
-        name = env.testname(t) + b"_clock"
-        res = sess1.compound(env.home + [op.savefh(),
-                                         op.create(createtype4(NF4DIR), name,
-                                                   {FATTR4_MODE: 0o755}),
-                                         op.getattr(1<<FATTR4_TIME_MODIFY),
-                                         op.restorefh(),
-                                         op.remove(name)])
-        check(res)
-        now = res.resarray[-3].obj_attributes[FATTR4_TIME_MODIFY]
+        now = _server_now(sess1, env, env.testname(t) + b"_clock")
         attrs2 = dict(attrs1)
         attrs2[FATTR4_TIME_ACCESS] = now
         attrs2[FATTR4_TIME_MODIFY] = now

-- 
2.56.1

