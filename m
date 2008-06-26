From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFS: set transport defaults after mount option parsing is
	finished
Date: Thu, 26 Jun 2008 17:46:57 -0400
Message-ID: <20080626214656.3129.40838.stgit@ellison.1015granger.net>
References: <20080626214451.3129.85650.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23344 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbYFZVre (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 17:47:34 -0400
In-Reply-To: <20080626214451.3129.85650.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address some unfortunate mount option parsing behavior by setting certain
transport-based defaults *after* option parsing is complete.

 o  Some options don't obey the "rightmost wins" rule.  Jeff Layton
    noticed that specifying the "proto=" mount option after the "retrans"
    or "timeo" options will cause the retrans and timeo values to be
    overwritten with default settings.

    Allow these options to be specified in any order without unexpectedly
    reverting retrans and timeo to their default.

 o  I've received several reports that text-based mounting through
    firewalls that block UDP fails, even if "proto=tcp" is specified.

    If a user specifies "proto=tcp" via the legacy mount API, the mount
    command also uses TCP to contact the server's mount daemon.  Ditto
    for "proto=udp".  We want the kernel's mount option to emulate this
    behavior; however, we still want the default mount protocol to be UDP
    if no transport options were specified.

Since remounts don't allow switching transports, this new logic is not
appropriate for the remount path; and if invoked in that path would cause
transport-related settings to revert to their defaults.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c         |   61 +++++++++++++++++++++++++++++++++---------------
 include/linux/nfs_fs.h |    5 ++++
 2 files changed, 47 insertions(+), 19 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 73a8e59..396a12e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -817,6 +817,44 @@ static void nfs_parse_ip_address(char *string, size_t str_len,
 }
 
 /*
+ * Time-out and mount transport default settings are based on the
+ * specified NFS transport.  For legacy mounts, these are set by
+ * the mount command before mount(2) is invoked.  For text-based
+ * mounts, the kernel must take care to set these.
+ */
+static void nfs_set_transport_defaults(struct nfs_parsed_mount_data *mnt)
+{
+	switch (mnt->nfs_server.protocol) {
+	case XPRT_TRANSPORT_UDP:
+		if (mnt->mount_server.protocol == 0)
+			mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
+		if (mnt->timeo == 0)
+			mnt->timeo = NFS_DEF_UDP_TIMEO;
+		if (mnt->retrans == 0)
+			mnt->retrans = NFS_DEF_UDP_RETRANS;
+		break;
+	case XPRT_TRANSPORT_TCP:
+	case XPRT_TRANSPORT_RDMA:
+		if (mnt->mount_server.protocol == 0)
+			mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
+		if (mnt->timeo == 0)
+			mnt->timeo = NFS_DEF_TCP_TIMEO;
+		if (mnt->retrans == 0)
+			mnt->retrans = NFS_DEF_TCP_RETRANS;
+		break;
+	default:
+		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+		if (mnt->mount_server.protocol == 0)
+			mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
+		if (mnt->timeo == 0)
+			mnt->timeo = NFS_DEF_TCP_TIMEO;
+		if (mnt->retrans == 0)
+			mnt->retrans = NFS_DEF_TCP_RETRANS;
+		break;
+	}
+}
+
+/*
  * Error-check and convert a string of mount options from user space into
  * a data structure
  */
@@ -896,20 +934,14 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-			mnt->timeo = 7;
-			mnt->retrans = 5;
 			break;
 		case Opt_tcp:
 			mnt->flags |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-			mnt->timeo = 600;
-			mnt->retrans = 2;
 			break;
 		case Opt_rdma:
 			mnt->flags |= NFS_MOUNT_TCP; /* for side protocols */
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-			mnt->timeo = 600;
-			mnt->retrans = 2;
 			break;
 		case Opt_acl:
 			mnt->flags &= ~NFS_MOUNT_NOACL;
@@ -1103,21 +1135,15 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-				mnt->timeo = 7;
-				mnt->retrans = 5;
 				break;
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-				mnt->timeo = 600;
-				mnt->retrans = 2;
 				break;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-				mnt->timeo = 600;
-				mnt->retrans = 2;
 				break;
 			default:
 				goto out_unrec_xprt;
@@ -1438,16 +1464,12 @@ static int nfs_validate_mount_data(void *options,
 	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
-	args->timeo		= 600;
-	args->retrans		= 2;
 	args->acregmin		= 3;
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
 	args->mount_server.port	= 0;	/* autobind unless user sets port */
-	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
 	args->nfs_server.port	= 0;	/* autobind unless user sets port */
-	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
 	case 1:
@@ -1546,6 +1568,8 @@ static int nfs_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
+		nfs_set_transport_defaults(args);
+
 		status = nfs_parse_devname(dev_name,
 					   &args->nfs_server.hostname,
 					   PAGE_SIZE,
@@ -2095,14 +2119,11 @@ static int nfs4_validate_mount_data(void *options,
 
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
-	args->timeo		= 600;
-	args->retrans		= 2;
 	args->acregmin		= 3;
 	args->acregmax		= 60;
 	args->acdirmin		= 30;
 	args->acdirmax		= 60;
 	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
-	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 
 	switch (data->version) {
 	case 1:
@@ -2175,6 +2196,8 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			return -EINVAL;
 
+		nfs_set_transport_defaults(args);
+
 		switch (args->auth_flavor_len) {
 		case 0:
 			args->auth_flavors[0] = RPC_AUTH_UNIX;
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
 

