Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f49.google.com ([209.85.160.49]:35410 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103AbaDXK7R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 06:59:17 -0400
Received: by mail-pb0-f49.google.com with SMTP id rr13so1808979pbb.8
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 03:59:16 -0700 (PDT)
Message-ID: <5358EE7C.3030905@gmail.com>
Date: Thu, 24 Apr 2014 18:59:08 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS4.0: Cases for SGID/UID status after writing
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/environment.py | 10 +++++
 nfs4.0/servertests/st_write.py    | 90 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 99 insertions(+), 1 deletion(-)

diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 993320d..355a928 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -113,6 +113,7 @@ class Environment(testmod.Environment):
         self.longname = "a"*512
         self.uid = 0
         self.gid = 0
+        self.nclnt = 2
         self.opts = opts
         self.filedata = "This is the file test data."
         self.linkdata = "/etc/X11"
@@ -388,3 +389,12 @@ def compareTimes(time1, time2):
         if time1.nseconds > time2.nseconds:
             return 1
         return 0
+
+def clientWithSys(env, uid, gid):
+    opts = env.opts
+    env.nclnt += 1
+    authsys = rpc.SecAuthSys(0, opts.machinename, uid, gid, [])
+    c = NFS4Client('client%d_pid%i' % (env.nclnt, os.getpid()),
+                    opts.server, opts.port, opts.path,
+                    sec_list=[authsys], opts=opts)
+    return c
diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
index 1a4deaf..d47704e 100644
--- a/nfs4.0/servertests/st_write.py
+++ b/nfs4.0/servertests/st_write.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 from nfs4_type import *
-from environment import check, checklist, compareTimes, makeBadID, makeBadIDganesha, makeStaleId
+from environment import check, checklist, compareTimes, makeBadID, makeBadIDganesha, makeStaleId, clientWithSys
 import struct
 
 _text = 'write data' # len=10
@@ -384,3 +384,91 @@ def testSizes(t, env):
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
+def doCheckSGUID(t, env, fsguid = 0, wsguid = 0, cmode = 06777):
+    c = env.c1
+    path = c.homedir + [t.code]
+    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
+    check(res)
+
+    c1 = clientWithSys(env, fsguid, fsguid)
+    c1.init_connection()
+
+    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 06777}
+    path += [t.code]
+    fh, stateid = c1.create_confirm(t.code, path, attrs=attrs,
+                                   deny=OPEN4_SHARE_DENY_NONE)
+    doCheckMode(t, c1, fh, 06777)
+
+    c2 = clientWithSys(env, wsguid, wsguid)
+    c2.init_connection()
+
+    ops = c2.use_obj(fh)
+    ops += [c2.write_op(stateid4(0, ''), 0, UNSTABLE4, 'for test')]
+    res = c2.compound(ops)
+    check(res)
+
+    doCheckMode(t, c2, fh, cmode)
+
+def testSGUIDRootRoot(t, env):
+    """ root writing data to file (blongs to root)
+        will not clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16a
+    """
+    doCheckSGUID(t, env)
+
+def testSGUIDRootNoRoot(t, env):
+    """ root writing data to file (blongs to no-root)
+        will not clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16b
+    """
+    doCheckSGUID(t, env, 9999)
+
+def testSGUIDNoRootSelf(t, env):
+    """ no-root writing data to file (blongs to self)
+        will clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16c
+    """
+    doCheckSGUID(t, env, 9999, 9999, 0777)
+
+def testSGUIDNoRootRoot(t, env):
+    """ no-root writing data to file (blongs to root)
+        will clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16d
+    """
+    doCheckSGUID(t, env, 0, 9999, 0777)
+
+def testSGUIDNoRootNoRoot(t, env):
+    """ no-root writing data to file (blongs to no-root)
+        will clear the SUID/SGID mode
+
+    FLAGS: wrtie file all
+    DEPEND: MODE MKFILE
+    CODE: WRT16e
+    """
+    doCheckSGUID(t, env, 6666, 9999, 0777)
-- 
1.9.0

