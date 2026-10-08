Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 763BF4EDCBF
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474455; cv=none; b=Roz47TeepUPrcEbWCkcaK1hazTYCMYiLDNunds+omo4Bqo/lYB1FFnHsru9NJaXv/Pjx5z1qGAl9ywPvbUB/gm0XPkwNVwC08BXK/X3aU9rcuw8y7LqRaWmEZmDbwmyVm5oYf1mHuhHxAcO0NIe0MDBuxvfxjLDlTZKODun6sjo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474455; c=relaxed/simple;
	bh=07OkTll3rq2+bo7cEHEruK9fau0IFI1tT4Swyrf/EJk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tBVDzFFX/UaIWbuVcO79NmeBiTMUppfRY6idodfO8YfqFFcbse73a90BZpTOiZgttp7t9sf+UPTWMGbGduEU2mUGMcd+fdNpHjF5BYZxTfeFJ0YAkkbioGRNot33ghprXP6y/NH6KDPIE7fvly7SYgTErx1x9+SLOmqVGVPb+8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eIYSPyP1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eIYSPyP1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 931D21F00898;
	Thu,  8 Oct 2026 15:47:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474451;
	bh=lE9tOOx+kL0DQGlSwnWsIzjfpZZdnsf5Gtagw/Eu1CE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=eIYSPyP1BXjKuUBolQTgWLMl8ixLf7l5ATTXHzUq4caVvmY0AfOAOHED52trFER2X
	 pSFLfytlM0tlERbtfkTjWO0OJddsOOqEr8dwfBcApzpCWUCtmDWgKSsqFBmbJHS+Hh
	 Q7EfBE20n/yX6GmLI/PgAc6wh2h/Ha1eoOrRWMu7MmSPrJiJYru4qa6lo12ALaZFqH
	 iw8d02A9ItF2Qa8aIHiwD1uG1SnWZcM9OIstkkKERxl9xn9b1MrM+q7dL9vgBMy/bt
	 Ljv7o7QOsd0Z6Oj948tazxvG8490bc+nNlkx50bL6r6DY1/92nC6W5FvCSbFBYkP50
	 Zt5Oi3nI0XLRQ==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/8] pynfs: add test for OPEN(CLAIM_FH) delegation request on an open file
Date: Thu,  8 Oct 2026 11:47:23 -0400
Message-ID: <20261008154729.77787-3-cel@kernel.org>
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

A client that wants a delegation on a file it already has open can
repeat the OPEN with CLAIM_FH, the same open-owner, and a want bit.
The server treats that OPEN as an upgrade of the existing open, and
no test checks that a delegation can come back from one.

Add DELEG28. It keeps the file open with WANT_NO_DELEG, then sends
OPEN(CLAIM_FH) with WANT_READ_DELEG from the same open-owner. The
reply has to carry a read delegation and the original open stateid
with its seqid incremented by one.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 41 +++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index c35ce8f5ec3b..56d227127a15 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -686,3 +686,44 @@ def testClaimFHReadDeleg(t, env):
     check(res)
     res = close_file(sess1, fh, stateid=stateid)
     check(res)
+
+def testClaimFHUpgradeReadDeleg(t, env):
+    """OPEN(CLAIM_FH) with WANT_READ_DELEG from an open-owner that
+       already has the file open
+
+    FLAGS: open deleg all
+    CODE: DELEG29
+    """
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    res = create_file(sess1, name, access=OPEN4_SHARE_ACCESS_READ |
+                      OPEN4_SHARE_ACCESS_WANT_NO_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    # The second pass is the retry that _open_claim_fh_retry() makes.
+    # Each OPEN bumps the seqid, so count them here.
+    seqid = stateid.seqid
+    for attempt in range(2):
+        res = _open_claim_fh(sess1, fh, name, OPEN4_SHARE_ACCESS_READ |
+                             OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
+        check(res)
+        seqid += 1
+        upgraded = res.resarray[-1].stateid
+        if upgraded.other != stateid.other:
+            fail("OPEN by the same open-owner returned a different stateid")
+        if upgraded.seqid != seqid:
+            fail("Expected open stateid seqid %i, got %i" %
+                 (seqid, upgraded.seqid))
+        deleg = res.resarray[-1].delegation
+        if _got_deleg(deleg):
+            break
+    if deleg.delegation_type != OPEN_DELEGATE_READ:
+        _delegreturn(sess1, fh, deleg)
+        fail("Expected a read delegation, got %s" % _deleg_desc(deleg))
+
+    res = sess1.compound([op.putfh(fh), op.delegreturn(deleg.read.stateid)])
+    check(res)
+    res = close_file(sess1, fh, stateid=upgraded)
+    check(res)
-- 
2.55.0

