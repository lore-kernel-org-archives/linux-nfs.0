Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952Ab3EPP45 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 May 2013 11:56:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 05/13] NFSv4.2: Added NFS v4.2 support to the NFS client
Date: Thu, 16 May 2013 11:56:40 -0400
Message-Id: <1368719808-14584-6-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This enable NFSv4.2 support. To enable this code the
CONFIG_NFS_V4_2 Kconfig define needs to be set and
the -o v4.2 mount option need to be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/Kconfig        |  9 +++++++++
 fs/nfs/callback.c     |  1 +
 fs/nfs/callback_xdr.c |  6 +++---
 fs/nfs/nfs4client.c   |  5 +++++
 fs/nfs/nfs4proc.c     | 15 +++++++++++++++
 fs/nfs/super.c        |  7 ++++++-
 include/linux/nfs4.h  |  4 ++++
 7 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 13ca196..79c500e 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -104,6 +104,15 @@ config NFS_V4_1
 
 	  If unsure, say N.
 
+config NFS_V4_2
+	bool "NFS client support for NFSv4.2"
+	depends on NFS_V4_1
+	help
+	  This option enables support for minor version 1 of the NFSv4 protocol
+	  in the kernel's NFS client.
+
+	  If unsure, say N.
+
 config PNFS_FILE_LAYOUT
 	tristate
 	depends on NFS_V4_1
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index cff089a..78e368d 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -282,6 +282,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
 			ret = nfs4_callback_up_net(serv, net);
 			break;
 		case 1:
+		case 2:
 			ret = nfs41_callback_up_net(serv, net);
 			break;
 		default:
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 59461c9..e7ee629 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -166,9 +166,9 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	hdr->minorversion = ntohl(*p++);
-	/* Check minor version is zero or one. */
-	if (hdr->minorversion <= 1) {
-		hdr->cb_ident = ntohl(*p++); /* ignored by v4.1 */
+	/* Check minor version is zero or one or two. */
+	if (hdr->minorversion <= 2) {
+		hdr->cb_ident = ntohl(*p++); /* ignored by v4.1 and v4.2 */
 	} else {
 		pr_warn_ratelimited("NFS: %s: NFSv4 server callback with "
 			"illegal minor version %u!\n",
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 947b0c9..3332cc0 100644
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
index 8fbc100..abf46f4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7004,11 +7004,26 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
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
index c1bbb53..2e94f21 100644
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
@@ -1097,6 +1098,10 @@ static int nfs_parse_version_string(char *string,
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
index 7764aca..4204600 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -399,11 +399,15 @@ enum lock_type4 {
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
1.8.1.4

