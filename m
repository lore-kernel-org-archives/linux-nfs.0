Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:54466 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992448Ab2JYRWB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2012 13:22:01 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so2132436vcb.19
        for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 10:22:01 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 6/9] nfsdcltrack: add a legacy transition mechanism
Date: Thu, 25 Oct 2012 13:21:40 -0400
Message-Id: <1351185703-14191-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351185703-14191-1-git-send-email-jlayton@redhat.com>
References: <1351185703-14191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the kernel passes the legacy recdir path in the environment, then we
can use that to transition from the old legacy tracker to the new one.

On a "check" operation, if there is no record of the client in the
database, check to see if there is a matching recoverydir. If there
isn't then just refuse the reclaim. If there is, then insert a new
record for this client into the db, and remove the legacy recoverydir.
If either of those operations fail, then refuse the reclaim.

On a "gracedone" operation, clean out the entire legacy recoverydir
after purging any unreclaimed records from the db. There's not much
we can do if this fails, so just log a warning if it does.

Note that this is a one-way conversion. If the user later boots back
into an older kernel, it will have no knowledge of the new database.

In principle, we could create a tool that would walk the clients
table, md5 hash the clientids and create directories in the
v4recovery dir. Doing that automatically would be pretty difficult
however.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 85 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 1d262a2..9801b9c 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -36,6 +36,7 @@
 #include <unistd.h>
 #include <libgen.h>
 #include <sys/inotify.h>
+#include <dirent.h>
 #ifdef HAVE_SYS_CAPABILITY_H
 #include <sys/prctl.h>
 #include <sys/capability.h>
@@ -296,6 +297,48 @@ cltrack_remove(const char *id)
 }
 
 static int
+cltrack_check_legacy(const unsigned char *blob, const ssize_t len)
+{
+	int ret;
+	struct stat st;
+	char *recdir = getenv("NFSDCLTRACK_LEGACY_RECDIR");
+
+	if (!recdir) {
+		xlog(D_GENERAL, "No NFSDCLTRACK_LEGACY_RECDIR env var");
+		return -EOPNOTSUPP;
+	}
+
+	/* fail recovery on any stat failure */
+	ret = stat(recdir, &st);
+	if (ret) {
+		xlog(D_GENERAL, "Unable to stat %s: %d", recdir, errno);
+		return -errno;
+	}
+
+	/* fail if it isn't a directory */
+	if (!S_ISDIR(st.st_mode)) {
+		xlog(D_GENERAL, "%s is not a directory: mode=0%o", recdir
+				, st.st_mode);
+		return -ENOTDIR;
+	}
+
+	/* Dir exists, try to insert record into db */
+	ret = sqlite_insert_client(blob, len);
+	if (ret) {
+		xlog(D_GENERAL, "Failed to insert client: %d", ret);
+		return -EREMOTEIO;
+	}
+
+	/* remove the legacy recoverydir */
+	ret = rmdir(recdir);
+	if (ret) {
+		xlog(D_GENERAL, "Failed to rmdir %s: %d", recdir, errno);
+		return -errno;
+	}
+	return 0;
+}
+
+static int
 cltrack_check(const char *id)
 {
 	int ret;
@@ -312,10 +355,50 @@ cltrack_check(const char *id)
 		return (int)len;
 
 	ret = sqlite_check_client(blob, len);
+	if (ret)
+		ret = cltrack_check_legacy(blob, len);
 
 	return ret ? -EPERM : ret;
 }
 
+/* Clean out the v4recoverydir -- best effort here */
+static void
+cltrack_legacy_gracedone(void)
+{
+	DIR *v4recovery;
+	struct dirent *entry;
+	char *dirname = getenv("NFSDCLTRACK_LEGACY_TOPDIR");
+
+	if (!dirname)
+		return;
+
+	v4recovery = opendir(dirname);
+	if (!v4recovery)
+		return;
+
+	while ((entry = readdir(v4recovery))) {
+		int len;
+
+		/* borrow the clientid blob for this */
+		len = snprintf((char *)blob, sizeof(blob), "%s/%s", dirname,
+				entry->d_name);
+
+		/* if there's a problem, then skip this entry */
+		if (len < 0 || (size_t)len >= sizeof(blob)) {
+			xlog(L_WARNING, "%s: unable to build filename for %s!",
+				__func__, entry->d_name);
+			continue;
+		}
+
+		len = rmdir((char *)blob);
+		if (len)
+			xlog(L_WARNING, "%s: unable to rmdir %s: %d", __func__,
+				(char *)blob, len);
+	}
+
+	closedir(v4recovery);
+}
+
 static int
 cltrack_gracedone(const char *timestr)
 {
@@ -343,6 +426,8 @@ cltrack_gracedone(const char *timestr)
 
 	ret = sqlite_remove_unreclaimed(gracetime);
 
+	cltrack_legacy_gracedone();
+
 	return ret ? -EREMOTEIO : ret;
 }
 
-- 
1.7.11.7

