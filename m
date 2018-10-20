Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727413AbeJUAO0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Oct 2018 20:14:26 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 544A03001A52
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 16:03:31 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-63.rdu2.redhat.com [10.10.120.63])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 01C745D6A6
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 16:03:30 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] gssd: Introduce use-gss-proxy boolean to nfs.conf
Date: Sat, 20 Oct 2018 12:03:29 -0400
Message-Id: <20181020160329.135824-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the used of the gssprox-mech(8) through a the
boolean variable in the [gssd] section of nfs.conf

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 nfs.conf             |  1 +
 systemd/nfs.conf.man |  1 +
 utils/gssd/gssd.c    | 10 ++++++++++
 3 files changed, 12 insertions(+)

diff --git a/nfs.conf b/nfs.conf
index 0d0ec9b..5546109 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -11,6 +11,7 @@
 #[gssd]
 # use-memcache=0
 # use-machine-creds=1
+# use-gss-proxy=0
 # avoid-dns=1
 # limit-to-legacy-enctypes=0
 # context-timeout=0
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 189b052..699db3f 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -213,6 +213,7 @@ for details.
 Recognized values:
 .BR use-memcache ,
 .BR use-machine-creds ,
+.BR use-gss-proxy ,
 .BR avoid-dns ,
 .BR limit-to-legacy-enctypes ,
 .BR context-timeout ,
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 00df2fc..2e92f28 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -89,6 +89,7 @@ char *preferred_realm = NULL;
 char *ccachedir = NULL;
 /* Avoid DNS reverse lookups on server names */
 static bool avoid_dns = true;
+static bool use_gssproxy = false;
 int thread_started = false;
 pthread_mutex_t pmutex = PTHREAD_MUTEX_INITIALIZER;
 pthread_cond_t pcond = PTHREAD_COND_INITIALIZER;
@@ -872,6 +873,7 @@ read_gss_conf(void)
 	if (s)
 		preferred_realm = s;
 
+	use_gssproxy = conf_get_bool("gssd", "use-gss-proxy", use_gssproxy);
 }
 
 int
@@ -957,6 +959,14 @@ main(int argc, char *argv[])
 		exit(1);
 	}
 
+	if (use_gssproxy) {
+		if (setenv("GSS_USE_PROXY", "yes", 1) < 0) {
+			printerr(0, "gssd: Unable to set $GSS_USE_PROXY: %s\n", 
+				strerror(errno));
+			exit(EXIT_FAILURE);
+		}
+	}
+
 	if (ccachedir) {
 		char *ccachedir_copy;
 		char *ptr;
-- 
2.17.2
