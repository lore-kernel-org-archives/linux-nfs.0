From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/2] Change to a dependency on libgssglue rather than
	libgssapi
Date: Fri, 07 Sep 2007 10:18:35 -0400
Message-ID: <20070907141835.16229.22790.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070907141603.16229.68150.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITefJ-0006mE-Ng
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 07:18:33 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ITefM-00083Q-44
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 07:18:38 -0700
In-Reply-To: <20070907141603.16229.68150.stgit@RoCk.CiTi.UmIcH.EdU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

From: Guillaume Rousse <Guillaume.Rousse@inria.fr>

Use the renamed library libgssglue rather than libgssapi.
Also bump the required version for librpcsecgss (to the one that
also requires libgssglue rather than libgssapi).

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 configure.ac |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1d07cd7..a378953 100644
--- a/configure.ac
+++ b/configure.ac
@@ -181,11 +181,11 @@ if test "$enable_nfsv4" = yes; then
     dnl librpcsecgss already has a dependency on libgssapi,
     dnl but we need to make sure we get the right version
     if test "$enable_gss" = yes; then
-     PKG_CHECK_MODULES(RPCSECGSS, librpcsecgss >= 0.10, ,
+     PKG_CHECK_MODULES(RPCSECGSS, librpcsecgss >= 0.16, ,
       [AC_MSG_ERROR([Unable to locate information required to use librpcsecgss.  If you have pkgconfig installed, you might try setting environment variable PKG_CONFIG_PATH to /usr/local/lib/pkgconfig])
       ]
      )
-    PKG_CHECK_MODULES(GSSAPI, libgssapi >= 0.11)
+    PKG_CHECK_MODULES(GSSGLUE, libgssglue >= 0.1)
     fi
 
 fi
@@ -228,9 +228,9 @@ if test "$enable_gss" = yes; then
 
   dnl This is not done until here because we need to have KRBLIBS set
   dnl ("librpcsecgss=1" is so that it doesn't get added to LIBS)
-  AC_CHECK_LIB(rpcsecgss, authgss_create_default, [librpcsecgss=1], AC_MSG_ERROR([librpcsecgss needed for nfsv4 support]), -lgssapi -ldl)
+  AC_CHECK_LIB(rpcsecgss, authgss_create_default, [librpcsecgss=1], AC_MSG_ERROR([librpcsecgss needed for nfsv4 support]), -lgssglue -ldl)
   AC_CHECK_LIB(rpcsecgss, authgss_set_debug_level,
-  	       AC_DEFINE(HAVE_AUTHGSS_SET_DEBUG_LEVEL, 1, [Define this if the rpcsec_gss library has the function authgss_set_debug_level]),, -lgssapi -ldl)
+  	       AC_DEFINE(HAVE_AUTHGSS_SET_DEBUG_LEVEL, 1, [Define this if the rpcsec_gss library has the function authgss_set_debug_level]),, -lgssglue -ldl)
 
 fi
 
@@ -284,7 +284,7 @@ AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
 
 
 dnl *************************************************************
-dnl Check for data sizes (XXX These should go away with libgssapi pkg-config)
+dnl Check for data sizes
 dnl *************************************************************
 AC_CHECK_SIZEOF(short)
 AC_CHECK_SIZEOF(int)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
