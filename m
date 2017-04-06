Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29219 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752558AbdDFQbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 12:31:05 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9BFAFC04B94A
        for <linux-nfs@vger.kernel.org>; Thu,  6 Apr 2017 16:31:04 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 2/4] gssd: add a deprecation warning for pipefs-directory in gssd section
Date: Thu,  6 Apr 2017 12:31:02 -0400
Message-Id: <20170406163104.28397-3-smayhew@redhat.com>
In-Reply-To: <20170406163104.28397-1-smayhew@redhat.com>
References: <20170406163104.28397-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All the daemons should use the same rpc_pipefs, so pipefs-directory
should be specified in the [general] section.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs.conf             |  1 -
 systemd/nfs.conf.man |  3 ++-
 utils/gssd/gssd.c    |  4 ++++
 utils/gssd/gssd.man  | 12 ++++++++----
 4 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/nfs.conf b/nfs.conf
index 0828bdd..10d383d 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -15,7 +15,6 @@
 # limit-to-legacy-enctypes=0
 # context-timeout=0
 # rpc-timeout=5
-# pipefs-directory=/var/lib/nfs/rpc_pipefs
 # keytab-file=/etc/krb5.keytab
 # cred-cache-directory=
 # preferred-realm=
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index e493ea3..1a72da0 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -102,6 +102,8 @@ Recognized values:
 
 See
 .BR rpc.idmapd (8)
+and
+.BR rpc.gssd (8)
 for details.
 
 .TP
@@ -214,7 +216,6 @@ Recognized values:
 .BR limit-to-legacy-enctypes ,
 .BR context-timeout ,
 .BR rpc-timeout ,
-.BR pipefs-directory ,
 .BR keytab-file ,
 .BR cred-cache-directory ,
 .BR preferred-realm .
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 77125f1..28f9649 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -857,6 +857,10 @@ read_gss_conf(void)
 	s = conf_get_str("gssd", "pipefs-directory");
 	if (!s)
 		s = conf_get_str("general", "pipefs-directory");
+	else
+		printerr(0, "WARNING: Specifying pipefs-directory in the [gssd] "
+			 "section of %s is deprecated.  Use the [general] "
+			 "section instead.", NFS_CONFFILE);
 	if (s)
 		pipefs_path = s;
 	s = conf_get_str("gssd", "keytab-file");
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 87eef02..e620f0d 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -335,10 +335,6 @@ Equivalent to
 Equivalent to
 .BR -t .
 .TP
-.B pipefs-directory
-Equivalent to
-.BR -p .
-.TP
 .B keytab-file
 Equivalent to
 .BR -k .
@@ -350,6 +346,14 @@ Equivalent to
 .B preferred-realm
 Equivalent to
 .BR -R .
+.P
+In addtion, the following value is recognized from the
+.B [general]
+section:
+.TP
+.B pipefs-directory
+Equivalent to
+.BR -p .
 
 .SH SEE ALSO
 .BR rpc.svcgssd (8),
-- 
2.9.3

