From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 01/12] Touch up some of the autotools files
Date: Thu, 08 Feb 2007 17:26:53 -0500
Message-ID: <20070208222653.23464.55054.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk2-0006sA-Mu
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:47 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk4-0006m4-Bu
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:48 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

this patch touches up the autotool code a bit in nfs-utils:
 - run autogen.sh with -e so if something fails, it'll abort properly
 - set ACLOCAL_AMFLAGS so that when running autoreconf or when
   autotools re-runs itself, the m4 files are found properly
 - make sure we include bsdsignals.m4 in the final tarball
 - add some cross-compiling fallback logic to bsdsignals.m4 so that
   when cross-compiling nfs-utils, the configure is a bit more nice
   than simply:
      checking for BSD signal semantics... configure: error: cannot run test program while cross compiling
---

 Makefile.am           |    3 +++
 aclocal/bsdsignals.m4 |    9 ++++++++-
 autogen.sh            |    2 +-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 8298aa0..c04e9de 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -35,10 +35,13 @@ EXTRA_DIST = \
 	debian/nhfsstone.prerm \
 	debian/rules \
 	\
+	aclocal/bsdsignals.m4 \
 	aclocal/nfs-utils.m4 \
 	aclocal/kerberos5.m4 \
 	aclocal/tcp-wrappers.m4
 
+ACLOCAL_AMFLAGS = -I aclocal
+
 install-data-hook:
 	if [ ! -d $(DESTDIR)$(statedir) ]; then mkdir -p $(DESTDIR)$(statedir); fi
 	touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
diff --git a/aclocal/bsdsignals.m4 b/aclocal/bsdsignals.m4
index e951194..24572aa 100644
--- a/aclocal/bsdsignals.m4
+++ b/aclocal/bsdsignals.m4
@@ -23,7 +23,14 @@ AC_DEFUN([AC_BSD_SIGNALS], [
 		kill(getpid(), SIGHUP); kill(getpid(), SIGHUP);
 		return (counter == 2)? 0 : 1;
 	}
-    ], knfsd_cv_bsd_signals=yes, knfsd_cv_bsd_signals=no)]) dnl
+    ], knfsd_cv_bsd_signals=yes, knfsd_cv_bsd_signals=no,
+    [
+      case "$host_os" in
+        *linux*) knfsd_cv_bsd_signals=no;;
+        *bsd*)   knfsd_cv_bsd_signals=yes;;
+        *)       AC_MSG_ERROR([unable to guess signal semantics for $host_os; please set knfsd_cv_bsd_signals]);;
+      esac
+    ])]) dnl
     AC_MSG_RESULT($knfsd_cv_bsd_signals)
     test $knfsd_cv_bsd_signals = yes && AC_DEFINE(HAVE_BSD_SIGNALS, 1, [Define this if you want to use BSD signal semantics])
 ])dnl
diff --git a/autogen.sh b/autogen.sh
index c89e674..9e8b89b 100644
--- a/autogen.sh
+++ b/autogen.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/sh -e
 
 echo -n cleaning up .
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
