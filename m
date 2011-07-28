Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59035 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755440Ab1G1UDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:03:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/6] CLNT: provide new_client_session shortcut
Date: Thu, 28 Jul 2011 16:02:59 -0400
Message-Id: <1311883384-20260-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Most tests begin with new_client + create_session.  Provide a handy
shortcut for both.

This will also provide a convenient place to put a RECLAIM_COMPLETE,
which most tests also need.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/nfs4client.py                |    5 ++
 nfs4.1/server41tests/environment.py |    3 +-
 nfs4.1/server41tests/st_block.py    |   16 +++---
 nfs4.1/server41tests/st_open.py     |   21 ++-----
 nfs4.1/server41tests/st_rename.py   |  108 ++++++++++++-----------------------
 nfs4.1/server41tests/st_secinfo.py  |    6 +-
 nfs4.1/server41tests/st_sequence.py |    8 +--
 7 files changed, 62 insertions(+), 105 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 9786bf3..e162e70 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -289,6 +289,11 @@ class NFS4Client(rpc.Client, rpc.Server):
         else:
             return None
 
+    def new_client_session(self, name, flags=0):
+        c = self.new_client(name, flags=flags)
+        s = c.create_session()
+        return s
+
 class ClientStateProtection(object):
     def __init__(self, p_res, p_arg):
         self.type = p_res.spr_how
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index b8e2508..b987e9d 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -143,8 +143,7 @@ class Environment(testmod.Environment):
         """Run once before any test is run"""
         if self.opts.noinit:
             return
-        c = self.c1.new_client("Environment.init_%i" % self.timestamp)
-        sess = c.create_session()
+        sess = self.c1.new_client_session("Environment.init_%i" % self.timestamp)
         if self.opts.maketree:
             self._maketree(sess)
         # Make sure opts.home exists
diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
index 779e328..f62968e 100644
--- a/nfs4.1/server41tests/st_block.py
+++ b/nfs4.1/server41tests/st_block.py
@@ -14,8 +14,8 @@ def testStateid1(t, env):
     FLAGS: block
     CODE: BLOCK1
     """
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    sess = c1.create_session()
+    sess = env.c1.new_client_session(env.testname(t),
+                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -56,8 +56,8 @@ def testStateid2(t, env):
     FLAGS: block
     CODE: BLOCK2
     """
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    sess = c1.create_session()
+    c1 = env.c1.new_client_session(env.testname(t),
+                                    flags=EXCHGID4_FLAG_USE_PNFS_MDS)
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -116,8 +116,8 @@ def testEmptyCommit(t, env):
     FLAGS: block
     CODE: BLOCK3
     """
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    sess = c1.create_session()
+    c1 = env.c1.new_client_session(env.testname(t),
+                                    flags=EXCHGID4_FLAG_USE_PNFS_MDS)
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
@@ -178,8 +178,8 @@ def testSplitCommit(t, env):
     FLAGS: block
     CODE: BLOCK4
     """
-    c1 = env.c1.new_client(env.testname(t), flags=EXCHGID4_FLAG_USE_PNFS_MDS)
-    sess = c1.create_session()
+    sess = env.c1.new_client_session(env.testname(t),
+                                        flags=EXCHGID4_FLAG_USE_PNFS_MDS)
     # Create the file
     res = create_file(sess, env.testname(t))
     check(res)
diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 97198a6..b599b04 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -18,8 +18,7 @@ def testSupported(t, env):
     FLAGS: open all
     CODE: OPEN1
     """
-    c1 = env.c1.new_client(env.testname(t))
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(env.testname(t))
     res = create_file(sess1, env.testname(t))
     check(res)
     # See 8.1.3.1 of draft-10:
@@ -38,8 +37,7 @@ def testServerStateSeqid(t, env):
     CODE: OPEN2
     """
     name = env.testname(t)
-    c1 = env.c1.new_client(name)
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(name)
     owner = "owner_%s" % name
     path = sess1.c.homedir + [name]
     res = create_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_WRITE)
@@ -60,8 +58,7 @@ def xtestClientStateSeqid(t, env):
     CODE: OPEN3
     """
     name = env.testname(t)
-    c1 = env.c1.new_client(name)
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(name)
     owner = "owner_%s" % name
     path = sess1.c.homedir + [name]
     res = create_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_WRITE)
@@ -86,8 +83,7 @@ def xtestOpenSeqid(t, env):
     CODE: OPEN4
     """
     name = env.testname(t)
-    c1 = env.c1.new_client(name)
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(name)
     owner = "owner_%s" % name
     path = sess1.c.homedir + [name]
     res = create_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_WRITE)
@@ -143,8 +139,7 @@ def testReadDeleg(t, env):
     if deleg.delegation_type == OPEN_DELEGATE_NONE:
         fail("Could not get delegation")
     # c2 - OPEN - WRITE
-    c2 = env.c1.new_client("%s_2" % env.testname(t))
-    sess2 = c2.create_session()
+    sess2 = env.c1.new_client_session("%s_2" % env.testname(t))
     claim = open_claim4(CLAIM_NULL, env.testname(t))
     owner = open_owner4(0, "My Open Owner 2")
     how = openflag4(OPEN4_NOCREATE)
@@ -168,8 +163,7 @@ def testReadWrite(t, env):
     FLAGS: open all
     CODE: OPEN30
     """
-    c1 = env.c1.new_client(env.testname(t))
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(env.testname(t))
     owner = open_owner4(0, "My Open Owner")
     res = create_file(sess1, env.testname(t))
     check(res)
@@ -196,8 +190,7 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
     FLAGS: open all
     CODE: OPEN6
     """
-    c1 = env.c1.new_client(env.testname(t))
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client(env.testname(t))
 
     res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1)
     check(res)
diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index 331cd21..7804316 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -10,8 +10,7 @@ def testValidDir(t, env):
     CODE: RNM1d
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1', ['foo']], ['dir2']])
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
@@ -25,8 +24,7 @@ def testValidFile(t, env):
     CODE: RNM1r
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1', 'foo'], ['dir2']])
     res = rename_obj(sess, basedir + ['dir1', 'foo'], basedir + ['dir2', 'bar'])
@@ -40,8 +38,7 @@ def testValidLink(t, env):
     CODE: RNM1a
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2']])
     res = create_obj(sess, basedir + ['dir1', 'foo'], createtype4(NF4LNK, linkdata=env.linkdata))
@@ -57,8 +54,7 @@ def testValidBlock(t, env):
     CODE: RNM1b
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2']])
     res = create_obj(sess, basedir + ['dir1', 'foo'], createtype4(NF4BLK, devdata=specdata4(1, 2)))
@@ -74,8 +70,7 @@ def testValidChar(t, env):
     CODE: RNM1c
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2']])
     res = create_obj(sess, basedir + ['dir1', 'foo'], createtype4(NF4BLK, devdata=specdata4(1, 2)))
@@ -91,8 +86,7 @@ def testValidFifo(t, env):
     CODE: RNM1f
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2']])
     res = create_obj(sess, basedir + ['dir1', 'foo'], NF4FIFO)
@@ -108,8 +102,7 @@ def testValidSocket(t, env):
     CODE: RNM1s
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2']])
     res = create_obj(sess, basedir + ['dir1', 'foo'], NF4SOCK)
@@ -125,8 +118,7 @@ def testSfhFile(t, env):
     CODE: RNM2r
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.usefile + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
 
@@ -137,8 +129,7 @@ def testSfhLink(t, env):
     CODE: RNM2a
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.uselink + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
 
@@ -149,8 +140,7 @@ def testSfhBlock(t, env):
     CODE: RNM2b
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.useblock + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
 
@@ -161,8 +151,7 @@ def testSfhChar(t, env):
     CODE: RNM2c
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.usechar + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
 
@@ -173,8 +162,7 @@ def testSfhFifo(t, env):
     CODE: RNM2f
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.usefifo + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
 
@@ -185,8 +173,7 @@ def testSfhSocket(t, env):
     CODE: RNM2s
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = rename_obj(sess, env.opts.usesocket + [name], env.c1.homedir + [name])
     check(res, NFS4ERR_NOTDIR, "RENAME with non-dir <sfh>")
 
@@ -197,8 +184,7 @@ def testCfhFile(t, env):
     CODE: RNM3r
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = create_obj(sess, [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usefile + [name])
@@ -211,8 +197,7 @@ def testCfhLink(t, env):
     CODE: RNM3a
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = create_obj(sess, [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.uselink + [name])
@@ -225,8 +210,7 @@ def testCfhBlock(t, env):
     CODE: RNM3b
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = create_obj(sess, [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.useblock + [name])
@@ -239,8 +223,7 @@ def testCfhChar(t, env):
     CODE: RNM3c
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = create_obj(sess, [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usechar + [name])
@@ -253,8 +236,7 @@ def testCfhFifo(t, env):
     CODE: RNM3f
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = create_obj(sess, [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usefifo + [name])
@@ -267,8 +249,7 @@ def testCfhSocket(t, env):
     CODE: RNM3s
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     res = create_obj(sess, [name])
     check(res)
     res = rename_obj(sess, env.c1.homedir + [name], env.opts.usesocket + [name])
@@ -281,8 +262,7 @@ def testNoSfh(t, env):
     CODE: RNM4
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     ops = env.home + [op.rename(name, name)]
     res = sess.compound(ops)
     check(res, NFS4ERR_NOFILEHANDLE, "RENAME with no <sfh>")
@@ -296,8 +276,7 @@ def testNonExistent(t, env):
     CODE: RNM5
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     res = create_obj(sess, basedir)
     check(res)
@@ -311,8 +290,7 @@ def testZeroLengthOldname(t, env):
     CODE: RNM6
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     res = create_obj(sess, basedir)
     check(res)
@@ -326,8 +304,7 @@ def testZeroLengthNewname(t, env):
     CODE: RNM7
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     res = create_obj(sess, basedir)
     check(res)
@@ -341,8 +318,7 @@ def testBadutf8Oldname(t, env):
     CODE: RNM8
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     res = create_obj(sess, basedir)
     check(res)
@@ -358,8 +334,7 @@ def testBadutf8Newname(t, env):
     CODE: RNM9
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, [name]])
     for bad_utf8 in get_invalid_utf8strings():
@@ -374,8 +349,7 @@ def testDotsOldname(t, env):
     CODE: RNM10
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, [name]])
     res = rename_obj(sess, basedir + ['.'], basedir + [name])
@@ -392,8 +366,7 @@ def testDotsNewname(t, env):
     CODE: RNM11
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, [name]])
     res = rename_obj(sess, basedir + [name], basedir + ['.'])
@@ -410,8 +383,7 @@ def testDirToObj(t, env):
     CODE: RNM12
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['dir'], basedir + ['file'])
@@ -424,8 +396,7 @@ def testDirToDir(t, env):
     CODE: RNM13
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1', ['foo']], ['dir2']])
     res = rename_obj(sess, basedir + ['dir1'], basedir + ['dir2'])
@@ -438,8 +409,7 @@ def testFileToDir(t, env):
     CODE: RNM14
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
@@ -452,8 +422,7 @@ def testFileToFile(t, env):
     CODE: RNM15
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, 'file1', 'file2'])
     res = rename_obj(sess, basedir + ['file1'], basedir + ['file2'])
@@ -466,8 +435,7 @@ def testDirToFullDir(t, env):
     CODE: RNM16
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir1'], ['dir2', ['foo']]])
     res = rename_obj(sess, basedir + ['dir1'], basedir + ['dir2'])
@@ -480,8 +448,7 @@ def testFileToFullDir(t, env):
     CODE: RNM17
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, 'file', ['dir', ['foo']]])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
@@ -494,8 +461,7 @@ def testSelfRenameDir(t, env):
     CODE: RNM18
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     maketree(sess, [name])
     basedir = env.c1.homedir + [name]
     res = rename_obj(sess, basedir, basedir)
@@ -513,8 +479,7 @@ def testSelfRenameFile(t, env):
     CODE: RNM19
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     fh, stateid = create_confirm(sess, name)
     basedir = env.c1.homedir + [name]
     res = rename_obj(sess, basedir, basedir)
@@ -532,8 +497,7 @@ def testLinkRename(t, env):
     CODE: RNM20
     """
     name = env.testname(t)
-    c = env.c1.new_client(name)
-    sess = c.create_session()
+    sess = env.c1.new_client_session(name)
     maketree(sess, [name, 'file'])
     basedir = env.c1.homedir + [name]
     res = link(sess, basedir + ['file'], basedir + ['link'])
diff --git a/nfs4.1/server41tests/st_secinfo.py b/nfs4.1/server41tests/st_secinfo.py
index c0e5b71..d9a1e98 100644
--- a/nfs4.1/server41tests/st_secinfo.py
+++ b/nfs4.1/server41tests/st_secinfo.py
@@ -12,8 +12,7 @@ def testSupported(t, env):
     CODE: SEC1
     """
     name = env.testname(t)
-    c = env.c1.new_client(env.testname(t))
-    sess = c.create_session()
+    sess = env.c1.new_client_session(env.testname(t))
 
     # Create a tmpfile for testing
     owner = "owner_%s" % name
@@ -38,8 +37,7 @@ def testSupported2(t, env):
     CODE: SEC2
     """
     name = env.testname(t)
-    c = env.c1.new_client(env.testname(t))
-    sess = c.create_session()
+    sess = env.c1.new_client_session(env.testname(t))
 
     # Create a tmpfile for testing
     owner = "owner_%s" % name
diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index 7277290..f4f6772 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -205,8 +205,7 @@ def testReplayCache002(t, env):
     FLAGS: sequence all
     CODE: SEQ9b
     """
-    c1 = env.c1.new_client(env.testname(t))
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(env.testname(t))
     res = create_file(sess1, "%s_1" % env.testname(t))
     check(res)
     ops = env.home + [op.savefh(),\
@@ -290,8 +289,7 @@ def testReplayCache007(t, env):
     FLAGS: sequence all
     CODE: SEQ10b
     """
-    c1 = env.c1.new_client(env.testname(t))
-    sess1 = c1.create_session()
+    sess1 = env.c1.new_client_session(env.testname(t))
     res = create_file(sess1, "%s_1" % env.testname(t))
     check(res)
     ops = env.home + [op.savefh(),\
@@ -373,8 +371,8 @@ def testReuseSlotID(t, env):
     CODE: SEQ14
     """
     c = env.c1.new_client(env.testname(t))
-    # CREATE_SESSION
     sess1 = c.create_session()
+    sess1 = env.c1.new_client_session(env.testname(t))
 
     name = "%s_1" % env.testname(t)
     res = create_file(sess1, name)
-- 
1.7.4.1

