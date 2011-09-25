Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:42326 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501Ab1IYRuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Sep 2011 13:50:18 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] add dependency on devmapper for blkmapd
Date: Sun, 25 Sep 2011 13:50:11 -0400
Message-Id: <1316973011-6393-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 configure.ac |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index 80fb39d..f101b86 100644
--- a/configure.ac
+++ b/configure.ac
@@ -265,6 +265,12 @@ if test "$enable_nfsv4" = yes; then
     AC_RPCSEC_VERSION
   fi
 fi
+
+if test "$enable_nfsv41" = yes; then
+  AC_CHECK_LIB([devmapper], [dm_task_create], [LIBDEVMAPPER="-ldevmapper"], AC_MSG_ERROR([libdevmapper needed]))
+  AC_CHECK_HEADER(libdevmapper.h, , AC_MSG_ERROR([Cannot find devmapper header file libdevmapper.h]))
+fi
+
 dnl enable nfsidmap when its support by libnfsidmap
 AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
 
-- 
1.7.4.1

