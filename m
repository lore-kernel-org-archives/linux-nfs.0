Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAFn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:05:43 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:05:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] mount.nfs: Eliminate compiler warning in
	utils/mount/nfsumount.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:05:40 -0400
Message-ID: <20101011000540.6667.51299.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

nfsumount.c:374: warning: ISO C forbids omitting the middle term of a ?: expression

This is also probably harmless, but let's make the code unambiguous.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 78a2178..b1927de 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -110,7 +110,7 @@ static int del_mtab(const char *spec, const char *node)
 			res = try_remount(spec, node);
 			if (res)
 				goto writemtab;
-			return 0;
+			return EX_SUCCESS;
 		} else
 			umnt_err = errno;
 	}
@@ -128,7 +128,7 @@ static int del_mtab(const char *spec, const char *node)
 	}
 
 	if (res >= 0)
-		return 0;
+		return EX_SUCCESS;
 
 	if (umnt_err)
 		umount_error(umnt_err, node);
@@ -363,7 +363,7 @@ int nfsumount(int argc, char *argv[])
 		}
 	}
 
-	ret = 0;
+	ret = EX_SUCCESS;
 	if (mc) {
 		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
 			/* We ignore the error from nfs_umount23.
@@ -372,7 +372,7 @@ int nfsumount(int argc, char *argv[])
 			 * could cause /sbin/mount to retry!
 			 */
 			nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
-		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir) ?: ret;
+		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
 			ret = nfs_umount23(spec, "tcp,v3");

