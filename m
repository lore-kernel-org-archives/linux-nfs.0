From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 76/85] nfs41: Release backchannel resources associated with session
Date: Mon, 10 Nov 2008 22:31:47 +0200
Message-ID: <1226349107-9769-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53121 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbYKJUbw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:31:52 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Frees the preallocated backchannel resources that are associated with
this session when the session is destroyed.

A backchannel is currently created once per session. Destroy the backchannel
only when the session is destroyed.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    6 ++++++
 fs/nfs/super.c    |    1 -
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f6a9894..b57ff19 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -57,6 +57,7 @@
 #if defined(CONFIG_NFS_V4_1)
 #include "callback.h"
 #include <linux/nfs41_session_recovery.h>
+#include <linux/sunrpc/bc_xprt.h>
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
@@ -4588,6 +4589,11 @@ void nfs4_put_session(struct nfs4_session **session)
 {
 	dprintk("--> nfs4_put_session()\n");
 	if (atomic_dec_and_test(&((*session)->ref_count))) {
+		nfs4_proc_destroy_session(*session);
+		dprintk("%s Destroy backchannel for xprt%p\n",
+			__func__, (*session)->clnt->cl_xprt);
+		xprt_destroy_backchannel((*session)->clnt->cl_xprt,
+					 NFS41_BC_MIN_CALLBACKS);
 		nfs4_destroy_slot_table(&((*session)->fore_channel));
 		nfs4_free_session(*session);
 		*session = NULL;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d7f99f8..e005889 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2434,7 +2434,6 @@ static void nfs4_kill_super(struct super_block *sb)
 	dprintk("--> %s\n", __func__);
 	nfs_return_all_delegations(sb);
 	kill_anon_super(sb);
-
 	nfs4_renewd_prepare_shutdown(server);
 	nfs_free_server(server);
 	dprintk("<-- %s\n", __func__);
-- 
1.6.0.2

