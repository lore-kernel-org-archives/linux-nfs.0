Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34643 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbG1Lqp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:46:45 -0400
Received: by pacan13 with SMTP id an13so70173485pac.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:46:45 -0700 (PDT)
Message-ID: <55B76B94.4060208@gmail.com>
Date: Tue, 28 Jul 2015 19:46:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: [PATCH 1/4] 4.0 setclientid: More cases for setclientid behavior
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

More cases of RFC 7530 16.33.5 setclientid/setclientid_confirm behavior.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/st_setclientid.py | 245 ++++++++++++++++++++++++++++++++---
 1 file changed, 227 insertions(+), 18 deletions(-)

diff --git a/nfs4.0/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
index e9d0052..ca3e1d4 100644
--- a/nfs4.0/servertests/st_setclientid.py
+++ b/nfs4.0/servertests/st_setclientid.py
@@ -49,25 +49,7 @@ def testClientUpdateCallback(t, env):
     c.init_connection(id, verf)
     res = c.close_file(t.code, fh, stateid)
     check(res, msg="Close after updating callback info")
-    
-def testInUse(t, env):
-    """SETCLIENTID with same nfs_client_id.id should return NFS4ERR_CLID_INUSE
 
-    This requires NCL1 and NCL2 to have different principals (UIDs).
-    
-    FLAGS: setclientid setclientidconfirm all
-    DEPEND: _checkprinciples INIT
-    CODE: CID2
-    """
-    c1 = env.c1
-    c2 = env.c2
-    c1.init_connection("Badid_for_%s_pid=%i" % (t.code, os.getpid()),
-                       verifier=c1.verifier)
-    ops = [c2.setclientid(id="Badid_for_%s_pid=%i" % (t.code, os.getpid()),
-                          verifier=c1.verifier)]
-    res = c2.compound(ops)
-    check(res, NFS4ERR_CLID_INUSE, "SETCLIENTID with same nfs_client_id.id")
-    
 def testLoseAnswer(t, env):
     """SETCLIENTID after a client reboot could cause case not covered in RFC
 
@@ -114,7 +96,234 @@ def testAllCases(t, env):
     # (*xc*s), (*xd*t)
     res = c.compound([c.setclientid(id=id, verifier='')])
     check(res)
+
+def testInUse(t, env):
+    """SETCLIENTID with same nfs_client_id.id should return NFS4ERR_CLID_INUSE
+
+    This requires NCL1 and NCL2 to have different principals (UIDs).
     
+    FLAGS: setclientid setclientidconfirm all
+    DEPEND: _checkprinciples INIT
+    CODE: CID4a
+    """
+    c1 = env.c1
+    c2 = env.c2
+    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
+    c1.init_connection(clid, verifier=c1.verifier)
+    ops = [c2.setclientid(clid, verifier=c1.verifier)]
+    res = c2.compound(ops)
+    check(res, NFS4ERR_CLID_INUSE, "SETCLIENTID with same nfs_client_id.id")
+
+def testCallbackInfoUpdate(t, env):
+    """A probable callback information update and records
+       an unconfirmed { v, x, c, k, t } and leaves the
+       confirmed { v, x, c, l, s } in place, such that t != s.
+
+    FLAGS: setclientid all
+    DEPEND: INIT
+    CODE: CID4b
+    """
+    c1 = env.c1
+    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
+
+    # confirmed { v, x, c, l, s }
+    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
+
+    # request { v, x, c, k, s } --> unconfirmed { v, x, c, k, t }
+    ops = [c1.setclientid(clid, verifier=c1.verifier)]
+    res = c1.compound(ops)
+    check(res)
+
+    tclientid = res.resarray[0].switch.switch.clientid
+    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # (t != s)
+    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
+        t.fail("Got clientid confirm verifier with all zero!")
+
+    if cclientid != tclientid:
+        t.fail("Return a different clientID for callback information updating!")
+
+    if tconfirm == cconfirm:
+        t.fail("Return a same confirm for callback information updating!")
+
+def testConfirmedDiffVerifier(t, env):
+    """The server has previously recorded a confirmed { u, x, c, l, s }
+       record such that v != u, l may or may not equal k, and has not
+       recorded any unconfirmed { *, x, *, *, * } record for x.  The
+       server records an unconfirmed { v, x, d, k, t } (d != c, t != s).
+
+    FLAGS: setclientid all
+    DEPEND: INIT
+    CODE: CID4c
+    """
+    c1 = env.c1
+    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
+
+    # confirmed { u, x, c, l, s }
+    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
+
+    # request { v, x, c, k, s } --> unconfirmed { v, x, d, k, t }
+    ops = [c1.setclientid(clid, verifier="diff")]
+    res = c1.compound(ops)
+    check(res)
+
+    tclientid = res.resarray[0].switch.switch.clientid
+    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # (d != c, t != s)
+    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
+        t.fail("Got clientid confirm verifier with all zero!")
+
+    if cclientid == tclientid:
+        t.fail("Return a same clientID for different verifier!")
+
+    if tconfirm == cconfirm:
+        t.fail("Return a same confirm for different verifier!")
+
+def testConfUnConfDiffVerifier1(t, env):
+    """The server has previously recorded a confirmed { u, x, c, l, s }
+       record such that v != u, l may or may not equal k, and recorded an
+       unconfirmed { w, x, d, m, t } record such that c != d, t != s, m
+       may or may not equal k, m may or may not equal l, and k may or may
+       not equal l.  Whether w == v or w != v makes no difference.  The
+       server simply removes the unconfirmed { w, x, d, m, t } record and
+       replaces it with an unconfirmed { v, x, e, k, r } record, such
+       that e != d, e != c, r != t, r != s.
+
+    FLAGS: setclientid all
+    DEPEND: INIT
+    CODE: CID4d1
+    """
+    c1 = env.c1
+    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
+
+    # confirmed { u, x, c, l, s }
+    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
+
+    # unconfirmed { w, x, d, m, t }
+    ops = [c1.setclientid(clid, verifier="unconf")]
+    res = c1.compound(ops)
+    check(res)
+
+    uclientid = res.resarray[0].switch.switch.clientid
+    uconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # request { v, x, c, k, s } --> unconfirmed { v, x, e, k, r }
+    # (v == w)
+    ops = [c1.setclientid(clid, verifier="unconf")]
+    res = c1.compound(ops)
+    check(res)
+
+    tclientid = res.resarray[0].switch.switch.clientid
+    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # removes the unconfirmed { w, x, d, m, t }
+    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
+    res = c1.compound(ops)
+    check(res, NFS4ERR_STALE_CLIENTID)
+
+    # (e != d, e != c, r != t, r != s)
+    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
+        t.fail("Got clientid confirm verifier with all zero!")
+
+    if cclientid == tclientid or uclientid == tclientid:
+        t.fail("Return a same clientID for different verifier!")
+
+    if tconfirm == cconfirm or tconfirm == uconfirm:
+        t.fail("Return a same confirm for different verifier!")
+
+def testConfUnConfDiffVerifier2(t, env):
+    """Whether w == v or w != v makes no difference.
+
+    FLAGS: setclientid all
+    DEPEND: INIT
+    CODE: CID4d2
+    """
+    c1 = env.c1
+    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
+
+    # confirmed { u, x, c, l, s }
+    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
+
+    # unconfirmed { w, x, d, m, t }
+    ops = [c1.setclientid(clid, verifier="unconf")]
+    res = c1.compound(ops)
+    check(res)
+
+    uclientid = res.resarray[0].switch.switch.clientid
+    uconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # request { v, x, c, k, s } --> unconfirmed { v, x, e, k, r }
+    # (v != w)
+    ops = [c1.setclientid(clid, verifier="testconf")]
+    res = c1.compound(ops)
+    check(res)
+
+    tclientid = res.resarray[0].switch.switch.clientid
+    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # removes the unconfirmed { w, x, d, m, t }
+    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
+    res = c1.compound(ops)
+    check(res, NFS4ERR_STALE_CLIENTID)
+
+    # (e != d, e != c, r != t, r != s)
+    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
+        t.fail("Got clientid confirm verifier with all zero!")
+
+    if cclientid == tclientid or uclientid == tclientid:
+        t.fail("Return a same clientID for different verifier!")
+
+    if tconfirm == cconfirm or tconfirm == uconfirm:
+        t.fail("Return a same confirm for different verifier!")
+
+def testUnConfReplaced(t, env):
+    """The server has no confirmed { *, x, *, *, * } for x.  It may or
+       may not have recorded an unconfirmed { u, x, c, l, s }, where l
+       may or may not equal k, and u may or may not equal v.  Any
+       unconfirmed record { u, x, c, l, * }, regardless of whether u == v
+       or l == k, is replaced with an unconfirmed record { v, x, d, k, t}
+       where d != c, t != s.
+
+    FLAGS: setclientid all
+    DEPEND: INIT
+    CODE: CID4e
+    """
+    c1 = env.c1
+    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
+
+    # unconfirmed { w, x, d, m, t }
+    ops = [c1.setclientid(clid, verifier="unconf")]
+    res = c1.compound(ops)
+    check(res)
+
+    uclientid = res.resarray[0].switch.switch.clientid
+    uconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # request { v, x, c, k, s } --> unconfirmed { v, x, d, k, t }
+    ops = [c1.setclientid(clid, verifier="diff")]
+    res = c1.compound(ops)
+    check(res)
+
+    tclientid = res.resarray[0].switch.switch.clientid
+    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
+
+    # removes the unconfirmed { w, x, d, m, t }
+    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
+    res = c1.compound(ops)
+    check(res, NFS4ERR_STALE_CLIENTID)
+
+    # (d != c, t != s)
+    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
+        t.fail("Got clientid confirm verifier with all zero!")
+
+    if uclientid == tclientid:
+        t.fail("Return a same clientID for different verifier!")
+
+    if tconfirm == uconfirm:
+        t.fail("Return a same confirm for different verifier!")
+
 def testLotsOfClients(t, env):
     """SETCLIENTID called multiple times
 
-- 
2.4.3

