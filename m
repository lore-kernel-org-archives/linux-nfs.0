Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE04B3C73F7
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474456; cv=none; b=CUpQAG9WjN796FIQk7TsvQWQtsfgpwpSR2gIFxYd90xFzUU/pY/Ar3r4HHqU5u3suvchdlfejGPGrH+eOdzCffpUDqgW+u1KYc/5Mmsb4o4dafSenFgMfLNVDDgWYu3IsBjOj44ZWxBLP0XQvAnbVcLlcRK/9/VhRoIotMf6tok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474456; c=relaxed/simple;
	bh=GBSrVB1c9GBxwmj+2W4iiiTGH11/Ak/y+EEvavoH/Dc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YOlusKAw9Ve5IfyAkzXqPFiYhib47wJtntzGJcU3ruIY43LvT5B5agddPzLqCLRvMM90Kv0hVJ6usTgdG+7vlVHjd+/bn6K59R0ndoMxuHSGjKlAXtZZJICb9knkCWwJKmr5uKe1D7Dul+2XDhc8ZOKev6eiU29rDv9NN6jDf34=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=izQgDrT2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="izQgDrT2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8A31E1F0089C;
	Thu,  8 Oct 2026 15:47:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474453;
	bh=fjjkw5wL1o22weQ7Sl9cB5m9x0AxA0m0V7siTWncAKQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=izQgDrT2iCGJ9/FsnNcdhgj3v79Dm9uxH0E4pxWNiC/zLDlJTsGYiX3axuzyukNkp
	 W+sV87snGqCOMYcOdFhm7p8ssnBngrqnsm6jOR9zXXwguX1hW7rl36IcGmI/e2K3/a
	 +9lwWjZoenPu4NzR9w8L7nTz3PZj5vyGfUCoudfpvEAfDd+Kz/eDffwUgp3ELw9q5h
	 xzsCWhMP02/+32OYryIEMfW0za/UEDlESt44dlF2dXa+w1nmXSURjF10wCRkKElMrM
	 +hPDYywV3iCFpyIUiDEByxgZs3EVSTIaiYL+bqxF/dsdeGwimRyxW41JXPX95yON4L
	 TcSAml8kFX++Q==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 6/8] pynfs: add test for a CLAIM_FH delegation that outlives its open
Date: Thu,  8 Oct 2026 11:47:27 -0400
Message-ID: <20261008154729.77787-7-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261008154729.77787-1-cel@kernel.org>
References: <20261008154729.77787-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On a server without WANT_OPEN_XOR_DELEGATION, a client can still get
a delegation without disturbing its existing open stateid. It sends
OPEN(CLAIM_FH) from a second open-owner and closes that open once
the delegation arrives. DELEG26 shows a delegation outliving the
CLOSE of a CLAIM_NULL open by the only open-owner. No test covers a
second open-owner or CLAIM_FH.

Add DELEG33. It holds the file open under one open-owner, obtains a
read delegation with OPEN(CLAIM_FH) from another, closes the second
owner's open, and expects TEST_STATEID to accept the delegation
stateid.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 31 +++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index a8b7ea54a772..3b6ca1d3b005 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -918,3 +918,34 @@ def testClaimFHXorDeleg(t, env):
     check(res)
     res = close_file(sess1, fh, stateid=upgraded)
     check(res)
+
+def testClaimFHDelegAfterClose(t, env):
+    """A delegation from OPEN(CLAIM_FH) by a second open-owner outlives
+       the CLOSE of that owner's open
+
+    FLAGS: open deleg all
+    CODE: DELEG34
+    """
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    res = create_file(sess1, name, access=OPEN4_SHARE_ACCESS_READ |
+                      OPEN4_SHARE_ACCESS_WANT_NO_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    res = _open_claim_fh_retry(sess1, fh, b"%s_2" % name,
+                               OPEN4_SHARE_ACCESS_READ |
+                               OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
+    deleg = res.resarray[-1].delegation
+    if deleg.delegation_type != OPEN_DELEGATE_READ:
+        _delegreturn(sess1, fh, deleg)
+        fail("Expected a read delegation, got %s" % _deleg_desc(deleg))
+    res = close_file(sess1, fh, stateid=res.resarray[-1].stateid)
+    check(res)
+    _check_deleg_stateid(sess1, deleg.read.stateid)
+
+    res = sess1.compound([op.putfh(fh), op.delegreturn(deleg.read.stateid)])
+    check(res)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
-- 
2.55.0

