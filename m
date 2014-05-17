Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:55773 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaEQCUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2014 22:20:47 -0400
Received: by mail-oa0-f46.google.com with SMTP id i4so3915336oah.33
        for <linux-nfs@vger.kernel.org>; Fri, 16 May 2014 19:20:46 -0700 (PDT)
Message-ID: <5376C773.5090400@gmail.com>
Date: Sat, 17 May 2014 10:20:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 2/3 v2] NFS4.0: Cases for SGID/SUID status after writing
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adds Environment.c3.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/environment.py |  4 ++
 nfs4.0/servertests/st_write.py    | 84 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+)

diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 993320d..4b6e725 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -104,12 +104,16 @@ class Environment(testmod.Environment):
         sec1, sec2 = self._get_security(opts)
 #        authsys1 = rpc.SecAuthSys(0, opts.machinename, opts.uid, opts.gid, [])
         authsys2 = rpc.SecAuthSys(0, opts.machinename, opts.uid+1, opts.gid+1, [])
+        authsys3 = rpc.SecAuthSys(0, opts.machinename, opts.uid+2, opts.gid+2, [])
         self.c1 = NFS4Client('client1_pid%i' % os.getpid(),
                              opts.server, opts.port, opts.path,
                              sec_list=[sec1], opts=opts)
         self.c2 = NFS4Client('client2_pid%i' % os.getpid(),
                              opts.server, opts.port, opts.path,
                              sec_list=[authsys2], opts=opts)
+        self.c3 = NFS4Client('client3_pid%i' % os.getpid(),
+                             opts.server, opts.port, opts.path,
+                             sec_list=[authsys3], opts=opts)
         self.longname = "a"*512
         self.uid = 0
         self.gid = 0
diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
index 1a4deaf..4e55135 100644
--- a/nfs4.0/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -384,3 +384,87 @@ def testSizes(t, env):
         ops += [c.getattr([FATTR4_SIZE]), c.getattr([FATTR4_SIZE])]
         res = c.compound(ops)
         check(res, msg="length %d WRITE" % i)
+
+def doCheckMode(t, c, fh, mode):
+    ops = c.use_obj(fh)
+    ops += [c.getattr([FATTR4_MODE, FATTR4_OWNER, FATTR4_OWNER_GROUP])]
+    res = c.compound(ops)
+    check(res)
+
+    attrs = res.resarray[-1].obj_attributes
+    if FATTR4_MODE not in attrs.keys():
+         t.fail("Attributes not contains FATTR4_MODE")
+    resmode = attrs[FATTR4_MODE]
+    if resmode != mode:
+         t.fail("Mode is %o, not expected %o" % (resmode, mode))
+
+def doCheckSGUID(t, env, cc, cw, cmode = 06777):
+    c = env.c1
+    path = c.homedir + [t.code]
+    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
+    check(res)
+
+    cc.init_connection()
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 06777}
+    path += [t.code]
+    fh, stateid = cc.create_confirm(t.code, path, attrs=attrs,
+                                   deny=OPEN4_SHARE_DENY_NONE)
+    doCheckMode(t, cc, fh, 06777)
+
+    cw.init_connection()
+    ops = cw.use_obj(fh)
+    ops += [cw.write_op(stateid4(0, ''), 0, UNSTABLE4, 'for test')]
+    res = cw.compound(ops)
+    check(res)
+
+    doCheckMode(t, cw, fh, cmode)
+
+def testSGUIDRootRoot(t, env):
+    """ root writing data to file (blongs to root)
+        will not clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16a
+    """
+    doCheckSGUID(t, env, env.c1, env.c1)
+
+def testSGUIDRootNoRoot(t, env):
+    """ root writing data to file (blongs to no-root)
+        will not clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16b
+    """
+    doCheckSGUID(t, env, env.c2, env.c1)
+
+def testSGUIDNoRootSelf(t, env):
+    """ no-root writing data to file (blongs to self)
+        will clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16c
+    """
+    doCheckSGUID(t, env, env.c2, env.c2, 0777)
+
+def testSGUIDNoRootRoot(t, env):
+    """ no-root writing data to file (blongs to root)
+        will clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16d
+    """
+    doCheckSGUID(t, env, env.c1, env.c2, 0777)
+
+def testSGUIDNoRootNoRoot(t, env):
+    """ no-root writing data to file (blongs to no-root)
+        will clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16e
+    """
+    doCheckSGUID(t, env, env.c2, env.c3, 0777)
-- 
1.9.0

