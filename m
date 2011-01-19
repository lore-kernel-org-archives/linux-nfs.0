Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab1ASPqO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 10:46:14 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0JFkEoP023173
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 19 Jan 2011 10:46:14 -0500
From: Karel Zak <kzak@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>, Karel Zak <kzak@redhat.com>
Subject: [PATCH] configure: fix AM_CONDITIONAL(CONFIG_NFSIDMAP)
Date: Wed, 19 Jan 2011 16:46:03 +0100
Message-Id: <1295451963-14978-1-git-send-email-kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

./configure --disable-gss --disable-nfsv4
[...]
configure: error: conditional "CONFIG_NFSIDMAP" was never defined.

Signed-off-by: Karel Zak <kzak@redhat.com>
---
 configure.ac |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 92833e3..2e074d9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -247,9 +247,6 @@ if test "$enable_nfsv4" = yes; then
   dnl check for nfsidmap libraries and headers
   AC_LIBNFSIDMAP
 
-  dnl enable nfsidmap when its support by libnfsidmap
-  AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
-
   dnl check for the keyutils libraries and headers
   AC_KEYUTILS
 
@@ -260,6 +257,9 @@ if test "$enable_nfsv4" = yes; then
   fi
 fi
 
+dnl enable nfsidmap when its support by libnfsidmap
+AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
+
 if test "$knfsd_cv_glibc2" = no; then
     AC_CHECK_LIB(bsd, daemon, [LIBBSD="-lbsd"])
 fi
-- 
1.7.3.3

