Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63809 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753014Ab1C1I4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 04:56:46 -0400
Message-ID: <4D904D97.3020003@cn.fujitsu.com>
Date: Mon, 28 Mar 2011 16:57:59 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/5] CLNT: try to destroy session after test complete
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D904BEB.1060101@cn.fujitsu.com>
In-Reply-To: <4D904BEB.1060101@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When testing pynfs41, I got NFS4ERR_DELAY at some tests.
At a test case, we don't destroy the session after create.
So, this patch try to destroy session test complete.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/nfs4client.py                       |    4 +++
 nfs4.1/server41tests/environment.py        |    1 +
 nfs4.1/server41tests/st_block.py           |    4 +++
 nfs4.1/server41tests/st_create_session.py  |   20 +++++++++++++++
 nfs4.1/server41tests/st_debug.py           |    6 ++++
 nfs4.1/server41tests/st_destroy_session.py |    9 +++++++
 nfs4.1/server41tests/st_exchange_id.py     |   12 ++++++++-
 nfs4.1/server41tests/st_getdevicelist.py   |   11 ++++++++
 nfs4.1/server41tests/st_lookup.py          |    5 ++++
 nfs4.1/server41tests/st_lookupp.py         |   11 ++++++++
 nfs4.1/server41tests/st_open.py            |   10 +++++++
 nfs4.1/server41tests/st_putfh.py           |    8 ++++++
 nfs4.1/server41tests/st_reboot.py          |    1 +
 nfs4.1/server41tests/st_rename.py          |   36 ++++++++++++++++++++++++++++
 nfs4.1/server41tests/st_secinfo.py         |    2 +
 nfs4.1/server41tests/st_secinfo_no_name.py |    2 +
 nfs4.1/server41tests/st_sequence.py        |   18 ++++++++++++++
 nfs4.1/server41tests/st_trunking.py        |    4 +++
 nfs4.1/server41tests/st_verify.py          |    1 +
 19 files changed, 164 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 9786bf3..0b3382e 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -495,6 +495,10 @@ class SessionRecord(object):
             res.resarray = res.resarray[1:]
         return res
 
+    def destroy(self):
+        res = self.c.compound([op.destroy_session(self.sessionid)])
+        nfs4lib.check(res)
+
 ##     def open(self, owner, name=None, type=OPEN4_NOCREATE,
 ##              mode=UNCHECKED4, attrs={FATTR4_MODE:0644}, verf=None,
 ##              access=OPEN4_SHARE_ACCESS_READ,
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index b8e2508..4ce7a70 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -153,6 +153,7 @@ class Environment(testmod.Environment):
         # Make sure it is empty
         clean_dir(sess, self.opts.home)
         sess.c.null()
+        sess.destroy()
 
     def _maketree(self, sess):
         """Make test tree"""
diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
index 779e328..c796540 100644
--- a/nfs4.1/server41tests/st_block.py
+++ b/nfs4.1/server41tests/st_block.py
@@ -49,6 +49,7 @@ def testStateid1(t, env):
             # the server increments by one the value of the "seqid" in each
             # subsequent LAYOUTGET and LAYOUTRETURN response,
             fail("Expected stateid.seqid==%i, got %i" % (i+2, lo_stateid.seqid))
+    sess.destroy_session()
 
 def testStateid2(t, env):
     """Check for proper sequence handling in layout stateids.
@@ -109,6 +110,7 @@ def testStateid2(t, env):
                            layoutupdate4(LAYOUT4_BLOCK_VOLUME, p.get_buffer()))]
     res = sess.compound(ops)
     check(res)
+    sess.destroy_session()
 
 def testEmptyCommit(t, env):
     """Check for proper handling of empty LAYOUTCOMMIT.
@@ -171,6 +173,7 @@ def testEmptyCommit(t, env):
                            layoutupdate4(LAYOUT4_BLOCK_VOLUME, ""))]
     res = sess.compound(ops)
     check(res)
+    sess.destroy_session()
 
 def testSplitCommit(t, env):
     """Check for proper handling of disjoint LAYOUTCOMMIT.opaque
@@ -218,3 +221,4 @@ def testSplitCommit(t, env):
                            layoutupdate4(LAYOUT4_BLOCK_VOLUME, p.get_buffer()))]
     res = sess.compound(ops)
     check(res)
+    sess.destroy_session()
diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index f8f59f6..5938e83 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -25,6 +25,7 @@ def testSupported1(t, env):
     """
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
+    sess.destroy();
 
 def testSupported2(t, env):
     """Do a CREATE_SESSION after a SEQUENCE (for same client)
@@ -44,6 +45,8 @@ def testSupported2(t, env):
     # Now make sure sess2 works
     res = sess2.compound([op.putrootfh()])
     check(res)
+    sess1.destroy();
+    sess2.destroy();
     
 def testSupported2b(t, env):
     """Do a CREATE_SESSION after a SEQUENCE (for different client)
@@ -64,6 +67,8 @@ def testSupported2b(t, env):
     # Now make sure sess2 works
     res = sess2.compound([op.putrootfh()])
     check(res)
+    sess1.destroy();
+    sess2.destroy();
     
 def testNoExchange(t, env):
     """Send CREATE_SESSION when server has no record of clientid
@@ -132,6 +137,8 @@ def testReplay1a(t, env):
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
 
+    sess1.destroy();
+
 def testReplay1b(t, env):
     """Replay a successful SEQUENCE:CREATE_SESSION without a preceeding SEQUENCE
 
@@ -156,6 +163,8 @@ def testReplay1b(t, env):
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
 
+    sess1.destroy();
+
 def testReplay2(t, env):
     """Replay a unsuccessful CREATE_SESSION
     
@@ -251,6 +260,7 @@ def testCbSecParms(t, env):
                                
     c1 = env.c1.new_client(env.testname(t))
     sess1 = c1.create_session(sec=sec)
+    sess1.destroy();
 
 def testCbSecParmsDec(t, env):
     """A decode problem was found at NFS server
@@ -267,6 +277,7 @@ def testCbSecParmsDec(t, env):
 
     c1 = env.c1.new_client(env.testname(t))
     sess1 = c1.create_session(sec=sec)
+    sess1.destroy();
 
 def testRdmaArray0(t, env):
     """Test 0 length rdma arrays
@@ -278,6 +289,7 @@ def testRdmaArray0(t, env):
     chan_attrs = channel_attrs4(0, 8192,8192,8192,128,8,[])
     sess1 = c1.create_session(fore_attrs=chan_attrs,
                               back_attrs=chan_attrs)
+    sess1.destroy();
 
 def testRdmaArray1(t, env):
     """Test length 1 rdma arrays
@@ -289,6 +301,7 @@ def testRdmaArray1(t, env):
     chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[57])
     sess1 = c1.create_session(fore_attrs=chan_attrs,
                               back_attrs=chan_attrs)
+    sess1.destroy();
 
 def testRdmaArray2(t, env):
     """Test length 2 rdma arrays
@@ -351,6 +364,8 @@ def testCallbackProgram(t, env):
     finally:
         env.c1._check_program = orig
 
+    sess.destroy();
+
 def testCallbackVersion(t, env):
     """Check server sends callback program with a version listed in nfs4client.py
 
@@ -380,6 +395,8 @@ def testCallbackVersion(t, env):
     finally:
         env.c1._check_version = orig
 
+    sess.destroy()
+
 def testMaxreqs(t, env):
     """A CREATE_SESSION with maxreqs too large should return
        a modified value
@@ -428,6 +445,8 @@ def testCsr_sequence(t, env):
     if not nfs4lib.test_equal(sess1.seqid, csa_sequence, "int"):
         fail("Server returns bad csr_sequence which not equal to csa_sequence")
 
+    sess1.destroy()
+
 def testTooSmallMaxRS(t, env):
     """If client selects a value for ca_maxresponsesize such that
        a replier on a channel could never send a response,
@@ -471,6 +490,7 @@ def testRepTooBig(t, env):
     # read data rather than ca_maxresponsesize
     res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 500)])
     check(res, NFS4ERR_REP_TOO_BIG)
+    sess1.destroy()
 
 def testRepTooBigToCache(t, env):
     """If requester sends a request for which the size of the reply
diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
index aff6842..9678192 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -30,6 +30,8 @@ def testSupported2(t, env):
     # STUB - since we are not handling callback, deleg_return never gets done
     print res
     check(res)
+    sess1.destroy()
+    sess2.destroy()
     
 def testReadWrite(t, env):
     """Do a simple READ and WRITE
@@ -57,6 +59,7 @@ def testReadWrite(t, env):
     res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 1000)])
     print res
     check(res)
+    sess1.destroy()
 
 
 def testDeadlock(t, env):
@@ -86,6 +89,7 @@ def testDeadlock(t, env):
         res = sess1.listen(xid)
         check(res)
         print res
+    sess1.destroy()
 
 def testLayout(t, env):
     """Verify layout handling
@@ -118,6 +122,7 @@ def testLayout(t, env):
                         0, 0xffffffff, 0, 0xffff)]
     res = sess.compound(ops)
     check(res)
+    sess.destroy()
     
 def testGetDevList(t, env):
     """Check devlist
@@ -142,3 +147,4 @@ def testGetDevList(t, env):
     ops = use_obj(env.opts.path) + [op.getdevicelist(LAYOUT4_BLOCK_VOLUME, 0, 0, "")]
     res = sess.compound(ops)
     check(res)
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index 1feb671..74893ca 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -27,6 +27,7 @@ def testDestroy(t, env):
     env.c1.compound([sess.seq_op()], pipe=rogue)
     res = c.c.compound([op.destroy_session(sess.sessionid)], pipe=rogue)
     check(res)
+    sess.destroy()
 
 def testDestroy2(t, env):
     """
@@ -74,6 +75,9 @@ def testDestroy2(t, env):
     recall.wait(100) # STUB - deal with timeout
     if not recall.happened:
         fail("Did not get callback")
+    sess1.destroy()
+    sess2.destroy()
+    sess3.destroy()
 
 def testDestroy3(t, env):
     """
@@ -132,6 +136,9 @@ def testDestroy3(t, env):
     recall.wait(100) # STUB - deal with timeout
     if not recall.happened:
         fail("Did not get callback")
+    sess1.destroy()
+    sess2.destroy()
+    sess3.destroy()
 
 def testDestoryNotFinalOps(t, env):
     """ If the COMPOUND request starts with SEQUENCE, DESTROY_SESSION
@@ -149,6 +156,7 @@ def testDestoryNotFinalOps(t, env):
                         op.destroy_session(sess1.sessionid),
                         op.putrootfh()])
     check(res, NFS4ERR_NOT_ONLY_OP)
+    sess1.destroy()
 
 def testDestoryNotSoleOps(t, env):
     """ If the COMPOUND request does not start with SEQUENCE,
@@ -167,3 +175,4 @@ def testDestoryNotSoleOps(t, env):
 
     res = c.c.compound([op.putrootfh(), op.destroy_session(sess1.sessionid)])
     check(res, NFS4ERR_NOT_ONLY_OP)
+    sess1.destroy()
diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
index f3e6f84..5b3cd7e 100644
--- a/nfs4.1/server41tests/st_exchange_id.py
+++ b/nfs4.1/server41tests/st_exchange_id.py
@@ -56,7 +56,7 @@ def testSupported2(t, env):
     # per draft 21 13.1, server MUST set one of these bits
     if not (res.resarray[0].eir_flags & EXCHGID4_FLAG_MASK_PNFS):
         fail("server did not set any EXCHGID4_FLAG_USE_* bits")
-
+    sess1.destroy()
 
 def testSSV(t, env):
     """Do a simple EXCHANGE_ID
@@ -84,6 +84,7 @@ def testSSV(t, env):
     # SET_SSV
     res = sess.set_ssv('\x5a' * c.protect.context.ssv_len)
     print res
+    sess.destroy()
     
 def testNoImplId(t, env):
     """Do a simple EXCHANGE_ID w/o setting client impl_id
@@ -213,6 +214,7 @@ def testNoUpdate100(t, env):
     # Check that cred1 state is destroyed
     res = sess1.compound([])
     check(res, NFS4ERR_BADSESSION)
+    sess1.destroy()
 
 # Need similar tests of 100 for expired lease, existing state (IN_USE)
 
@@ -237,6 +239,7 @@ def testNoUpdate101(t, env):
     res = sess1.compound([])
     check(res, NFS4ERR_BADSESSION)
     # FIXME - more checks here
+    sess1.destroy()
 
 def testNoUpdate110(t, env):
     """
@@ -255,6 +258,7 @@ def testNoUpdate110(t, env):
     # Check that cred1 state is destroyed
     res = sess1.compound([])
     check(res, NFS4ERR_BADSESSION)
+    sess1.destroy()
 
 # Need similar tests of 110 for expired lease, existing state (IN_USE)
 
@@ -272,6 +276,7 @@ def testNoUpdate111(t, env):
     if c1.clientid != c2.clientid:
         fail("Expected clientid %i, got %i" % (c1.clientid, c2.clientid))
     # STUB - really want to check to see if E_ID results are the same
+    sess1.destroy()
 
 def testUpdateNonexistant(t, env):
     """Do an EXCHANGE_ID update of a non-existant record
@@ -357,6 +362,7 @@ def testUpdate100(t, env):
                            cred=env.cred2,
                            flags=EXCHGID4_FLAG_UPD_CONFIRMED_REC_A,
                            expect=NFS4ERR_NOT_SAME)
+    sess1.destroy()
     
 def testUpdate101(t, env):
     """
@@ -372,6 +378,7 @@ def testUpdate101(t, env):
                            cred=env.cred1,
                            flags=EXCHGID4_FLAG_UPD_CONFIRMED_REC_A,
                            expect=NFS4ERR_NOT_SAME)
+    sess1.destroy()
     
 def testUpdate110(t, env):
     """
@@ -387,6 +394,7 @@ def testUpdate110(t, env):
                            cred=env.cred2,
                            flags=EXCHGID4_FLAG_UPD_CONFIRMED_REC_A,
                            expect=NFS4ERR_PERM)
+    sess1.destroy()
 
 
 def testUpdate111(t, env):
@@ -406,6 +414,7 @@ def testUpdate111(t, env):
         fail("Record update changed clientid from %r to %r\n" %
              (c1.clientid, c2.clientid))
     # STUB - want to check update occurred
+    sess1.destroy()
 
 # Want test similar to testUpdate111, that tries to update qqc that cant update
 
@@ -472,3 +481,4 @@ def testLeasePeriod(t, env):
                                         chan_attrs, chan_attrs,
                                         123, [])], None)
     check(res2, NFS4ERR_STALE_CLIENTID)
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
index 8d53633..4ee7ab7 100644
--- a/nfs4.1/server41tests/st_getdevicelist.py
+++ b/nfs4.1/server41tests/st_getdevicelist.py
@@ -32,6 +32,7 @@ def testGetDevList(t, env):
         # STUB - check block stuff
         dev_list = res.resarray[-1].gdlr_deviceid_list
         print dev_list
+    sess.destroy()
 
 def testGetDevInfo(t, env):
     """Check devlist
@@ -69,6 +70,8 @@ def testGetDevInfo(t, env):
                 p.done()
                 print decode
 
+    sess.destroy()
+
 
 ## def xxxtestLayout(t, env):
 ##     """Verify layout handling
@@ -140,6 +143,8 @@ def testGetLayout(t, env):
             p.done()
             print opaque
 
+    sess.destroy()
+
 def testEMCGetLayout(t, env):
     """Verify layout handling
 
@@ -183,6 +188,8 @@ def testEMCGetLayout(t, env):
             p.done()
             print opaque
 
+    sess.destroy()
+
 def testLayoutReturnFile(t, env):
     """
     Return a file's layout
@@ -215,6 +222,7 @@ def testLayoutReturnFile(t, env):
                                          layoutreturn_file4(0, 0xffffffffffffffff, layout_stateid, "")))]
     res = sess.compound(ops)
     check(res)
+    sess.destroy()
 
 def testLayoutReturnFsid(t, env):
     """
@@ -247,6 +255,7 @@ def testLayoutReturnFsid(t, env):
                            layoutreturn4(LAYOUTRETURN4_FSID))]
     res = sess.compound(ops)
     check(res)
+    sess.destroy()
 
 def testLayoutReturnAll(t, env):
     """
@@ -278,6 +287,7 @@ def testLayoutReturnAll(t, env):
                            layoutreturn4(LAYOUTRETURN4_ALL))]
     res = sess.compound(ops)
     check(res)
+    sess.destroy()
 
 def testLayoutCommit(t, env):
     """
@@ -341,5 +351,6 @@ def testLayoutCommit(t, env):
     res = sess.compound(ops)
     check(res)
     print res
+    sess.destroy()
          
     
diff --git a/nfs4.1/server41tests/st_lookup.py b/nfs4.1/server41tests/st_lookup.py
index 33e06b9..457bef4 100644
--- a/nfs4.1/server41tests/st_lookup.py
+++ b/nfs4.1/server41tests/st_lookup.py
@@ -12,6 +12,7 @@ def testHome(t, env):
     sess1 = c1.create_session()
     res = sess1.compound(env.home + [op.getfh()])
     check(res)
+    sess1.destroy()
     
 def testNoFh(t, env):
     """LOOKUP should fail with NFS4ERR_NOFILEHANDLE if no (cfh)
@@ -23,6 +24,7 @@ def testNoFh(t, env):
     sess1 = c1.create_session()
     res = sess1.compound([op.lookup(env.testname(t))])
     check(res, NFS4ERR_NOFILEHANDLE, "LOOKUP with no <cfh>")
+    sess1.destroy()
 
 def testNonExistent(t, env):
     """LOOKUP with non-existent components should return NFS4ERR_NOENT
@@ -36,6 +38,7 @@ def testNonExistent(t, env):
     res = sess1.compound(env.home + [op.lookup(name)])
     check(res, NFS4ERR_NOENT,
           "LOOKUP with non-existant component '%s'" % name)
+    sess1.destroy()
 
 def testZeroLength(t, env):
     """LOOKUP with zero length name should return NFS4ERR_INVAL
@@ -47,6 +50,7 @@ def testZeroLength(t, env):
     sess1 = c1.create_session()
     res = sess1.compound([op.putrootfh(), op.lookup('')])
     check(res, NFS4ERR_INVAL, "LOOKUP with no zero-length component")
+    sess1.destroy()
 
 def testLongName(t, env):
     """LOOKUP should fail with NFS4ERR_NAMETOOLONG with long filenames
@@ -58,6 +62,7 @@ def testLongName(t, env):
     sess1 = c1.create_session()
     res = sess1.compound([op.putrootfh(), op.lookup('abc' * 512)])
     check(res, NFS4ERR_NAMETOOLONG, "LOOKUP with very long component")
+    sess1.destroy()
     # STUB - if get NOENT, check fattr4_maxname
     # NOTE there is NO limit on component4 length
 
diff --git a/nfs4.1/server41tests/st_lookupp.py b/nfs4.1/server41tests/st_lookupp.py
index 512ea6b..41941e9 100644
--- a/nfs4.1/server41tests/st_lookupp.py
+++ b/nfs4.1/server41tests/st_lookupp.py
@@ -22,6 +22,7 @@ def testLookupp(t, env):
         if res.resarray[2*i+1].object != res.resarray[-(2*i+1)].object:
             t.fail('LOOKUPP returned %r, expected %r' %
                    (res.resarray[-(2*i+1)].object, res.resarray[2*i+1].object))
+    sess1.destroy()
 
 def testFile(t, env):
     """LOOKUPP with non-dir (cfh)
@@ -34,6 +35,7 @@ def testFile(t, env):
     ops = use_obj(env.opts.usefile) + [op.lookupp()]
     res = sess1.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
+    sess1.destroy()
 
 def testFifo(t, env):
     """LOOKUPP with non-dir (cfh)
@@ -46,6 +48,7 @@ def testFifo(t, env):
     ops = use_obj(env.opts.usefifo) + [op.lookupp()]
     res = sess1.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
+    sess1.destroy()
 
 def testLink(t, env):
     """LOOKUPP with non-dir (cfh)
@@ -58,6 +61,7 @@ def testLink(t, env):
     ops = use_obj(env.opts.uselink) + [op.lookupp()]
     res = sess1.compound(ops)
     check(res, NFS4ERR_SYMLINK, "LOOKUPP with non-dir <cfh>")
+    sess1.destroy()
 
 def testBlock(t, env):
     """LOOKUPP with non-dir (cfh)
@@ -70,6 +74,7 @@ def testBlock(t, env):
     ops = use_obj(env.opts.useblock) + [op.lookupp()]
     res = sess1.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
+    sess1.destroy()
 
 def testChar(t, env):
     """LOOKUPP with non-dir (cfh)
@@ -82,6 +87,7 @@ def testChar(t, env):
     ops = use_obj(env.opts.usechar) + [op.lookupp()]
     res = sess1.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
+    sess1.destroy()
 
 def testSock(t, env):
     """LOOKUPP with non-dir (cfh)
@@ -94,6 +100,7 @@ def testSock(t, env):
     ops = use_obj(env.opts.usesocket) + [op.lookupp()]
     res = sess1.compound(ops)
     check(res, NFS4ERR_NOTDIR, "LOOKUPP with non-dir <cfh>")
+    sess1.destroy()
 
 def testLookuppRoot(t, env):
     """Lookupp from root should return NFS4ERR_NOENT
@@ -108,6 +115,7 @@ def testLookuppRoot(t, env):
     fh = res.resarray[-1].object
     res = sess1.compound([op.putfh(fh), op.lookupp()])
     check(res, NFS4ERR_NOENT)
+    sess1.destroy()
 
 def testNoFH(t, env):
     """Lookup without a cfh should return NFS4ERR_NOFILEHANDLE
@@ -119,6 +127,7 @@ def testNoFH(t, env):
     sess1 = c1.create_session()
     res = sess1.compound([op.lookupp()])
     check(res, NFS4ERR_NOFILEHANDLE)
+    sess1.destroy()
 
 def testXdev(t, env):
     """LOOKUPP with dir on different fs
@@ -138,3 +147,5 @@ def testXdev(t, env):
     fh2 = res.resarray[-1].object
     if fh1 != fh2:
         t.fail("file handles not equal")
+
+    sess1.destroy()
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 03edf76..09b2baa 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -30,6 +30,7 @@ def testSupported(t, env):
     # see draft-10 line 19445
     # QUESTION - what does "If the server supports the new _WANT_ flags" mean?
     #    will the server return INVAL? NOTSUPP? or just silently ignore?
+    sess1.destroy()
 
 def testServerStateSeqid(t, env):
     """Do multiple OPENs of a file, check that server bumps stateid.seqid
@@ -49,6 +50,7 @@ def testServerStateSeqid(t, env):
     check(res)
     expect(res, seqid=2)
     # STUB - need to check no delegation return
+    sess1.destroy()
 
 # Test outdate, see draft22 8.2.2
 def xtestClientStateSeqid(t, env):
@@ -73,6 +75,7 @@ def xtestClientStateSeqid(t, env):
     stateid = res.resarray[-2].stateid
     res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, "write test data")])
     check(res, NFS4ERR_BAD_STATEID, "Using an open_stateid w/o zeroing the seqid")
+    sess1.destroy()
     
 
 # Test outdated by draft15 8.8
@@ -96,6 +99,7 @@ def xtestOpenSeqid(t, env):
     res = open_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_READ,
                     seqid=1)
     check(res, NFS4ERR_INVAL, msg="Using non-zero seqid in OPEN")
+    sess1.destroy()
     
     
 # Test outdated by draft15 8.8
@@ -116,6 +120,7 @@ def xtestOpenClientid(t, env):
     sess1 = c1.create_session()
     res = create_file(sess1, env.testname(t), clientid=c1.clientid)
     check(res, NFS4ERR_INVAL, msg="Using non-zero clientid in open_owner")
+    sess1.destroy()
 
 def testReadDeleg(t, env):
     """Test read delgation handout and return
@@ -173,6 +178,9 @@ def testReadDeleg(t, env):
     print res
     checklist(res, [NFS4_OK, NFS4ERR_DELAY])
     print "FRED - done"
+
+    sess1.destroy()
+    sess2.destroy()
     
                          
     
@@ -201,6 +209,7 @@ def testReadWrite(t, env):
     desired = "\0"*5 + data
     if res.resarray[-1].data != desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
+    sess1.destroy()
 
 def testEXCLUSIVE4AtNameAttribute(t, env):
     """If the file does exist,but the stored verifier does not match,
@@ -219,3 +228,4 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
     res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
                         verifier = "Justtest")
     check(res, NFS4ERR_EXIST)
+    sess1.destroy()
diff --git a/nfs4.1/server41tests/st_putfh.py b/nfs4.1/server41tests/st_putfh.py
index d7bc0be..ce7edc7 100644
--- a/nfs4.1/server41tests/st_putfh.py
+++ b/nfs4.1/server41tests/st_putfh.py
@@ -23,6 +23,7 @@ def testFile(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.usefile)
+    sess.destroy()
 
 def testLink(t, env):
     """PUTFH followed by GETFH should end up with original fh
@@ -33,6 +34,7 @@ def testLink(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.uselink)
+    sess.destroy()
 
 def testBlock(t, env):
     """PUTFH followed by GETFH should end up with original fh
@@ -43,6 +45,7 @@ def testBlock(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.useblock)
+    sess.destroy()
 
 def testChar(t, env):
     """PUTFH followed by GETFH should end up with original fh
@@ -53,6 +56,7 @@ def testChar(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.usechar)
+    sess.destroy()
 
 def testDir(t, env):
     """PUTFH followed by GETFH should end up with original fh
@@ -63,6 +67,7 @@ def testDir(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.usedir)
+    sess.destroy()
 
 def testFifo(t, env):
     """PUTFH followed by GETFH should end up with original fh
@@ -73,6 +78,7 @@ def testFifo(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.usefifo)
+    sess.destroy()
 
 def testSocket(t, env):
     """PUTFH followed by GETFH should end up with original fh
@@ -83,6 +89,7 @@ def testSocket(t, env):
     c = env.c1.new_client(env.testname(t))
     sess = c.create_session()
     _try_put(t, sess, env.opts.usesocket)
+    sess.destroy()
 
 def testBadHandle(t, env):
     """PUTFH with bad filehandle should return NFS4ERR_BADHANDLE
@@ -94,3 +101,4 @@ def testBadHandle(t, env):
     sess = c.create_session()
     res = sess.compound([op.putfh('abc')])
     check(res, NFS4ERR_BADHANDLE, "PUTFH with bad filehandle='abc'")
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
index 9eee19d..31f4b3f 100644
--- a/nfs4.1/server41tests/st_reboot.py
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -74,3 +74,4 @@ def testRebootValid(t, env):
         reclaim_complete(sess)
     finally:
         env.sleep(sleeptime, "Waiting for grace period to end")
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index 331cd21..554597c 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -17,6 +17,7 @@ def testValidDir(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of directory %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testValidFile(t, env):
     """RENAME : normal operation
@@ -32,6 +33,7 @@ def testValidFile(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of file %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testValidLink(t, env):
     """RENAME : normal operation
@@ -49,6 +51,7 @@ def testValidLink(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of symlink %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testValidBlock(t, env):
     """RENAME : normal operation
@@ -66,6 +69,7 @@ def testValidBlock(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of block device %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testValidChar(t, env):
     """RENAME : normal operation
@@ -83,6 +87,7 @@ def testValidChar(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of character device %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testValidFifo(t, env):
     """RENAME : normal operation
@@ -100,6 +105,7 @@ def testValidFifo(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of fifo %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testValidSocket(t, env):
     """RENAME : normal operation
@@ -117,6 +123,7 @@ def testValidSocket(t, env):
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
     check(res, msg="RENAME of socket %s/dir1/foo to %s/dir2/bar" %
           (name, name))
+    sess.destroy()
 
 def testSfhFile(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -129,6 +136,7 @@ def testSfhFile(t, env):
     sess = c.create_session()
     res = rename_obj(sess, env.opts.usefile + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
+    sess.destroy()
 
 def testSfhLink(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -141,6 +149,7 @@ def testSfhLink(t, env):
     sess = c.create_session()
     res = rename_obj(sess, env.opts.uselink + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
+    sess.destroy()
 
 def testSfhBlock(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -153,6 +162,7 @@ def testSfhBlock(t, env):
     sess = c.create_session()
     res = rename_obj(sess, env.opts.useblock + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
+    sess.destroy()
 
 def testSfhChar(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -165,6 +175,7 @@ def testSfhChar(t, env):
     sess = c.create_session()
     res = rename_obj(sess, env.opts.usechar + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
+    sess.destroy()
 
 def testSfhFifo(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -177,6 +188,7 @@ def testSfhFifo(t, env):
     sess = c.create_session()
     res = rename_obj(sess, env.opts.usefifo + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
+    sess.destroy()
 
 def testSfhSocket(t, env):
     """RENAME with non-dir (sfh) should return NFS4ERR_NOTDIR
@@ -189,6 +201,7 @@ def testSfhSocket(t, env):
     sess = c.create_session()
     res = rename_obj(sess, env.opts.usesocket + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
+    sess.destroy()
 
 def testCfhFile(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -203,6 +216,7 @@ def testCfhFile(t, env):
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usefile + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    sess.destroy()
 
 def testCfhLink(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -217,6 +231,7 @@ def testCfhLink(t, env):
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.uselink + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    sess.destroy()
 
 def testCfhBlock(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -231,6 +246,7 @@ def testCfhBlock(t, env):
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.useblock + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    sess.destroy()
 
 def testCfhChar(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -245,6 +261,7 @@ def testCfhChar(t, env):
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usechar + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    sess.destroy()
 
 def testCfhFifo(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -259,6 +276,7 @@ def testCfhFifo(t, env):
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usefifo + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    sess.destroy()
 
 def testCfhSocket(t, env):
     """RENAME with non-dir (cfh) should return NFS4ERR_NOTDIR
@@ -273,6 +291,7 @@ def testCfhSocket(t, env):
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usesocket + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <cfh>")
+    sess.destroy()
 
 def testNoSfh(t, env):
     """RENAME without (sfh) should return NFS4ERR_NOFILEHANDLE
@@ -286,6 +305,7 @@ def testNoSfh(t, env):
     ops = env.home + [op.rename(name, name)]
     res = sess.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "RENAME with no <sfh>")
+    sess.destroy()
 
 # FRED - can't test No Cfh, with a Sfh
 
@@ -303,6 +323,7 @@ def testNonExistent(t, env):
     check(res)
     res = rename_obj(sess, basedir + ['foo'], basedir + ['bar'])
     check(res, NFS4ERR_NOENT, "RENAME on non-existing object %s/foo" % name)
+    sess.destroy()
 
 def testZeroLengthOldname(t, env):
     """RENAME with zero length oldname should return NFS4ERR_INVAL
@@ -318,6 +339,7 @@ def testZeroLengthOldname(t, env):
     check(res)
     res = rename_obj(sess, basedir + [''], basedir + ['bar'])
     check(res, NFS4ERR_INVAL, "RENAME with zero length oldname")
+    sess.destroy()
 
 def testZeroLengthNewname(t, env):
     """RENAME with zero length newname should return NFS4ERR_INVAL
@@ -333,6 +355,7 @@ def testZeroLengthNewname(t, env):
     check(res)
     res = rename_obj(sess, basedir + ['foo'], basedir + [''])
     check(res, NFS4ERR_INVAL, "RENAME with zero length newname")
+    sess.destroy()
 
 def testBadutf8Oldname(t, env):
     """RENAME with non-UTF8 oldname should return NFS4ERR_INVAL
@@ -350,6 +373,7 @@ def testBadutf8Oldname(t, env):
         res = rename_obj(sess, basedir + [bad_utf8], basedir + [name])
         check(res, NFS4ERR_INVAL, "RENAME with non-UTF8 oldname %s/%s" %
                                    (name, repr(bad_utf8)[1:-1]))
+    sess.destroy()
 
 def testBadutf8Newname(t, env):
     """RENAME with non-UTF8 newname should return NFS4ERR_INVAL
@@ -366,6 +390,7 @@ def testBadutf8Newname(t, env):
         res = rename_obj(sess, basedir + [name], basedir + [bad_utf8])
         check(res, NFS4ERR_INVAL, "RENAME with non-UTF8 newname %s/%s" %
                                    (name, repr(bad_utf8)[1:-1]))
+    sess.destroy()
 
 def testDotsOldname(t, env):
     """RENAME from nonexistant . or .. should return _NOENT/_BADNAME
@@ -384,6 +409,7 @@ def testDotsOldname(t, env):
     res = rename_obj(sess, basedir + ['..'], basedir + [name])
     check(res, NFS4ERR_BADNAME, "RENAME from nonexistant '..'",
           [NFS4ERR_NOENT])
+    sess.destroy()
 
 def testDotsNewname(t, env):
     """RENAME into . or .. should return _BADNAME or NFS4_OK
@@ -402,6 +428,7 @@ def testDotsNewname(t, env):
     res = rename_obj(sess, basedir + [name], basedir + ['..'])
     check(res, NFS4ERR_BADNAME, "RENAME into '..'",
           [NFS4_OK])
+    sess.destroy()
 
 def testDirToObj(t, env):
     """RENAME dir into existing nondir should return NFS4ERR_EXIST
@@ -416,6 +443,7 @@ def testDirToObj(t, env):
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['dir'], basedir + ['file'])
     check(res, NFS4ERR_EXIST, "RENAME dir into existing file")
+    sess.destroy()
 
 def testDirToDir(t, env):
     """RENAME dir into existing, empty dir should retrun NFS4_OK
@@ -430,6 +458,7 @@ def testDirToDir(t, env):
     maketree(sess, [name, ['dir1', ['foo']], ['dir2']])
     res = rename_obj(sess, basedir + ['dir1'], basedir + ['dir2'])
     check(res, msg="RENAME dir1 into existing, empty dir2")
+    sess.destroy()
 
 def testFileToDir(t, env):
     """RENAME file into existing dir should return NFS4ERR_EXIST
@@ -444,6 +473,7 @@ def testFileToDir(t, env):
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
     check(res, NFS4ERR_EXIST, "RENAME file into existing dir")
+    sess.destroy()
 
 def testFileToFile(t, env):
     """RENAME file into existing file should return NFS4_OK
@@ -458,6 +488,7 @@ def testFileToFile(t, env):
     maketree(sess, [name, 'file1', 'file2'])
     res = rename_obj(sess, basedir + ['file1'], basedir + ['file2'])
     check(res, msg="RENAME file1 into existing file2")
+    sess.destroy()
 
 def testDirToFullDir(t, env):
     """RENAME dir into existing, nonempty dir should return NFS4ERR_EXIST
@@ -472,6 +503,7 @@ def testDirToFullDir(t, env):
     maketree(sess, [name, ['dir1'], ['dir2', ['foo']]])
     res = rename_obj(sess, basedir + ['dir1'], basedir + ['dir2'])
     check(res, NFS4ERR_EXIST, "RENAME dir1 into existing, nonempty dir2")
+    sess.destroy()
 
 def testFileToFullDir(t, env):
     """RENAME file into existing, nonempty dir should return NFS4ERR_EXIST
@@ -486,6 +518,7 @@ def testFileToFullDir(t, env):
     maketree(sess, [name, 'file', ['dir', ['foo']]])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
     check(res, NFS4ERR_EXIST, "RENAME file into existing, nonempty dir")
+    sess.destroy()
 
 def testSelfRenameDir(t, env):
     """RENAME that does nothing
@@ -505,6 +538,7 @@ def testSelfRenameDir(t, env):
     if scinfo.before != scinfo.after or tcinfo.before != tcinfo.after:
         t.fail("RENAME of dir %s into itself should do nothing, "
                "but cinfo was changed" % name)
+    sess.destroy()
 
 def testSelfRenameFile(t, env):
     """RENAME that does nothing
@@ -524,6 +558,7 @@ def testSelfRenameFile(t, env):
     if scinfo.before != scinfo.after or tcinfo.before != tcinfo.after:
         t.fail("RENAME of file %s into itself should do nothing, "
                "but cinfo was changed" % name)
+    sess.destroy()
 
 def testLinkRename(t, env):
     """RENAME of file into its hard link should do nothing
@@ -545,3 +580,4 @@ def testLinkRename(t, env):
     if scinfo.before != scinfo.after or tcinfo.before != tcinfo.after:
         t.fail("RENAME of file into its hard link should do nothing, "
                "but cinfo was changed")
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_secinfo.py b/nfs4.1/server41tests/st_secinfo.py
index c0e5b71..381898d 100644
--- a/nfs4.1/server41tests/st_secinfo.py
+++ b/nfs4.1/server41tests/st_secinfo.py
@@ -29,6 +29,7 @@ def testSupported(t, env):
     # Just do a simple SECINFO
     res = sess.compound([op.putfh(fh), op.secinfo(name)])
     check(res)
+    sess.destroy()
 
 def testSupported2(t, env):
     """GETFH after do a SECINFO_NO_NAME or SECINFO
@@ -55,3 +56,4 @@ def testSupported2(t, env):
     # GETFH after do a SECINFO should get error NFS4ERR_NOFILEHANDLE
     res = sess.compound([op.putfh(fh), op.secinfo(name), op.getfh()])
     check(res, NFS4ERR_NOFILEHANDLE)
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_secinfo_no_name.py b/nfs4.1/server41tests/st_secinfo_no_name.py
index 14bc410..cc2c30f 100644
--- a/nfs4.1/server41tests/st_secinfo_no_name.py
+++ b/nfs4.1/server41tests/st_secinfo_no_name.py
@@ -18,6 +18,7 @@ def testSupported(t, env):
     # Do a simple SECINFO_NO_NAME
     res = sess.compound([op.putrootfh(), op.secinfo_no_name(0)])
     check(res)
+    sess.destroy()
 
 def testSupported2(t, env):
     """GETFH after do a SECINFO_NO_NAME or SECINFO
@@ -33,3 +34,4 @@ def testSupported2(t, env):
     res = sess.compound([op.putrootfh(), op.secinfo_no_name(0), op.getfh()])
     print res
     check(res, NFS4ERR_NOFILEHANDLE)
+    sess.destroy()
diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index 7277290..9c2a756 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -15,6 +15,7 @@ def testSupported(t, env):
     sess = c.create_session()
     res = sess.compound([])
     check(res)
+    sess.destroy()
 
 def testNotFirst(t, env):
     """SEQUENCE must be first
@@ -26,6 +27,7 @@ def testNotFirst(t, env):
     sess = c.create_session()
     res = sess.compound([sess.seq_op()])
     check(res, NFS4ERR_SEQUENCE_POS)
+    sess.destroy()
 
 def testNotBound(t, env):
     """SEQUENCE sent on unbound connection
@@ -70,6 +72,7 @@ def testImplicitBind(t, env):
     res = env.c1.compound([sess.seq_op()], pipe=rogue)
     check(res)
     env.c1.close(rogue)
+    sess.destroy()
     
 def testImplicitBind4a(t, env):
     """SEQUENCE sent on unbound connection will bind it if no enforcing done
@@ -93,6 +96,7 @@ def testImplicitBind4a(t, env):
     print "B4"
     env.c1.close(rogue)
     print "B5"
+    sess.destroy()
     
 def xtestImplicitBind(t, env):
     """SEQUENCE sent on unbound connection will bind it if no enforcing done
@@ -122,6 +126,7 @@ def xtestImplicitBind(t, env):
     res = c.compound([op.sequence(sid, seqid, 0, 0, True)], pipe=rogue)
     check(res)
     c.close(rogue)
+    sess.destroy()
     
 def testBadSession(t, env):
     """SEQUENCE sent on unknown session
@@ -148,6 +153,7 @@ def testRequestTooBig(t, env):
     res = sess1.compound([op.putrootfh(), op.lookup("12345"*100)])
     # FIXME - NAME_TOO_BIG is valid, don't want it to be
     check(res, NFS4ERR_REQ_TOO_BIG)
+    sess1.destroy()
 
 def testTooManyOps(t, env):
     """Send a request with more ops than the session can handle
@@ -168,6 +174,7 @@ def testTooManyOps(t, env):
     lots_of_ops += [op.getattr(0)]
     res = sess1.compound(lots_of_ops)
     check(res, NFS4ERR_TOO_MANY_OPS)
+    sess1.destroy()
 
 def testBadSlot(t, env):
     """Send a request with a bad slot
@@ -182,6 +189,7 @@ def testBadSlot(t, env):
     # Send sequence on (non-existant) slot number 8
     res = env.c1.compound([op.sequence(sess1.sessionid, 1, 8, 8, True)])
     check(res, NFS4ERR_BADSLOT)
+    sess1.destroy()
 
 def testReplayCache001(t, env):
     """Send two successful idempotent compounds with same seqid
@@ -198,6 +206,7 @@ def testReplayCache001(t, env):
     res1.tag = res2.tag = ""
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
+    sess1.destroy()
 
 def testReplayCache002(t, env):
     """Send two successful non-idempotent compounds with same seqid
@@ -218,6 +227,7 @@ def testReplayCache002(t, env):
     res1.tag = res2.tag = ""
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
+    sess1.destroy()
 
 def testReplayCache003(t, env):
     """Send two unsuccessful idempotent compounds with same seqid
@@ -234,6 +244,7 @@ def testReplayCache003(t, env):
     res1.tag = res2.tag = ""
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
+    sess1.destroy()
 
 def testReplayCache004(t, env):
     """Send two unsuccessful non-idempotent compounds with same seqid
@@ -251,6 +262,7 @@ def testReplayCache004(t, env):
     res1.tag = res2.tag = ""
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
+    sess1.destroy()
 
 def testReplayCache005(t, env):
     """Send two unsupported compounds with same seqid
@@ -267,6 +279,7 @@ def testReplayCache005(t, env):
     res1.tag = res2.tag = ""
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
+    sess1.destroy()
 
 def testReplayCache006(t, env):
     """Send two solo sequence compounds with same seqid
@@ -283,6 +296,7 @@ def testReplayCache006(t, env):
     res1.tag = res2.tag = ""
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
+    sess1.destroy()
 
 def testReplayCache007(t, env):
     """Send two successful non-idempotent compounds with same seqid and False cache_this
@@ -300,6 +314,7 @@ def testReplayCache007(t, env):
     check(res1, NFS4_OK)
     res2 = sess1.compound(ops, seq_delta=0, cache_this=False)
     check(res2, NFS4ERR_RETRY_UNCACHED_REP)
+    sess1.destroy()
 
 def testOpNotInSession(t, env):
     """Operations other than SEQUENCE, BIND_CONN_TO_SESSION, EXCHANGE_ID,
@@ -338,6 +353,7 @@ def testSessionidSequenceidSlotid(t, env):
 
     if not nfs4lib.test_equal(res.resarray[0].sr_slotid, 2, "int"):
         fail("server return bad slotid")
+    sess1.destroy()
 
 def testBadSequenceidAtSlot(t, env):
     """ If the difference between sa_sequenceid and the server's cached
@@ -363,6 +379,7 @@ def testBadSequenceidAtSlot(t, env):
 
     res = c.c.compound([op.sequence(sid, nfs4lib.dec_u32(seqid), 2, 3, True)])
     check(res, NFS4ERR_SEQ_MISORDERED)
+    sess1.destroy()
 
 def testReuseSlotID(t, env):
     """ If client reuses a slot ID and sequence ID for a completely
@@ -392,3 +409,4 @@ def testReuseSlotID(t, env):
     res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE)] +
                         nfs4lib.use_obj(dir) + [op.rename(name, "test")])
     check(res)
+    sess1.destroy()
diff --git a/nfs4.1/server41tests/st_trunking.py b/nfs4.1/server41tests/st_trunking.py
index d99f80f..a0b4281 100644
--- a/nfs4.1/server41tests/st_trunking.py
+++ b/nfs4.1/server41tests/st_trunking.py
@@ -23,6 +23,8 @@ def testTwoSessions(t, env):
 	c = env.c1.new_client(env.testname(t))
 	sess = c.create_session()
 	sess2 = c.create_session()
+        sess.destroy()
+        sess2.destroy()
 
 
 def testUseTwoSessions(t, env):
@@ -42,6 +44,8 @@ def testUseTwoSessions(t, env):
 	check(res)
 	res = sess2.compound([])
 	check(res)
+        sess.destroy()
+        sess2.destroy()
 
 # create client
 # create session
diff --git a/nfs4.1/server41tests/st_verify.py b/nfs4.1/server41tests/st_verify.py
index a1bc5ca..d6e62f1 100644
--- a/nfs4.1/server41tests/st_verify.py
+++ b/nfs4.1/server41tests/st_verify.py
@@ -12,6 +12,7 @@ def _try_mand(t, env, path):
     ops = use_obj(path) + [op.verify(dict)] + use_obj(path)
     res = sess1.compound(ops)
     check(res, msg="Verifying mandatory attributes against getattr")
+    sess1.destroy()
 
 def _try_type(env, path, type):
     c = env.c1
-- 
1.7.4.1



