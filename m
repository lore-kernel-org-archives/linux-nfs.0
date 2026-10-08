Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 229BF4EE841
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474458; cv=none; b=KlQRfshO1vhntn8aQwwlK2n2RwRZHG5MZPhZQZlUFteKMss30IsH5bOK/n+J16b1UCwa4ZZYgBiYt8lgE+HSxyzdek9VwolqmBmRKTAa7+moh+2M5huY3uHjA+aaXdAct+X229RJQ5XRDWS9rKAoiJ02s6u13KYfferGfkHu1tY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474458; c=relaxed/simple;
	bh=GBwRq2iRz4lczO11qIeMFx5dYpaaP/bVdyYnxpXMhjU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=W57N9sv/eWZcLHxKChWXj0aRnFxjnsEoBh7eOPNZCiJVVuQSCB6Xl+/1t/RKHJBZvHMTbEy+Mr75Qn8vjO3cFEEUZks3+anrXJn2WiR1u96kR6qtuhmdcyTcUDJMPomrobVAbKDmGVmLY/aRMIEHTMaWrG730rtu6pJRQ1hcc24=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bR1RqHka; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bR1RqHka"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 137F61F0089B;
	Thu,  8 Oct 2026 15:47:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474453;
	bh=w0VUGn+f96Ncm5+kLJv+nQB+4vlzpM4528C4/DcgHNU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bR1RqHkaQtUfg5GVBf5lUgBzoIpKhc4EzXu7gkRnS309PUfjKas0WOduyAds2JvOc
	 IzMXJjdexCfxg3OWpe0Zb9M70O/7/Be+6NvtcJWnsBbAporNC9e1AYERVodlm2fnzQ
	 KdDpdKDt90J44T4WensE/KN6o/AJFsMrQsx5moTC09kM3g9Ydwo954khmETwxvFqFt
	 a3yDWBU3BZCVe0UB8PcD6kiIibKVS6C5D+fa5/ZKqyJGvap29yxeeI8eRZ/qrSPwfa
	 LMUtWO0CAejK11mKm9Rp1egZ8c7DCJ1GSsBTvtNK4OsRLNP/ykzVOL4rrEi4tbdxx+
	 ALuhmq4XcI4DA==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 5/8] pynfs: add test for WANT_OPEN_XOR_DELEGATION through CLAIM_FH
Date: Thu,  8 Oct 2026 11:47:26 -0400
Message-ID: <20261008154729.77787-6-cel@kernel.org>
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

An OPEN(CLAIM_FH) from the open-owner that already has the file open
bumps the seqid of that owner's open stateid, even when the client
only wants a delegation. RFC 9754 gives the client a way around
that: send the OPEN from a second open-owner with
OPEN4_SHARE_ACCESS_WANT_OPEN_XOR_DELEGATION, and the server returns
the delegation alone. No test exercises XOR.

Add DELEG32. It holds the file open under one open-owner and sends
the XOR request from another. The reply has to carry a read
delegation and OPEN4_RESULT_NO_OPEN_STATEID, and the first owner's
open stateid has to keep its seqid. The test reports UNSUPPORTED
when the open_arguments attribute does not advertise XOR.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 59 +++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 198555ce9b9d..a8b7ea54a772 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -859,3 +859,62 @@ def testReadDelegHolderSetattr(t, env):
     _testHolderSetattr(t, env, OPEN4_SHARE_ACCESS_READ |
                        OPEN4_SHARE_ACCESS_WANT_READ_DELEG,
                        OPEN_DELEGATE_READ)
+
+def testClaimFHXorDeleg(t, env):
+    """OPEN(CLAIM_FH) with WANT_OPEN_XOR_DELEGATION from a second
+       open-owner returns a delegation and no open stateid
+
+    FLAGS: open deleg all
+    CODE: DELEG33
+    """
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    res = sess1.compound([op.putrootfh(),
+                          op.getattr(nfs4lib.list2bitmap([FATTR4_OPEN_ARGUMENTS]))])
+    check(res)
+    caps = res.resarray[-1].obj_attributes
+    xor = 1 << OPEN_ARGS_SHARE_ACCESS_WANT_OPEN_XOR_DELEGATION
+    if (FATTR4_OPEN_ARGUMENTS not in caps or
+        not caps[FATTR4_OPEN_ARGUMENTS].oa_share_access_want & xor):
+        t.fail_support("Server does not advertise WANT_OPEN_XOR_DELEGATION")
+
+    res = create_file(sess1, name, access=OPEN4_SHARE_ACCESS_READ |
+                      OPEN4_SHARE_ACCESS_WANT_NO_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    owner2 = b"%s_2" % name
+    access = (OPEN4_SHARE_ACCESS_READ | OPEN4_SHARE_ACCESS_WANT_READ_DELEG |
+              OPEN4_SHARE_ACCESS_WANT_OPEN_XOR_DELEGATION)
+    res = _open_claim_fh(sess1, fh, owner2, access)
+    check(res)
+    if not _got_deleg(res.resarray[-1].delegation):
+        # Close first, so that the retry is not an upgrade of this open
+        res = close_file(sess1, fh, stateid=res.resarray[-1].stateid)
+        check(res)
+        res = _open_claim_fh(sess1, fh, owner2, access)
+        check(res)
+    deleg = res.resarray[-1].delegation
+    if deleg.delegation_type != OPEN_DELEGATE_READ:
+        fail("Expected a read delegation, got %s" % _deleg_desc(deleg))
+    if not res.resarray[-1].rflags & OPEN4_RESULT_NO_OPEN_STATEID:
+        _delegreturn(sess1, fh, deleg)
+        fail("Got a delegation, but OPEN4_RESULT_NO_OPEN_STATEID is not set")
+
+    # An OPEN by the first open-owner bumps its seqid once. Any other
+    # seqid means the second open-owner's OPEN changed that stateid.
+    res = _open_claim_fh(sess1, fh, name, OPEN4_SHARE_ACCESS_READ |
+                         OPEN4_SHARE_ACCESS_WANT_NO_DELEG)
+    check(res)
+    upgraded = res.resarray[-1].stateid
+    if upgraded.other != stateid.other:
+        fail("OPEN by the same open-owner returned a different stateid")
+    if upgraded.seqid != stateid.seqid + 1:
+        fail("Expected open stateid seqid %i, got %i" %
+             (stateid.seqid + 1, upgraded.seqid))
+
+    res = sess1.compound([op.putfh(fh), op.delegreturn(deleg.read.stateid)])
+    check(res)
+    res = close_file(sess1, fh, stateid=upgraded)
+    check(res)
-- 
2.55.0

