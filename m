Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53569 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757733Ab1FJSLP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 14:11:15 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 6/7] nfs-utils:  Implement srcaddr=n binding for unmount.
Date: Fri, 10 Jun 2011 11:09:38 -0700
Message-Id: <1307729379-7702-7-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307729379-7702-1-git-send-email-greearb@candelatech.com>
References: <1307729379-7702-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This fully implements binding to a local IP address when
attempting to un-mount.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 8cd2852... ef5ec17... M	utils/mount/nfsumount.c
:100644 100644 eb50074... c3d3467... M	utils/mount/utils.c
:100644 100644 3fcd504... ef71814... M	utils/mount/utils.h
 utils/mount/nfsumount.c |   26 +++++++++++++++++++++++---
 utils/mount/utils.c     |    6 ++++--
 utils/mount/utils.h     |    4 +++-
 3 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 8cd2852..ef5ec17 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -239,6 +239,9 @@ int nfsumount(int argc, char *argv[])
 	int c, ret;
 	char *spec;
 	struct mntentchn *mc;
+	char *opt;
+	struct local_bind_info local_ip;
+	memset(&local_ip, 0, sizeof(local_ip));
 
 	if (argc < 2) {
 		umount_usage();
@@ -314,7 +317,7 @@ int nfsumount(int argc, char *argv[])
 			return EX_USAGE;
 		}
 		if (hasmntopt(&mc->m, "users") == NULL) {
-			char *opt = hasmntopt(&mc->m, "user");
+			opt = hasmntopt(&mc->m, "user");
 			struct passwd *pw;
 			char *comma;
 			size_t len;
@@ -334,6 +337,22 @@ int nfsumount(int argc, char *argv[])
 		}
 	}
 
+	if (mc) {
+		opt = hasmntopt(&mc->m, "srcaddr");
+		if ((opt != NULL) && strlen(opt) > strlen("srcaddr=")) {
+			char *sa = xstrdup(opt + strlen("srcaddr="));
+			unsigned int z;
+			for (z = 0; z < strlen(sa); z++) {
+				if (sa[z] == ',') {
+					sa[z] = 0;
+					break;
+				}
+			}
+			parse_local_bind(&local_ip, sa);
+			free(sa);
+		}
+	}
+
 	ret = EX_SUCCESS;
 	if (mc) {
 		if (!lazy) {
@@ -344,7 +363,8 @@ int nfsumount(int argc, char *argv[])
 				 * we don't want to signal an error, as that
 				 * could cause /sbin/mount to retry!
 				 */
-				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts,
+					     &local_ip);
 				break;
 			case 1:
 				break;
@@ -355,7 +375,7 @@ int nfsumount(int argc, char *argv[])
 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
-			ret = nfs_umount23(spec, "tcp,v3");
+			ret = nfs_umount23(spec, "tcp,v3", &local_ip);
 	} else
 		ret = del_mtab(NULL, spec);
 
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index eb50074..c3d3467 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -153,7 +153,8 @@ int chk_mountpoint(const char *mount_point)
  * pmap tuple.  If the GETPORT call later fails to disambiguate them,
  * then we fail.
  */
-int nfs_umount23(const char *devname, char *string)
+int nfs_umount23(const char *devname, char *string,
+		 struct local_bind_info *local_ip)
 {
 	char *hostname = NULL, *dirname = NULL;
 	struct mount_options *options;
@@ -164,7 +165,8 @@ int nfs_umount23(const char *devname, char *string)
 
 	options = po_split(string);
 	if (options) {
-		result = nfs_umount_do_umnt(options, &hostname, &dirname, NULL);
+		result = nfs_umount_do_umnt(options, &hostname, &dirname,
+					    local_ip);
 		po_destroy(options);
 	} else
 		nfs_error(_("%s: option parsing error"), progname);
diff --git a/utils/mount/utils.h b/utils/mount/utils.h
index 3fcd504..ef71814 100644
--- a/utils/mount/utils.h
+++ b/utils/mount/utils.h
@@ -31,6 +31,8 @@ void mount_usage(void);
 void umount_usage(void);
 int chk_mountpoint(const char *mount_point);
 
-int nfs_umount23(const char *devname, char *string);
+struct local_bind_info;
+int nfs_umount23(const char *devname, char *string,
+		 struct local_bind_info *local_ip);
 
 #endif	/* !_NFS_UTILS_MOUNT_UTILS_H */
-- 
1.7.3.4

