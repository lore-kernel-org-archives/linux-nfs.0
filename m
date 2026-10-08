Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 964574EDCD5
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474463; cv=none; b=hLiwUoE6p9UsLPr26Ms+fpj1y1+hmTi2xCnO06BGUSJt8T3evDAef17909CGtagXAaMHsWmxAXTsnQzCyP9QxagCyD4DYCr0Q/iZA3xVtSiCLg9aq6M7McwuHgO3zZuPpWApWEKrmwt9E1s53nYtzDTRgAMpJ8TffjQLD9xr/oY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474463; c=relaxed/simple;
	bh=qQZScXblnTgZ6boNd46OtjaoT0fKsdtISnfIJX2B5+o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=avDaV1o/XD7cR2Na2fOsPwFea8GqHFcWfiEEpo4weqk8k1I96RB9UwBmj0yjduc9GLg2JKh+NgfX6J7h6Br5yFHInB7CXRCK3eDrHWxnSfPX9IjEVdj38otsp7oP8s/YrL8UrP1Q4iy0YvI/RrxYsbeMuIKbHiR1FnUmZSP73H8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a2zwCo65; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a2zwCo65"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 906761F0089D;
	Thu,  8 Oct 2026 15:47:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474454;
	bh=nCFz3lVVPbKw0on90XTmrmOdYU55CSEFV6ignfhIvA8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=a2zwCo65NipfYVi4Bo+ubv8DCJ+YLoS9BOHOrROtjntftP6jN4Q00WuwgtCRJjCeO
	 P/tVE9ZmKr8rhxGz/mMQbR4w6Czx8Cv3iJaBORsMG/Vv5r87wLFiSGMs+81nrZnlVv
	 8lKVORejrJa+6wgrZ632BNLcC1udhYfjVkd3i/3PBFfpd9ddb8vv3nkGcQM5CHCs+7
	 aOyMdgMapj+kVARu+mCGuJ9YQzc6Fq6VAfWche01Sx/OCKGJ8mwIUSems/sm9r0G2V
	 3audRVIZuMmlwhugs58x1wAkpVeLrhMl+tSDIu9VlaWp1/BPSATztLOmUwFxeOqMGL
	 fh0CZCGqYhzOA==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 8/8] pynfs: add test for OPEN with WANT_CANCEL
Date: Thu,  8 Oct 2026 11:47:29 -0400
Message-ID: <20261008154729.77787-9-cel@kernel.org>
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

RFC 8881 Section 18.16.3 defines WND4_CANCELLED as the reason a
server gives when an OPEN sets OPEN4_SHARE_ACCESS_WANT_CANCEL. No
test sends that want, so a server that answers with another reason
goes unnoticed. NFSD reports WND4_NOT_WANTED.

Add DELEG36. It creates a file with WANT_CANCEL and fails unless the
reply carries OPEN_DELEGATE_NONE_EXT with ond_why set to
WND4_CANCELLED.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 29d8341762d8..5af83c8744c4 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -1006,3 +1006,27 @@ def testWriteDelegDowngrade(t, env):
                      OPEN4_SHARE_ACCESS_READ |
                      OPEN4_SHARE_ACCESS_WANT_READ_DELEG, OPEN_DELEGATE_READ,
                      WND4_NOT_SUPP_DOWNGRADE)
+
+def testWantCancel(t, env):
+    """OPEN with WANT_CANCEL gets no delegation and WND4_CANCELLED
+
+    FLAGS: open deleg all
+    CODE: DELEG37
+    """
+    sess1 = env.c1.new_client_session(b"%s_1" % env.testname(t))
+    res = create_file(sess1, env.testname(t),
+                      access=OPEN4_SHARE_ACCESS_READ |
+                      OPEN4_SHARE_ACCESS_WANT_CANCEL)
+    check(res)
+    fh = res.resarray[-1].object
+    deleg = res.resarray[-2].delegation
+    _delegreturn(sess1, fh, deleg)
+    res = close_file(sess1, fh, stateid=res.resarray[-2].stateid)
+    check(res)
+    if deleg.delegation_type == OPEN_DELEGATE_NONE:
+        fail("Got OPEN_DELEGATE_NONE, expected OPEN_DELEGATE_NONE_EXT")
+    if deleg.delegation_type != OPEN_DELEGATE_NONE_EXT:
+        fail("Got a delegation (type %d) despite WANT_CANCEL" %
+             deleg.delegation_type)
+    if deleg.ond_why != WND4_CANCELLED:
+        fail("Got ond_why %d, expected WND4_CANCELLED" % deleg.ond_why)
-- 
2.55.0

