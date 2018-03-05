Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34198 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751462AbeCEPyX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Mar 2018 10:54:23 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1D14022B69
        for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2018 15:54:23 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-53.phx2.redhat.com [10.3.116.53])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C5E5260C89
        for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2018 15:54:22 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Removed -Werror=unused-result warnings.
Date: Mon,  5 Mar 2018 10:54:20 -0500
Message-Id: <20180305155420.104418-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/nfs_mntent.c         | 3 ++-
 utils/blkmapd/device-discovery.c | 6 ++++--
 utils/mount/network.c            | 8 ++++++--
 utils/nfsd/nfssvc.c              | 5 +++--
 utils/statd/statd.c              | 3 ++-
 5 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
index a2118a2..c60988a 100644
--- a/support/nfs/nfs_mntent.c
+++ b/support/nfs/nfs_mntent.c
@@ -150,7 +150,8 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
 		res = fflush(mfp->mntent_fp);
 		if (res < 0)
 			/* Avoid leaving a corrupt mtab file */
-			ftruncate(fileno(mfp->mntent_fp), length);
+			if (ftruncate(fileno(mfp->mntent_fp), length))
+				{/* ignore return value */};
 	}
 	return (res < 0) ? 1 : 0;
 }
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index b71c949..1afc80f 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -504,9 +504,11 @@ int main(int argc, char **argv)
 			close(pidfd);
 			exit(1);
 		}
-		ftruncate(pidfd, 0);
+		if (ftruncate(pidfd, 0) < 0)
+			BL_LOG_WARNING("ftruncate on %s failed: m\n", PID_FILE);
 		sprintf(pidbuf, "%d\n", getpid());
-		write(pidfd, pidbuf, strlen(pidbuf));
+		if (write(pidfd, pidbuf, strlen(pidbuf)) != (ssize_t)strlen(pidbuf))
+			BL_LOG_WARNING("write on %s failed: m\n", PID_FILE);
 	}
 
 	signal(SIGINT, sig_die);
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8d6e4c6..9a2c878 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -811,8 +811,12 @@ int start_statd(void)
 			switch (pid) {
 			case 0: /* child */
 				setgroups(0, NULL);
-				setgid(0);
-				setuid(0);
+				if (setgid(0) < 0)
+					nfs_error(_("%s: setgid(0) failed: %s"),
+						progname, strerror(errno));
+				if (setuid(0) < 0)
+					nfs_error(_("%s: setuid(0) failed: %s"),
+						progname, strerror(errno));
 				execle(START_STATD, START_STATD, NULL, envp);
 				exit(1);
 			case -1: /* error */
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index fc36792..7923f5d 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -68,7 +68,7 @@ nfssvc_mount_nfsdfs(char *progname)
 	 * mount nfsdfs when nfsd.ko is plugged in. So, ignore the return
 	 * code from it and just check for the "threads" file afterward.
 	 */
-	system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
+	err = system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
 
 	err = stat(NFSD_THREAD_FILE, &statbuf);
 	if (err == 0)
@@ -325,7 +325,8 @@ nfssvc_set_time(const char *type, const int seconds)
 		/* set same value for lockd */
 		fd = open("/proc/sys/fs/nfs/nlm_grace_period", O_WRONLY);
 		if (fd >= 0) {
-			write(fd, nbuf, strlen(nbuf));
+			if (write(fd, nbuf, strlen(nbuf)) != (ssize_t)strlen(nbuf))
+				xlog(L_ERROR, "Unable to write nlm_grace_period : %m");
 			close(fd);
 		}
 	}
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 197d853..563a272 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -225,7 +225,8 @@ static void set_nlm_port(char *type, int port)
 	fd = open(pathbuf, O_WRONLY);
 	if (fd < 0 && errno == ENOENT) {
 		/* probably module not loaded */
-		system("modprobe lockd");
+		if (system("modprobe lockd"))
+			{/* ignore return value */};
 		fd = open(pathbuf, O_WRONLY);
 	}
 	if (fd >= 0) {
-- 
2.14.3

