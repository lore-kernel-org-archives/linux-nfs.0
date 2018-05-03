Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43024 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751095AbeECQuv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 May 2018 12:50:51 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 51976406C791
        for <linux-nfs@vger.kernel.org>; Thu,  3 May 2018 16:50:51 +0000 (UTC)
Message-ID: <1525366249.7550.24.camel@redhat.com>
Subject: [PATCH v2 6/7] nfs-utils: Add nfsconftool cli
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <SteveD@RedHat.com>
Date: Thu, 03 May 2018 17:50:49 +0100
In-Reply-To: <1525365943.7550.18.camel@redhat.com>
References: <1525365943.7550.18.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This tool uses the conffile facilities to allow commandline
querying of configuration settings and to dump the current
config for diagnosis and testing

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 Makefile.am       | 2 +-
 configure.ac      | 1 +
 tools/Makefile.am | 2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/Makefile.am b/Makefile.am
index e1f39aa..0022084 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -2,7 +2,7 @@
 
 AUTOMAKE_OPTIONS = foreign
 
-SUBDIRS = tools support utils linux-nfs tests systemd
+SUBDIRS = support tools utils linux-nfs tests systemd
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/configure.ac b/configure.ac
index 5a11636..b925666 100644
--- a/configure.ac
+++ b/configure.ac
@@ -616,6 +616,7 @@ AC_CONFIG_FILES([
 	tools/rpcgen/Makefile
 	tools/mountstats/Makefile
 	tools/nfs-iostat/Makefile
+	tools/nfsconf/Makefile
 	utils/Makefile
 	utils/blkmapd/Makefile
 	utils/nfsdcltrack/Makefile
diff --git a/tools/Makefile.am b/tools/Makefile.am
index f2ce282..4266da4 100644
--- a/tools/Makefile.am
+++ b/tools/Makefile.am
@@ -6,6 +6,8 @@ if CONFIG_RPCGEN
 OPTDIRS += rpcgen
 endif
 
+OPTDIRS += nfsconf
+
 SUBDIRS = locktest rpcdebug nlmtest mountstats nfs-iostat $(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
-- 
1.8.3.1



