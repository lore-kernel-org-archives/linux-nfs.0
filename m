Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53240 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753025Ab3JVOWp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:45 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 3/3] ANDROS: update gsskeyd to use new /run/user/UID/krb5cc/tgt cache file
Date: Tue, 22 Oct 2013 10:22:37 -0400
Message-ID: <1382451757-3032-4-git-send-email-andros@netapp.com>
In-Reply-To: <1382451757-3032-1-git-send-email-andros@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gsskeyd/gsskeyd.c | 87 ++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 65 insertions(+), 22 deletions(-)

diff --git a/utils/gsskeyd/gsskeyd.c b/utils/gsskeyd/gsskeyd.c
index 6d598fa..722f893 100644
--- a/utils/gsskeyd/gsskeyd.c
+++ b/utils/gsskeyd/gsskeyd.c
@@ -17,10 +17,11 @@
 #include <sys/queue.h>
 #include <sys/uio.h>
 #include <unistd.h>
+#include <dirent.h>
 
 #define MAX_EVENT_SIZE (sizeof(struct inotify_event) + NAME_MAX + 1)
 
-//#define DEBUG_TRACE
+#define DEBUG_TRACE
 
 #ifdef DEBUG_TRACE
 #define TRACE(X...) do { fprintf(stderr, "_trace_: " X); } while (0)
@@ -162,46 +163,57 @@ print_event_mask(FILE *fp, uint32_t mask)
 static int
 manage_gss_ctx_keyring_mapping(struct update *u)
 {
-	char buf[MAXPATHLEN];
 	int status;
 	uid_t uid;
 	pid_t pid;
-	key_serial_t key;
+	key_serial_t serial;
 	long res;
 
-	snprintf(buf, MAXPATHLEN, "%s/%s", u->dir, u->name);
-
+#if CONFIG_OLD
 	if (sscanf(u->name, "krb5cc_%u", &uid) <= 0)
 		perror("parsing krb5cc uid");
+#endif /* CONFIG_OLD */
+
+	if (sscanf(u->dir, "/run/user/%u/krb5cc", &uid) <= 0)
+		perror("parsing krb5cc uid");
 
 	if ((pid = fork()) < 0)
 		perror("fork");
 
 	if (pid == 0) {
+		char description[16];
+
 		if (setuid(uid) < 0)
 			perror("setuid");
 
+		memset(description, 0, 16);
+		snprintf(description, 16, "gss-ctx_%d", uid);
+
 		if (u->is_remove) {
-			fprintf(stderr, "remove gss ctx mapping for uid %u\n",
-				uid);
-			key = request_key("gss-ctx", "_nfstgt_", NULL,
-				KEY_SPEC_USER_KEYRING);
-			if (key > 0) {
-				res = keyctl_unlink(key, KEY_SPEC_USER_KEYRING);
+
+			serial = keyctl_search(KEY_SPEC_USER_SESSION_KEYRING,
+						"gss-ctx", description, 0);
+			if (serial > 0) {
+				res = keyctl_unlink(serial,
+						KEY_SPEC_USER_SESSION_KEYRING);
 				if (res < 0)
 					warn("keyctl_unlink failed");
-			} else
-				warn("request_key failed");
+			} else 
+				warn("keyctl_search failed");
+			
+			TRACE("keyclt_unlink: serial %u  for %d\n",
+				serial, uid);
 		} else {
-			fprintf(stderr, "add gss ctx mapping for uid=%u\n",
-				uid);
-			snprintf(buf, MAXPATHLEN, "FILE:%s/%s",
+			char ccache[MAXPATHLEN];
+
+			snprintf(ccache, MAXPATHLEN, "FILE:%s/%s",
 				u->dir, u->name);
-			key = add_key("gss-ctx", "_nfstgt_", buf,
-				MAXPATHLEN, KEY_SPEC_USER_KEYRING);
+			serial = add_key("gss-ctx", description, ccache,
+				MAXPATHLEN, KEY_SPEC_USER_SESSION_KEYRING);
 
-			if (key < 0)
+			if (serial < 0)
 				warn("add_key failed");
+			TRACE("add_key: serial %u  for %d\n", serial, uid);
 		}
 
 		exit(0);
@@ -246,8 +258,7 @@ parse_events(int notify, struct watchdir_list *watchdirs, struct updates *update
 			fprintf(stderr, "\n");
 #endif
 
-			if (strlen(e->name) >= strlen("krb5cc_") &&
-			    strncmp("krb5cc_", e->name, strlen("krb5cc_")) != 0)
+			if (strncmp("tkt", e->name, strlen("tkt")) != 0)
 				TRACE("skip file: %s\n", e->name);
 			else
 				updates_add(updates, watchdirs, e);
@@ -288,6 +299,38 @@ handle_events(struct updates *updates)
 	timerclear(&updates->first);
 }
 
+/**
+ * /run/user/<UID>/krb5cc are the directories that we want to watch.
+ * Note: assume only UIDs in the /run/user directory.
+ */
+void get_notify_dirs(struct watchdir_list *watchdirs, char *dirpath, int notify)
+{
+	DIR *dp;
+	struct dirent *ep;
+	char buf[MAXPATHLEN];
+
+	dp = opendir(dirpath);
+	if (dp == NULL) {
+		perror ("Couldn't open the notify directory");
+		return;
+	}
+
+	while (ep = readdir (dp)) {
+		if (strncmp(ep->d_name, ".", 1) == 0)
+			continue;
+		else if (strncmp(ep->d_name, "..", 2) == 0)
+			continue;
+		else if (ep->d_type == DT_DIR) {
+			memset(buf, 0, MAXPATHLEN);
+			snprintf(buf, MAXPATHLEN, "%s/%s/%s", dirpath,
+				ep->d_name, "krb5cc");
+			fprintf(stderr, "Added watch dir %s\n", buf);
+			watchdir_add(watchdirs, notify, buf);
+		}
+	}
+	(void) closedir (dp);
+	return;
+}
 
 int
 main(int argc, char **argv)
@@ -305,7 +348,7 @@ main(int argc, char **argv)
 	if (notify < 0)
 		perror("inotify_init1");
 
-	watchdir_add(&watchdirs, notify, "/tmp");
+	get_notify_dirs(&watchdirs, "/run/user", notify);
 
 	LIST_INIT(&updates.list);
 	timerclear(&updates.first);
-- 
1.8.3.1

