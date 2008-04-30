From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 4/6] NFS: Fix "retrans" and "timeo" mount option behavior
Date: Wed, 30 Apr 2008 12:00:03 -0400
Message-ID: <20080430160003.32402.85844.stgit@manray.1015granger.net>
References: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:59334 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758713AbYD3QAH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 12:00:07 -0400
Received: by an-out-0708.google.com with SMTP id d40so120817and.103
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 09:00:06 -0700 (PDT)
In-Reply-To: <20080430154011.32402.42101.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton noticed that specifying the "proto=" mount option after the
"retrans" or "timeo" options will cause the retrans and timeo values to
be overwritten with default settings.

Allow these options to be specified in any order without unexpectedly
reverting retrans and timeo to their default.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c         |   64 +++++++++++++++++++++++++++++++++++-------------
 include/linux/nfs_fs.h |    5 ++++
 2 files changed, 51 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cfe8d4c..1f3fa91 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -739,11 +739,16 @@ static void nfs_parse_server_address(char *value,
 /*
  * Error-check and convert a string of mount options from user space into
  * a data structure
+ *
+ * Note that callers can pre-initialize @mnt with default settings.  Take
+ * care not to overwrite fields (and thus wipe out the default setting)
+ * unless there is actually a specified mount option.
  */
 static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
+	int timeo = 0, retrans = 0;
 	int rc;
 
 	if (!raw) {
@@ -816,20 +821,26 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-			mnt->timeo = 7;
-			mnt->retrans = 5;
+			if (timeo == 0)
+				timeo = NFS_DEF_UDP_TIMEO;
+			if (retrans == 0)
+				retrans = NFS_DEF_UDP_RETRANS;
 			break;
 		case Opt_tcp:
 			mnt->flags |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-			mnt->timeo = 600;
-			mnt->retrans = 2;
+			if (timeo == 0)
+				timeo = NFS_DEF_TCP_TIMEO;
+			if (retrans == 0)
+				retrans = NFS_DEF_TCP_RETRANS;
 			break;
 		case Opt_rdma:
 			mnt->flags |= NFS_MOUNT_TCP; /* for side protocols */
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-			mnt->timeo = 600;
-			mnt->retrans = 2;
+			if (timeo == 0)
+				timeo = NFS_DEF_TCP_TIMEO;
+			if (retrans == 0)
+				retrans = NFS_DEF_TCP_RETRANS;
 			break;
 		case Opt_acl:
 			mnt->flags &= ~NFS_MOUNT_NOACL;
@@ -873,12 +884,18 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->bsize = option;
 			break;
 		case Opt_timeo:
-			if (match_int(args, &mnt->timeo))
+			if (match_int(args, &option))
+				return 0;
+			if (option <= 0)
 				return 0;
+			timeo = option;
 			break;
 		case Opt_retrans:
-			if (match_int(args, &mnt->retrans))
+			if (match_int(args, &option))
+				return 0;
+			if (option <= 0)
 				return 0;
+			retrans = option;
 			break;
 		case Opt_acregmin:
 			if (match_int(args, &mnt->acregmin))
@@ -1023,21 +1040,27 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-				mnt->timeo = 7;
-				mnt->retrans = 5;
+				if (timeo == 0)
+					timeo = NFS_DEF_UDP_TIMEO;
+				if (retrans == 0)
+					retrans = NFS_DEF_UDP_RETRANS;
 				break;
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-				mnt->timeo = 600;
-				mnt->retrans = 2;
+				if (timeo == 0)
+					timeo = NFS_DEF_TCP_TIMEO;
+				if (retrans == 0)
+					retrans = NFS_DEF_TCP_RETRANS;
 				break;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-				mnt->timeo = 600;
-				mnt->retrans = 2;
+				if (timeo == 0)
+					timeo = NFS_DEF_TCP_TIMEO;
+				if (retrans == 0)
+					retrans = NFS_DEF_TCP_RETRANS;
 				break;
 			default:
 				goto out_unrec_xprt;
@@ -1109,6 +1132,11 @@ static int nfs_parse_mount_options(char *raw,
 	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address,
 				mnt->nfs_server.port);
 
+	if (timeo != 0)
+		mnt->timeo = timeo;
+	if (retrans != 0)
+		mnt->retrans = retrans;
+
 	return 1;
 
 out_nomem:
@@ -1222,8 +1250,8 @@ static int nfs_validate_mount_data(void *options,
 	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
-	args->timeo		= 600;
-	args->retrans		= 2;
+	args->timeo		= NFS_DEF_TCP_TIMEO;
+	args->retrans		= NFS_DEF_TCP_RETRANS;
 	args->acregmin		= 3;
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
@@ -1791,8 +1819,8 @@ static int nfs4_validate_mount_data(void *options,
 
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
-	args->timeo		= 600;
-	args->retrans		= 2;
+	args->timeo		= NFS_DEF_TCP_TIMEO;
+	args->retrans		= NFS_DEF_TCP_RETRANS;
 	args->acregmin		= 3;
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 27d6a8d..afc3956 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -12,6 +12,11 @@
 #include <linux/magic.h>
 
 /* Default timeout values */
+#define NFS_DEF_UDP_TIMEO	(7)
+#define NFS_DEF_UDP_RETRANS	(5)
+#define NFS_DEF_TCP_TIMEO	(600)
+#define NFS_DEF_TCP_RETRANS	(2)
+
 #define NFS_MAX_UDP_TIMEOUT	(60*HZ)
 #define NFS_MAX_TCP_TIMEOUT	(600*HZ)
 

