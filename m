Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37009 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933548AbeCGTaF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 14:30:05 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A0BF680F8F
        for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2018 19:30:05 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-102.phx2.redhat.com [10.3.116.102])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 568427DE4C
        for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2018 19:30:05 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Removed -Werror=format-truncation and format warnings
Date: Wed,  7 Mar 2018 14:30:02 -0500
Message-Id: <20180307193002.46760-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 tools/locktest/testlk.c          |  2 +-
 utils/blkmapd/device-discovery.c |  2 +-
 utils/gssd/krb5_util.c           | 24 ++++++++++--------------
 utils/idmapd/idmapd.c            |  2 +-
 4 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/tools/locktest/testlk.c b/tools/locktest/testlk.c
index 82ed765..b392f71 100644
--- a/tools/locktest/testlk.c
+++ b/tools/locktest/testlk.c
@@ -81,7 +81,7 @@ main(int argc, char **argv)
 		if (fl.l_type == F_UNLCK) {
 			printf("%s: no conflicting lock\n", fname);
 		} else {
-			printf("%s: conflicting lock by %d on (%lld;%lld)\n",
+			printf("%s: conflicting lock by %d on (%ld;%ld)\n",
 				fname, fl.l_pid, fl.l_start, fl.l_len);
 		}
 		return 0;
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index 1afc80f..3a202e0 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -239,7 +239,7 @@ int bl_discover_devices(void)
 {
 	FILE *f;
 	int n;
-	char buf[PATH_MAX], devname[PATH_MAX], fulldevname[PATH_MAX];
+	char buf[PATH_MAX], devname[PATH_MAX], fulldevname[PATH_MAX+NAME_MAX];
 
 	/* release previous list */
 	bl_release_disk();
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6e61da2..b342b06 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -188,7 +188,7 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
 	int found = 0;
 	struct dirent *best_match_dir = NULL;
 	struct stat best_match_stat, tmp_stat;
-	char buf[1030];
+	char buf[PATH_MAX+4+2+256];
 	char *princname = NULL;
 	char *realm = NULL;
 	int score, best_match_score = 0, err = -EACCES;
@@ -202,39 +202,35 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
 			dirname, strerror(errno));
 	}
 	else if (n > 0) {
-		char statname[1024];
 		for (i = 0; i < n; i++) {
-			snprintf(statname, sizeof(statname),
+			snprintf(buf, sizeof(buf),
 				 "%s/%s", dirname, namelist[i]->d_name);
 			printerr(3, "CC '%s' being considered, "
 				 "with preferred realm '%s'\n",
-				 statname, preferred_realm ?
+				 buf, preferred_realm ?
 					preferred_realm : "<none selected>");
-			if (lstat(statname, &tmp_stat)) {
-				printerr(0, "Error doing stat on '%s'\n",
-					 statname);
+			if (lstat(buf, &tmp_stat)) {
+				printerr(0, "Error doing stat on '%s'\n", buf);
 				free(namelist[i]);
 				continue;
 			}
 			/* Only pick caches owned by the user (uid) */
 			if (tmp_stat.st_uid != uid) {
 				printerr(3, "CC '%s' owned by %u, not %u\n",
-					 statname, tmp_stat.st_uid, uid);
+					 buf, tmp_stat.st_uid, uid);
 				free(namelist[i]);
 				continue;
 			}
 			if (!S_ISREG(tmp_stat.st_mode) &&
 			    !S_ISDIR(tmp_stat.st_mode)) {
 				printerr(3, "CC '%s' is not a regular "
-					 "file or directory\n",
-					 statname);
+					 "file or directory\n", buf);
 				free(namelist[i]);
 				continue;
 			}
 			if (uid == 0 && !root_uses_machine_creds && 
 				strstr(namelist[i]->d_name, "machine_")) {
-				printerr(3, "CC '%s' not available to root\n",
-					 statname);
+				printerr(3, "CC '%s' not available to root\n", buf);
 				free(namelist[i]);
 				continue;
 			}
@@ -865,7 +861,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 		if (strcmp(realm, default_realm) == 0)
 			tried_default = 1;
 		for (j = 0; svcnames[j] != NULL; j++) {
-			char spn[300];
+			char spn[NI_MAXHOST+2];
 
 			/*
 			 * The special svcname "$" means 'try the active
@@ -1059,7 +1055,7 @@ err_cache:
 int
 gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
 {
-	char			buf[MAX_NETOBJ_SZ], dirname[PATH_MAX];
+	char			buf[PATH_MAX+2+256], dirname[PATH_MAX];
 	const char		*cctype;
 	struct dirent		*d;
 	int			err, i, j;
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 67d115d..b87c4dd 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -420,7 +420,7 @@ dirscancb(int UNUSED(fd), short UNUSED(which), void *data)
 	int nent, i;
 	struct dirent **ents;
 	struct idmap_client *ic, *nextic;
-	char path[PATH_MAX];
+	char path[PATH_MAX+256]; /* + sizeof(d_name) */
 	struct idmap_clientq *icq = data;
 
 	nent = scandir(pipefsdir, &ents, NULL, alphasort);
-- 
2.14.3

