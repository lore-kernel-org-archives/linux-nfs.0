From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 23/39] nfs41: Release backchannel resources associated with session
Date: Fri,  1 May 2009 02:22:57 +0300
Message-ID: <1241133777-1054-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32564 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757552AbZD3XXE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:23:04 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

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
index aab69f0..485c279 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -49,6 +49,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/module.h>
+#include <linux/sunrpc/bc_xprt.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -4484,6 +4485,11 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 
 void nfs4_destroy_session(struct nfs4_session *session)
 {
+	nfs4_proc_destroy_session(session);
+	dprintk("%s Destroy backchannel for xprt %p\n",
+		__func__, session->clp->cl_rpcclient->cl_xprt);
+	xprt_destroy_backchannel(session->clp->cl_rpcclient->cl_xprt,
+				NFS41_BC_MIN_CALLBACKS);
 	nfs4_destroy_slot_table(session);
 	kfree(session);
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 892215c..923b28f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2486,7 +2486,6 @@ static void nfs4_kill_super(struct super_block *sb)
 	dprintk("--> %s\n", __func__);
 	nfs_super_return_all_delegations(sb);
 	kill_anon_super(sb);
-
 	nfs4_renewd_prepare_shutdown(server);
 	nfs_fscache_release_super_cookie(sb);
 	nfs_free_server(server);
-- 
1.6.2.1

