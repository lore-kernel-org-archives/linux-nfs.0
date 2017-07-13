Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47494 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751062AbdGMGap (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 02:30:45 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>
Date: Thu, 13 Jul 2017 16:30:05 +1000
Subject: [PATCH 3/4] mount: move handling of "-t nfs4" into nfs_nfs_version()
Cc: linux-nfs@vger.kernel.org
Message-ID: <149992740560.9181.15169927556408775845.stgit@noble>
In-Reply-To: <149992731965.9181.6611555845253022123.stgit@noble>
References: <149992731965.9181.6611555845253022123.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current "-t nfs4" causes other mount options to be ignored
and an NFSv4 version to be negotiated.
This is even true when "-o vers=4.1" is given.

To address this, we need to move the handled of "-t nfs4"
into nfs_nfs_version, which means passing in the filesystem type.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/configfile.c |    2 +-
 utils/mount/network.c    |   11 ++++++-----
 utils/mount/network.h    |    2 +-
 utils/mount/nfsumount.c  |    2 +-
 utils/mount/stropts.c    |    8 +-------
 5 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index dc964c79107f..e4b39ef86bad 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -260,7 +260,7 @@ default_value(char *mopt)
 		}
 	} else if (strncasecmp(field, "vers", strlen("vers")) == 0) {
 		if ((options = po_split(field)) != NULL) {
-			if (!nfs_nfs_version(options, &config_default_vers)) {
+			if (!nfs_nfs_version("nfs", options, &config_default_vers)) {
 				xlog_warn("Unable to set default version: %s", 
 					strerror(errno));
 				
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 92457c726be7..d673391b5fff 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1260,7 +1260,7 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
  * or FALSE if the option was specified with an invalid value.
  */
 int
-nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
+nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *version)
 {
 	char *version_key, *version_val, *cptr;
 	int i, found = 0;
@@ -1275,10 +1275,11 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
 		}
 	}
 
-	if (!found)
+	if (!found && strcmp(type, "nfs4") == 0)
+		version_val = type + 3;
+	else if (!found)
 		return 1;
-
-	if (i <= 2 ) {
+	else if (i <= 2 ) {
 		/* v2, v3, v4 */
 		version_val = version_key + 1;
 		version->v_mode = V_SPECIFIC;
@@ -1650,7 +1651,7 @@ int nfs_options2pmap(struct mount_options *options,
 
 	if (!nfs_nfs_program(options, &nfs_pmap->pm_prog))
 		return 0;
-	if (!nfs_nfs_version(options, &version))
+	if (!nfs_nfs_version("nfs", options, &version))
 		return 0;
 	if (version.v_mode == V_DEFAULT)
 		nfs_pmap->pm_vers = 0;
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 9cc5decf19fa..ecaac33d88de 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -72,7 +72,7 @@ struct nfs_version {
 
 int nfs_nfs_proto_family(struct mount_options *options, sa_family_t *family);
 int nfs_mount_proto_family(struct mount_options *options, sa_family_t *family);
-int nfs_nfs_version(struct mount_options *options, struct nfs_version *version);
+int nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *version);
 int  nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol);
 
 int nfs_options2pmap(struct mount_options *,
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index de284f2419da..e16fb6a1bbb1 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -180,7 +180,7 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
 		options = po_split(pmc->m.mnt_opts);
 		if (options != NULL) {
 			struct nfs_version version;
-			int rc = nfs_nfs_version(options, &version);
+			int rc = nfs_nfs_version("nfs", options, &version);
 			po_destroy(options);
 			if (rc && version.major == 4)
 				goto out_nfs4;
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0a371bf1811e..eb9a27ba2f50 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -327,15 +327,9 @@ static int nfs_append_sloppy_option(struct mount_options *options)
 
 static int nfs_set_version(struct nfsmount_info *mi)
 {
-	if (!nfs_nfs_version(mi->options, &mi->version))
+	if (!nfs_nfs_version(mi->type, mi->options, &mi->version))
 		return 0;
 
-	if (strncmp(mi->type, "nfs4", 4) == 0) {
-		/* Set to default values */
-		mi->version.major = NFS_DEFAULT_MAJOR;
-		mi->version.minor = NFS_DEFAULT_MINOR;
-		mi->version.v_mode = V_GENERAL;
-	}
 	/*
 	 * Before 2.6.32, the kernel NFS client didn't
 	 * support "-t nfs vers=4" mounts, so NFS version


