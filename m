Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35867 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757097AbcH3AEl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:41 -0400
Received: by mail-it0-f68.google.com with SMTP id x131so619634ite.3
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] NFSv4.x: Add kernel parameter to control the callback server
Date: Mon, 29 Aug 2016 20:03:52 -0400
Message-Id: <1472515432-54202-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472515432-54202-6-git-send-email-trond.myklebust@primarydata.com>
References: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-3-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-4-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-5-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for the kernel parameter nfs.callback_nr_threads to set
the number of threads that will be assigned to the callback channel.

Add support for the kernel parameter nfs.nfs.max_session_cb_slots
to set the maximum size of the callback channel slot table.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 Documentation/kernel-parameters.txt | 12 ++++++++++++
 fs/nfs/callback.c                   |  5 ++++-
 fs/nfs/callback.h                   |  3 ++-
 fs/nfs/nfs4_fs.h                    |  1 +
 fs/nfs/nfs4proc.c                   |  7 +++----
 fs/nfs/nfs4session.h                |  1 +
 fs/nfs/super.c                      | 10 ++++++++++
 7 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 46c030a49186..679879384b68 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2420,6 +2420,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	nfsrootdebug	[NFS] enable nfsroot debugging messages.
 			See Documentation/filesystems/nfs/nfsroot.txt.
 
+	nfs.callback_nr_threads=
+			[NFSv4] set the total number of threads that the
+			NFS client will assign to service NFSv4 callback
+			requests.
+
 	nfs.callback_tcpport=
 			[NFS] set the TCP port on which the NFSv4 callback
 			channel should listen.
@@ -2443,6 +2448,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			of returning the full 64-bit number.
 			The default is to return 64-bit inode numbers.
 
+	nfs.max_session_cb_slots=
+			[NFSv4.1] Sets the maximum number of session
+			slots the client will assign to the callback
+			channel. This determines the maximum number of
+			callbacks the client will process in parallel for
+			a particular server.
+
 	nfs.max_session_slots=
 			[NFSv4.1] Sets the maximum number of session slots
 			the client will attempt to negotiate with the server.
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index b91c49f4670b..532d8e242d4d 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -148,11 +148,14 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 				  struct svc_serv *serv)
 {
-	const int nrservs = NFS4_NR_CALLBACK_THREADS;
+	int nrservs = nfs_callback_nr_threads;
 	int ret;
 
 	nfs_callback_bc_serv(minorversion, xprt, serv);
 
+	if (nrservs < NFS4_MIN_NR_CALLBACK_THREADS)
+		nrservs = NFS4_MIN_NR_CALLBACK_THREADS;
+
 	if (serv->sv_nrthreads-1 == nrservs)
 		return 0;
 
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 14bd863495db..41ad65151ec8 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -198,8 +198,9 @@ extern void nfs_callback_down(int minorversion, struct net *net);
 #define NFS41_BC_MIN_CALLBACKS 1
 #define NFS41_BC_MAX_CALLBACKS 1
 
-#define NFS4_NR_CALLBACK_THREADS 1
+#define NFS4_MIN_NR_CALLBACK_THREADS 1
 
 extern unsigned int nfs_callback_set_tcpport;
+extern unsigned short nfs_callback_nr_threads;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9bf64eacba5b..f230aa62ca59 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -471,6 +471,7 @@ extern struct nfs_subversion nfs_v4;
 struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *, struct nfs_subversion *);
 extern bool nfs4_disable_idmapping;
 extern unsigned short max_session_slots;
+extern unsigned short max_session_cb_slots;
 extern unsigned short send_implementation_id;
 extern bool recover_lost_locks;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5aecaabcb7c..e924907cccef 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7463,7 +7463,7 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args,
 	args->bc_attrs.max_resp_sz = max_bc_payload;
 	args->bc_attrs.max_resp_sz_cached = 0;
 	args->bc_attrs.max_ops = NFS4_MAX_BACK_CHANNEL_OPS;
-	args->bc_attrs.max_reqs = NFS41_BC_MAX_CALLBACKS;
+	args->bc_attrs.max_reqs = min_t(unsigned short, max_session_cb_slots, 1);
 
 	dprintk("%s: Back Channel : max_rqst_sz=%u max_resp_sz=%u "
 		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
@@ -7510,10 +7510,9 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
 		return -EINVAL;
 	if (rcvd->max_resp_sz_cached > sent->max_resp_sz_cached)
 		return -EINVAL;
-	/* These would render the backchannel useless: */
-	if (rcvd->max_ops != sent->max_ops)
+	if (rcvd->max_ops > sent->max_ops)
 		return -EINVAL;
-	if (rcvd->max_reqs != sent->max_reqs)
+	if (rcvd->max_reqs > sent->max_reqs)
 		return -EINVAL;
 out:
 	return 0;
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index f703b755351b..3bb6af70973c 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -9,6 +9,7 @@
 
 /* maximum number of slots to use */
 #define NFS4_DEF_SLOT_TABLE_SIZE (64U)
+#define NFS4_DEF_CB_SLOT_TABLE_SIZE (1U)
 #define NFS4_MAX_SLOT_TABLE (1024U)
 #define NFS4_NO_SLOT ((u32)-1)
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d39601381adf..001796bcd6c8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2848,19 +2848,23 @@ out_invalid_transport_udp:
  * NFS client for backwards compatibility
  */
 unsigned int nfs_callback_set_tcpport;
+unsigned short nfs_callback_nr_threads;
 /* Default cache timeout is 10 minutes */
 unsigned int nfs_idmap_cache_timeout = 600;
 /* Turn off NFSv4 uid/gid mapping when using AUTH_SYS */
 bool nfs4_disable_idmapping = true;
 unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
+unsigned short max_session_cb_slots = NFS4_DEF_CB_SLOT_TABLE_SIZE;
 unsigned short send_implementation_id = 1;
 char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
 bool recover_lost_locks = false;
 
+EXPORT_SYMBOL_GPL(nfs_callback_nr_threads);
 EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
 EXPORT_SYMBOL_GPL(nfs_idmap_cache_timeout);
 EXPORT_SYMBOL_GPL(nfs4_disable_idmapping);
 EXPORT_SYMBOL_GPL(max_session_slots);
+EXPORT_SYMBOL_GPL(max_session_cb_slots);
 EXPORT_SYMBOL_GPL(send_implementation_id);
 EXPORT_SYMBOL_GPL(nfs4_client_id_uniquifier);
 EXPORT_SYMBOL_GPL(recover_lost_locks);
@@ -2887,6 +2891,9 @@ static const struct kernel_param_ops param_ops_portnr = {
 #define param_check_portnr(name, p) __param_check(name, p, unsigned int);
 
 module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
+module_param_named(callback_nr_threads, nfs_callback_nr_threads, ushort, 0644);
+MODULE_PARM_DESC(callback_nr_threads, "Number of threads that will be "
+		"assigned to the NFSv4 callback channels.");
 module_param(nfs_idmap_cache_timeout, int, 0644);
 module_param(nfs4_disable_idmapping, bool, 0644);
 module_param_string(nfs4_unique_id, nfs4_client_id_uniquifier,
@@ -2896,6 +2903,9 @@ MODULE_PARM_DESC(nfs4_disable_idmapping,
 module_param(max_session_slots, ushort, 0644);
 MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
 		"requests the client will negotiate");
+module_param(max_session_cb_slots, ushort, 0644);
+MODULE_PARM_DESC(max_session_slots, "Maximum number of parallel NFSv4.1 "
+		"callbacks the client will process for a given server");
 module_param(send_implementation_id, ushort, 0644);
 MODULE_PARM_DESC(send_implementation_id,
 		"Send implementation ID with NFSv4.1 exchange_id");
-- 
2.7.4

