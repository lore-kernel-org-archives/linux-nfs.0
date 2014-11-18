Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754773AbaKROGq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:46 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jaI008796
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6iTt030993
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] mount.nfs: default enable mount config file (nfsmount.conf)
Date: Tue, 18 Nov 2014 09:06:39 -0500
Message-Id: <63a58a49d14a76829a1892e104251cf288140add.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 configure.ac |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index e3af723..c13e7ee 100644
--- a/configure.ac
+++ b/configure.ac
@@ -178,8 +178,10 @@ if test "$enable_mount" = yes; then
 	[AC_HELP_STRING([--enable-mountconfig],
                         [enable mount to use a configuration file])],
 	mountconfig=$enableval,
-	mountconfig=no)
-	if test "$enable_mountconfig" = yes; then
+	mountconfig=yes)
+	if test "$enable_mountconfig" = no; then
+		enable_mountconfig=
+	else
 		AC_DEFINE(MOUNT_CONFIG, 1, 
 			[Define this if you want mount to read a configuration file])
 		AC_ARG_WITH(mountfile,
@@ -191,8 +193,6 @@ if test "$enable_mount" = yes; then
 		AC_SUBST(mountfile)
 		AC_DEFINE_UNQUOTED(MOUNTOPTS_CONFFILE, "$mountfile", 
 			[This defines the location of the NFS mount configuration file])
-	else
-		enable_mountconfig=
 	fi
 	AC_SUBST(enable_mountconfig)
 	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mountconfig" = "yes"])
-- 
1.7.1

