From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 1/2] Allow nfs/vers=4 option in old style mount commands
Date: Tue,  5 May 2009 14:46:43 -0700
Message-ID: <1241560004-16787-2-git-send-email-kevin.constantine@disneyanimation.com>
References: <1241560004-16787-1-git-send-email-kevin.constantine@disneyanimation.com>
Cc: Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:2848 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759104AbZEEVqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2009 17:46:44 -0400
In-Reply-To: <1241560004-16787-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows a user to specify nfsvers=4, or vers=4 on the mount
commandline and have mount.nfs4 called as though fstype=nfs4 were
specified.  This patch handles the nfs4mount, and nfsmount cases in
try_mount().

Added the function find_rightmost() to return the rightmost option in the
extra_opts string.  If vers=4 is overridden later in the string by
vers=3, we need to honor that.

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 utils/mount/mount.c |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 06e2804..4cebc0f 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -444,11 +444,38 @@ static int try_mount(char *spec, char *mount_point, int flags,
 	return ret;
 }
 
+static void find_rightmost(char *extra_opts, char *search_opt, char **rightmost_opt)
+{
+	char *opts = xstrdup(extra_opts);
+	char *right_opt = NULL, *token = NULL;
+	int i = 0;
+
+	for (;;) {
+		if (i == 0) {
+			token = strtok(opts, ",");
+			i++;
+		}
+		else 
+			token = strtok(NULL, ",");
+
+		if (token == NULL) 
+			break;
+		if (! strncmp(token, search_opt, strlen(search_opt))) 
+			right_opt = xstrdup(token);
+	}
+	if (right_opt != NULL) {
+		*rightmost_opt = xmalloc(strlen(right_opt));
+		strcpy(*rightmost_opt, right_opt);
+	}
+	free(opts);
+	free(right_opt);
+}
+
 int main(int argc, char *argv[])
 {
 	int c, flags = 0, mnt_err = 1, fake = 0;
 	char *spec, *mount_point, *fs_type = "nfs";
-	char *extra_opts = NULL, *mount_opts = NULL;
+	char *extra_opts = NULL, *mount_opts = NULL, *vers_opt=NULL;
 	uid_t uid = getuid();
 
 	progname = basename(argv[0]);
@@ -562,6 +589,18 @@ int main(int argc, char *argv[])
 
 	parse_opts(mount_opts, &flags, &extra_opts);
 
+	find_rightmost(extra_opts, "vers", &vers_opt);
+	if (vers_opt != NULL) {
+		if ((strcmp(vers_opt, "vers=4")) == 0) 
+			fs_type = "nfs4";
+	}
+
+	find_rightmost(extra_opts, "nfsvers", &vers_opt);
+	if (vers_opt != NULL) {
+		if ((strcmp(vers_opt, "nfsvers=4")) == 0) 
+			fs_type = "nfs4";
+	}
+
 	if (uid != 0) {
 		if (!(flags & (MS_USERS|MS_USER))) {
 			nfs_error(_("%s: permission denied"), progname);
-- 
1.6.2.1

