From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] touchup autotools
Date: Wed, 4 Oct 2006 12:23:10 -0400
Message-ID: <200610041223.14614.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_y/9IFb1tcw3yRhd"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GV9Wg-0008DW-BZ
	for nfs@lists.sourceforge.net; Wed, 04 Oct 2006 09:23:18 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GV9Wh-0007tb-2c
	for nfs@lists.sourceforge.net; Wed, 04 Oct 2006 09:23:19 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id D2B6C64A4B
	for <nfs@lists.sourceforge.net>; Wed,  4 Oct 2006 16:23:17 +0000 (UTC)
To: nfs@lists.sourceforge.net
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

--Boundary-00=_y/9IFb1tcw3yRhd
Content-Type: multipart/signed; boundary="nextPart5412039.yqH8YyTyZF";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart5412039.yqH8YyTyZF
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

this patch touches up the autotool code a bit in nfs-utils:
 - run autogen.sh with -e so if something fails, it'll abort properly
 - set ACLOCAL_AMFLAGS so that when running autoreconf or when autotools=20
re-runs itself, the m4 files are found properly
 - make sure we include bsdsignals.m4 in the final tarball
 - add some cross-compiling fallback logic to bsdsignals.m4 so that when=20
cross-compiling nfs-utils, the configure is a bit more nice than simply:
checking for BSD signal semantics... configure: error: cannot run test prog=
ram=20
while cross compiling
=2Dmike

--nextPart5412039.yqH8YyTyZF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iQIVAwUARSPf8kFjO5/oN/WBAQKe4w/+OEcnlPB/8qdHeAASqTX9jxZiKiBGEuk0
XiczQbLormmujviGKZrprshGNpWWwcfauHtsbXgy8ttdFK3LYXGrEMjsx4jX6GxJ
dirvk7PmLhiZZqa6uE9FJHiFdDiXdyR/XFgDQNLZBmen6MXCSmQqpxWFkt3SI5PV
A0VB/QPvyHrCqC0lKA4T8qtIcM16cMYV869ty9R1IslN+cf+Kv3u4NRUFww6f+iS
RMa4pyx9hSIt2cDsQPfefVjmwiVYGtAaM/R3f2PdNCI3kq8o2NEC0LIEZBqADkGA
uyIyYLFZdkdnjMOSjMFrvp8tMJGUQxBOIQgt1BaAaU8Fq6UuHW6i7t0gkqMT28NN
wEwOWNpuDBQtGyryO5eyYOII0r4Gb+8E2QTaJ5AV52vDLA0A7EUVuhbjYmSz7p8W
gdh1MGOMXmuXJsqUOWJ1bQRzy0D/U8V1M5E1f/ATZek5PI02SoaqR/6bK1iuuNg2
9mjJk4kh2zIJVbXak9SN6Va4arsnFdjlc8v2Z3lejli1hruPEfTfvqcRw4e00/4Z
OSV9seKy2NBOKKu0x3IpH1SxWNRHQANcmqkkeT6iDRW5YhIvsgjJxASNP8oYR0Yt
4cQ1wR5tAKADufNn3MXZ6qfnp4FiaHYNziZywXqIueAQg3ouqi1391LQsCi4TrcG
NDkk+AygXx8=
=80QC
-----END PGP SIGNATURE-----

--nextPart5412039.yqH8YyTyZF--

--Boundary-00=_y/9IFb1tcw3yRhd
Content-Type: text/x-diff; charset="us-ascii"; name="nfs-utils-autotools.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="nfs-utils-autotools.patch"

--- autogen.sh
+++ autogen.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/sh -e
 
 echo -n cleaning up .
 
--- Makefile.am
+++ Makefile.am
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
--- aclocal/bsdsignals.m4
+++ aclocal/bsdsignals.m4
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

--Boundary-00=_y/9IFb1tcw3yRhd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--Boundary-00=_y/9IFb1tcw3yRhd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_y/9IFb1tcw3yRhd--
