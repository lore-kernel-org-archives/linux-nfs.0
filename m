Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:55854 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752046AbcK0G1g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:36 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 02/12] Close the files opened in the OPEN tests
Date: Sat, 26 Nov 2016 22:26:31 -0800
Message-ID: <1480228001-64821-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise open files are left behind and as each test gets
their own client ID.

Also, as OPEN7 can get a delegation from an agressive server
and pynfs does not handle CBs, do not get the delegation.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/server41tests/st_open.py | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open=
.py
index 235212c..473732d 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -29,12 +29,17 @@ def testSupported(t, env):
     # See 8.1.3.1 of draft-10:
     # the server MUST provide an "seqid" value starting at one...
     expect(res, seqid=3D1)
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
=20
     # STUB - need to check  open_res.delegation.delegation_type
     # see draft-10 line 19445
     # QUESTION - what does "If the server supports the new _WANT_ flags" m=
ean?
     #    will the server return INVAL? NOTSUPP? or just silently ignore?
=20
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
+
 def testServerStateSeqid(t, env):
     """Do multiple OPENs of a file, check that server bumps stateid.seqid
=20
@@ -51,8 +56,14 @@ def testServerStateSeqid(t, env):
     res =3D open_file(sess1, owner, path, access=3DOPEN4_SHARE_ACCESS_READ=
)
     check(res)
     expect(res, seqid=3D2)
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
+
     # STUB - need to check no delegation return
=20
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
+
 def testReadWrite(t, env):
     """Do a simple READ and WRITE
=20
@@ -78,6 +89,9 @@ def testReadWrite(t, env):
     if res.resarray[-1].data !=3D desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
=20
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
+
 def testAnonReadWrite(t, env):
     """Do a simple READ and WRITE using anonymous stateid
=20
@@ -93,6 +107,7 @@ def testAnonReadWrite(t, env):
     data =3D "write test data"
     stateid =3D res.resarray[-2].stateid
     res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
     res =3D sess1.compound([op.putfh(fh), op.write(nfs4lib.state00, 5, FIL=
E_SYNC4, data)])
     check(res)
     res =3D sess1.compound([op.putfh(fh), op.read(nfs4lib.state00, 0, 1000=
)])
@@ -115,11 +130,16 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
=20
     res =3D create_file(sess1, env.testname(t), mode=3DEXCLUSIVE4_1)
     check(res)
+    fh =3D res.resarray[-1].object
+    stateid =3D res.resarray[-2].stateid
=20
     res =3D create_file(sess1, env.testname(t), mode=3DEXCLUSIVE4_1,
                         verifier =3D "Justtest")
     check(res, NFS4ERR_EXIST)
=20
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
+
 def testOPENClaimFH(t, env):
     """OPEN file with claim_type is CLAIM_FH
=20
@@ -127,7 +147,7 @@ def testOPENClaimFH(t, env):
     CODE: OPEN7
     """
     sess1 =3D env.c1.new_client_session(env.testname(t))
-    res =3D create_file(sess1, env.testname(t))
+    res =3D create_file(sess1, env.testname(t), want_deleg=3DFalse)
     check(res)
=20
     fh =3D res.resarray[-1].object
@@ -138,7 +158,9 @@ def testOPENClaimFH(t, env):
     claim =3D open_claim4(CLAIM_FH)
     how =3D openflag4(OPEN4_NOCREATE)
     oowner =3D open_owner4(0, "My Open Owner 2")
-    open_op =3D op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
+    access =3D OPEN4_SHARE_ACCESS_BOTH|OPEN4_SHARE_ACCESS_WANT_NO_DELEG
+
+    open_op =3D op.open(0, access, OPEN4_SHARE_DENY_NONE,
                       oowner, how, claim)
     res =3D sess1.compound([op.putfh(fh), open_op])
     check(res)
@@ -156,6 +178,9 @@ def testOPENClaimFH(t, env):
     if res.resarray[-1].data !=3D desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
=20
+    res =3D close_file(sess1, fh, stateid=3Dstateid)
+    check(res)
+
 def testCloseWithZeroSeqid(t, env):
     """OPEN followed by CLOSE with stateid.seq =3D 0
=20
--=20
2.3.6

