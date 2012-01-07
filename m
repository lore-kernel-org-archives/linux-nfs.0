Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:44504 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab2AGJMP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2012 04:12:15 -0500
From: Sasha Levin <levinsasha928@gmail.com>
To: chuck.lever@oracle.com, linux@razik.name, Trond.Myklebust@netapp.com
Cc: penberg@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] nfs: Don't try mounting device as nfs root unless type fully matches
Date: Sat,  7 Jan 2012 11:12:03 +0200
Message-Id: <1325927523-30103-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we'll try mounting any device who's major device number is
UNNAMED_MAJOR as NFS root. This would happen for non-NFS devices as well (such
as 9p devices) but it wouldn't cause any issues since mounting the device
as NFS would fail quickly and the code proceeded to doing the proper mount:

	[  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
	[  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.

Commit 6829a048 ("NFS: Retry mounting NFSROOT") has introduced retries when
mounting NFS root, which means that now we don't immediately fail and instead
it takes an additional 90+ seconds until we stop retrying.

This meant that it would take an additional 90 seconds to boot when we're not
using a device type which gets detected in order before NFS.

This patch modifies the NFS type check to require device type to be
'Root_NFS' instead of requiring the device to have an UNNAMED_MAJOR major.
This makes boot process cleaner since we now won't go through the NFS mounting
code at all when the device isn't an NFS root ("/dev/nfs").

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 init/do_mounts.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/init/do_mounts.c b/init/do_mounts.c
index 06225d2..da76f2c 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -475,7 +475,7 @@ void __init change_floppy(char *fmt, ...)
 void __init mount_root(void)
 {
 #ifdef CONFIG_ROOT_NFS
-	if (MAJOR(ROOT_DEV) == UNNAMED_MAJOR) {
+	if (ROOT_DEV == Root_NFS) {
 		if (mount_nfs_root())
 			return;
 
-- 
1.7.8.2

