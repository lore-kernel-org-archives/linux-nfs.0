Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59040 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727774AbeGVKXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 06:23:35 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 6/6] pynfs: python3 support plan: octal literal 0644 -> 0o644
Date: Sun, 22 Jul 2018 17:27:10 +0800
Message-Id: <20180722092710.17521-6-jiyin@redhat.com>
In-Reply-To: <20180722092710.17521-1-jiyin@redhat.com>
References: <20180722092710.17521-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

s/\<0([0-9]{3})\>/0o\1/g
s/\<0([0-9]{2})\>/0o\1/g

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/nfs4acl.py                   |  8 ++++----
 nfs4.0/nfs4lib.py                   | 10 +++++-----
 nfs4.0/nfs4state.py                 |  4 ++--
 nfs4.0/servertests/st_close.py      |  4 ++--
 nfs4.0/servertests/st_create.py     |  2 +-
 nfs4.0/servertests/st_delegation.py |  2 +-
 nfs4.0/servertests/st_lock.py       |  2 +-
 nfs4.0/servertests/st_locku.py      |  2 +-
 nfs4.0/servertests/st_lookup.py     | 10 +++++-----
 nfs4.0/servertests/st_open.py       | 18 +++++++++---------
 nfs4.0/servertests/st_read.py       |  4 ++--
 nfs4.0/servertests/st_readdir.py    |  8 ++++----
 nfs4.0/servertests/st_reboot.py     |  4 ++--
 nfs4.0/servertests/st_setattr.py    | 18 +++++++++---------
 nfs4.0/servertests/st_write.py      | 16 ++++++++--------
 nfs4.1/client41tests/environment.py |  8 ++++----
 nfs4.1/dataserver.py                |  6 +++---
 nfs4.1/fs.py                        |  2 +-
 nfs4.1/nfs4client.py                |  2 +-
 nfs4.1/server41tests/environment.py | 14 +++++++-------
 nfs4.1/server41tests/st_lookup.py   |  4 ++--
 21 files changed, 74 insertions(+), 74 deletions(-)

diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 91a0316..b7f033e 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -66,9 +66,9 @@ def mode2acl(mode, dir=False):
     """Translate a 3-digit octal mode into a posix compatible acl"""
     if dir: modes = DMODES
     else:   modes = MODES
-    owner = modes[(mode & 0700)//0100] | FLAG_ALL | FLAG_OWN
-    group = modes[(mode & 0070)//010] | FLAG_ALL
-    other = modes[(mode & 0007)] | FLAG_ALL
+    owner = modes[(mode & 0o700)//0o100] | FLAG_ALL | FLAG_OWN
+    group = modes[(mode & 0o070)//0o10] | FLAG_ALL
+    other = modes[(mode & 0o007)] | FLAG_ALL
 
     return [ nfsace4(ALLOWED, 0, owner, "OWNER@"),
              nfsace4(DENIED, 0, negate(owner), "OWNER@"),
@@ -102,7 +102,7 @@ def acl2mode(acl):
     for key in perms:
         if perms[key] is None:
             perm[keys] = 0
-    return perms["OWNER@"]*0100 + perms["GROUP@"]*010 + perms["EVERYONE@"]
+    return perms["OWNER@"]*0o100 + perms["GROUP@"]*0o10 + perms["EVERYONE@"]
         
 def maps_to_posix(acl):
     """Raises ACLError if acl does not map to posix """
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index d255eb7..5c9e853 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -463,7 +463,7 @@ class NFS4Client(rpc.RPCClient):
         return self.compound(ops)
 
     def open(self, owner, name=None, type=OPEN4_NOCREATE,
-             mode=UNCHECKED4, attrs={FATTR4_MODE:0644}, verf=None,
+             mode=UNCHECKED4, attrs={FATTR4_MODE:0o644}, verf=None,
              access=OPEN4_SHARE_ACCESS_READ,
              deny=OPEN4_SHARE_DENY_WRITE,
              claim_type=CLAIM_NULL, deleg_type=None, deleg_cur_info=None):
@@ -568,7 +568,7 @@ class NFS4Client(rpc.RPCClient):
         for e in entries:
             # We separate setattr and remove to avoid an inode locking bug
             ops = [op4.putfh(fh), op4.lookup(e.name)]
-            ops += [op4.setattr(stateid, {FATTR4_MODE:0755})]
+            ops += [op4.setattr(stateid, {FATTR4_MODE:0o755})]
             res = self.compound(ops)
             check_result(res, "Making sure %s is writable" % repr(e.name))
             ops = [op4.putfh(fh), op4.remove(e.name)]
@@ -589,7 +589,7 @@ class NFS4Client(rpc.RPCClient):
         d = self.do_getattrdict([], [FATTR4_LEASE_TIME])
         return d[FATTR4_LEASE_TIME]
 
-    def create_obj(self, path, type=NF4DIR, attrs={FATTR4_MODE:0755},
+    def create_obj(self, path, type=NF4DIR, attrs={FATTR4_MODE:0o755},
                    linkdata="/etc/X11"):
         if __builtins__['type'](path) is str:
             path = self.homedir + [path]
@@ -613,7 +613,7 @@ class NFS4Client(rpc.RPCClient):
         ops += [op4.rename(oldpath[-1], newpath[-1])]
         return self.compound(ops)
 
-    def create_file(self, owner, path=None, attrs={FATTR4_MODE: 0644},
+    def create_file(self, owner, path=None, attrs={FATTR4_MODE: 0o644},
                     access=OPEN4_SHARE_ACCESS_BOTH,
                     deny=OPEN4_SHARE_DENY_WRITE,
                     mode=UNCHECKED4, verifier=None,
@@ -702,7 +702,7 @@ class NFS4Client(rpc.RPCClient):
         return (fhandle, stateid)
         
 
-    def create_confirm(self, owner, path=None, attrs={FATTR4_MODE: 0644},
+    def create_confirm(self, owner, path=None, attrs={FATTR4_MODE: 0o644},
                        access=OPEN4_SHARE_ACCESS_BOTH,
                        deny=OPEN4_SHARE_DENY_WRITE,
                        mode=GUARDED4):
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index 484a284..180e642 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -953,7 +953,7 @@ class VirtualHandle(NFSFileHandle):
 
         if self.fattr4_type == NF4DIR:
             self.dirent = DirList()
-            self.fattr4_mode = 0755
+            self.fattr4_mode = 0o755
         if self.fattr4_type == NF4REG:
             self.file = StringIO.StringIO()
             self.state = NFSFileState()
@@ -987,7 +987,7 @@ class VirtualHandle(NFSFileHandle):
         self.fattr4_maxname = 128 # Are these enforced?
         self.fattr4_maxread = 1000 # Are these enforced?
         self.fattr4_maxwrite = 1000 # Are these enforced?
-        self.fattr4_mode = 0644 # Currently no access restrictions enforced
+        self.fattr4_mode = 0o644 # Currently no access restrictions enforced
         self.fattr4_acl = nfs4acl.mode2acl(self.fattr4_mode,
                                            self.fattr4_type == NF4DIR)
         self.fattr4_numlinks = 1 # Updated? - Yes
diff --git a/nfs4.0/servertests/st_close.py b/nfs4.0/servertests/st_close.py
index 1690fad..89ccbba 100644
--- a/nfs4.0/servertests/st_close.py
+++ b/nfs4.0/servertests/st_close.py
@@ -110,7 +110,7 @@ def testTimedoutClose1(t, env):
     sleeptime = c.getLeaseTime() * 2
     c.init_connection()
     fh, stateid = c.create_confirm(t.code, deny=OPEN4_SHARE_DENY_WRITE,
-                                   attrs={FATTR4_MODE: 0666})
+                                   attrs={FATTR4_MODE: 0o666})
     env.sleep(sleeptime)
     # Conflicting open should force server to drop state
     c2 = env.c2
@@ -132,7 +132,7 @@ def testTimedoutClose2(t, env):
     sleeptime = c.getLeaseTime() * 2
     c.init_connection()
     fh, stateid = c.create_confirm(t.code, deny=OPEN4_SHARE_DENY_WRITE,
-                                   attrs={FATTR4_MODE: 0666})
+                                   attrs={FATTR4_MODE: 0o666})
     res = c.lock_file(t.code, fh, stateid)
     check(res)
     env.sleep(sleeptime)
diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
index ac57aaf..c7256e5 100644
--- a/nfs4.0/servertests/st_create.py
+++ b/nfs4.0/servertests/st_create.py
@@ -8,7 +8,7 @@ def getDefaultAttr(c):
     attr = {}
     #attr[FATTR4_OWNER] = c.security.get_owner()
     #attr[FATTR4_OWNER_GROUP] = c.security.get_group()
-    attr[FATTR4_MODE] = 0755
+    attr[FATTR4_MODE] = 0o755
     return attr
 
 def _test_create(t, env, type, name, **keywords):
diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index 8e0d891..937d95f 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -706,7 +706,7 @@ def testServerChmod(t, env):
     c.init_connection('pynfs%i_%s' % (os.getpid(), t.code), cb_ident=0)
     c.create_confirm(t.code, path=c.homedir + [t.code + '-2'])
     _get_deleg(t, c, c.homedir + [t.code], _recall, NFS4_OK)
-    env.serverhelper("chmod 0777 " + _listToPath(c.homedir + [t.code]))
+    env.serverhelper("chmod 0o777 " + _listToPath(c.homedir + [t.code]))
     _verify_cb_occurred(t, c, count)
 
 def testServerSelfConflict(t, env):
diff --git a/nfs4.0/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
index 1cdbea3..060236a 100644
--- a/nfs4.0/servertests/st_lock.py
+++ b/nfs4.0/servertests/st_lock.py
@@ -529,7 +529,7 @@ def testReadLocks2(t, env):
     file = c1.homedir + [t.code]
     # Client1 creates a file
     fh1, stateid1 = c1.create_confirm('owner1', file,
-                                      attrs={FATTR4_MODE: 0666},
+                                      attrs={FATTR4_MODE: 0o666},
                                       access=OPEN4_SHARE_ACCESS_BOTH,
                                       deny=OPEN4_SHARE_DENY_NONE)
     # Client2 opens the file
diff --git a/nfs4.0/servertests/st_locku.py b/nfs4.0/servertests/st_locku.py
index 3006445..74b464a 100644
--- a/nfs4.0/servertests/st_locku.py
+++ b/nfs4.0/servertests/st_locku.py
@@ -256,7 +256,7 @@ def testTimedoutUnlock(t, env):
     c = env.c1
     sleeptime = c.getLeaseTime() * 3 // 2
     c.init_connection()
-    fh, stateid = c.create_confirm(t.code, attrs={FATTR4_MODE: 0666})
+    fh, stateid = c.create_confirm(t.code, attrs={FATTR4_MODE: 0o666})
     res1 = c.lock_file(t.code, fh, stateid)
     check(res1)
     env.sleep(sleeptime)
diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
index cd1b93c..a57d4cb 100644
--- a/nfs4.0/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -206,7 +206,7 @@ def testNonAccessable(t, env):
     DEPEND: MKDIR
     CODE: LOOK6
     """
-    # Create dir/foo, and set mode of dir to 000
+    # Create dir/foo, and set mode of dir to 0o000
     c = env.c1
     dir = c.homedir + [t.code]
     res = c.create_obj(dir)
@@ -220,9 +220,9 @@ def testNonAccessable(t, env):
     check(res)
     res = c.compound(c.use_obj(dir + ['foo']))
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP object in a dir with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP object in a dir with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=000")
+	    check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=0o000")
 
 def testInvalidUtf8(t, env):
     """LOOKUP with bad UTF-8 name strings should return NFS4ERR_INVAL
@@ -283,9 +283,9 @@ def testUnaccessibleDir(t, env):
     check(res, msg="Setting mode=0 on directory %s" % t.code)
     res = c.compound(c.use_obj(path + ['hidden']))
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP off of dir with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "LOOKUP off of dir with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "LOOKUP off of dir with mode=000")
+	    check(res, NFS4ERR_ACCESS, "LOOKUP off of dir with mode=0o000")
 
 def testBadOpaque(t, env):
     """LOOKUP with a path component that has an incorrect array length
diff --git a/nfs4.0/servertests/st_open.py b/nfs4.0/servertests/st_open.py
index 437fb67..12db5df 100644
--- a/nfs4.0/servertests/st_open.py
+++ b/nfs4.0/servertests/st_open.py
@@ -25,7 +25,7 @@ def testCreateUncheckedFile(t, env):
     c.init_connection()
 
     # Create the file
-    orig_attrs = { FATTR4_MODE: 0644, FATTR4_SIZE: 32 }
+    orig_attrs = { FATTR4_MODE: 0o644, FATTR4_SIZE: 32 }
     res = c.create_file(t.code, attrs=orig_attrs,  deny=OPEN4_SHARE_DENY_NONE)
     check(res, msg="Trying to create file %s" % t.code)
     fh, stateid = c.confirm(t.code, res)
@@ -33,7 +33,7 @@ def testCreateUncheckedFile(t, env):
     checkdict(orig_attrs, rcvd_attrs, get_bitnumattr_dict(),
               "Checking attrs on creation")
     # Create the file again...it should ignore attrs
-    attrs = { FATTR4_MODE: 0600, FATTR4_SIZE: 16 }
+    attrs = { FATTR4_MODE: 0o600, FATTR4_SIZE: 16 }
     res = c.create_file(t.code, attrs=attrs,  deny=OPEN4_SHARE_DENY_NONE)
     check(res, msg="Trying to recreate file %s" % t.code)
     fh, stateid = c.confirm(t.code, res)
@@ -41,12 +41,12 @@ def testCreateUncheckedFile(t, env):
     checkdict(orig_attrs, rcvd_attrs, get_bitnumattr_dict(),
               "Attrs on recreate should be ignored")
     # Create the file again, should truncate size to 0 and ignore other attrs
-    attrs = { FATTR4_MODE: 0600, FATTR4_SIZE: 0 }
+    attrs = { FATTR4_MODE: 0o600, FATTR4_SIZE: 0 }
     res = c.create_file(t.code, attrs=attrs,  deny=OPEN4_SHARE_DENY_NONE)
     check(res, msg="Trying to truncate file %s" % t.code)
     fh, stateid = c.confirm(t.code, res)
     rcvd_attrs = c.do_getattrdict(fh, orig_attrs.keys())
-    expect = { FATTR4_MODE: 0644, FATTR4_SIZE: 0 }
+    expect = { FATTR4_MODE: 0o644, FATTR4_SIZE: 0 }
     checkdict(expect, rcvd_attrs, get_bitnumattr_dict(),
               "Attrs on recreate should be ignored, except for size")
         
@@ -327,13 +327,13 @@ def testModeChange(t, env):
     check(res)
     ops = c.use_obj(fh) + [c.setattr({FATTR4_MODE:0})]
     res = c.compound(ops)
-    check(res, msg="Setting mode of file %s to 000" % t.code)
+    check(res, msg="Setting mode of file %s to 0o000" % t.code)
     res = c.open_file(t.code, access=OPEN4_SHARE_ACCESS_BOTH,
                       deny=OPEN4_SHARE_DENY_NONE)
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "Opening file %s with mode=000" % t.code)
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "Opening file %s with mode=0o000" % t.code)
     else:
-	    check(res, NFS4ERR_ACCESS, "Opening file %s with mode=000" % t.code)
+	    check(res, NFS4ERR_ACCESS, "Opening file %s with mode=0o000" % t.code)
 
 def testShareConflict1(t, env):
     """OPEN conflicting with previous share
@@ -361,13 +361,13 @@ def testFailedOpen(t, env):
     c1.init_connection()
     # Client 1: create a file and deny others access
     fh, stateid = c1.create_confirm(t.code)
-    ops = c1.use_obj(fh) + [c1.setattr({FATTR4_MODE: 0700})]
+    ops = c1.use_obj(fh) + [c1.setattr({FATTR4_MODE: 0o700})]
     check(c1.compound(ops))
     # Client 2: try to open the file
     c2 = env.c2
     c2.init_connection()
     res = c2.open_file(t.code)
-    check(res, NFS4ERR_ACCESS, "Opening file with mode 0700 as 'other'")
+    check(res, NFS4ERR_ACCESS, "Opening file with mode 0o700 as 'other'")
     # Client 1: try to use fh, stateid
     res1 = c1.lock_file(t.code, fh, stateid)
     check(res1, msg="Locking file after another client had a failed open")
diff --git a/nfs4.0/servertests/st_read.py b/nfs4.0/servertests/st_read.py
index 9b2203b..15f8795 100644
--- a/nfs4.0/servertests/st_read.py
+++ b/nfs4.0/servertests/st_read.py
@@ -74,7 +74,7 @@ def testLargeCount(t, env):
     c = env.c1
     c.init_connection()
     fh, stateid = c.create_confirm(t.code, attrs={FATTR4_SIZE: 10000000,
-                                                  FATTR4_MODE: 0644})
+                                                  FATTR4_MODE: 0o644})
     res = c.read_file(fh, 0, 9000000, stateid)
     check(res, msg="Reading file %s" % t.code)
     _compare(t, res, '\x00'*9000000, False)
@@ -234,7 +234,7 @@ def testStolenStateid(t, env):
     """
     c = env.c1
     c.init_connection()
-    res = c.create_file(t.code, attrs={FATTR4_MODE: 0600})
+    res = c.create_file(t.code, attrs={FATTR4_MODE: 0o600})
     fh, stateid = c.confirm(t.code, res)
     security=c.security
     c.security=rpc.SecAuthSys(0, "whatever", 3912, 2422, [])
diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
index 5a70145..fb484b6 100644
--- a/nfs4.0/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -232,9 +232,9 @@ def testUnaccessibleDir(t, env):
     ops = c.use_obj(path) + [c.readdir()]
     res = c.compound(ops)
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=000")
+	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0o000")
    
 def testUnaccessibleDirAttrs(t, env):
     """READDIR with (cfh) in unaccessible directory requesting attrs
@@ -253,9 +253,9 @@ def testUnaccessibleDirAttrs(t, env):
           [c.readdir(attr_request=[FATTR4_RDATTR_ERROR, FATTR4_TYPE])]
     res = c.compound(ops)
     if env.opts.uid == 0:
-	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=000")
+	    check(res, [NFS4_OK, NFS4ERR_ACCESS], "READDIR of directory with mode=0o000")
     else:
-	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=000")
+	    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0o000")
    
 ###########################################
 
diff --git a/nfs4.0/servertests/st_reboot.py b/nfs4.0/servertests/st_reboot.py
index 33c3a4a..16cb008 100644
--- a/nfs4.0/servertests/st_reboot.py
+++ b/nfs4.0/servertests/st_reboot.py
@@ -116,7 +116,7 @@ def testEdge1(t, env):
     c1 = env.c1
     c1.init_connection()
     # Client 1: lock file
-    fh1, stateid1 = c1.create_confirm(t.code, attrs={FATTR4_MODE:0666},
+    fh1, stateid1 = c1.create_confirm(t.code, attrs={FATTR4_MODE:0o666},
                                       access=OPEN4_SHARE_ACCESS_BOTH,
                                       deny=OPEN4_SHARE_DENY_NONE)
     res1 = c1.lock_file(t.code, fh1, stateid1)
@@ -161,7 +161,7 @@ def testEdge2(t, env):
     c1 = env.c1
     c1.init_connection()
     # Client 1: lock file
-    fh1, stateid1 = c1.create_confirm(t.code, attrs={FATTR4_MODE:0666},
+    fh1, stateid1 = c1.create_confirm(t.code, attrs={FATTR4_MODE:0o666},
                                       access=OPEN4_SHARE_ACCESS_BOTH,
                                       deny=OPEN4_SHARE_DENY_NONE)
     res1 = c1.lock_file(t.code, fh1, stateid1)
diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index 4a80f65..aa7123b 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -7,7 +7,7 @@ op = nfs_ops.NFS4ops()
 
 def _set_mode(t, c, file, stateid=None, msg=" using stateid=0",
               warnlist=[]):
-    mode = 0740
+    mode = 0o740
     dict = {FATTR4_MODE: mode}
     ops = c.use_obj(file) + [c.setattr(dict, stateid)]
     res = c.compound(ops)
@@ -399,7 +399,7 @@ def testInvalidAttr1(t, env):
     path = c.homedir + [t.code]
     res = c.create_obj(path)
     check(res)
-    badattr = dict2fattr({FATTR4_MODE: 0644})
+    badattr = dict2fattr({FATTR4_MODE: 0o644})
     badattr.attr_vals = ''
     res = c.compound(c.use_obj(path) + [op.setattr(env.stateid0, badattr)])
     check(res, NFS4ERR_BADXDR, "SETATTR(FATTR4_MODE) with no data")
@@ -418,7 +418,7 @@ def testInvalidAttr2(t, env):
     path = c.homedir + [t.code]
     res = c.create_obj(path)
     check(res)
-    badattr = dict2fattr({FATTR4_MODE: 0644})
+    badattr = dict2fattr({FATTR4_MODE: 0o644})
     badattr.attr_vals += 'Garbage data'
     res = c.compound(c.use_obj(path) + [op.setattr(env.stateid0, badattr)])
     check(res, NFS4ERR_BADXDR,
@@ -674,7 +674,7 @@ def testInodeLocking(t, env):
     
     # In a single compound statement, setattr on dir and then
     # do a state operation on a file in dir (like write or remove)
-    ops = c.use_obj(basedir) + [c.setattr({FATTR4_MODE:0754})]
+    ops = c.use_obj(basedir) + [c.setattr({FATTR4_MODE:0o754})]
     ops += [op.lookup('file'), op.write(stateid, 0, 0, 'blahblah')]
     res = c.compound(ops)
     check(res, msg="SETATTR on dir and state operation on file in dir")
@@ -690,7 +690,7 @@ def testChange(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     change = c.do_getattr(FATTR4_CHANGE, fh)
-    ops = c.use_obj(fh) + [c.setattr({FATTR4_MODE: 0740})]
+    ops = c.use_obj(fh) + [c.setattr({FATTR4_MODE: 0o740})]
     res = c.compound(ops)
     check(res)
     change2 = c.do_getattr(FATTR4_CHANGE, fh)
@@ -708,10 +708,10 @@ def testChangeGranularity(t, env):
     c.init_connection()
     fh, stateid = c.create_confirm(t.code)
     ops = c.use_obj(fh) + [c.getattr([FATTR4_CHANGE])] \
-        + [c.setattr({FATTR4_MODE: 0740})] + [c.getattr([FATTR4_CHANGE])] \
-        + [c.setattr({FATTR4_MODE: 0741})] + [c.getattr([FATTR4_CHANGE])] \
-        + [c.setattr({FATTR4_MODE: 0742})] + [c.getattr([FATTR4_CHANGE])] \
-        + [c.setattr({FATTR4_MODE: 0743})] + [c.getattr([FATTR4_CHANGE])]
+        + [c.setattr({FATTR4_MODE: 0o740})] + [c.getattr([FATTR4_CHANGE])] \
+        + [c.setattr({FATTR4_MODE: 0o741})] + [c.getattr([FATTR4_CHANGE])] \
+        + [c.setattr({FATTR4_MODE: 0o742})] + [c.getattr([FATTR4_CHANGE])] \
+        + [c.setattr({FATTR4_MODE: 0o743})] + [c.getattr([FATTR4_CHANGE])]
     res = c.compound(ops)
     check(res)
     chattr1 = res.resarray[1].obj_attributes
diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
index 2f73cbb..4777e1b 100644
--- a/nfs4.0/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -38,7 +38,7 @@ def testSimpleWrite(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs,
                                    deny=OPEN4_SHARE_DENY_NONE)
     res = c.write_file(fh, _text, how=UNSTABLE4)
@@ -55,7 +55,7 @@ def testSimpleWrite2(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs,
                                    deny=OPEN4_SHARE_DENY_NONE)
     res = c.write_file(fh, _text, 30)
@@ -72,7 +72,7 @@ def testStateidOne(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs,
                                    deny=OPEN4_SHARE_DENY_NONE)
     res = c.write_file(fh, _text, 5, env.stateid1, DATA_SYNC4)
@@ -91,7 +91,7 @@ def testWithOpen(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs)
     res = c.write_file(fh, _text, 50, stateid, FILE_SYNC4)
     check(res, msg="WRITE with openstateid and FILE_SYNC4")
@@ -109,7 +109,7 @@ def testNoData(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs)
     time_prior = c.do_getattr(FATTR4_TIME_MODIFY, fh)
     env.sleep(1)
@@ -281,7 +281,7 @@ def testOpenMode(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs,
                                    access=OPEN4_SHARE_ACCESS_READ)
     res = c.write_file(fh, _text, 0, stateid)
@@ -298,7 +298,7 @@ def testShareDeny(t, env):
     """
     c = env.c1
     c.init_connection()
-    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0644}
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 0o644}
     fh, stateid = c.create_confirm(t.code, attrs=attrs,
                                    deny=OPEN4_SHARE_DENY_WRITE)
     res = c.write_file(fh, _text)
@@ -520,7 +520,7 @@ def testStolenStateid(t, env):
     """
     c = env.c1
     c.init_connection()
-    res = c.create_file(t.code, attrs={FATTR4_MODE: 0600})
+    res = c.create_file(t.code, attrs={FATTR4_MODE: 0o600})
     fh, stateid = c.confirm(t.code, res)
     security=c.security
     c.security=rpc.SecAuthSys(0, "whatever", 3912, 2422, [])
diff --git a/nfs4.1/client41tests/environment.py b/nfs4.1/client41tests/environment.py
index 7c7bb0c..933264c 100644
--- a/nfs4.1/client41tests/environment.py
+++ b/nfs4.1/client41tests/environment.py
@@ -362,7 +362,7 @@ def clean_dir(sess, path):
     for e in entries:
         # We separate setattr and remove to avoid an inode locking bug
         ops = use_obj(path + [e.name])
-        ops += [op.setattr(stateid, {FATTR4_MODE:0755})]
+        ops += [op.setattr(stateid, {FATTR4_MODE:0o755})]
         res = sess.compound(ops)
         check(res, msg="Setting mode on %s" % repr(e.name))
         ops = use_obj(path)
@@ -405,7 +405,7 @@ def use_obj(file):
     else:
         return [op.putrootfh()] + [op.lookup(comp) for comp in file]
 
-def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0755}):
+def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0o755}):
     """Return ops needed to create given non-file object"""
     # Ensure using createtype4
     if not hasattr(kind, "type"):
@@ -413,7 +413,7 @@ def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0755}):
     ops = use_obj(path[:-1]) + [op.create(kind, path[-1], attrs)]
     return sess.compound(ops)
 
-def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                 access=OPEN4_SHARE_ACCESS_BOTH,
                 deny=OPEN4_SHARE_DENY_NONE,
                 mode=GUARDED4, verifier=None, want_deleg=False):
@@ -434,7 +434,7 @@ def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
                       open_claim4(CLAIM_NULL, name))
     return sess.compound(use_obj(dir) + [open_op, op.getfh()])
 
-def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                    access=OPEN4_SHARE_ACCESS_BOTH,
                    deny=OPEN4_SHARE_DENY_NONE,
                    mode=GUARDED4):
diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
index 80179f8..af0e35a 100644
--- a/nfs4.1/dataserver.py
+++ b/nfs4.1/dataserver.py
@@ -130,7 +130,7 @@ class DataServer41(DataServer):
         self.sess.compound([op4.reclaim_complete(const4.FALSE)])
 
     def make_root(self):
-        attrs = {const4.FATTR4_MODE:0777}
+        attrs = {const4.FATTR4_MODE:0o777}
         existing_path = []
         kind = type4.createtype4(const4.NF4DIR)
         for comp in self.path:
@@ -153,7 +153,7 @@ class DataServer41(DataServer):
         seqid=0
         access = const4.OPEN4_SHARE_ACCESS_BOTH
         deny = const4.OPEN4_SHARE_DENY_NONE
-        attrs = {const4.FATTR4_MODE: 0777}
+        attrs = {const4.FATTR4_MODE: 0o777}
         owner = "mds"
         mode = const4.GUARDED4
         verifier = self.sess.c.verifier
@@ -257,7 +257,7 @@ class DataServer3(DataServer):
     def open_file(self, mds_fh):
         name = self.fh_to_name(mds_fh)
         where = type3.diropargs3(self.rootfh, name)
-        attr = type3.sattr3(mode=type3.set_mode3(True, 0777),
+        attr = type3.sattr3(mode=type3.set_mode3(True, 0o777),
                             uid=type3.set_uid3(True, 0),
                             gid=type3.set_gid3(True, 0),
                             size=type3.set_size3(False),
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index b0b06d5..e2c7eca 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -25,7 +25,7 @@ class MetaData(object):
         self.refcnt = 0
         self.createverf = ""
         self.owner = ""
-        self.mode = 0777
+        self.mode = 0o777
         self.time_access = self.time_modify = self.time_create = nfs4lib.get_nfstime()
         if 1:
             self.parent = 0
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 135981d..5288942 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -560,7 +560,7 @@ class SessionRecord(object):
         return res
 
 ##     def open(self, owner, name=None, type=OPEN4_NOCREATE,
-##              mode=UNCHECKED4, attrs={FATTR4_MODE:0644}, verf=None,
+##              mode=UNCHECKED4, attrs={FATTR4_MODE:0o644}, verf=None,
 ##              access=OPEN4_SHARE_ACCESS_READ,
 ##              deny=OPEN4_SHARE_DENY_WRITE,
 ##              claim_type=CLAIM_NULL, deleg_type=None, deleg_cur_info=None):
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 823dfe3..3020371 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -418,7 +418,7 @@ def clean_dir(sess, path):
     for e in entries:
         # We separate setattr and remove to avoid an inode locking bug
         ops = use_obj(path + [e.name])
-        ops += [op.setattr(stateid, {FATTR4_MODE:0755})]
+        ops += [op.setattr(stateid, {FATTR4_MODE:0o755})]
         res = sess.compound(ops)
         check(res, msg="Setting mode on %s" % repr(e.name))
         ops = use_obj(path)
@@ -460,7 +460,7 @@ def do_getattrdict(sess, file, attrlist):
     check(res)
     return res.resarray[-1].obj_attributes
 
-def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0755}):
+def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0o755}):
     """Return ops needed to create given non-file object"""
     # Ensure using createtype4
     if not hasattr(kind, "type"):
@@ -468,7 +468,7 @@ def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0755}):
     ops = use_obj(path[:-1]) + [op.create(kind, path[-1], attrs)]
     return sess.compound(ops)
 
-def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                      access=OPEN4_SHARE_ACCESS_BOTH,
                      deny=OPEN4_SHARE_DENY_NONE,
 		     mode=GUARDED4, verifier=None,
@@ -483,7 +483,7 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
 
     return sess.compound(open_op)
 
-def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                      access=OPEN4_SHARE_ACCESS_BOTH,
                      deny=OPEN4_SHARE_DENY_NONE,
 		     mode=GUARDED4, verifier=None,
@@ -526,7 +526,7 @@ def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
 
     return fh_op + [open_op, op.getfh()]
 
-def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                 access=OPEN4_SHARE_ACCESS_BOTH,
                 deny=OPEN4_SHARE_DENY_NONE,
                 mode=GUARDED4, verifier=None, want_deleg=False,
@@ -559,7 +559,7 @@ def open_file(sess, owner, path=None,
                             verifier, claim_type, want_deleg, deleg_type,
                             open_create, seqid, clientid)
 
-def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                    access=OPEN4_SHARE_ACCESS_BOTH,
                    deny=OPEN4_SHARE_DENY_NONE,
                    mode=GUARDED4):
@@ -572,7 +572,7 @@ def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
     fh = res.resarray[-1].object
     return fh, res.resarray[-2].stateid
 
-def create_close(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
+def create_close(sess, owner, path=None, attrs={FATTR4_MODE: 0o644},
                    access=OPEN4_SHARE_ACCESS_BOTH,
                    deny=OPEN4_SHARE_DENY_NONE,
                    mode=GUARDED4):
diff --git a/nfs4.1/server41tests/st_lookup.py b/nfs4.1/server41tests/st_lookup.py
index 9f50004..3899425 100644
--- a/nfs4.1/server41tests/st_lookup.py
+++ b/nfs4.1/server41tests/st_lookup.py
@@ -270,7 +270,7 @@ if 0:
         DEPEND: MKDIR
         CODE: LOOK6
         """
-        # Create dir/foo, and set mode of dir to 000
+        # Create dir/foo, and set mode of dir to 0o000
         c = env.c1
         dir = c.homedir + [t.code]
         res = c.create_obj(dir)
@@ -283,7 +283,7 @@ if 0:
         res = c.compound(c.use_obj(dir))
         check(res)
         res = c.compound(c.use_obj(dir + ['foo']))
-        check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=000")
+        check(res, NFS4ERR_ACCESS, "LOOKUP object in a dir with mode=0o000")
 
     def testInvalidUtf8(t, env):
         """LOOKUP with bad UTF-8 name strings should return NFS4ERR_INVAL
-- 
2.17.1

