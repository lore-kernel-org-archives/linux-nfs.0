Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759492AbbA1Uk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:40:29 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7RnV031501
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:27 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-65.rdu2.redhat.com [10.10.58.65])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Oxm020173
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:26 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/4] svcgssd: Disable support for the rpcsec_gss server by default
Date: Wed, 28 Jan 2015 09:07:20 -0500
Message-Id: <1422454042-12840-3-git-send-email-steved@redhat.com>
In-Reply-To: <1422454042-12840-1-git-send-email-steved@redhat.com>
References: <1422454042-12840-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At this point the gssproxy is better option than the
svcgssd so the support is off by default.

Use --enable-svcgss to re-enable the support

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 72055be..3feb0b3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -115,9 +115,9 @@ AC_ARG_ENABLE(gss,
 
 AC_ARG_ENABLE(svcgss,
 	[AC_HELP_STRING([--enable-svcgss],
-    [enable building svcgssd for rpcsec_gss server support @<:@default=yes@:>@])],
+    [enable building svcgssd for rpcsec_gss server support @<:@default=no@:>@])],
 	enable_svcgss=$enableval,
-	enable_svcgss=yes)
+	enable_svcgss=no)
 	if test "$enable_gss" = yes -a "$enable_svcgss" = yes; then
 		SVCGSSD=svcgssd
 	else
-- 
2.1.0

