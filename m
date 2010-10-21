Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58190 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab0JUPDe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 11:03:34 -0400
Received: by mail-gy0-f174.google.com with SMTP id 13so509532gyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 08:03:34 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] mount.nfs: freq and pass are always zero
To: linux-nfs@vger.kernel.org
Cc: kzak@redhat.com
Date: Thu, 21 Oct 2010 11:03:31 -0400
Message-ID: <20101021150331.2866.82516.stgit@ellison.1015granger.net>
In-Reply-To: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
References: <20101021145747.2866.11537.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

No need to pass constant zeros to add_mtab() from its only call site.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index b4da21f..8fb03e0 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -249,6 +249,7 @@ create_mtab (void) {
 		mnt.mnt_fsname = xstrdup(fstab->m.mnt_fsname);
 		mnt.mnt_type = fstab->m.mnt_type;
 		mnt.mnt_opts = fix_opts_string (flags, extra_opts);
+		/* these are always zero for NFS */
 		mnt.mnt_freq = mnt.mnt_passno = 0;
 		free(extra_opts);
 
@@ -273,7 +274,7 @@ create_mtab (void) {
 }
 
 static int add_mtab(char *spec, char *mount_point, char *fstype,
-			int flags, char *opts, int freq, int pass)
+			int flags, char *opts)
 {
 	struct mntent ment;
 	int result = EX_SUCCESS;
@@ -282,8 +283,8 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	ment.mnt_dir = mount_point;
 	ment.mnt_type = fstype;
 	ment.mnt_opts = fix_opts_string(flags & ~MS_NOMTAB, opts);
-	ment.mnt_freq = freq;
-	ment.mnt_passno = pass;
+	/* these are always zero for NFS */
+	ment.mnt_freq = ment.mnt_passno = 0;
 
 	if (!nomtab && mtab_does_not_exist()) {
 		if (verbose > 1)
@@ -441,9 +442,7 @@ static int try_mount(char *spec, char *mount_point, int flags,
 	if (!fake)
 		print_one(spec, mount_point, fs_type, mount_opts);
 
-	ret = add_mtab(spec, mount_point, fs_type, flags, *extra_opts,
-			0, 0 /* these are always zero for NFS */ );
-	return ret;
+	return add_mtab(spec, mount_point, fs_type, flags, *extra_opts);
 }
 
 int main(int argc, char *argv[])

