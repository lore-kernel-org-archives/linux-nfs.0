From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
 option are set (vers-02)
Date: Tue, 25 Aug 2009 13:55:31 -0400
Message-ID: <4A942593.8030101@RedHat.com>
References: <4A9424DB.2040303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484AbZHYRzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 13:55:33 -0400
In-Reply-To: <4A9424DB.2040303-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 1471d23d692efc7388794a8a3c3b9e548d1c5be8
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Aug 25 12:15:18 2009 -0400

    Make sure umount use correct fs type.
    
    umounts use the fs type in /etc/mtab to determine
    which file system is being unmounted. The mtab
    entry is create during the mount. To ensure the
    correct entry is create when the fs type changes
    due to the mount options, the address of the fs_type
    variable has to be passed so it can be updated.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 355df79..507fbb5 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -417,13 +417,14 @@ static int chk_mountpoint(char *mount_point)
 }
 
 static int try_mount(char *spec, char *mount_point, int flags,
-			char *fs_type, char **extra_opts, char *mount_opts,
+			char *type, char **extra_opts, char *mount_opts,
 			int fake, int bg)
 {
 	int ret;
+	char *fs_type = type;
 
 	if (string)
-		ret = nfsmount_string(spec, mount_point, fs_type, flags,
+		ret = nfsmount_string(spec, mount_point, &fs_type, flags,
 					extra_opts, fake, bg);
 	else {
 		if (strcmp(fs_type, "nfs4") == 0)
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 153723d..1031c08 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -734,13 +734,13 @@ static int nfsmount_start(struct nfsmount_info *mi)
  * @fake: flag indicating whether to carry out the whole operation
  * @child: one if this is a mount daemon (bg)
  */
-int nfsmount_string(const char *spec, const char *node, const char *type,
+int nfsmount_string(const char *spec, const char *node, char **type,
 		    int flags, char **extra_opts, int fake, int child)
 {
 	struct nfsmount_info mi = {
 		.spec		= spec,
 		.node		= node,
-		.type		= type,
+		.type		= *type,
 		.extra_opts	= extra_opts,
 		.flags		= flags,
 		.fake		= fake,
@@ -751,6 +751,9 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	mi.options = po_split(*extra_opts);
 	if (mi.options) {
 		retval = nfsmount_start(&mi);
+		/* Note any fs type changes */
+		if (!retval)
+			*type =  (char *)mi.type;
 		po_destroy(mi.options);
 	} else
 		nfs_error(_("%s: internal option parsing error"), progname);
diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
index b4fd888..dad9997 100644
--- a/utils/mount/stropts.h
+++ b/utils/mount/stropts.h
@@ -24,7 +24,7 @@
 #ifndef _NFS_UTILS_MOUNT_STROPTS_H
 #define _NFS_UTILS_MOUNT_STROPTS_H
 
-int nfsmount_string(const char *, const char *, const char *, int,
+int nfsmount_string(const char *, const char *, char **, int,
 			char **, int, int);
 
 #endif	/* _NFS_UTILS_MOUNT_STROPTS_H */

