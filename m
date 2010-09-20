Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50761 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab0ITQch (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:32:37 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so1361234gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:32:37 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] mountd: Make NFS version checks more strict
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:32:34 -0400
Message-ID: <20100920163234.3170.57979.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ensure users and programmers specify NFS version numbers correctly.
This also makes the next patch more clean.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |   47 +++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 982b06e..753fd37 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -71,16 +71,34 @@ static struct option longopts[] =
 	{ NULL, 0, 0, 0 }
 };
 
-static int nfs_version = -1;
+#define NFSVERSBIT(vers)	(0x1 << (vers - 1))
+#define NFSVERSBIT_ALL		(NFSVERSBIT(2) | NFSVERSBIT(3) | NFSVERSBIT(4))
+
+static int nfs_version = NFSVERSBIT_ALL;
+
+static int version2(void)
+{
+	return nfs_version & NFSVERSBIT(2);
+}
+
+static int version3(void)
+{
+	return nfs_version & NFSVERSBIT(3);
+}
+
+static int version_any(void)
+{
+	return nfs_version & NFSVERSBIT_ALL;
+}
 
 static void
 unregister_services (void)
 {
-	if (nfs_version & (0x1 << 1)) {
+	if (version2()) {
 		pmap_unset (MOUNTPROG, MOUNTVERS);
 		pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
 	}
-	if (nfs_version & (0x1 << 2))
+	if (version3())
 		pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
 }
 
@@ -673,6 +691,7 @@ main(int argc, char **argv)
 	int	port = 0;
 	int	descriptors = 0;
 	int	c;
+	int	vers;
 	struct sigaction sa;
 	struct rlimit rlim;
 
@@ -716,7 +735,13 @@ main(int argc, char **argv)
 			}
 			break;
 		case 'N':
-			nfs_version &= ~(1 << (atoi (optarg) - 1));
+			vers = atoi(optarg);
+			if (vers < 2 || vers > 4) {
+				fprintf(stderr, "%s: bad version number: %s\n",
+					argv[0], optarg);
+				usage(argv[0], 1);
+			}
+			nfs_version &= ~NFSVERSBIT(vers);
 			break;
 		case 'n':
 			_rpcfdtype = SOCK_DGRAM;
@@ -735,7 +760,13 @@ main(int argc, char **argv)
 			num_threads = atoi (optarg);
 			break;
 		case 'V':
-			nfs_version |= 1 << (atoi (optarg) - 1);
+			vers = atoi(optarg);
+			if (vers < 2 || vers > 4) {
+				fprintf(stderr, "%s: bad version number: %s\n",
+					argv[0], optarg);
+				usage(argv[0], 1);
+			}
+			nfs_version |= NFSVERSBIT(vers);
 			break;
 		case 'v':
 			printf("kmountd %s\n", VERSION);
@@ -750,7 +781,7 @@ main(int argc, char **argv)
 	/* No more arguments allowed.
 	 * Require at least one valid version (2, 3, or 4)
 	 */
-	if (optind != argc || !(nfs_version & 0xE))
+	if (optind != argc || !version_any())
 		usage(argv [0], 1);
 
 	if (chdir(state_dir)) {
@@ -798,13 +829,13 @@ main(int argc, char **argv)
 	if (new_cache)
 		cache_open();
 
-	if (nfs_version & (0x1 << 1)) {
+	if (version2()) {
 		rpc_init("mountd", MOUNTPROG, MOUNTVERS,
 			 mount_dispatch, port);
 		rpc_init("mountd", MOUNTPROG, MOUNTVERS_POSIX,
 			 mount_dispatch, port);
 	}
-	if (nfs_version & (0x1 << 2))
+	if (version3())
 		rpc_init("mountd", MOUNTPROG, MOUNTVERS_NFSV3,
 			 mount_dispatch, port);
 

