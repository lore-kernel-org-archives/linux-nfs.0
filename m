Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031135Ab2CITty (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:49:54 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29Jns6O029987
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:49:54 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 6/7] Kill SPKM3: Stop checking for spkm3.h in configure
Date: Fri,  9 Mar 2012 14:49:45 -0500
Message-Id: <1331322586-4631-7-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 configure.ac |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 920e8da0216c447c1c93a017f8dea6c17043d148..67e8d2d9a2c6ec4296c96bb243202bbfea0ab4e9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -316,9 +316,6 @@ if test "$enable_gss" = yes; then
   dnl 'gss' also depends on nfsidmap.h - at least for svcgssd_proc.c
   AC_LIBNFSIDMAP
 
-  AC_CHECK_HEADERS([spkm3.h], ,
-                   [AC_MSG_WARN([Could not locate SPKM3 header; will not have SPKM3 support])])
-
   dnl Check for Kerberos V5
   AC_KERBEROS_V5
 
-- 
1.7.7.6

