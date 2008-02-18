From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/17] Introduce "--enable-ipv6" ./configure option
Date: Mon, 18 Feb 2008 13:35:36 -0500
Message-ID: <20080218183535.19060.99802.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:54943 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbYBRSfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:39 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZaTO016603
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:37 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZaTR019312
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:36 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think we want to continue to allow nfs-utils to be built on systems that
do not have any IPv6 development libraries and headers installed, so add a
./configure switch that allows distros to disable IPv6 functionality.

For now, it defaults to "yes" and is a no-op.  As we add IPv6 functionality
we can insert it behind this option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index ab3198a..5a06971 100644
--- a/configure.ac
+++ b/configure.ac
@@ -127,6 +127,18 @@ AC_ARG_ENABLE(mount,
 	enable_mount=$enableval,
 	enable_mount=yes)
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
+AC_ARG_ENABLE(ipv6,
+	[AC_HELP_STRING([--enable-ipv6],
+                        [enable support for IPv6 @<:@default=yes@:>@])],
+	enable_ipv6=$enableval,
+	enable_ipv6=yes)
+	if test "$enable_ipv6" = yes; then
+		AC_DEFINE(IPV6_SUPPORTED, 1, [Define this if you want IPv6 support compiled in])
+	else
+		enable_ipv6=
+	fi
+	AC_SUBST(enable_ipv6)
+	AM_CONDITIONAL(CONFIG_IPV6, [test "$enable_ipv6" = "yes"])
 
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS

