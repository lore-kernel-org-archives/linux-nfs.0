Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:44244 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755773Ab2CLRXr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 13:23:47 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1S78yC-0006Zk-Pt
	for linux-nfs@vger.kernel.org; Mon, 12 Mar 2012 13:23:45 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/1] exportfs: Stop racing exportfs on clusters
Date: Mon, 12 Mar 2012 13:23:40 -0400
Message-Id: <1331573020-28628-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This problem can occur when multiple cluster services fail over
at the same time, causing missing high-available exports.
Having a lot of nfs-exports will trigger this issue easier.

https://bugzilla.linux-nfs.org/show_bug.cgi?id=224

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/exportfs.h |    4 ++++
 utils/exportfs/exportfs.c  |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

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
index 7432a65..7326802 100644
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
@@ -44,6 +45,39 @@ static void	validate_export(nfs_export *exp);
 static int	matchhostname(const char *hostname1, const char *hostname2);
 static void	export_d_read(const char *dname);
 
+static const char *lockfile = EXP_LOCKFILE;
+static int _lockfd = -1;
+
+/*
+ * If we aren't careful, changes made by exportfs can be lost
+ * when multiple exports process run at once:
+ *
+ *	exportfs process 1	exportfs process 2
+ *	------------------------------------------
+ *	reads etab version A	reads etab version A
+ *	adds new export B	adds new export C
+ *	writes A+B		writes A+C
+ *
+ * The locking in support/export/xtab.c will prevent mountd from
+ * seeing a partially written version of etab, and will prevent 
+ * the two writers above from writing simultaneously and
+ * corrupting etab, but to prevent problems like the above we
+ * need these additional lockfile() routines.
+ */
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
@@ -129,6 +163,13 @@ main(int argc, char **argv)
 			return 0;
 		}
 	}
+
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
1.7.7.5

