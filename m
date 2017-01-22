Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49342 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdAVQvX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2017 11:51:23 -0500
From: Christoph Hellwig <hch@lst.de>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [pynfs PATCH] check that a mixed size / uid setattr works
Date: Sun, 22 Jan 2017 17:51:18 +0100
Message-Id: <1485103878-15160-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On some Linux file systems this currently fails and/or trips an ASSERT.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 nfs4.0/servertests/st_setattr.py | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index b6a398b..accd807 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -27,6 +27,23 @@ def _set_size(t, c, file, stateid=None, msg=" using stateid=0"):
     check(res, msg="Changing size from %i to 0" % newsize)
     check_res(t, c, res, file, dict)
 
+#
+# Mix size and non-size attributes in a single SETATTR.  Some Linux file
+# systems aren't happy with this mix, and a server passing this on 1:1
+# will trigger warnings or incorrect results.
+#
+def _set_mixed(t, c, file, stateid=None, msg=" using stateid=0"):
+    startsize = c.do_getattr(FATTR4_SIZE, file)
+    newsize = startsize + 10
+    owner = "65534" # nobody
+
+    dict = {FATTR4_SIZE: newsize, FATTR4_OWNER: owner}
+    ops = c.use_obj(file) + [c.setattr(dict, stateid)]
+    res = c.compound(ops)
+    check(res, msg="Changing size from %i to %i and owner to %s%s" %
+          (startsize, newsize, owner, msg), warnlist=[NFS4ERR_BAD_STATEID])
+    check_res(t, c, res, file, dict)
+
 def _try_readonly(t, env, path):
     c = env.c1
     baseops = c.use_obj(path)
@@ -701,3 +718,15 @@ def testChangeGranularity(t, env):
     chattr4 = res.resarray[7].obj_attributes
     if chattr1 == chattr2 or chattr2 == chattr3 or chattr3 == chattr4:
         t.fail("consecutive SETATTR(mode)'s don't all change change attribute")
+
+def testMixed(t, env):
+    """SETATTR(FATTR4_SIZE + FATTR4_OWNER) on file with stateid = 0
+
+    FLAGS: setattr file all
+    DEPEND: MKFILE
+    CODE: SATT16
+    """
+    c = env.c1
+    c.init_connection()
+    fh, stateid = c.create_confirm(t.code, deny=OPEN4_SHARE_DENY_NONE)
+    _set_mixed(t, c, fh)
-- 
2.1.4

