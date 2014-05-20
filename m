Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:57645 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbaETDyh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 23:54:37 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so6669838pab.34
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 20:54:36 -0700 (PDT)
Message-ID: <537AD1E7.6080404@gmail.com>
Date: Tue, 20 May 2014 11:54:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH] mount.nfs: print more useful error message
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When mounting spec of a regular file, mount.nfs print error message as,

# mount -t nfs 127.0.0.1:/root/testfile /mnt/
mount.nfs: mount point /mnt is not a directory
# mount -t nfs 127.0.0.1:/root/testfile /mnt/testfile
mount.nfs: mount point /mnt/testfile is not a directory

This patch lets mount.nfs print more useful message,

# mount -t nfs 127.0.0.1:/root/testfile /mnt/
mount.nfs: mount spec 127.0.0.1:/root/testfile or point /mnt is not a directory
# mount -t nfs 127.0.0.1:/root/testfile /mnt/testfile
mount.nfs: mount point /mnt/testfile is not a directory

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/mount/error.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index f8fc13f..e06f598 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -215,8 +215,12 @@ void mount_error(const char *spec, const char *mount_point, int error)
 				progname);
 		break;
 	case ENOTDIR:
-		nfs_error(_("%s: mount point %s is not a directory"),
-				progname, mount_point);
+		if (spec)
+			nfs_error(_("%s: mount spec %s or point %s is not a "
+				  "directory"),	progname, spec, mount_point);
+		else
+			nfs_error(_("%s: mount point %s is not a directory"),
+				  progname, mount_point);
 		break;
 	case EBUSY:
 		nfs_error(_("%s: %s is busy or already mounted"),
-- 
1.9.0

