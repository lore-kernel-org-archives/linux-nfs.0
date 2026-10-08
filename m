Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D3154EE844
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474460; cv=none; b=g4Wpad6yi1zadgDVlQALU1fvKKNEwkFrgubkNWxxk3ZZOD3VmO+p9QnZPZryNgrPpf8AShbZLu6oNL1z7ySOAkPa3Vqltw+OsHoSmhd3rAcBRVxZSgZW21DOPKt8rUzx7QUMKZwfqjz7qqoFk0PsuEYGCkC6eUihHi2SOLclD0I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474460; c=relaxed/simple;
	bh=cbuVKOMw+0RNG7knbVNXNzYHg6h+EBDjkL7x87aV4sI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bZadV0plD83Eq1xk5LqIclRxIIKD9SJ5OS2Kvio4Pg7k+TP1rk9FgaOvNk3/HvomBx9W3rB/kynW2/Xsnmv6F5J9ZKpySVKYPARfeEtUJ5vLNIPAfKQkDT27xNnDfPEHjfqaOA9JN7dySUkRO2aDNGubgzqzcaZ4cgDomGI7We0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DKpm9eaN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DKpm9eaN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13C7E1F0089E;
	Thu,  8 Oct 2026 15:47:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474454;
	bh=zpmBdQv6GufzR1q07ed+Cgg0BhaY/AnnbM94/fhdKwg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DKpm9eaNOqUMUgPrCkC6laqjUXCL0edEaIShRFsclnFBohLkI5xHsjVvxqkRyU43R
	 iXMKHrL4haiS7Ve59RxBfDj5eybZCks8pWTJoodehoG9uhxz8u1S/vUjCattLTKBCd
	 IMS/T5Vhy625JimDMMMx8zhGiIfJMOpus1Wd9XzrZe+yyPjmyErR5Fy8ZBYsJ6/Ofj
	 oa/m0dt+JA9KQ4K8rHNua2bNvg0Vuo3u9Xz5y34PeXqWnAjSh0ilkdkNJ9O64qXrFe
	 fDwGuI4Ps9e2qtlnLVRPI3kX884M3SUKLGuh2Ubx1S8nRzRW2xWvr86tBF9UL/zqEc
	 TZOajMf6ShEQg==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 7/8] pynfs: add tests for delegation upgrade and downgrade wants
Date: Thu,  8 Oct 2026 11:47:28 -0400
Message-ID: <20261008154729.77787-8-cel@kernel.org>
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

RFC 8881 Section 18.16.3 treats a want for the other delegation
type, from a client that already holds a delegation on the file, as
a request to upgrade or downgrade it. A server that supports neither
has to say so with WND4_NOT_SUPP_UPGRADE or WND4_NOT_SUPP_DOWNGRADE.
No test sends a want while a delegation is held, so a server that
gives another reason goes unnoticed.

Add DELEG34 and DELEG35. Each takes a delegation, then sends
OPEN(CLAIM_FH) from a second open-owner with a want for the other
type. The reply has to carry either a delegation of the wanted type
or the matching reason. DELEG35 reports UNSUPPORTED when the server
grants no write delegation to start from.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 57 +++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 3b6ca1d3b005..29d8341762d8 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -949,3 +949,60 @@ def testClaimFHDelegAfterClose(t, env):
     check(res)
     res = close_file(sess1, fh, stateid=stateid)
     check(res)
+
+def _testDelegXgrade(t, env, access, held_type, want_access, want_type, why):
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    fh, stateid, deleg = __create_file_with_deleg(sess1, name, access)
+    if deleg.delegation_type != held_type:
+        _delegreturn(sess1, fh, deleg)
+        t.fail_support("Wanted %s, got %s" %
+                       (open_delegation_type4[held_type], _deleg_desc(deleg)))
+
+    res = _open_claim_fh(sess1, fh, b"%s_2" % name, want_access)
+    check(res)
+    stateid2 = res.resarray[-1].stateid
+    xgrade = res.resarray[-1].delegation
+    if xgrade.delegation_type == want_type:
+        deleg = xgrade
+
+    # Return the delegation first, so that a failure does not leave it
+    # behind to block the removal of the test file
+    _delegreturn(sess1, fh, deleg)
+    res = close_file(sess1, fh, stateid=stateid2)
+    check(res)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
+
+    if (xgrade.delegation_type != want_type and
+        (xgrade.delegation_type != OPEN_DELEGATE_NONE_EXT or
+         xgrade.ond_why != why)):
+        fail("Expected %s or %s, got %s" %
+             (open_delegation_type4[want_type], why_no_delegation4[why],
+              _deleg_desc(xgrade)))
+
+def testReadDelegUpgrade(t, env):
+    """WANT_WRITE_DELEG from the holder of a read delegation gets a
+       write delegation or WND4_NOT_SUPP_UPGRADE
+
+    FLAGS: open deleg all
+    CODE: DELEG35
+    """
+    _testDelegXgrade(t, env, OPEN4_SHARE_ACCESS_READ |
+                     OPEN4_SHARE_ACCESS_WANT_READ_DELEG, OPEN_DELEGATE_READ,
+                     OPEN4_SHARE_ACCESS_BOTH |
+                     OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG, OPEN_DELEGATE_WRITE,
+                     WND4_NOT_SUPP_UPGRADE)
+
+def testWriteDelegDowngrade(t, env):
+    """WANT_READ_DELEG from the holder of a write delegation gets a
+       read delegation or WND4_NOT_SUPP_DOWNGRADE
+
+    FLAGS: writedelegations deleg all
+    CODE: DELEG36
+    """
+    _testDelegXgrade(t, env, OPEN4_SHARE_ACCESS_BOTH |
+                     OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG, OPEN_DELEGATE_WRITE,
+                     OPEN4_SHARE_ACCESS_READ |
+                     OPEN4_SHARE_ACCESS_WANT_READ_DELEG, OPEN_DELEGATE_READ,
+                     WND4_NOT_SUPP_DOWNGRADE)
-- 
2.55.0

