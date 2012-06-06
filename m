Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c12o149.mxlogic.net ([208.65.145.82]:59787 "EHLO
	p02c12o149.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756059Ab2FFRil convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jun 2012 13:38:41 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Jian Li <jiali@redhat.com>
Date: Wed, 6 Jun 2012 13:36:59 -0400
Subject: RE: servers may allow owners to override permissions on readdir
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC070388CE57@IT-1874.Isys.com>
References: <20120606165133.GB32394@fieldses.org>
In-Reply-To: <20120606165133.GB32394@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, I don't understand.  Why would it be desirable for the server to be able override directory permissions for readdir unless the directory is already open?

It is desirable to override permissions for regular files because executing a file requires that file's contents to be read or when writing to a file, requires reading the contents in order to perform read/modify/write cycles.  The protocol doesn't contain sufficient support to be able to distinguish the various models on a per-operation basis, so the server leaves it up the client to "do the right thing".

Perhaps a better solution would be to track open directories?  Or is this part of the future directory delegations work?  :-)

	Thanx...

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
Sent: Wednesday, June 06, 2012 12:52 PM
To: linux-nfs@vger.kernel.org
Cc: Jian Li
Subject: servers may allow owners to override permissions on readdir

Anyone see any reason why I server wouldn't want to allow owners to override directory permissions on readdir?

(It turns out that the actual behavior of linux nfsd is more
complicated: it attempts to allow overrides on readdir, but then does a lookup_one_len in the filldir method called on each entry, which results on an ACCESS error.  But readdirs of empty directories, or nfsv4 readdirs with the rdattr_error, may succeed.  I'm not quite sure what to do about that.)

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
 
 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
