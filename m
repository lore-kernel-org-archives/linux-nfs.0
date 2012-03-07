Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932758Ab2CGT4h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 14:56:37 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q27Jub8Q016777
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 7 Mar 2012 14:56:37 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q27Juatg032563
	for <linux-nfs@vger.kernel.org>; Wed, 7 Mar 2012 14:56:37 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] exportfs: Stop racing exportfs on clusters
Date: Wed,  7 Mar 2012 14:56:30 -0500
Message-Id: <1331150190-18401-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This problem can occur when multiple cluster services fail over
at the same time, causing missing high-available exports.
Having a lot of nfs-exports will trigger this issue easier.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/exportfs.h |    4 ++++
 utils/exportfs/exportfs.c  |   24 ++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 01e87dd..99916e5 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -32,6 +32,10 @@ enum {
 	FSLOC_STUB
 };
 
+#ifndef EXP_LOCKFILE
+#define EXP_LOCKFILE "/var/lib/nfs/export-lock"
+#endif
+
 typedef struct mclient {
 	struct mclient *	m_next;
 	char *			m_hostname;
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 7432a65..769d438 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -16,6 +16,7 @@
 #include <sys/stat.h>
 #include <sys/vfs.h>
 #include <sys/stat.h>
+#include <sys/file.h>
 #include <unistd.h>
 #include <stdbool.h>
 #include <stdlib.h>
@@ -44,6 +45,23 @@ static void	validate_export(nfs_export *exp);
 static int	matchhostname(const char *hostname1, const char *hostname2);
 static void	export_d_read(const char *dname);
 
+static const char *lockfile = EXP_LOCKFILE;
+static int _lockfd = -1;
+
+void 
+grab_lockfile()
+{
+	_lockfd = open(lockfile, O_CREAT|O_RDWR, 0666);
+	if (_lockfd != -1) 
+		lockf(_lockfd, F_LOCK, 0);
+}
+void 
+release_lockfile()
+{
+	if (_lockfd != -1)
+		lockf(_lockfd, F_ULOCK, 0);
+}
+
 int
 main(int argc, char **argv)
 {
@@ -129,6 +147,12 @@ main(int argc, char **argv)
 			return 0;
 		}
 	}
+	/*
+	 * Serialize things as best we can
+	 */
+	grab_lockfile();
+	atexit(release_lockfile);
+
 	if (f_export && ! f_ignore) {
 		export_read(_PATH_EXPORTS);
 		export_d_read(_PATH_EXPORTS_D);
-- 
1.7.7.6

