Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754923Ab2FFQve (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jun 2012 12:51:34 -0400
Date: Wed, 6 Jun 2012 12:51:33 -0400
To: linux-nfs@vger.kernel.org
Cc: Jian Li <jiali@redhat.com>
Subject: servers may allow owners to override permissions on readdir
Message-ID: <20120606165133.GB32394@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anyone see any reason why I server wouldn't want to allow owners to
override directory permissions on readdir?

(It turns out that the actual behavior of linux nfsd is more
complicated: it attempts to allow overrides on readdir, but then does a
lookup_one_len in the filldir method called on each entry, which results
on an ACCESS error.  But readdirs of empty directories, or nfsv4
readdirs with the rdattr_error, may succeed.  I'm not quite sure what to
do about that.)

--b.

commit a86c3e5f716a9b8a83dddc445a4593305c7e76d6
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jun 6 12:38:58 2012 -0400

    4.0 server tests: server may allow owner to override permissions on readdir
    
    As with regular files, permissions to access a directory are checked on
    open not on individual reads.  Therefore it is the client's
    responsibility to do an access check, and the server should be permitted
    to allow the owner of a directory to overrider permissions.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
index d3570dd..66efae2 100644
--- a/nfs4.0/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -216,41 +216,6 @@ def testReservedCookies(t, env):
         check(res, NFS4ERR_BAD_COOKIE,
               "READDIR with reserved cookie=%i" % cookie)
 
-def testUnaccessibleDir(t, env):
-    """READDIR with (cfh) in unaccessible directory 
-
-    FLAGS: readdir all
-    DEPEND: MKDIR MODE
-    CODE: RDDR11
-    """
-    c = env.c1
-    path = c.homedir + [t.code]
-    c.maketree([t.code, ['hidden']])
-    ops = c.use_obj(path) + [c.setattr({FATTR4_MODE:0})]
-    res = c.compound(ops)
-    check(res, msg="Setting mode=0 on directory %s" % t.code)
-    ops = c.use_obj(path) + [c.readdir()]
-    res = c.compound(ops)
-    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0")
-   
-def testUnaccessibleDirAttrs(t, env):
-    """READDIR with (cfh) in unaccessible directory requesting attrs
-
-    FLAGS: readdir all
-    DEPEND: MKDIR MODE
-    CODE: RDDR12
-    """
-    c = env.c1
-    path = c.homedir + [t.code]
-    c.maketree([t.code, ['hidden']])
-    ops = c.use_obj(path) + [c.setattr({FATTR4_MODE:0})]
-    res = c.compound(ops)
-    check(res, msg="Setting mode=0 on directory %s" % t.code)
-    ops = c.use_obj(path) + \
-          [c.readdir(attr_request=[FATTR4_RDATTR_ERROR, FATTR4_TYPE])]
-    res = c.compound(ops)
-    check(res, NFS4ERR_ACCESS, "READDIR of directory with mode=0")
-   
 ###########################################
 
 
