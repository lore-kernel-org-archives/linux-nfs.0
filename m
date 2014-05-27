Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbaE0SSt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 14:18:49 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] Make IPv6 enabled by default
Date: Tue, 27 May 2014 14:18:39 -0400
Message-Id: <1401214719-8882-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

Added a --disable-ipv6 configuration flag to allow the
disabling of the IPv6 support.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/configure.ac b/configure.ac
index 7ff80a4..a99c5d6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -15,6 +15,13 @@ if test x$gss = xtrue; then
 	PKG_CHECK_MODULES(GSSGLUE, libgssglue, [],
 	AC_MSG_ERROR([Unable to locate information required to use libgssglue.]))
 fi
+AC_ARG_ENABLE(ipv6,
+	[AC_HELP_STRING([--disable-ipv6], [Disable IPv6 support @<:@default=no@:>@])],
+	[],[enable_ipv6=yes])
+AM_CONDITIONAL(INET6, test "x$disable_ipv6" != xno)
+if test "x$enable_ipv6" != xno; then
+	AC_DEFINE(INET6, 1, [Define to 1 if IPv6 is available])
+fi
 
 AC_PROG_CC
 AM_CONFIG_HEADER(config.h)
-- 
1.7.11.7

