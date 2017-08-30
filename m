Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751337AbdH3L5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 07:57:32 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B7421285A8
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 11:57:32 +0000 (UTC)
Message-ID: <1504094250.10850.9.camel@redhat.com>
Subject: [PATCH 5/7] nfs-utils: Add pkgconf data for libnfsconf
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 30 Aug 2017 12:57:30 +0100
In-Reply-To: <1504093866.10850.1.camel@redhat.com>
References: <1504093866.10850.1.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Generate pkgconf files for the nfsconf shared library

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 Makefile.am      |  5 +++++
 configure.ac     |  1 +
 libnfsconf.pc.in | 11 +++++++++++
 3 files changed, 17 insertions(+)
 create mode 100644 libnfsconf.pc.in

diff --git a/Makefile.am b/Makefile.am
index e1f39aa..a3109d9 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -35,3 +35,8 @@ uninstall-hook:
 	rm $(DESTDIR)$(statedir)/etab
 	rm $(DESTDIR)$(statedir)/rmtab
 	rm $(DESTDIR)$(statdpath)/state
+
+pkgconfigdir=$(libdir)/pkgconfig
+pkgconfig_DATA=libnfsconf.pc
+
+$(pkgconfig_DATA): $(top_builddir)/config.status
diff --git a/configure.ac b/configure.ac
index 1ca1603..0b2e8fc 100644
--- a/configure.ac
+++ b/configure.ac
@@ -525,6 +525,7 @@ AC_CONFIG_COMMANDS_PRE([eval eval _sysconfdir=$sysconfdir])
 
 AC_CONFIG_FILES([
 	Makefile
+	libnfsconf.pc
 	systemd/rpc-gssd.service
 	linux-nfs/Makefile
 	support/Makefile
diff --git a/libnfsconf.pc.in b/libnfsconf.pc.in
new file mode 100644
index 0000000..f134e32
--- /dev/null
+++ b/libnfsconf.pc.in
@@ -0,0 +1,11 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
+
+Name: libnfsconf
+Description: Library that parses nfs.conf and related config files.
+Requires:
+Version: @PACKAGE_VERSION@
+Libs: -L@libdir@ -lnfsconf
+Cflags: -I@includedir@
-- 
1.8.3.1



