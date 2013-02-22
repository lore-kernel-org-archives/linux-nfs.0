Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757765Ab3BVRJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 12:09:45 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFSv4.2: Added NFS v4.2 support to the NFS client
Date: Fri, 22 Feb 2013 12:09:40 -0500
Message-Id: <1361552981-29385-2-git-send-email-steved@redhat.com>
In-Reply-To: <1361552981-29385-1-git-send-email-steved@redhat.com>
References: <1361552981-29385-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This enable NFSv4.2 support. To enable this code the
CONFIG_NFS_V4_2 Kconfig define needs to be set and
the -o v4.2 mount option need to be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/Kconfig       | 33 +++++++++++++++++++--------------
 fs/nfs/callback.c    |  1 +
 fs/nfs/nfs4client.c  |  5 +++++
 fs/nfs/nfs4proc.c    | 15 +++++++++++++++
 fs/nfs/super.c       |  7 ++++++-
 include/linux/nfs4.h |  4 ++++
 6 files changed, 50 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 3861a1f..ec33289 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -104,6 +104,23 @@ config NFS_V4_1
 
 	  If unsure, say N.
 
+config NFS_V4_2
+	bool "NFS client support for NFSv4.2"
+	depends on NFS_V4_1
+	help
+	  This option enables support for minor version 2 of the NFSv4 protocol
+	  in the kernel's NFS client.
+
+	  Say Y here if you want enable fine-grained security label attribute
+	  support for NFS version 4.  Security labels allow security modules like
+	  SELinux and Smack to label files to facilitate enforcement of their policies.
+	  Without this an NFSv4 mount will have the same label on each file.
+
+	  WARNING: there is still a chance of backwards-incompatible protocol changes.  
+	  For now we recommend "Y" only for developers and testers."
+
+	  If unsure, say N.
+
 config PNFS_FILE_LAYOUT
 	tristate
 	depends on NFS_V4_1
@@ -133,21 +150,9 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 
 config NFS_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 client"
-	depends on NFS_V4 && SECURITY
-	help
-
-	Say Y here if you want enable fine-grained security label attribute
-	support for NFS version 4.  Security labels allow security modules like
-	SELinux and Smack to label files to facilitate enforcement of their policies.
-	Without this an NFSv4 mount will have the same label on each file.
-
-	If you do not wish to enable fine-grained security labels SELinux or
-	Smack policies on NFSv4 files, say N.
-
-	WARNING: there is still a chance of backwards-incompatible protocol changes.  
-	For now we recommend "Y" only for developers and testers."
+	depends on NFS_V4_2 && SECURITY
+	default y
 
-	If unsure, say N.
 
 config ROOT_NFS
 	bool "Root file system on NFS"
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 5088b57..cb35747 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -279,6 +279,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
 			ret = nfs4_callback_up_net(serv, net);
 			break;
 		case 1:
+		case 2:
 			ret = nfs41_callback_up_net(serv, net);
 			break;
 		default:
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2e9779b..2987fd6 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -66,6 +66,11 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	if (err)
 		goto error;
 
+	if (cl_init->minorversion > NFS4_MAX_MINOR_VERSION) {
+		err = -EINVAL;
+		goto error;
+	}
+		
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 30b3e44..826c48d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7131,11 +7131,26 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 };
 #endif
 
+#if defined(CONFIG_NFS_V4_2)
+static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
+	.minor_version = 2,
+	.call_sync = nfs4_call_sync_sequence,
+	.match_stateid = nfs41_match_stateid,
+	.find_root_sec = nfs41_find_root_sec,
+	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
+	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
+	.state_renewal_ops = &nfs41_state_renewal_ops,
+};
+#endif
+
 const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
 	[0] = &nfs_v4_0_minor_ops,
 #if defined(CONFIG_NFS_V4_1)
 	[1] = &nfs_v4_1_minor_ops,
 #endif
+#if defined(CONFIG_NFS_V4_2)
+	[2] = &nfs_v4_2_minor_ops,
+#endif
 };
 
 const struct inode_operations nfs4_dir_inode_operations = {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4e78f93..d35582c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -269,7 +269,7 @@ static match_table_t nfs_local_lock_tokens = {
 
 enum {
 	Opt_vers_2, Opt_vers_3, Opt_vers_4, Opt_vers_4_0,
-	Opt_vers_4_1,
+	Opt_vers_4_1, Opt_vers_4_2,
 
 	Opt_vers_err
 };
@@ -280,6 +280,7 @@ static match_table_t nfs_vers_tokens = {
 	{ Opt_vers_4, "4" },
 	{ Opt_vers_4_0, "4.0" },
 	{ Opt_vers_4_1, "4.1" },
+	{ Opt_vers_4_2, "4.2" },
 
 	{ Opt_vers_err, NULL }
 };
@@ -1143,6 +1144,10 @@ static int nfs_parse_version_string(char *string,
 		mnt->version = 4;
 		mnt->minorversion = 1;
 		break;
+	case Opt_vers_4_2:
+		mnt->version = 4;
+		mnt->minorversion = 2;
+		break;
 	default:
 		return 0;
 	}
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index aab8bd8..e9c040a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -394,11 +394,15 @@ enum lock_type4 {
 #define NFS4_VERSION 4
 #define NFS4_MINOR_VERSION 0
 
+#if defined(CONFIG_NFS_V4_2)
+#define NFS4_MAX_MINOR_VERSION 2
+#else
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MINOR_VERSION 1
 #else
 #define NFS4_MAX_MINOR_VERSION 0
 #endif /* CONFIG_NFS_V4_1 */
+#endif /* CONFIG_NFS_V4_2 */
 
 #define NFS4_DEBUG 1
 
-- 
1.8.1.2

