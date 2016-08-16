Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36852 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbcHPPS7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2016 11:18:59 -0400
Received: by mail-io0-f195.google.com with SMTP id y34so7871262ioi.3
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2016 08:18:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Allow the mount option retrans=0
Date: Tue, 16 Aug 2016 11:18:22 -0400
Message-Id: <1471360703-40804-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should allow retrans=0 as just meaning that every timeout is a major
timeout, and that there is no increment in the timeout value.

For instance, this means that we would allow TCP users to specify a
flat timeout value of 60s, by specifying "timeo=600,retrans=0" in their
mount option string.

Siged-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/client.c   | 10 +++++-----
 fs/nfs/internal.h |  5 ++++-
 fs/nfs/super.c    | 19 +++++++++++++++++--
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 003ebce4bbc4..1e106780a237 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -426,7 +426,7 @@ EXPORT_SYMBOL_GPL(nfs_mark_client_ready);
  * Initialise the timeout values for a connection
  */
 void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
-				    unsigned int timeo, unsigned int retrans)
+				    int timeo, int retrans)
 {
 	to->to_initval = timeo * HZ / 10;
 	to->to_retries = retrans;
@@ -434,9 +434,9 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 	switch (proto) {
 	case XPRT_TRANSPORT_TCP:
 	case XPRT_TRANSPORT_RDMA:
-		if (to->to_retries == 0)
+		if (retrans == NFS_UNSPEC_RETRANS)
 			to->to_retries = NFS_DEF_TCP_RETRANS;
-		if (to->to_initval == 0)
+		if (timeo == NFS_UNSPEC_TIMEO || to->to_retries == 0)
 			to->to_initval = NFS_DEF_TCP_TIMEO * HZ / 10;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
 			to->to_initval = NFS_MAX_TCP_TIMEOUT;
@@ -449,9 +449,9 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 		to->to_exponential = 0;
 		break;
 	case XPRT_TRANSPORT_UDP:
-		if (to->to_retries == 0)
+		if (retrans == NFS_UNSPEC_RETRANS)
 			to->to_retries = NFS_DEF_UDP_RETRANS;
-		if (!to->to_initval)
+		if (timeo == NFS_UNSPEC_TIMEO || to->to_initval == 0)
 			to->to_initval = NFS_DEF_UDP_TIMEO * HZ / 10;
 		if (to->to_initval > NFS_MAX_UDP_TIMEOUT)
 			to->to_initval = NFS_MAX_UDP_TIMEOUT;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7ce5e023c3c3..74935a19e4bf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -58,6 +58,9 @@ struct nfs_clone_mount {
  */
 #define NFS_UNSPEC_PORT		(-1)
 
+#define NFS_UNSPEC_RETRANS	(UINT_MAX)
+#define NFS_UNSPEC_TIMEO	(UINT_MAX)
+
 /*
  * Maximum number of pages that readdir can use for creating
  * a vmapped array of pages.
@@ -156,7 +159,7 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
 int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *, struct nfs_fattr *);
 void nfs_server_insert_lists(struct nfs_server *);
 void nfs_server_remove_lists(struct nfs_server *);
-void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
+void nfs_init_timeout_values(struct rpc_timeout *to, int proto, int timeo, int retrans);
 int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *t,
 		rpc_authflavor_t);
 struct nfs_server *nfs_alloc_server(void);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 18d446e1a82b..d39601381adf 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -923,6 +923,8 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data) {
+		data->timeo		= NFS_UNSPEC_TIMEO;
+		data->retrans		= NFS_UNSPEC_RETRANS;
 		data->acregmin		= NFS_DEF_ACREGMIN;
 		data->acregmax		= NFS_DEF_ACREGMAX;
 		data->acdirmin		= NFS_DEF_ACDIRMIN;
@@ -1189,6 +1191,19 @@ static int nfs_get_option_ul(substring_t args[], unsigned long *option)
 	return rc;
 }
 
+static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
+		unsigned long l_bound, unsigned long u_bound)
+{
+	int ret;
+
+	ret = nfs_get_option_ul(args, option);
+	if (ret != 0)
+		return ret;
+	if (*option < l_bound || *option > u_bound)
+		return -ERANGE;
+	return 0;
+}
+
 /*
  * Error-check and convert a string of mount options from user space into
  * a data structure.  The whole mount string is processed; bad options are
@@ -1352,12 +1367,12 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->bsize = option;
 			break;
 		case Opt_timeo:
-			if (nfs_get_option_ul(args, &option) || option == 0)
+			if (nfs_get_option_ul_bound(args, &option, 1, INT_MAX))
 				goto out_invalid_value;
 			mnt->timeo = option;
 			break;
 		case Opt_retrans:
-			if (nfs_get_option_ul(args, &option) || option == 0)
+			if (nfs_get_option_ul_bound(args, &option, 0, INT_MAX))
 				goto out_invalid_value;
 			mnt->retrans = option;
 			break;
-- 
2.7.4

