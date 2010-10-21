Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47414 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758359Ab0JUPDp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 11:03:45 -0400
Received: by ywi6 with SMTP id 6so2799132ywi.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 08:03:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] mount.nfs: Preserve options in /etc/mtab during remount
To: linux-nfs@vger.kernel.org
Cc: kzak@redhat.com
Date: Thu, 21 Oct 2010 11:03:41 -0400
Message-ID: <20101021150341.2866.22727.stgit@ellison.1015granger.net>
In-Reply-To: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
References: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It appears that, for a long while, NFS "remount" mounts have
completely wiped the existing mount options in /etc/mtab for a given
mount point.  This is a problem for umount.nfs, since it reads its
options out of /etc/mtab to find out how to do the unmount.

umount.nfs could read /proc/mounts instead, since it always has the
authoritative set of mount options in effect for that mount point.
However, /proc/mounts contains the options that were negotiated, not
the options that were specified on the command line.

For example, if the server's mountd had been restarted and has acquired
a different port since the client mounted the server, the specified
command line mount options would probably allow the UMNT to renegotiate
and complete successfully.  But the "in effect" mount options in
/proc/mounts, which always include a specific mountport=, would most
likely fail in this case.

In addition, older kernels won't show much of the information in
/proc/mounts that umount.nfs needs.

Therefore mount.nfs (and umount.nfs) must put the correct set of mount
options in /etc/mtab to ensure that the final umount.nfs will do the
right thing.

This is a fix for:

  https://bugzilla.linux-nfs.org/show_bug.cgi?id=188

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 8fb03e0..45ae5f6 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -273,6 +273,81 @@ create_mtab (void) {
 	reset_mtab_info();
 }
 
+static int string_is_empty(const char *s)
+{
+	if (s != NULL && *s != '\0')
+		return 0;
+	return 1;
+}
+
+static char *concat_opts(const char *left, const char *right)
+{
+	char *retval;
+
+	if (string_is_empty(left)) {
+		if (string_is_empty(right))
+			return NULL;
+		return strdup(right);
+	}
+	if (string_is_empty(right))
+		return strdup(left);
+
+	retval = malloc(strlen(left) + strlen(",") + strlen(right) + 1);
+	if (retval == NULL)
+		return retval;
+
+	retval[0] = '\0';
+	strcat(retval, left);
+	strcat(retval, ",");
+	strcat(retval, right);
+	return retval;
+}
+
+/*
+ * Return new set of MS_ flags and dynamically allocated string
+ * containing mount options to write to /etc/mtab after a remount.
+ */
+static void remount_opts(char *spec, char *cmdline,
+		int *flags, char **extra_opts)
+{
+	char *old_opts, *tmp_opts;
+	struct mntentchn *mc;
+
+	/*
+	 * Retrieve the existing mount options for this mount
+	 * point from /etc/mtab (or /proc/mounts).
+	 */
+	if (*spec == '/')
+		mc = getmntdirbackward(spec, NULL);
+	else
+		mc = getmntdevbackward(spec, NULL);
+	if (mc == NULL) {
+		if (verbose)
+			printf(_("Could not find %s in mtab\n"), spec);
+		/* don't change flags and extra_opts */
+		return;
+	}
+
+	/*
+	 * To construct the correct set of flags, concatenate the
+	 * command line options to the old options from mtab, then
+	 * parse them, left to right.  This ensures we handle the
+	 * default setting of "ro" and "rw" correctly, and prevents
+	 * duplicate MS_ options from showing up.
+	 *
+	 * Later, fix_opts_string() will re-assemble these into a
+	 * single canonical mount options string.
+	 */
+	tmp_opts = concat_opts(mc->m.mnt_opts, cmdline);
+	if (tmp_opts == NULL)
+		return;
+
+	xfree(*extra_opts);
+	*flags = 0;
+	parse_opts(tmp_opts, flags, extra_opts);
+	free(tmp_opts);
+}
+
 static int add_mtab(char *spec, char *mount_point, char *fstype,
 			int flags, char *opts)
 {
@@ -442,6 +517,9 @@ static int try_mount(char *spec, char *mount_point, int flags,
 	if (!fake)
 		print_one(spec, mount_point, fs_type, mount_opts);
 
+	if (flags & MS_REMOUNT)
+		remount_opts(spec, mount_opts, &flags, extra_opts);
+
 	return add_mtab(spec, mount_point, fs_type, flags, *extra_opts);
 }
 

