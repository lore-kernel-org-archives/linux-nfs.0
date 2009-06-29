From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 31/31] mount.nfs: Squelch compiler warnings in nfs_strerror()
Date: Mon, 29 Jun 2009 13:39:51 -0400
Message-ID: <20090629173950.2076.12289.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51709 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757111AbZF2RkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:11 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warnings:

    error.c: In function =E2=80=98nfs_strerror=E2=80=99:
    error.c:341: warning: comparison between signed and unsigned
    error.c:342: warning: comparison between signed and unsigned

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c |   12 ++++++------
 utils/mount/error.h |    2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 5c9d3f2..4cc9e09 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -300,6 +300,8 @@ void umount_error(int err, const char *dev)
 #define EDQUOT	ENOSPC
 #endif
=20
+#define ARRAY_SIZE(x)		(sizeof(x) / sizeof((x)[0]))=20
+
 static struct {
 	enum nfsstat stat;
 	int errnum;
@@ -329,19 +331,17 @@ static struct {
 #endif
 	/* Throw in some NFSv3 values for even more fun (HP returns these) */
 	{ 71,			EREMOTE		},
-
-	{ -1,			EIO		}
 };
=20
-char *nfs_strerror(int stat)
+char *nfs_strerror(unsigned int stat)
 {
-	int i;
+	unsigned int i;
 	static char buf[256];
=20
-	for (i =3D 0; nfs_errtbl[i].stat !=3D -1; i++) {
+	for (i =3D 0; i < ARRAY_SIZE(nfs_errtbl); i++) {
 		if (nfs_errtbl[i].stat =3D=3D stat)
 			return strerror(nfs_errtbl[i].errnum);
 	}
-	sprintf(buf, _("unknown nfs status return value: %d"), stat);
+	sprintf(buf, _("unknown nfs status return value: %u"), stat);
 	return buf;
 }
diff --git a/utils/mount/error.h b/utils/mount/error.h
index 7126de5..42b28cf 100644
--- a/utils/mount/error.h
+++ b/utils/mount/error.h
@@ -24,7 +24,7 @@
 #ifndef _NFS_UTILS_MOUNT_ERROR_H
 #define _NFS_UTILS_MOUNT_ERROR_H
=20
-char *nfs_strerror(int);
+char *nfs_strerror(unsigned int);
=20
 void mount_error(const char *, const char *, int);
 void rpc_mount_errors(char *, int, int);

