Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B0714F3911
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563719; cv=none; b=EpctyW3ytVx/TdhSl3G/EaxyVgDvxk3ICTs8U8Au/dNwBxNB/iYYfuMHr0RXo9zR3Thd74U5F6XDwGLe3ccqpejqDvXoQdQB6f1fBusJKLCjKbNHoqPeqqp6hGi50O5P0cVtVKQFvWp5bIfkRKVdljiuVaDY5s3I7mw6J17+Kl0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563719; c=relaxed/simple;
	bh=VqZBCU7AnxYSr31X/bd+tTgfrKMKrfrJuE0kttgvzwA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=i2NLvNYa0DbY7xWGK/JEJIFUjbLMhyjAG5uYQEjDA3UOVbXVeiCJ2BvtDutYJlG2GmbhrTtXmzf5Ajm0sAGLjEw+yWjM6uwEAWZwCdJ+NCx4GlYv8OSE0MhkR0Z5cJFuvlq+hQvtLShrZFNBQxoDhRfRM5QynxL4sY7CbT0P4is=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gzoVCLxz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gzoVCLxz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B03131F0089F;
	Fri,  9 Oct 2026 16:35:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563711;
	bh=QAZZHKUeh2CxFSaq8qQfsNDboKkhRMLuWOve0gqLF+I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gzoVCLxzRmvnlaPgtnS9kM43wrn2b82Dffs/gLca0pPI0Qoj4hWOmYCJfgNiU0YdG
	 PaLgH5d6+X7HeCJJTeMoWFhev439uA4QSkgpO8fn0fcQ31HZqzBV3Jzr8dBWpaMof+
	 /Hii7xglp39DaDFdqqVSkwzilB+GvukoeKOBMlalwLRxiFnKZtRv7kliQs12PJeUdd
	 67K3m6DB00Es3iKNrwAG8HhnBWDUriUMs5yOlbxpeE7PISatoSdfua5p2o8vf75YUP
	 TDt836RcKDZ2y/Qj+sBbyMADbvNm1CiKAntc3leZaj1PMWVmd+KIWbVpJ2C/BGMmMW
	 edshw+9FYuYNQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:35:03 -0400
Subject: [PATCH pynfs v3 9/9] Add tests for OPEN(create) with ACLs
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-9-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=19625; i=cel@kernel.org;
 h=from:subject:message-id; bh=1WwkCkJGT/i44jSWhapSW3WgDcSQjFzKgPB6C8v34j0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5e4EJNNcj4RPZT1CTG2JXaynHgXMtdFAJL
 /ShxanWyd2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 lxu1EADBUvBS6G6nQpn+FugTOZFyXyUSLfz9o4htcLMtBDAr82qXaglZtA8sFByvboeilyHL1xW
 6icIHkoJqrGLvShhmHT8wS/UOmfjgcbh1vswRckWFDEPOgBt3mp6Gxzn8dWmq2+ToVB0CuNNeIh
 qPjU7a37uEL5B7yx0Z3CQR1Dt7P3oWmaRf4T+9b24wyaeYwjGtFdRw+FXEc1qx4yXCymKqYwIh4
 GCBXiO7JWqW+GjNtyzOp9/gYzkF+LiYkXJjdDP7qRCdrjM4qKkdM1LNPQu8tjPScxhzLbcEA5m8
 i6V9hCE9fLD4RrYML39LuPKdEG9eITkLbnWW8+YqzOsBDZEC8Ospw+SlzvfxvWPEs3Hk+/X3r8y
 u/xu3knDrDXGZ/2oTd/yvqcSG7gW5hXiHpDT74Yeof1u3btM0VrlZTWXBBRgnWB38Td53ePLLpf
 8tjyc0Po+F0yWHR4eA+uRbPqgZOGuQ1IWe7ZuBJpQbG+TEuXaF14hvrzdSQsvro6VpN1PYQ3vIx
 F1moyfRId0+3EwTzO1sJbV6RSYWTCJvWxsKiHhlMS54BMxHoZPVDVPFSEmitRH9xbdtLGfQKtes
 bOyzCF4Kv+Ziz8H3BRg3LQ+J1dANbIR4PD/dBNZIoy6A2yWNZguDs6mHp7vAdq52kcQxQQApacF
 nOV/T9IqdA7SnSw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The NFSv4.1 OPEN tests set MODE at create time but never request an
ACL. A server that ignores FATTR4_ACL in the createattrs, or that
applies the requested MODE after both MODE and ACL are given, passes
the suite. RFC 8881 Section 6.4.1.3 requires the ACL to be set as
given and the mode to be derived from that ACL per Section 6.3.2.

Add OPEN8a and OPEN8b to check that the server advertises FATTR4_ACL
in supported_attrs and in suppattr_exclcreat, OPEN12 and OPEN13 to
check suppattr_exclcreat itself, then OPEN11, OPEN14, and OPEN38
through OPEN40 to create files with MODE alone, with an ACL alone,
and with MODE and ACL together under UNCHECKED4, GUARDED4, and
EXCLUSIVE4_1. The combined cases include a MODE more restrictive
than the ACL and a MODE that conflicts with it. Where an ACL is
requested, the test verifies the returned ACL against it and
compares the resulting mode with the RFC 8881 derivation from the
requested ACL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.1/server41tests/st_open.py | 463 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 460 insertions(+), 3 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 28540b59a8fe..c7ac94f86df1 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -1,15 +1,16 @@
 from .st_create_session import create_session
 from xdrdef.nfs4_const import *
 
-from .environment import check, fail, create_file, open_file, close_file, write_file, read_file
-from .environment import open_create_file_op
+from .environment import check, fail, unsupported, create_file, open_file, close_file, write_file, read_file
+from .environment import open_create_file_op, do_getattrdict
 from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 from xdrdef.nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
-from xdrdef.nfs4_type import open_to_lock_owner4
+from xdrdef.nfs4_type import open_to_lock_owner4, nfsace4
 import nfs_ops
 op = nfs_ops.NFS4ops()
 import threading
 import nfs4lib
+import nfs4acl
 
 def expect(res, seqid):
     """Verify that open result has expected stateid.seqid"""
@@ -195,3 +196,459 @@ def testCloseWithZeroSeqid(t, env):
     stateid.seqid = 0
     res = close_file(sess1, fh, stateid=stateid)
     check(res)
+
+def testSuppattrExclcreat(t, env):
+    """Check that FATTR4_SUPPATTR_EXCLCREAT is supported and valid
+
+    FLAGS: open all
+    CODE: OPEN12
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    res = sess.compound([op.putrootfh(),
+                        op.getattr(nfs4lib.list2bitmap([FATTR4_SUPPORTED_ATTRS,
+                                                         FATTR4_SUPPATTR_EXCLCREAT]))])
+    check(res)
+    attrs_info = res.resarray[-1].obj_attributes
+
+    if FATTR4_SUPPORTED_ATTRS not in attrs_info:
+        fail("Server did not return FATTR4_SUPPORTED_ATTRS")
+
+    # SUPPATTR_EXCLCREAT is REQUIRED (RFC 8881 Section 5.6), so a server
+    # that omits it from supported_attrs is non-compliant, not unsupported
+    supported = attrs_info[FATTR4_SUPPORTED_ATTRS]
+    if not (supported & (1 << FATTR4_SUPPATTR_EXCLCREAT)):
+        fail("REQUIRED attribute FATTR4_SUPPATTR_EXCLCREAT not in "
+             "FATTR4_SUPPORTED_ATTRS")
+
+    # If supported, check that it was returned
+    if FATTR4_SUPPATTR_EXCLCREAT not in attrs_info:
+        fail("FATTR4_SUPPATTR_EXCLCREAT not returned even though it "
+             "appears in FATTR4_SUPPORTED_ATTRS")
+
+def testSuppattrExclcreatSubset(t, env):
+    """FATTR4_SUPPATTR_EXCLCREAT must be subset of SUPPORTED_ATTRS
+
+    FLAGS: open all
+    CODE: OPEN13
+    DEPEND: OPEN12
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    res = sess.compound([op.putrootfh(),
+                        op.getattr(nfs4lib.list2bitmap([FATTR4_SUPPORTED_ATTRS,
+                                                         FATTR4_SUPPATTR_EXCLCREAT]))])
+    check(res)
+    attrs_info = res.resarray[-1].obj_attributes
+
+    supported = attrs_info[FATTR4_SUPPORTED_ATTRS]
+    excl_supported = attrs_info[FATTR4_SUPPATTR_EXCLCREAT]
+
+    # SUPPATTR_EXCLCREAT must be a subset of SUPPORTED_ATTRS
+    # i.e., every bit set in excl_supported must also be set in supported
+    invalid = excl_supported & ~supported
+    if invalid != 0:
+        fail("FATTR4_SUPPATTR_EXCLCREAT contains attributes not in "
+             "FATTR4_SUPPORTED_ATTRS:\n"
+             "  Invalid attributes: %s" % nfs4lib.attr_bitmap_to_str(invalid))
+
+def testACLSupported(t, env):
+    """Check that server supports FATTR4_ACL attribute
+
+    FLAGS: open acl all
+    CODE: OPEN8a
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    res = sess.compound([op.putrootfh(),
+                        op.getattr(nfs4lib.list2bitmap([FATTR4_SUPPORTED_ATTRS]))])
+    check(res)
+    attrs_info = res.resarray[-1].obj_attributes
+    if FATTR4_SUPPORTED_ATTRS not in attrs_info:
+        fail("Server did not return FATTR4_SUPPORTED_ATTRS")
+    supported = attrs_info[FATTR4_SUPPORTED_ATTRS]
+    if not (supported & (1 << FATTR4_ACL)):
+        unsupported("Server does not support FATTR4_ACL attribute")
+
+def testACLExclusiveSupported(t, env):
+    """Check that server supports setting ACL during EXCLUSIVE4_1 create
+
+    FLAGS: open acl all
+    CODE: OPEN8b
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    res = sess.compound([op.putrootfh(),
+                        op.getattr(nfs4lib.list2bitmap([FATTR4_SUPPATTR_EXCLCREAT]))])
+    check(res)
+    attrs_info = res.resarray[-1].obj_attributes
+    if FATTR4_SUPPATTR_EXCLCREAT not in attrs_info:
+        fail("REQUIRED attribute FATTR4_SUPPATTR_EXCLCREAT not returned")
+    excl_supported = attrs_info[FATTR4_SUPPATTR_EXCLCREAT]
+    if not (excl_supported & (1 << FATTR4_ACL)):
+        unsupported("Server does not support setting FATTR4_ACL during "
+                    "EXCLUSIVE4_1 create")
+
+def testOpenCreateWithACLExclusive(t, env):
+    """OPEN with EXCLUSIVE4_1 CREATE setting NFSv4 ACL attribute
+
+    FLAGS: open acl all
+    CODE: OPEN11
+    DEPEND: OPEN8b
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    acl = nfs4acl.make_test_acl()
+
+    # Create file with ACL attribute using EXCLUSIVE4_1 mode
+    # EXCLUSIVE4_1 allows attributes to be set atomically with create
+    # Don't set MODE with ACL - let the ACL determine permissions
+    attrs = {FATTR4_ACL: acl}
+    res = create_file(sess, env.testname(t), attrs=attrs, mode=EXCLUSIVE4_1)
+    check(res)
+    expect(res, seqid=1)
+
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+
+    # Verify the ACL was set correctly by reading it back
+    attrs_dict = do_getattrdict(sess, fh, [FATTR4_ACL])
+    if FATTR4_ACL not in attrs_dict:
+        fail("ACL attribute not returned after OPEN with CREATE")
+
+    try:
+        nfs4acl.verify_acl(attrs_dict[FATTR4_ACL], acl)
+    except AssertionError as e:
+        fail(str(e))
+
+    res = close_file(sess, fh, stateid=stateid)
+    check(res)
+
+def testOpenCreateModeWithACL(t, env):
+    """OPEN(create) setting both MODE and ACL under every create mode
+
+    Per RFC 8881 Section 6.4.1.3, when both MODE and ACL are set together,
+    both are processed, but the final mode is derived from the ACL and may
+    differ from the requested MODE. Each create mode is exercised with a
+    MODE the ACL widens and with one more restrictive than the ACL grants.
+
+    FLAGS: open acl all
+    CODE: OPEN14
+    DEPEND: OPEN8a OPEN8b
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    acl = nfs4acl.make_test_acl()
+
+    cases = [
+        (UNCHECKED4, b"unchecked"),
+        (GUARDED4, b"guarded"),
+        (EXCLUSIVE4_1, b"exclusive"),
+    ]
+    for mode in (0o640, 0o600, 0o400):
+        for createmode, label in cases:
+            name = env.testname(t) + b"_%o_%s" % (mode, label)
+            attrs = {FATTR4_MODE: mode, FATTR4_ACL: acl}
+            res = create_file(sess, name, attrs=attrs, mode=createmode)
+            check(res)
+            expect(res, seqid=1)
+
+            fh = res.resarray[-1].object
+            stateid = res.resarray[-2].stateid
+
+            # Check which attributes were actually set by examining the
+            # reply bitmask
+            attrset = nfs4lib.bitmap2list(res.resarray[-2].attrset)
+            if FATTR4_MODE not in attrset:
+                fail("MODE not in attrset, but MODE 0%o was requested (%s)"
+                     % (mode, label))
+            if FATTR4_ACL not in attrset:
+                fail("ACL not in attrset, but ACL was requested (%s)" % label)
+
+            # Verify ACL was set correctly and the mode derived from it
+            attrs_dict = do_getattrdict(sess, fh, [FATTR4_ACL, FATTR4_MODE])
+            try:
+                nfs4acl.verify_mode_and_acl(
+                    attrs_dict, acl,
+                    "%s CREATE with MODE 0%o" % (label.decode(), mode))
+            except AssertionError as e:
+                fail(str(e))
+
+            res = close_file(sess, fh, stateid=stateid)
+            check(res)
+
+#
+# Tests for OPEN CREATE with MODE and ACL per RFC 8881 Section 6.4.3
+#
+
+def testOpenCreateModeDerivation(t, env):
+    """OPEN CREATE with MODE should derive ACL from mode
+
+    Per RFC 8881 Section 6.4.3: If just mode is given, the mode MUST be
+    applied to the inherited/created ACL per Section 6.4.1.1. Test with
+    UNCHECKED4, GUARDED4, and EXCLUSIVE4_1.
+
+    FLAGS: open acl all
+    CODE: OPEN38
+    DEPEND: OPEN8a OPEN8b
+    """
+    from nfs4acl import acl2mode_rfc8881
+
+    sess = env.c1.new_client_session(env.testname(t))
+
+    # Test with UNCHECKED4
+    mode = 0o640
+    attrs = {FATTR4_MODE: mode}
+    name1 = env.testname(t) + b"_unchecked"
+    res = create_file(sess, name1, attrs=attrs, mode=UNCHECKED4)
+    check(res)
+    fh1 = res.resarray[-1].object
+    stateid1 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh1, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    if result_mode != mode:
+        fail("UNCHECKED4: mode (0%o) doesn't match requested (0%o)" %
+             (result_mode, mode))
+
+    acl_derived_mode = acl2mode_rfc8881(attrs_dict[FATTR4_ACL])
+    if result_mode != acl_derived_mode:
+        fail("UNCHECKED4: mode (0%o) doesn't match ACL derivation (0%o)" %
+             (result_mode, acl_derived_mode))
+
+    res = close_file(sess, fh1, stateid=stateid1)
+    check(res)
+
+    # Test with GUARDED4
+    mode = 0o750
+    attrs = {FATTR4_MODE: mode}
+    name2 = env.testname(t) + b"_guarded"
+    res = create_file(sess, name2, attrs=attrs, mode=GUARDED4)
+    check(res)
+    fh2 = res.resarray[-1].object
+    stateid2 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh2, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    if result_mode != mode:
+        fail("GUARDED4: mode (0%o) doesn't match requested (0%o)" %
+             (result_mode, mode))
+
+    acl_derived_mode = acl2mode_rfc8881(attrs_dict[FATTR4_ACL])
+    if result_mode != acl_derived_mode:
+        fail("GUARDED4: mode (0%o) doesn't match ACL derivation (0%o)" %
+             (result_mode, acl_derived_mode))
+
+    res = close_file(sess, fh2, stateid=stateid2)
+    check(res)
+
+    # Test with EXCLUSIVE4_1
+    mode = 0o755
+    attrs = {FATTR4_MODE: mode}
+    name3 = env.testname(t) + b"_exclusive"
+    res = create_file(sess, name3, attrs=attrs, mode=EXCLUSIVE4_1)
+    check(res)
+    fh3 = res.resarray[-1].object
+    stateid3 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh3, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    if result_mode != mode:
+        fail("EXCLUSIVE4_1: mode (0%o) doesn't match requested (0%o)" %
+             (result_mode, mode))
+
+    acl_derived_mode = acl2mode_rfc8881(attrs_dict[FATTR4_ACL])
+    if result_mode != acl_derived_mode:
+        fail("EXCLUSIVE4_1: mode (0%o) doesn't match ACL derivation (0%o)" %
+             (result_mode, acl_derived_mode))
+
+    res = close_file(sess, fh3, stateid=stateid3)
+    check(res)
+
+def testOpenCreateACLDerivation(t, env):
+    """OPEN CREATE with ACL should derive mode from ACL
+
+    Per RFC 8881 Section 6.4.3: If just ACL is given, inheritance SHOULD NOT
+    take place, ACL should be set as given, and mode modified per Section 6.4.1.2.
+
+    FLAGS: open acl all
+    CODE: OPEN39
+    DEPEND: OPEN8a OPEN8b
+    """
+    from nfs4acl import acl2mode_rfc8881
+
+    sess = env.c1.new_client_session(env.testname(t))
+
+    # Test with UNCHECKED4
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"GROUP@")
+    ]
+    attrs = {FATTR4_ACL: acl}
+    name1 = env.testname(t) + b"_unchecked"
+    res = create_file(sess, name1, attrs=attrs, mode=UNCHECKED4)
+    check(res)
+    fh1 = res.resarray[-1].object
+    stateid1 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh1, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if result_mode != expected_mode:
+        fail("UNCHECKED4: mode (0%o) doesn't match ACL derivation (0%o)" %
+             (result_mode, expected_mode))
+
+    res = close_file(sess, fh1, stateid=stateid1)
+    check(res)
+
+    # Test with GUARDED4
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_EXECUTE,
+                b"OWNER@")
+    ]
+    attrs = {FATTR4_ACL: acl}
+    name2 = env.testname(t) + b"_guarded"
+    res = create_file(sess, name2, attrs=attrs, mode=GUARDED4)
+    check(res)
+    fh2 = res.resarray[-1].object
+    stateid2 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh2, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if result_mode != expected_mode:
+        fail("GUARDED4: mode (0%o) doesn't match ACL derivation (0%o)" %
+             (result_mode, expected_mode))
+
+    res = close_file(sess, fh2, stateid=stateid2)
+    check(res)
+
+    # Test with EXCLUSIVE4_1
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
+    attrs = {FATTR4_ACL: acl}
+    name3 = env.testname(t) + b"_exclusive"
+    res = create_file(sess, name3, attrs=attrs, mode=EXCLUSIVE4_1)
+    check(res)
+    fh3 = res.resarray[-1].object
+    stateid3 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh3, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if result_mode != expected_mode:
+        fail("EXCLUSIVE4_1: mode (0%o) doesn't match ACL derivation (0%o)" %
+             (result_mode, expected_mode))
+
+    res = close_file(sess, fh3, stateid=stateid3)
+    check(res)
+
+def testOpenCreateModeACLConflict(t, env):
+    """OPEN CREATE with both MODE and ACL - ACL should win
+
+    Per RFC 8881 Section 6.4.3: If both mode and ACL are given, both attributes
+    will be set per Section 6.4.1.3 (MODE first, then ACL, with ACL modifying
+    the final mode).
+
+    FLAGS: open acl all
+    CODE: OPEN40
+    DEPEND: OPEN8a OPEN8b
+    """
+    from nfs4acl import acl2mode_rfc8881
+
+    sess = env.c1.new_client_session(env.testname(t))
+
+    # Test with UNCHECKED4: ACL would derive to 0754, request MODE 0640
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
+    mode = 0o640
+    attrs = {FATTR4_MODE: mode, FATTR4_ACL: acl}
+    name1 = env.testname(t) + b"_unchecked"
+    res = create_file(sess, name1, attrs=attrs, mode=UNCHECKED4)
+    check(res)
+    fh1 = res.resarray[-1].object
+    stateid1 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh1, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if result_mode != expected_mode:
+        fail("UNCHECKED4: mode (0%o) doesn't match ACL derivation (0%o). "
+             "Per Section 6.4.3, should follow Section 6.4.1.3 (ACL wins)" %
+             (result_mode, expected_mode))
+
+    res = close_file(sess, fh1, stateid=stateid1)
+    check(res)
+
+    # Test with GUARDED4
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA,
+                b"OWNER@")
+    ]
+    mode = 0o755
+    attrs = {FATTR4_MODE: mode, FATTR4_ACL: acl}
+    name2 = env.testname(t) + b"_guarded"
+    res = create_file(sess, name2, attrs=attrs, mode=GUARDED4)
+    check(res)
+    fh2 = res.resarray[-1].object
+    stateid2 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh2, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if result_mode != expected_mode:
+        fail("GUARDED4: mode (0%o) doesn't match ACL derivation (0%o). "
+             "Per Section 6.4.3, should follow Section 6.4.1.3" %
+             (result_mode, expected_mode))
+
+    res = close_file(sess, fh2, stateid=stateid2)
+    check(res)
+
+    # Test with EXCLUSIVE4_1
+    acl = [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_EXECUTE,
+                b"OWNER@")
+    ]
+    mode = 0o644
+    attrs = {FATTR4_MODE: mode, FATTR4_ACL: acl}
+    name3 = env.testname(t) + b"_exclusive"
+    res = create_file(sess, name3, attrs=attrs, mode=EXCLUSIVE4_1)
+    check(res)
+    fh3 = res.resarray[-1].object
+    stateid3 = res.resarray[-2].stateid
+
+    attrs_dict = do_getattrdict(sess, fh3, [FATTR4_MODE, FATTR4_ACL])
+    result_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(acl)
+
+    if result_mode != expected_mode:
+        fail("EXCLUSIVE4_1: mode (0%o) doesn't match ACL derivation (0%o). "
+             "Per Section 6.4.3, should follow Section 6.4.1.3" %
+             (result_mode, expected_mode))
+
+    res = close_file(sess, fh3, stateid=stateid3)
+    check(res)

-- 
2.54.0

