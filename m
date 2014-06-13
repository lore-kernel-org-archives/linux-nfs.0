Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:57131 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaFMKw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2014 06:52:28 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so2008487pad.6
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2014 03:52:27 -0700 (PDT)
Message-ID: <539AD7DD.5060108@gmail.com>
Date: Fri, 13 Jun 2014 18:52:13 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 3/3 v3] ACL: Add some test cases for nfsv4 acl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3, modify for exist st_acl.py

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/st_acl.py | 337 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 326 insertions(+), 11 deletions(-)

diff --git a/nfs4.0/servertests/st_acl.py b/nfs4.0/servertests/st_acl.py
index 9636357..5c7146a 100644
--- a/nfs4.0/servertests/st_acl.py
+++ b/nfs4.0/servertests/st_acl.py
@@ -1,6 +1,39 @@
 from nfs4_const import *
 from environment import check, checklist
+from nfs4lib import get_attr_name
 from nfs4_type import nfsace4
+from nfs4acl import *
+
+MASK_ALL_FILE = ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | \
+                ACE4_READ_NAMED_ATTRS | ACE4_WRITE_NAMED_ATTRS | \
+                ACE4_EXECUTE | ACE4_READ_ATTRIBUTES | ACE4_WRITE_ATTRIBUTES | \
+                ACE4_DELETE | ACE4_READ_ACL | ACE4_WRITE_ACL | \
+                ACE4_WRITE_OWNER | ACE4_SYNCHRONIZE
+MASK_ALL_DIR = ACE4_LIST_DIRECTORY | ACE4_ADD_FILE | ACE4_ADD_SUBDIRECTORY | \
+               ACE4_READ_NAMED_ATTRS | ACE4_WRITE_NAMED_ATTRS | \
+               ACE4_EXECUTE | ACE4_DELETE_CHILD | ACE4_READ_ATTRIBUTES | \
+               ACE4_WRITE_ATTRIBUTES | ACE4_READ_ACL | ACE4_WRITE_ACL | \
+               ACE4_WRITE_OWNER | ACE4_SYNCHRONIZE
+
+def doTestGetACL(t, env, path):
+    c = env.c1
+    ops = c.use_obj(path) + [c.getattr([FATTR4_ACL])]
+    res = c.compound(ops)
+    check(res)
+
+    attrs = res.resarray[-1].obj_attributes
+    if FATTR4_ACL not in attrs.keys():
+        t.fail("Attributes not contains FATTR4_ACL")
+#    print printableacl(attrs[FATTR4_ACL])
+
+def testCheckSupportedACL(t, env):
+    """ Check whether attributes contains FATTR4_ACLSUPPORT
+
+    FLAGS: getattr all
+    CODE: ACLSUPP
+    """
+    if not FATTR4_ACLSUPPORT & env.c1.supportedAttrs():
+        t.fail_support("Server does not support FATTR4_ACL")
 
 # assuming server will accept any small positive integer as an owner name:
 
@@ -8,8 +41,8 @@ def testACL(t, env):
     """SETATTR/GETATTR of a simple ACL
 
     FLAGS: acl all
-    DEPEND: LOOKFILE
-    CODE: ACL5
+    DEPEND: LOOKFILE ACLSUPP
+    CODE: ACL1
     """
     c = env.c1
     c.init_connection()
@@ -19,17 +52,301 @@ def testACL(t, env):
     ops += [c.setattr({FATTR4_ACL: acl})]
     res = c.compound(ops)
     check(res)
-    ops = c.use_obj(fh)
-    ops += [c.getattr([FATTR4_ACL])]
-    res = c.compound(ops)
+
+    doTestGetACL(t, env, fh)
+
+def testGetACLFile(t, env):
+    """ Get ACL of reg file
+
+    FLAGS: acl getattr file all
+    DEPEND: ACLSUPP LOOKFILE
+    CODE: ACL1r
+    """
+    doTestGetACL(t, env, env.opts.usefile)
+
+def testGetACLDir(t, env):
+    """ Get ACL of dir file
+
+    FLAGS: acl getattr dir all
+    DEPEND: ACLSUPP LOOKDIR
+    CODE: ACL1d
+    """
+    doTestGetACL(t, env, env.opts.usedir)
+
+def testGetACLFifo(t, env):
+    """ Get ACL of fifo file
+
+    FLAGS: acl getattr fifo all
+    DEPEND: ACLSUPP LOOKFIFO
+    CODE: ACL1f
+    """
+    doTestGetACL(t, env, env.opts.usefifo)
+
+def testGetACLLink(t, env):
+    """ Get ACL of symlink file
+
+    FLAGS: acl getattr symlink all
+    DEPEND: ACLSUPP LOOKLINK
+    CODE: ACL1a
+    """
+    doTestGetACL(t, env, env.opts.uselink)
+
+def testGetACLSocket(t, env):
+    """ Get ACL of socket file
+
+    FLAGS: acl getattr socket all
+    DEPEND: ACLSUPP LOOKSOCK
+    CODE: ACL1s
+    """
+    doTestGetACL(t, env, env.opts.usesocket)
+
+def testGetACLChar(t, env):
+    """ Get ACL of char file
+
+    FLAGS: acl getattr char all
+    DEPEND: ACLSUPP LOOKCHAR
+    CODE: ACL1c
+    """
+    doTestGetACL(t, env, env.opts.usechar)
+
+def testGetACLBlock(t, env):
+    """ Get ACL of block file
+
+    FLAGS: acl getattr block all
+    DEPEND: ACLSUPP LOOKBLK
+    CODE: ACL1b
+    """
+    doTestGetACL(t, env, env.opts.useblock)
+
+def doCheckACL(t, c, file, acl):
+    res = c.compound(c.use_obj(file) + [c.getattr([FATTR4_ACL])])
+    check(res)
+
+    attrs = res.resarray[-1].obj_attributes
+    if FATTR4_ACL not in attrs.keys():
+         t.fail("Attributes not contains FATTR4_ACL")
+
+#    print printableacl(acl)
+#    print printableacl(attrs[FATTR4_ACL])
+
+def doSetACLEnv(t, env, type = NF4REG):
+    c = env.c1
+    path = c.homedir + [t.code]
+    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
+    check(res)
+
+    c1 = env.c2
+    c1.init_connection()
+
+    path += [t.code]
+    attrs = {FATTR4_MODE: 0777}
+
+    if type == NF4REG:
+        fh, stateid = c1.create_confirm(t.code, path, attrs=attrs,
+                                        deny=OPEN4_SHARE_DENY_NONE)
+        return (c1, path, fh, stateid)
+    else:
+        res = c1.create_obj(path, attrs=attrs)
+        check(res)
+        return (c1, path)
+
+def testWriteFileWithoutACL(t, env):
+    """ Check write file without write ACL
+
+    FLAGS: acl file all
+    DEPEND: ACLSUPP MKFILE
+    CODE: ACL2
+    """
+    c1, path, fh, stateid = doSetACLEnv(t, env)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_WRITE_DATA, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, fh, testacl)
+
+    res = c1.open_file(t.code, path, access=OPEN4_SHARE_ACCESS_WRITE)
+    check(res, NFS4ERR_ACCESS, "Trying to OPEN file without write ACL")
+
+def testReadFileWithoutACL(t, env):
+    """ Check read file without read ACL
+
+    FLAGS: acl file all
+    DEPEND: ACLSUPP MKFILE
+    CODE: ACL3
+    """
+    c1, path, fh, stateid = doSetACLEnv(t, env)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_READ_DATA, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, fh, testacl)
+
+    res = c1.open_file(t.code, path, deny = OPEN4_SHARE_DENY_READ)
+    check(res, NFS4ERR_ACCESS, "Trying to OPEN file without read ACL")
+
+def testAppendFileWithoutACL(t, env):
+    """ Check write file without append ACL
+
+    FLAGS: acl file all
+    DEPEND: ACLSUPP MKFILE
+    CODE: ACL4
+    """
+    c1, path, fh, stateid = doSetACLEnv(t, env)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_APPEND_DATA, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, fh, testacl)
+
+    res = c1.open_file(t.code, path, access=OPEN4_SHARE_ACCESS_WRITE)
+    check(res, NFS4ERR_ACCESS, "Trying to OPEN file without append ACL")
+
+def testChownWithoutACL(t, env):
+    """ Check change file's owner without WRITE OWNER ACL
+
+    FLAGS: acl file all
+    DEPEND: ACLSUPP MKFILE
+    CODE: ACL5
+    """
+    c1, path, fh, stateid = doSetACLEnv(t, env)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_WRITE_OWNER, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, fh, testacl)
+
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_OWNER: "6666"})])
+    check(res, NFS4ERR_PERM, "Trying to change file's owner without ACL")
+
+def testSetACLWithoutACL(t, env):
+    """ Check set ACL without SETACL ACL
+
+    FLAGS: acl file all
+    DEPEND: ACLSUPP MKFILE
+    CODE: ACL6
+    """
+    c1, path, fh, stateid = doSetACLEnv(t, env)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_WRITE_ACL, "OWNER@")]
+    ops = c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})]
+    res = c1.compound(ops)
+    check(res)
+
+    doCheckACL(t, c1, fh, testacl)
+
+    res = c1.compound(ops)
+    check(res, NFS4ERR_PERM, "Trying to set acl without ACL")
+
+def testCreateFileWithoutACL(t, env):
+    """ Check create file in directory without ACL
+
+    FLAGS: acl dir all
+    DEPEND: ACLSUPP MKDIR
+    CODE: ACL7
+    """
+    c1, path = doSetACLEnv(t, env, type = NF4DIR)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_ADD_FILE, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, path, testacl)
+
+    path += [t.code]
+    res = c1.create_obj(path)
+    # NFSD's shortage, can not create sub-directory
+    check(res, NFS4ERR_ACCESS)
+
+    res = c1.create_file(t.code, path)
+    check(res, NFS4ERR_ACCESS, "Trying to create file without ACL")
+
+def testListDirWithoutACL(t, env):
+    """ Check list directory without ACL
+
+    FLAGS: acl dir all
+    DEPEND: ACLSUPP MKDIR
+    CODE: ACL8
+    """
+    c1, path = doSetACLEnv(t, env, type = NF4DIR)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_LIST_DIRECTORY, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
     check(res)
 
+    doCheckACL(t, c1, path, testacl)
+
+    res = c1.compound(c1.use_obj(path) + [c1.readdir()])
+    check(res, NFS4ERR_ACCESS, "Trying to list directory without ACL")
+
+def testMkdirWithoutACL(t, env):
+    """ Check creat sub-directory without ACL
+
+    FLAGS: acl dir all
+    DEPEND: ACLSUPP MKDIR
+    CODE: ACL9
+    """
+    c1, path = doSetACLEnv(t, env, type = NF4DIR)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_ADD_SUBDIRECTORY, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, path, testacl)
+
+    path += [t.code]
+    res = c1.create_file(t.code, path)
+    # NFSD's shortage, can not create file
+    check(res, NFS4ERR_ACCESS)
+
+    res = c1.create_obj(path)
+    check(res, NFS4ERR_ACCESS, "Trying to create sub-directory without ACL")
+
+def testLookupFileWithoutACL(t, env):
+    """ Check lookup file without ACL
+
+    FLAGS: acl dir all
+    DEPEND: ACLSUPP MKDIR
+    CODE: ACL10
+    """
+    c1, path = doSetACLEnv(t, env, type = NF4DIR)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_EXECUTE, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, path, testacl)
+
+    res = c1.compound(c1.use_obj(path) + c1.lookup_path([t.code]))
+    check(res, NFS4ERR_ACCESS, "Trying to lookup sub-file without ACL")
+
+def testUnlinkFileWithoutACL(t, env):
+    """ Check unlink sub-file without ACL
+
+    FLAGS: acl dir all
+    DEPEND: ACLSUPP MKDIR
+    CODE: ACL11
+    """
+    c1, path = doSetACLEnv(t, env, type = NF4DIR)
+
+    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_DELETE_CHILD, "OWNER@")]
+    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
+    check(res)
+
+    doCheckACL(t, c1, path, testacl)
+
+    res = c1.compound(c1.use_obj(path) + [c1.remove_op(t.code)])
+    check(res, NFS4ERR_ACCESS, "Trying to lookup sub-file without ACL")
+
 def testLargeACL(t, env):
     """SETATTR/GETATTR of a large ACL
 
     FLAGS: acl all
-    DEPEND: LOOKFILE
-    CODE: ACL10
+    DEPEND: LOOKFILE ACLSUPP
+    CODE: ACL12
     """
     c = env.c1
     c.init_connection()
@@ -42,7 +359,5 @@ def testLargeACL(t, env):
     ops += [c.setattr({FATTR4_ACL: acl})]
     res = c.compound(ops)
     check(res)
-    ops = c.use_obj(fh)
-    ops += [c.getattr([FATTR4_ACL])]
-    res = c.compound(ops)
-    check(res)
+
+    doTestGetACL(t, env, fh)
-- 
1.9.3

