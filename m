Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55413 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab1FMV1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 17:27:52 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v4 5/6] nfs-utils:  Implement srcaddr=n binding for unmount.
Date: Mon, 13 Jun 2011 14:26:47 -0700
Message-Id: <1308000408-13690-6-git-send-email-greearb@candelatech.com>
In-Reply-To: <1308000408-13690-1-git-send-email-greearb@candelatech.com>
References: <1308000408-13690-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This fully implements binding to a local IP address when
attempting to un-mount.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 b046874... 348211e... M	utils/mount/network.c
:100644 100644 8cd2852... 63fb37c... M	utils/mount/nfsumount.c
:100644 100644 eb50074... d146d82... M	utils/mount/utils.c
:100644 100644 3fcd504... f9fbc90... M	utils/mount/utils.h
 utils/mount/network.c   |   10 +++++++++-
 utils/mount/nfsumount.c |   28 ++++++++++++++++++++++++----
 utils/mount/utils.c     |    6 ++++--
 utils/mount/utils.h     |    4 +++-
 4 files changed, 40 insertions(+), 8 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index b046874..348211e 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1733,6 +1733,8 @@ int nfs_umount_do_umnt(struct mount_options *options,
 	socklen_t salen = sizeof(address);
 	struct pmap nfs_pmap, mnt_pmap;
 	sa_family_t family;
+	struct local_bind_info local_ip;
+	struct local_bind_info *lipp = NULL;
 
 	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap))
 		return EX_FAIL;
@@ -1753,7 +1755,13 @@ int nfs_umount_do_umnt(struct mount_options *options,
 		/* nfs_lookup reports any errors */
 		return EX_FAIL;
 
-	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname, NULL) == 0)
+	if (local_ip_opt &&
+	    nfs_parse_local_bind(&local_ip, local_ip_opt,
+				 sap->sa_family) >= 0) {
+		lipp = &local_ip;
+	}
+
+	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname, lipp) == 0)
 		/* nfs_advise_umount reports any errors */
 		return EX_FAIL;
 
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 8cd2852..63fb37c 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -239,6 +239,8 @@ int nfsumount(int argc, char *argv[])
 	int c, ret;
 	char *spec;
 	struct mntentchn *mc;
+	char *opt;
+	char *local_ip = NULL;
 
 	if (argc < 2) {
 		umount_usage();
@@ -314,7 +316,7 @@ int nfsumount(int argc, char *argv[])
 			return EX_USAGE;
 		}
 		if (hasmntopt(&mc->m, "users") == NULL) {
-			char *opt = hasmntopt(&mc->m, "user");
+			opt = hasmntopt(&mc->m, "user");
 			struct passwd *pw;
 			char *comma;
 			size_t len;
@@ -334,6 +336,20 @@ int nfsumount(int argc, char *argv[])
 		}
 	}
 
+	if (mc) {
+		opt = hasmntopt(&mc->m, "srcaddr");
+		if ((opt != NULL) && strlen(opt) > strlen("srcaddr=")) {
+			local_ip = xstrdup(opt + strlen("srcaddr="));
+			unsigned int z;
+			for (z = 0; z < strlen(local_ip); z++) {
+				if (local_ip[z] == ',') {
+					local_ip[z] = 0;
+					break;
+				}
+			}
+		}
+	}
+
 	ret = EX_SUCCESS;
 	if (mc) {
 		if (!lazy) {
@@ -344,20 +360,24 @@ int nfsumount(int argc, char *argv[])
 				 * we don't want to signal an error, as that
 				 * could cause /sbin/mount to retry!
 				 */
-				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts,
+					     local_ip);
 				break;
 			case 1:
 				break;
 			default:
-				return EX_FAIL;
+				ret = EX_FAIL;
+				goto out;
 			}
 		}
 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
-			ret = nfs_umount23(spec, "tcp,v3");
+			ret = nfs_umount23(spec, "tcp,v3", local_ip);
 	} else
 		ret = del_mtab(NULL, spec);
 
+out:
+	free(local_ip);
 	return ret;
 }
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index eb50074..d146d82 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -153,7 +153,8 @@ int chk_mountpoint(const char *mount_point)
  * pmap tuple.  If the GETPORT call later fails to disambiguate them,
  * then we fail.
  */
-int nfs_umount23(const char *devname, char *string)
+int nfs_umount23(const char *devname, char *string,
+		 char *local_ip_opt)
 {
 	char *hostname = NULL, *dirname = NULL;
 	struct mount_options *options;
@@ -164,7 +165,8 @@ int nfs_umount23(const char *devname, char *string)
 
 	options = po_split(string);
 	if (options) {
-		result = nfs_umount_do_umnt(options, &hostname, &dirname, NULL);
+		result = nfs_umount_do_umnt(options, &hostname, &dirname,
+					    local_ip_opt);
 		po_destroy(options);
 	} else
 		nfs_error(_("%s: option parsing error"), progname);
diff --git a/utils/mount/utils.h b/utils/mount/utils.h
index 3fcd504..f9fbc90 100644
--- a/utils/mount/utils.h
+++ b/utils/mount/utils.h
@@ -31,6 +31,8 @@ void mount_usage(void);
 void umount_usage(void);
 int chk_mountpoint(const char *mount_point);
 
-int nfs_umount23(const char *devname, char *string);
+struct local_bind_info;
+int nfs_umount23(const char *devname, char *string,
+		 char *local_ip_opt);
 
 #endif	/* !_NFS_UTILS_MOUNT_UTILS_H */
-- 
1.7.3.4

