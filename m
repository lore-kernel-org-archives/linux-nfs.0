Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbbA1UyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:54:21 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Qhh005331
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:26 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-65.rdu2.redhat.com [10.10.58.65])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Oxl020173
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:26 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] ipv6: Enable IPv6 support by default.
Date: Wed, 28 Jan 2015 09:07:19 -0500
Message-Id: <1422454042-12840-2-git-send-email-steved@redhat.com>
In-Reply-To: <1422454042-12840-1-git-send-email-steved@redhat.com>
References: <1422454042-12840-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enable IPv6 support to be on by default. Use
the --disable-ipv6 flag to disable the support

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 6740fda..72055be 100644
--- a/configure.ac
+++ b/configure.ac
@@ -171,10 +171,10 @@ AC_ARG_ENABLE(tirpc,
 	enable_tirpc=$enableval,
 	enable_tirpc='')
 AC_ARG_ENABLE(ipv6,
-	[AC_HELP_STRING([--enable-ipv6],
-                        [enable support for IPv6 @<:@default=no@:>@])],
+	[AC_HELP_STRING([--disable-ipv6],
+                        [disable support for IPv6 @<:@default=no@:>@])],
 	enable_ipv6=$enableval,
-	enable_ipv6=no)
+	enable_ipv6=yes)
 	if test "$enable_ipv6" = yes; then
 		AC_DEFINE(IPV6_SUPPORTED, 1, [Define this if you want IPv6 support compiled in])
 	else
-- 
2.1.0

