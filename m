Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53668 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab0JZP6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:58:30 -0400
Received: by mail-iw0-f174.google.com with SMTP id 10so2336058iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:58:29 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] mount.nfs: mnt_freq and mnt_pass are always zero
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:58:26 -0400
Message-ID: <20101026155826.19184.84163.stgit@matisse.1015granger.net>
In-Reply-To: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

No need to pass constant zeros to add_mtab() from its only call site.
Ensure that initialization of a struct mntent is consistent in both
places that it is done.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index b4da21f..a19af53 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -224,6 +224,20 @@ static char *fix_opts_string(int flags, const char *extra_opts)
 	return new_opts;
 }
 
+static void
+init_mntent(struct mntent *mnt, char *fsname, char *dir, char *type,
+		int flags, char *opts)
+{
+	mnt->mnt_fsname	= fsname;
+	mnt->mnt_dir	= dir;
+	mnt->mnt_type	= type;
+	mnt->mnt_opts	= fix_opts_string(flags & ~MS_NOMTAB, opts);
+
+	/* these are always zero for NFS */
+	mnt->mnt_freq	= 0;
+	mnt->mnt_passno	= 0;
+}
+
 /* Create mtab with a root entry.  */
 static void
 create_mtab (void) {
@@ -245,11 +259,8 @@ create_mtab (void) {
 	if ((fstab = getfsfile ("/")) || (fstab = getfsfile ("root"))) {
 		char *extra_opts;
 		parse_opts (fstab->m.mnt_opts, &flags, &extra_opts);
-		mnt.mnt_dir = "/";
-		mnt.mnt_fsname = xstrdup(fstab->m.mnt_fsname);
-		mnt.mnt_type = fstab->m.mnt_type;
-		mnt.mnt_opts = fix_opts_string (flags, extra_opts);
-		mnt.mnt_freq = mnt.mnt_passno = 0;
+		init_mntent(&mnt, xstrdup(fstab->m.mnt_fsname), "/",
+				fstab->m.mnt_type, flags, extra_opts);
 		free(extra_opts);
 
 		if (nfs_addmntent (mfp, &mnt) == 1) {
@@ -273,17 +284,12 @@ create_mtab (void) {
 }
 
 static int add_mtab(char *spec, char *mount_point, char *fstype,
-			int flags, char *opts, int freq, int pass)
+			int flags, char *opts)
 {
 	struct mntent ment;
 	int result = EX_SUCCESS;
 
-	ment.mnt_fsname = spec;
-	ment.mnt_dir = mount_point;
-	ment.mnt_type = fstype;
-	ment.mnt_opts = fix_opts_string(flags & ~MS_NOMTAB, opts);
-	ment.mnt_freq = freq;
-	ment.mnt_passno = pass;
+	init_mntent(&ment, spec, mount_point, fstype, flags, opts);
 
 	if (!nomtab && mtab_does_not_exist()) {
 		if (verbose > 1)
@@ -441,9 +447,7 @@ static int try_mount(char *spec, char *mount_point, int flags,
 	if (!fake)
 		print_one(spec, mount_point, fs_type, mount_opts);
 
-	ret = add_mtab(spec, mount_point, fs_type, flags, *extra_opts,
-			0, 0 /* these are always zero for NFS */ );
-	return ret;
+	return add_mtab(spec, mount_point, fs_type, flags, *extra_opts);
 }
 
 int main(int argc, char *argv[])

