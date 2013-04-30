Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50663 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab3D3Vqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 17:46:51 -0400
Date: Tue, 30 Apr 2013 17:46:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: Frank S Filz <ffilz@us.ibm.com>
Subject: Re: [PATCH] nfsd4: don't remap EISDIR errors in rename
Message-ID: <20130430214650.GB30768@fieldses.org>
References: <20130430214546.GA30768@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130430214546.GA30768@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 30, 2013 at 05:45:46PM -0400, bfields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We're going out of our way here to remap an error to make rfc 3530
> happy--but the rfc itself (nor rfc 1813, which has similar language)
> gives no justification.  And disagrees with local filesystem behavior,
> with Linux and posix man pages, and knfsd's implemented behavior for v2
> and v3.
> 
> And the documented behavior seems better, in that it gives a little more
> information--you could implement the 3530 behavior using the posix
> behavior, but not the other way around.
> 
> Also, the Linux client makes no attempt to remap this error in the v4
> case, so it can end up just returning EEXIST to the application in a
> case where it should return EISDIR.
> 
> So honestly I think the rfc's are just buggy here--or in any case it
> doesn't see worth the trouble to remap this error.

Also did a commit to make pynfs relax on this point:

	git://linux-nfs.org/~bfields/pynfs.git

--b.

commit 3e158f56db47cb25921dcb2e609ba5e79dc7197c
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Apr 30 16:44:44 2013 -0400

    server tests: allow NOTDIR/ISDIR on rename
    
    The rfc3530 behavior we're insisting on here looks to me like a mistake,
    or at least not necessarily a good idea: a server on a posix filesystem
    (or with posix clients) more likely wants to return the posix-specified
    errors.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/nfs4.0/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
index c5e7725..1e01d8e 100644
--- a/nfs4.0/servertests/st_rename.py
+++ b/nfs4.0/servertests/st_rename.py
@@ -374,7 +374,7 @@ def testDotsNewname(t, env):
           [NFS4_OK])
 
 def testDirToObj(t, env):
-    """RENAME dir into existing nondir should return NFS4ERR_EXIST
+    """RENAME dir into existing nondir should fail
 
     FLAGS: rename all
     DEPEND: MKDIR MKFILE
@@ -385,7 +385,8 @@ def testDirToObj(t, env):
     basedir = c.homedir + [t.code]
     c.maketree([t.code, ['dir'], 'file'])
     res = c.rename_obj(basedir + ['dir'], basedir + ['file'])
-    check(res, NFS4ERR_EXIST, "RENAME dir into existing file")
+    # note rfc 3530 and 1813 specify EXIST, but posix specifies NOTDIR
+    checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTDIR], "RENAME dir into existing file")
 
 def testDirToDir(t, env):
     """RENAME dir into existing, empty dir should retrun NFS4_OK
@@ -401,7 +402,7 @@ def testDirToDir(t, env):
     check(res, msg="RENAME dir1 into existing, empty dir2")
 
 def testFileToDir(t, env):
-    """RENAME file into existing dir should return NFS4ERR_EXIST
+    """RENAME file into existing dir should fail
 
     FLAGS: rename all
     DEPEND: MKDIR MKFILE
@@ -412,7 +413,8 @@ def testFileToDir(t, env):
     basedir = c.homedir + [t.code]
     c.maketree([t.code, ['dir'], 'file'])
     res = c.rename_obj(basedir + ['file'], basedir + ['dir'])
-    check(res, NFS4ERR_EXIST, "RENAME file into existing dir")
+    # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
+    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing dir")
 
 def testFileToFile(t, env):
     """RENAME file into existing file should return NFS4_OK
@@ -442,7 +444,7 @@ def testDirToFullDir(t, env):
     checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTEMPTY], "RENAME dir1 into existing, nonempty dir2")
 
 def testFileToFullDir(t, env):
-    """RENAME file into existing, nonempty dir should return NFS4ERR_EXIST
+    """RENAME file into existing, nonempty dir should fail
 
     FLAGS: rename all
     DEPEND: MKDIR MKFILE
@@ -453,7 +455,8 @@ def testFileToFullDir(t, env):
     basedir = c.homedir + [t.code]
     c.maketree([t.code, 'file', ['dir', ['foo']]])
     res = c.rename_obj(basedir + ['file'], basedir + ['dir'])
-    check(res, NFS4ERR_EXIST, "RENAME file into existing, nonempty dir")
+    # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
+    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing, nonempty dir")
 
 def testSelfRenameDir(t, env):
     """RENAME that does nothing
diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index 5267129..943587c 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -378,7 +378,7 @@ def testDotsNewname(t, env):
           [NFS4_OK])
 
 def testDirToObj(t, env):
-    """RENAME dir into existing nondir should return NFS4ERR_EXIST
+    """RENAME dir into existing nondir should fail
 
     FLAGS: rename all
     CODE: RNM12
@@ -388,7 +388,8 @@ def testDirToObj(t, env):
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['dir'], basedir + ['file'])
-    check(res, NFS4ERR_EXIST, "RENAME dir into existing file")
+    # note rfc 3530 and 1813 specify EXIST, but posix specifies NOTDIR
+    checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTDIR], "RENAME dir into existing file")
 
 def testDirToDir(t, env):
     """RENAME dir into existing, empty dir should retrun NFS4_OK
@@ -404,7 +405,7 @@ def testDirToDir(t, env):
     check(res, msg="RENAME dir1 into existing, empty dir2")
 
 def testFileToDir(t, env):
-    """RENAME file into existing dir should return NFS4ERR_EXIST
+    """RENAME file into existing dir should fail
 
     FLAGS: rename all
     CODE: RNM14
@@ -414,7 +415,8 @@ def testFileToDir(t, env):
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, ['dir'], 'file'])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
-    check(res, NFS4ERR_EXIST, "RENAME file into existing dir")
+    # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
+    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing dir")
 
 def testFileToFile(t, env):
     """RENAME file into existing file should return NFS4_OK
@@ -443,7 +445,7 @@ def testDirToFullDir(t, env):
     checklist(res, [NFS4ERR_EXIST, NFS4ERR_NOTEMPTY], "RENAME dir1 into existing, nonempty dir2")
 
 def testFileToFullDir(t, env):
-    """RENAME file into existing, nonempty dir should return NFS4ERR_EXIST
+    """RENAME file into existing, nonempty dir should fail
 
     FLAGS: rename all
     CODE: RNM17
@@ -453,7 +455,9 @@ def testFileToFullDir(t, env):
     basedir = env.c1.homedir + [name]
     maketree(sess, [name, 'file', ['dir', ['foo']]])
     res = rename_obj(sess, basedir + ['file'], basedir + ['dir'])
-    check(res, NFS4ERR_EXIST, "RENAME file into existing, nonempty dir")
+    # note rfc 3530 and 1813 specify EXIST, but posix specifies ISDIR
+    checklist(res, [NFS4ERR_EXIST, NFS4ERR_ISDIR], "RENAME file into existing, nonempty dir")
+
 
 def testSelfRenameDir(t, env):
     """RENAME that does nothing
