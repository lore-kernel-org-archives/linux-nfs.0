From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/31] mount.nfs: Remove unused parameter in try_mount()
Date: Mon, 29 Jun 2009 13:38:45 -0400
Message-ID: <20090629173844.2076.74807.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39642 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756811AbZF2RkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:06 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warning:

    mount.c: At top level:
    mount.c:420: warning: unused parameter =E2=80=98nomtab=E2=80=99

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index d531d64..a668cd9 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -417,7 +417,7 @@ static int chk_mountpoint(char *mount_point)
=20
 static int try_mount(char *spec, char *mount_point, int flags,
 			char *fs_type, char **extra_opts, char *mount_opts,
-			int fake, int nomtab, int bg)
+			int fake, int bg)
 {
 	int ret;
=20
@@ -582,7 +582,7 @@ int main(int argc, char *argv[])
 	}
=20
 	mnt_err =3D try_mount(spec, mount_point, flags, fs_type, &extra_opts,
-				mount_opts, fake, nomtab, FOREGROUND);
+				mount_opts, fake, FOREGROUND);
 	if (mnt_err =3D=3D EX_BG) {
 		printf(_("%s: backgrounding \"%s\"\n"),
 			progname, spec);
@@ -600,7 +600,7 @@ int main(int argc, char *argv[])
=20
 		mnt_err =3D try_mount(spec, mount_point, flags, fs_type,
 					&extra_opts, mount_opts, fake,
-					nomtab, BACKGROUND);
+					BACKGROUND);
 		if (verbose && mnt_err)
 			printf(_("%s: giving up \"%s\"\n"),
 				progname, spec);

