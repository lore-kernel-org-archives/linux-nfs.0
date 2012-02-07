Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754023Ab2BGA5Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 19:57:25 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 2/2] NFSv4.1: Add a module parameter to set the number of session slots
Date: Mon,  6 Feb 2012 19:57:17 -0500
Message-Id: <1328576237-7362-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the module parameter 'max_session_slots' to set the initial number
of slots that the NFSv4.1 client will attempt to negotiate with the
server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 Documentation/kernel-parameters.txt |    8 ++++++++
 fs/nfs/nfs4proc.c                   |    8 +++++++-
 include/linux/nfs_fs_sb.h           |    3 ++-
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 033d4e6..1d369c6 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1657,6 +1657,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			of returning the full 64-bit number.
 			The default is to return 64-bit inode numbers.
 
+	nfs.max_session_slots=
+			[NFSv4.1] Sets the maximum number of session slots
+			the client will attempt to negotiate with the server.
+			This limits the number of simultaneous RPC requests
+			that the client can send to the NFSv4.1 server.
+			Note that there is little point in setting this
+			value higher than the max_tcp_slot_table_limit.
+
 	nfs.nfs4_disable_idmapping=
 			[NFSv4] When set to the default of '1', this option
 			ensures that both the RPC level authentication
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0dc5dfb..da985c3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -72,6 +72,8 @@
 
 #define NFS4_MAX_LOOP_ON_RECOVER (10)
 
+static unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
+
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
@@ -5246,7 +5248,7 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 	args->fc_attrs.max_rqst_sz = mxrqst_sz;
 	args->fc_attrs.max_resp_sz = mxresp_sz;
 	args->fc_attrs.max_ops = NFS4_MAX_OPS;
-	args->fc_attrs.max_reqs = session->clp->cl_rpcclient->cl_xprt->max_reqs;
+	args->fc_attrs.max_reqs = max_session_slots;
 
 	dprintk("%s: Fore Channel : max_rqst_sz=%u max_resp_sz=%u "
 		"max_ops=%u max_reqs=%u\n",
@@ -6391,6 +6393,10 @@ const struct xattr_handler *nfs4_xattr_handlers[] = {
 	NULL
 };
 
+module_param(max_session_slots, ushort, 0644);
+MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
+		"requests the client will negotiate");
+
 /*
  * Local variables:
  *  c-basic-offset: 8
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2ae57f2..ba1e08d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -190,7 +190,8 @@ struct nfs_server {
 
 
 /* maximum number of slots to use */
-#define NFS4_MAX_SLOT_TABLE (128U)
+#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
+#define NFS4_MAX_SLOT_TABLE (255U)
 #define NFS4_NO_SLOT ((u32)-1)
 
 #if defined(CONFIG_NFS_V4)
-- 
1.7.7.6

