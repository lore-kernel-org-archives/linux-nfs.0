From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/31] mount.nfs: Use correct data type in
	discover_nfs_mount_data_version()
Date: Mon, 29 Jun 2009 13:38:35 -0400
Message-ID: <20090629173835.2076.57628.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:25913 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835AbZF2RkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:06 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warning:

    mount.c: In function =E2=80=98discover_nfs_mount_data_version=E2=80=
=99:
    mount.c:162: warning: comparison between signed and unsigned
    mount.c:164: warning: comparison between signed and unsigned
    mount.c:166: warning: comparison between signed and unsigned
    mount.c:168: warning: comparison between signed and unsigned
    mount.c:170: warning: comparison between signed and unsigned
    mount.c:178: warning: comparison between signed and unsigned

linux_version_code() and MAKE_VERSION() both return an unsigned int.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 06e2804..d531d64 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -156,7 +156,7 @@ static void parse_opts(const char *options, int *fl=
ags, char **extra_opts);
  */
 static void discover_nfs_mount_data_version(void)
 {
-	int kernel_version =3D linux_version_code();
+	unsigned int kernel_version =3D linux_version_code();
=20
 	if (kernel_version) {
 		if (kernel_version < MAKE_VERSION(2, 1, 32))

