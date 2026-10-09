Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 075844F3908
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563721; cv=none; b=X+aNa/fbncEYGuxPng+gNpeGYWvrKU5+F4jLFBCa8iRXpYH5vzxv+X0m1u3P3C1gH5SJWOqIovDGYrtGTBmW55zf7/wRR3m25DqyRQkTrnrTB5FCIVRNAbQgO5Ui+UrBMzTeUgT9nUyrcvhVVTfZBf+cysDKzvBJFAHUEHXFoF0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563721; c=relaxed/simple;
	bh=Z6bIcYlxXrtnqG4kRu3HDNXBGBMJrvJiQ9dbx1foXZM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rfk2Cuxh1EbVKhR98zfNQAsgsHuAuyKg86BSQfTyU6OKpSYCpFdcSjRPlvCmfEHiLFRjzezCZIKqaIwiMHfr2jqRxmS+qOXPZlUxxsD3+uWB752XHSujxLfgFTx09XO8EZskaRgWLzAAgZ5f60YKnVGOSGj5nwHf4/sd4qRes8o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T8M4GmpL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T8M4GmpL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1ACCD1F0089E;
	Fri,  9 Oct 2026 16:35:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563710;
	bh=nZ2fNoXgw5vmj50k7n317JLzi9weMVqqa+pqgYPsYQE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=T8M4GmpLrFSxETs2S3LWBBOKq3jvEFKbcu6V9rAjyEieCgLOHuQ7dWtJZsFdgFnoK
	 z4R0eN63CsmdXh6SOVhQykn4emr2CgREnWDa5NJEFqIlCuGQrYZxrdpN5/EgHKa9Mo
	 vk4Y71BMDwxJ7JL4ULr43ntHclSDJFS9CopyWqifUDeavBRUBwDv+9m9wzZbiHGzV3
	 kdG21ZzoC0xqUOusTWLHx1syqINUAUxFuTBy6Zpngwtuuk/JmnLkkpQ5H37S//pI22
	 66jfXlE/vSTYXe0CsCZk6ve007nE0TiuiQy/Zq5g7QqC7PX5XKSzvVMmGgeeyI6WPA
	 jXBt20TVgq6kA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:35:02 -0400
Subject: [PATCH pynfs v3 8/9] Add tests for SETATTR with MODE and ACL
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20261009-acl-mode-v3-8-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=31800; i=cel@kernel.org;
 h=from:subject:message-id; bh=ILLD3MBHp8fUkrKWxwLcmkA2ow8WH6Y8yppW4EZNcao=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5CYI5QkQLJSdthT2HCHTjncFtdOGoUhBsV
 2S9mCMZhqCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 l1lUD/9ve7MbrQULRVnbL0o6KQ3ccz1JwQj+X0DuYqC9wmxQezKEe1Zj+3d1uKIdl6dZEDjN/IU
 Z/Kvhm/zjwgjjyrgqO1z7CHFdiMsgl2FZBXTI2f4Zs1Cws0QQwnXIgicxYXC7jCaCr5onZ4iKte
 ou3fpo9UutmzGQXLg1Orkr+qpU5bsClGiSvwLWLgd/bzvqkmj6wBw3N/xim4hRbxaaG6j7MnxPj
 TphRkOWYcbpIM4sg8AL4bidGADFK3mUW1iU9VkXvXl1u6HurFyVCsaxbjHH+VAPkZq0My5GYJLL
 FT0miMleQVgnp8cCy/FiOrpu46wMMXguwQ3AqPa2+920lb/C7sntNVDoG4yo6X2CIDA4BaAP4Bb
 uvg92voOzsdkJOLP/G+rqUU7Z7uWvx68Ed4wADVErBJItCEhRmPMefKtndy8q6HjTyMpPZaBz2K
 HCPdeZ2E5CvNSlPSJa2ckIH5PMI7VrKndH9SKhVbhfi5vN+qCW0Z4gO7hosBeykXLjAt4mTNsLK
 Lk8Z+O8Z6/HhVvgTTMomDEBkC1UYbaUM4eY0EFI0QaKFdCe0MCCXrx8nZjBbUZevHr/qFejKz30
 d2+LkP9rHnJvWg4srEGCuUQuWaZulRBVUYizPMoNKrE7KEi4XVYKvqf8nV5mEarkTuW/SPnqeJ1
 VtBsi4wdP3FvZMA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

Add comprehensive tests that verify SETATTR behavior when both
mode bits and an ACL are set simultaneously. The new tests cover:

1. SATT19: testSetattrModeWithACL
 - Sets MODE and ACL in a single SETATTR, once each with a MODE the
   ACL widens (0o640, 0o600) and one more restrictive than the ACL
   grants (0o400)
 - Verifies both attributes appear in attrsset, the ACL is stored as
   given, and the final mode is derived from the ACL rather than
   taken from the requested MODE
2. SATT22: testSetattrACLThenMode
 - Compares setting MODE+ACL together vs separately in sequence
 - Creates two files and verifies consistent behavior

These tests ensure that servers correctly handle the interaction
between MODE and ACL attributes when setting file attributes, and
verify that the ACL specified in the OPEN operation matches the ACL
after the OPEN completes.

SETATTR: ACL-to-mode verification tests

These new tests verify:

- Mode is correctly derived from ACL per RFC 8881 §6.3.2
- Write bit requires both ACE4_WRITE_DATA and ACE4_APPEND_DATA
- ACL evaluation order (first ACE takes precedence)
- EVERYONE@ ACEs affect all three permission classes
- Complex ACLs with multiple identifiers

SETATTR: Two additional ACL verification tests

New test SATT28: Verify that the final ACL is the same no matter what
the file's previous mode bits were.

New test SATT29: Verify that SETATTR(ACL) preserves high-order mode
bits (SUID/SGID/SVTX).

SETATTR: Verify behavior when setting both MODE and ACL

Add three comprehensive tests that verify SETATTR(MODE+ACL) behavior
per RFC 8881 §6.4.1.3:

SATT30:
Verify attrsset bitmap and final mode consistency when MODE+ACL set
together. The server must report both MODE and ACL in attrsset, and
the final mode must match what the ACL derives to per §6.4.1.3.

SATT31:
Test MODE+ACL interaction when they conflict significantly.
Regardless of requested MODE, final mode always matches ACL
derivation. This shows that ACL wins when both are set (per
§6.4.1.3: "possibly changing the final mode").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.0/servertests/st_setattr.py | 728 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 727 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index 5d51054c29b4..2dd496503f48 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -1,9 +1,10 @@
 from xdrdef.nfs4_const import *
 from .environment import check, get_invalid_utf8strings
 from nfs4lib import bitmap2list, dict2fattr
-from xdrdef.nfs4_type import nfstime4, settime4
+from xdrdef.nfs4_type import nfstime4, settime4, nfsace4
 import nfs_ops
 op = nfs_ops.NFS4ops()
+import nfs4acl
 
 def _set_mode(t, c, file, stateid=None, msg=" using stateid=0",
               warnlist=[]):
@@ -783,3 +784,728 @@ def testMixed(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.word(), deny=OPEN4_SHARE_DENY_NONE)
     _set_mixed(t, c, fh)
+
+def testSetattrModeWithACL(t, env):
+    """SETATTR with both MODE and ACL attributes
+
+    Per RFC 8881 Section 6.4.1.3, when both MODE and ACL are set together,
+    both are processed, but the final mode is derived from the ACL and may
+    differ from the requested MODE. The requested MODE is varied from one
+    that the ACL widens to one more restrictive than the ACL grants.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT19
+    """
+    c = env.c1
+    c.init_connection()
+    acl = nfs4acl.make_test_acl()
+
+    for mode in (0o640, 0o600, 0o400):
+        fh, stateid = c.create_confirm(t.word() + (b"_%o" % mode))
+
+        # Set both MODE and ACL in a single SETATTR
+        attrs = {FATTR4_MODE: mode, FATTR4_ACL: acl}
+        ops = c.use_obj(fh) + [c.setattr(attrs)]
+        res = c.compound(ops)
+        check(res, msg="SETATTR with MODE 0%o and ACL" % mode)
+
+        # Check which attributes were actually set by examining the reply bitmask
+        attrsset = bitmap2list(res.resarray[-1].attrsset)
+
+        # Verify both MODE and ACL were set (processed)
+        if FATTR4_MODE not in attrsset:
+            t.fail("MODE not in attrsset, but MODE 0%o was requested" % mode)
+        if FATTR4_ACL not in attrsset:
+            t.fail("ACL not in attrsset, but ACL was requested with MODE 0%o"
+                   % mode)
+
+        # Verify ACL was set correctly and the mode derived from it
+        attrs_dict = c.do_getattrdict(fh, [FATTR4_ACL, FATTR4_MODE])
+        try:
+            nfs4acl.verify_mode_and_acl(attrs_dict, acl,
+                                        "SETATTR with MODE 0%o" % mode)
+        except AssertionError as e:
+            t.fail(str(e))
+
+def testSetattrACLThenMode(t, env):
+    """SETATTR MODE+ACL together vs ACL then MODE separately
+
+    Per RFC 8881 sections 6.4.1.1-6.4.1.3, when MODE and ACL are set
+    together in a single SETATTR, the server computes the final mode
+    from the ACL (the MODE attribute is effectively ignored). When
+    ACL is set first and MODE is set in a separate operation, the
+    final mode is the explicitly-set MODE value.
+
+    This test verifies this difference by using a MODE (0o755) that
+    differs from the ACL-derived mode (0o644).
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT22
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # Create two test files
+    fh1, stateid1 = c.create_confirm(t.word() + b"_1")
+    fh2, stateid2 = c.create_confirm(t.word() + b"_2")
+
+    # make_test_acl() derives to mode 0o644 (rw-r--r--)
+    acl = nfs4acl.make_test_acl()
+    acl_derived_mode = acl2mode_rfc8881(acl)
+
+    # Use a different mode to demonstrate the RFC-defined difference
+    explicit_mode = 0o755
+
+    # File 1: Set MODE and ACL together
+    # Per RFC 8881 Section 6.4.1.2, mode is derived from ACL (MODE ignored)
+    attrs = {FATTR4_MODE: explicit_mode, FATTR4_ACL: acl}
+    ops = c.use_obj(fh1) + [c.setattr(attrs)]
+    res = c.compound(ops)
+    check(res, msg="SETATTR with MODE and ACL together")
+
+    # File 2: Set ACL first, then MODE separately
+    # Per RFC 8881 Section 6.4.1.1, final mode is the explicit MODE value
+    ops = c.use_obj(fh2) + [c.setattr({FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR with ACL")
+
+    ops = c.use_obj(fh2) + [c.setattr({FATTR4_MODE: explicit_mode})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR with MODE after ACL")
+
+    # Verify the modes differ as expected per RFC 8881
+    attrs1 = c.do_getattrdict(fh1, [FATTR4_MODE, FATTR4_ACL])
+    attrs2 = c.do_getattrdict(fh2, [FATTR4_MODE, FATTR4_ACL])
+
+    mode1 = attrs1[FATTR4_MODE] & 0o777
+    mode2 = attrs2[FATTR4_MODE] & 0o777
+
+    # File 1 (MODE+ACL together): mode should be derived from ACL
+    if mode1 != acl_derived_mode:
+        t.fail("MODE+ACL together: expected ACL-derived mode 0%o, got 0%o"
+               % (acl_derived_mode, mode1))
+
+    # File 2 (ACL then MODE): mode should be explicit MODE value
+    if mode2 != explicit_mode:
+        t.fail("ACL then MODE: expected explicit mode 0%o, got 0%o"
+               % (explicit_mode, mode2))
+
+def testSetattrACLModeDeriveBasic(t, env):
+    """SETATTR(ACL) should derive mode per RFC 8881 Section 6.3.2
+
+    Test basic mode derivation from ACL when setting ACL alone.
+    The mode's permission bits should match what is computed from the ACL.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT23
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    fh, stateid = c.create_confirm(t.word())
+
+    # Create ACL: OWNER@ gets read+write+execute, others get nothing
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_DENIED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                b"GROUP@"),
+        nfsace4(ACE4_ACCESS_DENIED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                b"EVERYONE@")
+    ]
+
+    # Set ACL only (not MODE)
+    ops = c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR with ACL only")
+
+    # Get resulting mode
+    attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+    returned_mode = attrs[FATTR4_MODE] & 0o777
+
+    # Compute expected mode from the requested ACL per RFC 8881 Section 6.3.2
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if returned_mode != expected_mode:
+        t.fail("Mode (0%o) does not match RFC 8881 Section 6.3.2 derivation "
+               "from ACL (expected 0%o)" % (returned_mode, expected_mode))
+
+def testSetattrACLModeDeriveWriteBits(t, env):
+    """SETATTR(ACL) write bit requires BOTH WRITE_DATA and APPEND_DATA
+
+    Per RFC 8881 Section 6.3.2, the write mode bit should only be set if BOTH
+    ACE4_WRITE_DATA and ACE4_APPEND_DATA are present in the ACL.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT24
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # Test 1: Only WRITE_DATA (no APPEND_DATA) - write bit should NOT be set
+    fh1, stateid1 = c.create_confirm(t.word() + b"_1")
+    acl1 = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_WRITE_DATA,  # Missing APPEND_DATA
+                b"OWNER@")
+    ]
+    ops = c.use_obj(fh1) + [c.setattr({FATTR4_ACL: acl1})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR ACL with only WRITE_DATA")
+
+    attrs1 = c.do_getattrdict(fh1, [FATTR4_MODE, FATTR4_ACL])
+    mode1 = attrs1[FATTR4_MODE] & 0o777
+    expected_mode1 = acl2mode_rfc8881(acl1)
+
+    if mode1 != expected_mode1:
+        t.fail("Mode (0%o) with only WRITE_DATA does not match expected (0%o). "
+               "Write bit should NOT be set without APPEND_DATA." %
+               (mode1, expected_mode1))
+
+    # Test 2: Only APPEND_DATA (no WRITE_DATA) - write bit should NOT be set
+    fh2, stateid2 = c.create_confirm(t.word() + b"_2")
+    acl2 = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_APPEND_DATA,  # Missing WRITE_DATA
+                b"OWNER@")
+    ]
+    ops = c.use_obj(fh2) + [c.setattr({FATTR4_ACL: acl2})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR ACL with only APPEND_DATA")
+
+    attrs2 = c.do_getattrdict(fh2, [FATTR4_MODE, FATTR4_ACL])
+    mode2 = attrs2[FATTR4_MODE] & 0o777
+    expected_mode2 = acl2mode_rfc8881(acl2)
+
+    if mode2 != expected_mode2:
+        t.fail("Mode (0%o) with only APPEND_DATA does not match expected (0%o). "
+               "Write bit should NOT be set without WRITE_DATA." %
+               (mode2, expected_mode2))
+
+    # Test 3: Both WRITE_DATA and APPEND_DATA - write bit SHOULD be set
+    fh3, stateid3 = c.create_confirm(t.word() + b"_3")
+    acl3 = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_WRITE_DATA | ACE4_APPEND_DATA,  # Both present
+                b"OWNER@")
+    ]
+    ops = c.use_obj(fh3) + [c.setattr({FATTR4_ACL: acl3})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR ACL with both WRITE_DATA and APPEND_DATA")
+
+    attrs3 = c.do_getattrdict(fh3, [FATTR4_MODE, FATTR4_ACL])
+    mode3 = attrs3[FATTR4_MODE] & 0o777
+    expected_mode3 = acl2mode_rfc8881(acl3)
+
+    if mode3 != expected_mode3:
+        t.fail("Mode (0%o) with WRITE_DATA+APPEND_DATA does not match "
+               "expected (0%o)" % (mode3, expected_mode3))
+
+def testSetattrACLModeDeriveAllowDeny(t, env):
+    """SETATTR(ACL) with ALLOW/DENY interaction
+
+    Test that ACL evaluation order is correct when mixing ALLOW and DENY ACEs.
+    Per RFC 8881 Section 6.3.2, evaluate ACEs in order, with earlier ACEs taking
+    precedence.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT25
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # Test: ALLOW first, then DENY - the ALLOW should win
+    fh, stateid = c.create_confirm(t.word())
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_DENIED_ACE_TYPE, 0,
+                ACE4_READ_DATA,  # This should be ignored (already allowed)
+                b"OWNER@")
+    ]
+
+    ops = c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR ACL with ALLOW then DENY")
+
+    attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+    returned_mode = attrs[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if returned_mode != expected_mode:
+        t.fail("Mode (0%o) with ALLOW/DENY does not match expected (0%o). "
+               "First ACE should take precedence." % (returned_mode, expected_mode))
+
+def testSetattrACLModeDeriveEveryone(t, env):
+    """SETATTR(ACL) with EVERYONE@ affecting all identifiers
+
+    Test that EVERYONE@ ACEs are considered when evaluating permissions
+    for OWNER@ and GROUP@ per RFC 8881 Section 6.3.2.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT26
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # EVERYONE@ gets read, specific OWNER@ gets nothing extra
+    # Final result: OWNER@ should have read (from EVERYONE@)
+    fh, stateid = c.create_confirm(t.word())
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"EVERYONE@")
+    ]
+
+    ops = c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR ACL with only EVERYONE@")
+
+    attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+    returned_mode = attrs[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if returned_mode != expected_mode:
+        t.fail("Mode (0%o) does not match expected (0%o). "
+               "EVERYONE@ should affect all mode bits." %
+               (returned_mode, expected_mode))
+
+def testSetattrACLModeDeriveComplex(t, env):
+    """SETATTR(ACL) with complex ACL including multiple identifiers
+
+    Test mode derivation with a more realistic ACL including OWNER@,
+    GROUP@, and EVERYONE@ with various permissions.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT27
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    fh, stateid = c.create_confirm(t.word())
+
+    # Create a complex ACL:
+    # OWNER@: read + write + execute
+    # GROUP@: read + execute (no write)
+    # EVERYONE@: read only
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_EXECUTE,
+                b"GROUP@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"EVERYONE@")
+    ]
+
+    ops = c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR with complex ACL")
+
+    attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+    returned_mode = attrs[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if returned_mode != expected_mode:
+        t.fail("Mode (0%o) does not match RFC 8881 Section 6.3.2 derivation "
+               "from complex ACL (expected 0%o)" %
+               (returned_mode, expected_mode))
+
+def testSetattrACLIndependentOfMode(t, env):
+    """SETATTR(ACL) outcome should not depend on existing mode bits
+
+    Per RFC 8881 Section 6.4.1.2, when setting ACL without mode, the ACL should
+    be set as given. The existing mode should not affect the ACL that gets
+    stored. This test verifies that setting the same ACL on files with
+    different initial modes results in identical ACLs being stored.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT28
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # Create the same ACL to use for all files
+    # OWNER@: read + write, GROUP@: read, EVERYONE@: nothing
+    test_acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"GROUP@")
+    ]
+
+    # Test with various initial mode values
+    initial_modes = [0o600, 0o644, 0o755, 0o777, 0o400, 0o000]
+    files = []
+
+    # Create files with different initial modes
+    for initial_mode in initial_modes:
+        fh, stateid = c.create_confirm(t.word() + (b"_%o" % initial_mode))
+
+        # Set initial mode
+        ops = c.use_obj(fh) + [c.setattr({FATTR4_MODE: initial_mode})]
+        res = c.compound(ops)
+        check(res, msg="Setting initial mode to 0%o" % initial_mode)
+
+        files.append((fh, initial_mode))
+
+    # Now set the same ACL on all files
+    for fh, initial_mode in files:
+        ops = c.use_obj(fh) + [c.setattr({FATTR4_ACL: test_acl})]
+        res = c.compound(ops)
+        check(res, msg="SETATTR ACL on file with initial mode 0%o" % initial_mode)
+
+    # Retrieve the ACLs that were actually stored
+    acls = []
+    for fh, initial_mode in files:
+        attrs = c.do_getattrdict(fh, [FATTR4_ACL])
+        acls.append((initial_mode, attrs[FATTR4_ACL]))
+
+    # Helper function to compare ACLs (comparing ACE lists)
+    def acl_equal(acl1, acl2):
+        """Compare two ACLs for equality"""
+        if len(acl1) != len(acl2):
+            return False
+        for ace1, ace2 in zip(acl1, acl2):
+            if (ace1.type != ace2.type or
+                ace1.flag != ace2.flag or
+                ace1.access_mask != ace2.access_mask or
+                ace1.who != ace2.who):
+                return False
+        return True
+
+    def acl_to_string(acl):
+        """Convert ACL to readable string for error messages"""
+        aces = []
+        for ace in acl:
+            type_str = "ALLOW" if ace.type == ACE4_ACCESS_ALLOWED_ACE_TYPE else "DENY"
+            aces.append("<%s:%s:0x%x:0x%x>" %
+                       (type_str, ace.who.decode(), ace.access_mask, ace.flag))
+        return "[" + ", ".join(aces) + "]"
+
+    # Compare all ACLs - they should all be identical
+    reference_mode, reference_acl = acls[0]
+    for initial_mode, acl in acls[1:]:
+        if not acl_equal(reference_acl, acl):
+            t.fail("ACLs differ based on initial mode! "
+                   "File with mode 0%o has ACL %s, "
+                   "but file with mode 0%o has ACL %s. "
+                   "RFC 8881 Section 6.4.1.2: ACL should be set as given, "
+                   "independent of existing mode." %
+                   (reference_mode, acl_to_string(reference_acl),
+                    initial_mode, acl_to_string(acl)))
+
+    # Also verify that the mode derived from the ACL is consistent
+    modes = []
+    for initial_mode, acl in acls:
+        derived_mode = acl2mode_rfc8881(acl)
+        modes.append(derived_mode)
+
+    if len(set(modes)) != 1:
+        mode_str = ", ".join("0%o (from initial 0%o)" % (m, acls[i][0])
+                             for i, m in enumerate(modes))
+        t.fail("ACLs derive to different modes: %s. "
+               "This suggests ACLs were stored differently based on initial mode." %
+               mode_str)
+
+def testSetattrACLIndependentModeHighBits(t, env):
+    """SETATTR(ACL) should preserve high-order mode bits (SUID/SGID/SVTX)
+
+    Per RFC 8881 Section 6.4.1.2, when setting ACL without mode, the three
+    high-order bits of mode (SUID, SGID, SVTX) SHOULD remain unchanged.
+    Only the low-order nine permission bits should be modified.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT29
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # Create ACL to set
+    test_acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"GROUP@")
+    ]
+
+    # Test with different high-order bits set
+    test_cases = [
+        (0o4755, "SUID"),      # Set-user-ID
+        (0o2755, "SGID"),      # Set-group-ID
+        (0o1755, "SVTX"),      # Sticky bit
+        (0o6755, "SUID+SGID"), # Both SUID and SGID
+        (0o7755, "ALL"),       # All three bits
+    ]
+
+    # Preserving the high-order bits is a SHOULD, so collect violations
+    # and warn once the MUST checks below have run for every case
+    not_preserved = []
+    for initial_mode, description in test_cases:
+        fh, stateid = c.create_confirm(t.word() + (b"_%s" % description.encode()))
+
+        # Set initial mode with high-order bits
+        ops = c.use_obj(fh) + [c.setattr({FATTR4_MODE: initial_mode})]
+        res = c.compound(ops)
+        check(res, msg="Setting initial mode 0%o (%s)" % (initial_mode, description))
+
+        # Verify the mode was set
+        before_attrs = c.do_getattrdict(fh, [FATTR4_MODE])
+        before_mode = before_attrs[FATTR4_MODE] & 0o7777
+
+        # Set ACL only (not mode)
+        ops = c.use_obj(fh) + [c.setattr({FATTR4_ACL: test_acl})]
+        res = c.compound(ops)
+        check(res, msg="SETATTR ACL on file with %s" % description)
+
+        # Check that high-order bits are preserved
+        after_attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+        after_mode = after_attrs[FATTR4_MODE] & 0o7777
+
+        # Extract high-order bits (SUID, SGID, SVTX)
+        before_high = before_mode & 0o7000
+        after_high = after_mode & 0o7000
+
+        if before_high != after_high:
+            not_preserved.append("%s: before=0%o, after=0%o" %
+                                 (description, before_mode, after_mode))
+
+        # Verify low-order bits match ACL derivation
+        after_low = after_mode & 0o777
+        expected_low = acl2mode_rfc8881(test_acl)
+
+        if after_low != expected_low:
+            t.fail("Low-order mode bits (0%o) don't match RFC 8881 Section 6.3.2 "
+                   "derivation (expected 0%o) for %s" %
+                   (after_low, expected_low, description))
+
+    if not_preserved:
+        t.pass_warn("High-order mode bits not preserved (RFC 8881 Section "
+                    "6.4.1.2: SHOULD remain unchanged): %s" %
+                    "; ".join(not_preserved))
+
+def testSetattrModeACLattrsset(t, env):
+    """SETATTR(MODE+ACL) should indicate which attributes were actually set
+
+    Per RFC 8881 Section 6.4.1.3, when both MODE and ACL are set together, the
+    server processes MODE first, then ACL (which may modify the mode).
+    The attrsset bitmap indicates which attributes were actually set.
+    This test verifies the attrsset bitmap and final mode consistency.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT30
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    fh, stateid = c.create_confirm(t.word())
+
+    # Create an ACL that will derive to a specific mode (0754)
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_EXECUTE,
+                b"GROUP@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"EVERYONE@")
+    ]
+
+    # Request a different mode (0640)
+    requested_mode = 0o640
+
+    # Set both MODE and ACL together
+    attrs = {FATTR4_MODE: requested_mode, FATTR4_ACL: acl}
+    ops = c.use_obj(fh) + [c.setattr(attrs)]
+    res = c.compound(ops)
+    check(res, msg="SETATTR with MODE and ACL together")
+
+    # Check the attrsset bitmap
+    attrsset = bitmap2list(res.resarray[-1].attrsset)
+
+    # Get the final attributes
+    final_attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+    final_mode = final_attrs[FATTR4_MODE] & 0o777
+
+    # Both attributes were processed, so both must appear in attrsset
+    if FATTR4_MODE not in attrsset:
+        t.fail("MODE not in attrsset, but MODE was requested")
+    if FATTR4_ACL not in attrsset:
+        t.fail("ACL not in attrsset, but ACL was requested")
+
+    # Per RFC 8881 Section 6.4.1.3, ACL processing modifies the mode, so
+    # the final mode matches the ACL derivation, not the requested mode
+    acl_derived_mode = acl2mode_rfc8881(acl)
+    if final_mode != acl_derived_mode:
+        t.fail("Final mode (0%o) does not match ACL-derived mode (0%o)" %
+               (final_mode, acl_derived_mode))
+
+def testSetattrModeACLConflict(t, env):
+    """SETATTR(MODE+ACL) when MODE and ACL would produce different permissions
+
+    Test the interaction when the requested MODE differs significantly from
+    what the ACL would derive. Per RFC 8881 Section 6.4.1.3, MODE is applied first,
+    then ACL is applied (possibly changing the final mode).
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT31
+    """
+    from nfs4acl import acl2mode_rfc8881
+    c = env.c1
+    c.init_connection()
+
+    # Test multiple conflict scenarios
+    test_cases = [
+        # (requested_mode, ACL, description)
+        (0o777, [  # Request all permissions
+            nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                    ACE4_READ_DATA,  # But ACL only grants read
+                    b"OWNER@")
+        ], "MODE=0777 but ACL grants only read"),
+
+        (0o000, [  # Request no permissions
+            nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                    ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                    b"OWNER@")  # But ACL grants everything
+        ], "MODE=0000 but ACL grants rwx"),
+
+        (0o644, [  # Request read for all, write for owner
+            nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                    ACE4_EXECUTE,  # But ACL only grants execute
+                    b"OWNER@")
+        ], "MODE=0644 but ACL grants only execute"),
+    ]
+
+    for requested_mode, acl, description in test_cases:
+        fh, stateid = c.create_confirm(t.word() + ("_%o" % requested_mode).encode())
+
+        # Set both MODE and ACL together
+        attrs = {FATTR4_MODE: requested_mode, FATTR4_ACL: acl}
+        ops = c.use_obj(fh) + [c.setattr(attrs)]
+        res = c.compound(ops)
+        check(res, msg="SETATTR MODE+ACL: %s" % description)
+
+        # Get final attributes
+        final_attrs = c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
+        final_mode = final_attrs[FATTR4_MODE] & 0o777
+
+        # Verify final mode matches derivation from the requested ACL
+        expected_mode = acl2mode_rfc8881(acl)
+
+        if final_mode != expected_mode:
+            t.fail("Test case '%s': final mode (0%o) doesn't match "
+                   "ACL-derived mode (0%o). Per RFC 8881 Section 6.4.1.3, "
+                   "ACL should be set as given and mode derived from it." %
+                   (description, final_mode, expected_mode))
+
+def testSetattrACLNamedPrincipals(t, env):
+    """SETATTR(ACL) with named principals should preserve them
+
+    Per RFC 8881 Section 6.4.1.3: "the ACL attribute is set as given."
+    When an ACL contains named principals (not OWNER@/GROUP@/EVERYONE@),
+    the server must preserve those exact principals in the stored ACL,
+    not convert them to special identifiers. For SETATTR(ACL) alone,
+    Section 6.4.1.2 makes this a SHOULD, so that case only warns.
+
+    FLAGS: setattr acl all
+    DEPEND: MODE ACL0
+    CODE: SATT32
+    """
+    c = env.c1
+    c.init_connection()
+
+    # First create a file and get its owner and group
+    temp_fh, temp_stateid = c.create_confirm(t.word() + b"_temp")
+    attrs = c.do_getattrdict(temp_fh, [FATTR4_OWNER, FATTR4_OWNER_GROUP])
+    current_owner = attrs[FATTR4_OWNER]
+    current_group = attrs[FATTR4_OWNER_GROUP]
+
+    # Test 1: SETATTR(ACL) with named principals only
+    fh1, stateid1 = c.create_confirm(t.word() + b"_acl_only")
+
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA,
+                current_owner),  # Named principal, not OWNER@
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, ACE4_IDENTIFIER_GROUP,
+                ACE4_READ_DATA,
+                current_group)  # Named principal, not GROUP@
+    ]
+
+    ops = c.use_obj(fh1) + [c.setattr({FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR ACL with named principals")
+
+    # Verify ACL was preserved with named principals. Setting the ACL as
+    # given is a SHOULD in RFC 8881 Section 6.4.1.2, so hold the warning
+    # until test 2 has run.
+    returned_attrs = c.do_getattrdict(fh1, [FATTR4_ACL])
+    acl_only_warning = None
+    try:
+        nfs4acl.verify_acl(returned_attrs[FATTR4_ACL], acl)
+    except AssertionError as e:
+        acl_only_warning = ("%s. Server did not set the ACL as given "
+                            "(RFC 8881 Section 6.4.1.2: SHOULD)" % e)
+
+    # Test 2: SETATTR(MODE+ACL) with named principals
+    fh2, stateid2 = c.create_confirm(t.word() + b"_mode_acl")
+
+    mode = 0o755
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_EXECUTE,
+                current_owner),  # Named principal
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, ACE4_IDENTIFIER_GROUP,
+                ACE4_READ_DATA | ACE4_EXECUTE,
+                current_group),  # Named principal
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"EVERYONE@")  # Special identifier is fine
+    ]
+
+    ops = c.use_obj(fh2) + [c.setattr({FATTR4_MODE: mode, FATTR4_ACL: acl})]
+    res = c.compound(ops)
+    check(res, msg="SETATTR MODE+ACL with named principals")
+
+    # Verify ACL was preserved
+    returned_attrs = c.do_getattrdict(fh2, [FATTR4_ACL])
+    try:
+        nfs4acl.verify_acl(returned_attrs[FATTR4_ACL], acl)
+    except AssertionError as e:
+        t.fail("%s. Server did not set the ACL as given, "
+               "violating RFC 8881 Section 6.4.1.3" % e)
+
+    if acl_only_warning:
+        t.pass_warn(acl_only_warning)

-- 
2.54.0

