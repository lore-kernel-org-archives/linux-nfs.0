Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab0JKAGe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:06:34 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:06:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/15] mount.nfs: don't show "remount" flag in /etc/mtab
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:06:30 -0400
Message-ID: <20101011000630.6667.13971.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Don't add the 'remount' option to /etc/mtab.  This is the same
behavior as file systems that use the monolithic /sbin/mount command.
See the MS_NOMTAB macro in utils-linux-ng/mount/mount.c.

Note that mount(8) has MS_USERS and MS_USER in the "nomtab" category
as well, but mount.nfs needs to record those values so that unmounting
a user-mounted NFS file system can work.

While we're here, fix some white space damage in fix_opts_string().

This is a partial fix for:

  https://bugzilla.linux-nfs.org/show_bug.cgi?id=188

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c           |    4 ++--
 utils/mount/mount_constants.h |    4 ++++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 2909595..b4da21f 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -209,7 +209,7 @@ static char *fix_opts_string(int flags, const char *extra_opts)
 	}
 	if (flags & MS_USERS)
 		new_opts = xstrconcat3(new_opts, ",users", "");
-	
+
 	for (om = opt_map; om->opt != NULL; om++) {
 		if (om->skip)
 			continue;
@@ -281,7 +281,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	ment.mnt_fsname = spec;
 	ment.mnt_dir = mount_point;
 	ment.mnt_type = fstype;
-	ment.mnt_opts = fix_opts_string(flags, opts);
+	ment.mnt_opts = fix_opts_string(flags & ~MS_NOMTAB, opts);
 	ment.mnt_freq = freq;
 	ment.mnt_passno = pass;
 
diff --git a/utils/mount/mount_constants.h b/utils/mount/mount_constants.h
index cbfb099..4d050d8 100644
--- a/utils/mount/mount_constants.h
+++ b/utils/mount/mount_constants.h
@@ -64,4 +64,8 @@ if we have a stack or plain mount - mount atop of it, forming a stack. */
 #define MS_MGC_MSK 0xffff0000	/* magic flag number mask */
 #endif
 
+/* Generic options that are prevented from appearing
+ * in the options field in /etc/mtab. */
+#define MS_NOMTAB	(MS_REMOUNT)
+
 #endif	/* _NFS_UTILS_MOUNT_CONSTANTS_H */

