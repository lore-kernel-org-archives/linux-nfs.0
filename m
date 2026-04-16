Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9667432A3FF
	for <linux-nfs@vger.kernel.org>; Thu, 16 Apr 2026 18:15:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776363305; cv=none; b=iUF5zCID7JNY0RuWqTpxUChQ6EhpXBMgFoF8+S8nYxLhc+hUsxFh/8b7ihn+Vf7FzhSkWTeVEUp6bBcUe+RKhbM6npHvpVf8RxIWE9uJQbdcAv5FJ5hzmsd0+l2IXk2YexQeFVyogFHdfGiGAP7Qa6p5OSq6yRhg4sP9Ys58DNY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776363305; c=relaxed/simple;
	bh=AF2uPjlco0IMm2l95LwbXx3k/Dz4xmpDq5nwGVCuNug=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=D79Ut/eBRwmbZjmRST7Kg+RMHaTSxlHcV7K5sd9AuRg1a5TTRfSxToA+nTp5oQ9ou18BbysGgESLYP3zvycWDK8kIt0CjTKI/Lvc7U94zEqjlTTtZ8N1i118hqUDGUsMsptXJvzFAcxkyQqW58gFeY8E0JaoaYuIiqi+r+9P0w4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=qBIky52s; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="qBIky52s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB778C2BCB7;
	Thu, 16 Apr 2026 18:15:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776363305;
	bh=AF2uPjlco0IMm2l95LwbXx3k/Dz4xmpDq5nwGVCuNug=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=qBIky52sBmRQtgkoci8DPdA5ByuBeqhxYqd5OPUKKtR2Tjqc/uUBnK+J9BBmSEZkN
	 nETpNEmVNya9v2s5MetZQGrgpSl79E/BKz1vJtj1y+jiDqDRKEPMz55AMOSz4uHvig
	 Tar7n659vwub0Sn3cvrA92t6NcTdFEqxMjkF8ixr8chcH2c9tydqgp+5wPfpPR7D01
	 jz+ElrFfmrr+2ZEOr/fBxHdl361MM6699SaitC5t/ZMXevI3DuDmaUuS6ZjOuEFdfl
	 qmG5gbrIJGVb0oCVHdRlszkfwwRQgQwV8K+0osmcvvk7f1ZuRXd9LeW3VDzN+KOm0a
	 MkAu4aFi+JNMw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 16 Apr 2026 11:14:43 -0700
Subject: [PATCH pynfs v2 11/25] server41tests: test unrequested
 notification type triggers recall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260416-dir-deleg-v2-11-fad510db5941@kernel.org>
References: <20260416-dir-deleg-v2-0-fad510db5941@kernel.org>
In-Reply-To: <20260416-dir-deleg-v2-0-fad510db5941@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2060; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=AF2uPjlco0IMm2l95LwbXx3k/Dz4xmpDq5nwGVCuNug=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBp4ScgElHsh6eO0KcwzBFj4XKGuzvGrWXXJc/iR
 BTNIRiPdy2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaeEnIAAKCRAADmhBGVaC
 FbjsD/0T9Zb/MNXKK2/uB0lXEakJhZsvJAG5EY591xTh1GBIZ4EYCXDn1sKJYeGfgc44xxHq4k0
 +NNljqLOqPseO7XjhLxO5QlHU9lZqlw3ZxyNnQ9mRPPNYt4+524q2aYM/yQVB6cXEXiWjr2JbeF
 hIQgeBfUfAbA3Rolbg5S2yr6tmGU4swvlQh7KvE6x19Bw4zBa7pRdJeCnzGOuzbcaw3WJo6ejO0
 8Ad6uQiJGc4iN43VLt1yrNXO5cWwwDuvjWd5jdct8cx88iYuOZXBOcrJAdY/2ffibCfgtuNKxHF
 RKCmgByl730u4rXMxqTkjvrcWSf+oX0THuEVaxFLCRBFzJmGpIff+AB+OI3PJODxNkUolTZueN0
 PJuRL8LYKw9y41OAcifA9hat/bOj+JZOLtPT/X2+vOr8KMEL1h79ejCc6ReJuVY2BvlBYHc2/PM
 eTfu0PP492kbmxOAeJ2BJYHMNrmI1IMVGUjrZHMZ0LxuS9VDVhLaNog6cZGbyAnLAEiKIFC+B7s
 MoD5QIs02W7oVZeVqJyybcCfUSmNCtPSEFB4h4Put1GZFGd8oHjg0nDni5HHZNkMcjc3Uz0vgz3
 x6pOCiTVyyaIhbzTG5D5pgX/LzN4Jb4pCFip48fETCtZPY9Ik4wJW3iJuEiuzu+G1/GEigfW+/J
 dIDDYEHT7DfLxMA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Request a dir delegation with only REMOVE notifications. Trigger
an ADD event from a second client. Verify the server issues a
CB_RECALL instead of CB_NOTIFY since ADD was not requested.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_dir_deleg.py | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/nfs4.1/server41tests/st_dir_deleg.py b/nfs4.1/server41tests/st_dir_deleg.py
index 7d1e664a7923..d62ccb634056 100644
--- a/nfs4.1/server41tests/st_dir_deleg.py
+++ b/nfs4.1/server41tests/st_dir_deleg.py
@@ -297,3 +297,35 @@ def testDirDelegNoGflag(t, env):
         fail("Got CB_NOTIFY without GFLAG_EXTEND")
     if not cb.got_recall:
         fail("Expected CB_RECALL without GFLAG_EXTEND, but didn't get one")
+
+def testDirDelegFiltering(t, env):
+    """Verify unrequested notification type triggers recall
+
+    FLAGS: dirdeleg all
+    CODE: DIRDELEG8
+    """
+    c = env.c1
+    cb = threading.Event()
+    # Only request REMOVE notifications
+    sess1, fh, deleg = _getDirDeleg(t, env,
+                                     [NOTIFY4_REMOVE_ENTRY,
+                                      NOTIFY4_GFLAG_EXTEND], cb)
+
+    # Trigger an ADD event (not requested) from a second client
+    sess2 = c.new_client_session(b"%s_2" % env.testname(t))
+    claim = open_claim4(CLAIM_NULL, env.testname(t))
+    owner = open_owner4(0, b"owner")
+    how = openflag4(OPEN4_CREATE, createhow4(GUARDED4, {FATTR4_SIZE:0}))
+    open_op = [ op.putfh(fh), op.open(0,
+                                      OPEN4_SHARE_ACCESS_WRITE | OPEN4_SHARE_ACCESS_WANT_NO_DELEG,
+                                      OPEN4_SHARE_DENY_NONE, owner, how, claim) ]
+    slot = sess2.compound_async(open_op)
+    completed = cb.wait(2)
+    env.sleep(.1)
+
+    ops = [ op.putfh(fh), op.delegreturn(deleg) ]
+    res = sess1.compound(ops)
+    check(res)
+
+    if not cb.got_recall:
+        fail("Expected CB_RECALL for unrequested notification type")

-- 
2.53.0

