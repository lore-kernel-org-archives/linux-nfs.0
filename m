Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbaAFLSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 06:18:10 -0500
Date: Mon, 6 Jan 2014 12:18:05 +0100
From: Karel Zak <kzak@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Sander Klein <roedie@roedie.nl>, linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
Message-ID: <20140106111805.GF4435@x2.net.home>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
 <20131212154642.GA11521@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131212154642.GA11521@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 10:46:42AM -0500, J. Bruce Fields wrote:
> That's done by match_fsid().  Which does do a stat of the export path,
> but not of all the devices....  That's probably happening in one of the
> libblkid calls in uuid_by_path()?  I wonder if there's something wrong
> with libblkid configuration or with the way we're using it?

The blkid EVALUATE=<methods> configuration matters for UUID to
devname conversion, not vice versa. 
 
If you want to get filesystem UUID you have to ask udev (link with
libudev) or read it from the device (link with libblkid).

> > statfs("/some/export", {f_type=0x2fc12fc1, f_bsize=131072,
> > f_blocks=50331648, f_bfree=8355553, f_bavail=8355553,
> > f_files=2139121087, f_ffree=2139021753, f_fsid={1912623216,
> > 10933642}, f_namelen=255, f_frsize=131072}) = 0
> > stat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
> > lstat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
> > lstat("/some/export/..", {st_mode=S_IFDIR|0755, st_size=12288, ...}) = 0
> > stat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
> > open("/sys/dev/block/0:187", O_RDONLY)  = -1 ENOENT (No such file or
> > directory)

This is blkid_devno_to_devname(), the first attempt is /sys, but it
failed, then it tries to scan /dev (which is pretty expensive method).

BTW, what is device 0:187? 

It seems like btrfs... maybe we can  optimize the code to ignore such
devices especially when get_uuid_blkdev() filters out btrfs :-)

The another problem is poorly designed relationship between match_fsid()
and uuid_by_path().  The function uuid_by_path() is called in loop and 
blkid is *always* requested, but the blkid_val is used when type==0. 
It would be better to call get_uuid_blkdev() only when type==0.

The patch below is just untested suggestion :-)

    Karel

>From e4f5b38c87ef8d713c6d0a3169afaf1acc7e22c6 Mon Sep 17 00:00:00 2001
From: Karel Zak <kzak@redhat.com>
Date: Mon, 6 Jan 2014 12:03:01 +0100
Subject: [PATCH] mountd: optimize libblkid usage

 * use get_uuid_blkdev() only first time for the path (it means
   that uuid_by_path() is called with type==0)

 * don't use libblkid for btrfs, network or pseudo filesystems

Note that the patch defines the fs type ID rather than include
<linux/magic.h> as this file seems incomplete and libc specific).

Signed-off-by: Karel Zak <kzak@redhat.com>
---
 utils/mountd/cache.c | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index e04b86e..73c0be6 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -266,6 +266,26 @@ static int get_uuid(const char *val, size_t uuidlen, char *u)
 	return 1;
 }
 
+
+/*
+ * Don't ask libblkid for these filesystems. Note that BTRF is ignored, because
+ * we generate the identifier from statfs->f_fsid. The rest are network or
+ * pseudo filesystems. (See <linux/magic.h> for the basic IDs.)
+ */
+static const long int nonblkid_filesystems[] = {
+	0x9123683E,	/* BTRFS_SUPER_MAGIC */
+	0xFF534D42,	/* CIFS_MAGIC_NUMBER */
+	0x1373,		/* DEVFS_SUPER_MAGIC */
+	0x73757245,	/* CODA_SUPER_MAGIC */
+	0x564C,		/* NCP_SUPER_MAGIC */
+	0x6969,		/* NFS_SUPER_MAGIC */
+	0x9FA0,		/* PROC_SUPER_MAGIC */
+	0x62656572,	/* SYSFS_MAGIC */
+	0x517B,		/* SMB_SUPER_MAGIC */
+	0x01021994,	/* TMPFS_SUPER_MAGIC */
+	0		/* last */
+};
+
 static int uuid_by_path(char *path, int type, size_t uuidlen, char *uuid)
 {
 	/* get a uuid for the filesystem found at 'path'.
@@ -297,12 +317,24 @@ static int uuid_by_path(char *path, int type, size_t uuidlen, char *uuid)
 	 */
 	struct statfs64 st;
 	char fsid_val[17];
-	const char *blkid_val;
+	const char *blkid_val = NULL;
 	const char *val;
+	int rc;
 
-	blkid_val = get_uuid_blkdev(path);
+	rc = statfs64(path, &st);
+
+	if (type == 0 && rc == 0) {
+		const long int *bad;
+
+		for (bad = nonblkid_filesystems; *bad; bad++) {
+			if (*bad == st.f_type)
+				break;
+		}
+		if (*bad == 0)
+			blkid_val = get_uuid_blkdev(path);
+	}
 
-	if (statfs64(path, &st) == 0 &&
+	if (rc == 0 &&
 	    (st.f_fsid.__val[0] || st.f_fsid.__val[1]))
 		snprintf(fsid_val, 17, "%08x%08x",
 			 st.f_fsid.__val[0], st.f_fsid.__val[1]);
-- 
1.8.4.2

