Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbaISRK1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 13:10:27 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8JHARJL021070
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 13:10:27 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 2/2] rpc.svcgssd: the build of rpc.svcgssd is off by default
Date: Fri, 19 Sep 2014 13:10:21 -0400
Message-Id: <1411146621-18797-3-git-send-email-steved@redhat.com>
In-Reply-To: <1411146621-18797-1-git-send-email-steved@redhat.com>
References: <1411146621-18797-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Due to the fact the gssproxy is not managing the
GASSAPI credentials, on the server, there is
no need to build/install rpc.svcgssd.

To re-enable the build use the --enable-svcgss
configure flag

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac           | 23 +++++++++++++++++++----
 utils/gssd/Makefile.am | 11 +++++++++--
 2 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/configure.ac b/configure.ac
index bc48373..6767190 100644
--- a/configure.ac
+++ b/configure.ac
@@ -90,21 +90,36 @@ AC_ARG_ENABLE(nfsv41,
 
 AC_ARG_ENABLE(gss,
 	[AC_HELP_STRING([--enable-gss],
-                        [enable support for rpcsec_gss @<:@default=yes@:>@])],
+              [enable client support for rpcsec_gss @<:@default=yes@:>@])],
 	enable_gss=$enableval,
 	enable_gss=yes)
 	if test "$enable_gss" = yes; then
 		GSSD=gssd
-		SVCGSSD=svcgssd
 	else
 		enable_gss=
 		GSSD=
-		SVCGSSD=
 	fi
 	AC_SUBST(GSSD)
-	AC_SUBST(SVCGSSD)
 	AC_SUBST(enable_gss)
 	AM_CONDITIONAL(CONFIG_GSS, [test "$enable_gss" = "yes"])
+
+AC_ARG_ENABLE(svcgss,
+	[AC_HELP_STRING([--enable-svcgss],
+              [enable server support for rpcsec_gss @<:@default=no@:>@])],
+	enable_svcgss=$enableval,
+	enable_svcgss=no)
+	if test "$enable_gss" = yes; then
+		if "enable_svcgss" = yes; then
+			SVCGSSD=svcgssd
+		fi
+	else
+		enable_svcgss=
+		SVCGSSD=
+	fi
+	AC_SUBST(SVCGSSD)
+	AC_SUBST(enable_svcgss)
+	AM_CONDITIONAL(CONFIG_SVCGSS, [test "$enable_svcgss" = "yes"])
+
 AC_ARG_ENABLE(kprefix,
 	[AC_HELP_STRING([--enable-kprefix], [install progs as rpc.knfsd etc])],
 	test "$enableval" = "yes" && kprefix=k,
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index af59791..9835117 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -1,10 +1,17 @@
 ## Process this file with automake to produce Makefile.in
 
-man8_MANS	= gssd.man svcgssd.man
+man8_MANS	= gssd.man
+if CONFIG_SVCGSS
+man8_MANS	+= svcgssd.man
+endif
 
 RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
-sbin_PREFIXED	= gssd svcgssd
+sbin_PREFIXED	= gssd
+if CONFIG_SVCGSS
+sbin_PREFIXED	+= svcgssd
+endif
+
 sbin_PROGRAMS	= $(sbin_PREFIXED)
 
 EXTRA_DIST = \
-- 
1.9.3

