From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 3/3] nfs-utils: don't fdatasync the rmtab
Date: Thu, 28 Jan 2010 15:26:39 -0600
Message-ID: <20100128212639.29681.81589.stgit@case.americas.sgi.com>
References: <20100128211454.29681.24752.stgit@case.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: SteveD@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:45025 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932161Ab0A1V0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 16:26:40 -0500
In-Reply-To: <20100128211454.29681.24752.stgit-PhfrMOq4MEUPybYDWDrblq0bRtRcJeJQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're using the new caching interface the rmtab will be ignored by exportfs
so there is no need to fdatasync.  This improves mountd performance.
---
 support/nfs/cacheio.c |    5 ++---
 support/nfs/rmtab.c   |   23 ++++++++++++++++++-----
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 6a6ed5a..bdf5d84 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -285,9 +285,8 @@ int readline(int fd, char **buf, int *lenp)
 int
 check_new_cache(void)
 {
-	struct stat stb;
-	return	(stat("/proc/fs/nfs/filehandle", &stb) == 0) ||
-		(stat("/proc/fs/nfsd/filehandle", &stb) == 0);
+	return	(access("/proc/fs/nfs/filehandle", F_OK) == 0) ||
+		(access("/proc/fs/nfsd/filehandle", F_OK) == 0);
 }	
 
 
diff --git a/support/nfs/rmtab.c b/support/nfs/rmtab.c
index 4cbd285..a28abf3 100644
--- a/support/nfs/rmtab.c
+++ b/support/nfs/rmtab.c
@@ -117,11 +117,24 @@ void
 fendrmtabent(FILE *fp)
 {
 	if (fp) {
-		/* If it was written to, we really want
-		 * to flush to disk before returning
-		 */
-		fflush(fp);
-		fdatasync(fileno(fp));
+		static int have_new_cache = -1;
+		if (have_new_cache == -1) /* check only once */
+			have_new_cache = check_new_cache();
+
+		if (!have_new_cache) {
+			/*
+			 * If we are using the old caching interface: exportfs
+			 * uses the rmtab to determine what should be exported,
+			 * so it is important that it be up-to-date.
+			 *
+			 * If we are using the new caching interface: the rmtab
+			 * is ignored by exportfs and the fdatasync only serves
+			 * to slow us down.
+			 */
+			fflush(fp);
+			fdatasync(fileno(fp));
+		}
+
 		fclose(fp);
 	}
 }

