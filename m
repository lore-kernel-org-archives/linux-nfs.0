Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755233Ab2GLQo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 12:44:29 -0400
Date: Thu, 12 Jul 2012 18:44:20 +0200
From: Karel Zak <kzak@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] umount.nfs: restore correct error status when umount
 fails.
Message-ID: <20120712164420.GA15398@x2.net.home>
References: <20120712132757.7f86b86b@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120712132757.7f86b86b@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> This patch restores the use of EX_FILEIO for errors from umount.

 Looks good to me.

 Reviewed-by: Karel Zak <kzak@redhat.com>

> There is a case that I know it doesn't handle.  If you ask umount.nfs to
> unmount a filesystem that is not nfs or nfs4, then the old code will
> refuse
>   umount.nfs: /dev/sda7 on /mnt2 is not an NFS filesystem
> 
> and exit with status '1'.
> The new libmount code will just think that it couldn't find anything in
> fstab and will try to do an nfs23 unmount.  This is clearly different behaviour,
> I'm not sure that anyone would care though.

 I care, it's stupid bug to use umount.nfs for non-NFS filesytems. The
 patch below fixes this issue.

    Karel


>From 6071375b67ece8cb1a8321a55eb491d36f2fbf75 Mon Sep 17 00:00:00 2001
From: Karel Zak <kzak@redhat.com>
Date: Thu, 12 Jul 2012 18:33:43 +0200
Subject: [PATCH] umount.nfs: ignore non-nfs filesystems

 # umount.nfs /boot; echo $?
 umount.nfs: /boot: device is busy
 32

expected and fixed behavior:

 # umount.nfs /boot; echo $?
 # umount.nfs: /boot: is not an NFS filesystem
 1

Note that the function mnt_context_set_fstype_pattern() has never
been used for mtab/fstab evaluation. It's usable only for "umount -a"
and for "mount -t" operations.

Reported-by: NeilBrown <neilb@suse.de>
Signed-off-by: Karel Zak <kzak@redhat.com>
---
 utils/mount/mount_libmount.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index 5c1116a..ddf61b2 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -210,8 +210,6 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
 
 	if (mnt_context_set_target(cxt, spec))
 		goto err;
-	if (mnt_context_set_fstype_pattern(cxt, "nfs,nfs4"))	/* restrict filesystems */
-		goto err;
 
 	/* read mtab/fstab, evaluate permissions, etc. */
 	rc = mnt_context_prepare_umount(cxt);
@@ -221,6 +219,14 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
 		goto err;
 	}
 
+	if (mnt_context_get_fstype(cxt) &&
+	    !mnt_match_fstype(mnt_context_get_fstype(cxt), "nfs,nfs4")) {
+
+		nfs_error(_("%s: %s: is not an NFS filesystem"), progname, spec);
+		ret = EX_USAGE;
+		goto err;
+	}
+
 	opts = retrieve_mount_options(mnt_context_get_fs(cxt));
 
 	if (!mnt_context_is_lazy(cxt)) {
@@ -244,6 +250,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
 			/* strange, no entry in mtab or /proc not mounted */
 			nfs_umount23(spec, "tcp,v3");
 	}
+
 	ret = EX_FILEIO;
 	rc = mnt_context_do_umount(cxt);	/* call umount(2) syscall */
 	mnt_context_finalize_mount(cxt);	/* mtab update */
-- 
1.7.7.6

