From: Neil Brown <neilb@suse.de>
Subject: [PATCH - nfs-utils] Make sure statd gets started when 'string options' are in use.
Date: Tue, 6 May 2008 14:38:55 +1000
Message-ID: <18463.57567.260973.429439@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50343 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378AbYEFEjD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 00:39:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The code for checking and starting statd was only in the binary-options
branch of the code.
This moves it into common code.
---
 utils/mount/mount.c    |   22 ++++++++++++++++++++--
 utils/mount/nfsmount.c |   11 -----------
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 5076468..0036caa 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -334,7 +334,8 @@ static void parse_opt(const char *opt, int *mask, char *extra_opts, int len)
  * standard options (indicated by MS_ bits), and output parameter
  * "@extra_opts" gets all the filesystem-specific options.
  */
-static void parse_opts(const char *options, int *flags, char **extra_opts)
+static void parse_opts(const char *options, int *flags, char **extra_opts,
+		       int *lock)
 {
 	if (options != NULL) {
 		char *opts = xstrdup(options);
@@ -358,6 +359,10 @@ static void parse_opts(const char *options, int *flags, char **extra_opts)
 			/* end of option item or last item */
 			if (*p == '\0' || *(p + 1) == '\0') {
 				parse_opt(opt, flags, *extra_opts, len);
+				if (strcmp(opt, "lock") == 0)
+					*lock = 1;
+				if (strcmp(opt, "nolock") == 0)
+					*lock = 0;
 				opt = NULL;
 			}
 		}
@@ -421,6 +426,7 @@ int main(int argc, char *argv[])
 	char *spec, *mount_point, *fs_type = "nfs";
 	char *extra_opts = NULL, *mount_opts = NULL;
 	uid_t uid = getuid();
+	int lock = 1;
 
 	progname = basename(argv[0]);
 
@@ -531,7 +537,7 @@ int main(int argc, char *argv[])
 		goto out;
 	}
 
-	parse_opts(mount_opts, &flags, &extra_opts);
+	parse_opts(mount_opts, &flags, &extra_opts, &lock);
 
 	if (uid != 0) {
 		if (!(flags & (MS_USERS|MS_USER))) {
@@ -546,6 +552,18 @@ int main(int argc, char *argv[])
 		goto out;
 	}
 
+	if (!fake && lock) {
+		if (!start_statd()) {
+			nfs_error(_("%s: rpc.statd is not running but is "
+				"required for remote locking.\n"
+				"   Either use '-o nolock' to keep "
+				"locks local, or start statd."),
+					progname);
+			mnt_err = EX_FAIL;
+			goto out;
+		}
+	}
+
 	mnt_err = try_mount(spec, mount_point, flags, fs_type, &extra_opts,
 				mount_opts, fake, nomtab, FOREGROUND);
 	if (mnt_err == EX_BG) {
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6c0c365..e6ed019 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -851,17 +851,6 @@ noauth_flavors:
 
 	*extra_opts = xstrdup(new_opts);
 
-	if (!fake && !(data.flags & NFS_MOUNT_NONLM)) {
-		if (!start_statd()) {
-			nfs_error(_("%s: rpc.statd is not running but is "
-				"required for remote locking.\n"
-				"   Either use '-o nolock' to keep "
-				"locks local, or start statd."),
-					progname);
-			goto fail;
-		}
-	}
-
 	if (!fake) {
 		if (mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), &data)) {
-- 
1.5.5.1

