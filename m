From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 1/3] nfs41: SQUASHME: Update to removal of ugly #ifdefs
Date: Tue, 16 Jun 2009 11:26:38 -0700
Message-ID: <1245176800-10595-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61377 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881AbZFPSbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2009 14:31:11 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Moves the non-v4.1 version handling into common code.

[squash with: nfs41: Implement NFSv4.1 callback service process]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/callback.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 116424e..f874640 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -210,17 +210,15 @@ out:
 	return rqstp;
 }
 
-static inline void nfs_callback_svc_setup(u32 minorversion,
+static inline int nfs_minorversion_callback_svc_setup(u32 minorversion,
 		struct svc_serv *serv, struct rpc_xprt *xprt,
 		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
 {
 	if (minorversion) {
 		*rqstpp = nfs41_callback_up(serv, xprt);
 		*callback_svc = nfs41_callback_svc;
-	} else {
-		*rqstpp = nfs4_callback_up(serv);
-		*callback_svc = nfs4_callback_svc;
 	}
+	return minorversion;
 }
 
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
@@ -230,12 +228,11 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		xprt->bc_serv = cb_info->serv;
 }
 #else
-static inline void nfs_callback_svc_setup(u32 minorversion,
+static inline int nfs_minorversion_callback_svc_setup(u32 minorversion,
 		struct svc_serv *serv, struct rpc_xprt *xprt,
 		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
 {
-	*rqstpp = nfs4_callback_up(serv);
-	*callback_svc = nfs4_callback_svc;
+	return 0;
 }
 
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
@@ -255,6 +252,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 	char svc_name[12];
 	int ret = 0;
+	int minorversion_setup;
 
 	mutex_lock(&nfs_callback_mutex);
 	if (cb_info->users++ || cb_info->task != NULL) {
@@ -269,7 +267,13 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 
 	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
 	 * need to monitor and control them both */
-	nfs_callback_svc_setup(minorversion, serv, xprt, &rqstp, &callback_svc);
+	minorversion_setup =  nfs_minorversion_callback_svc_setup(minorversion,
+					serv, xprt, &rqstp, &callback_svc);
+	if (!minorversion_setup) {
+		/* v4.0 callback setup */
+		rqstp = nfs4_callback_up(serv);
+		callback_svc = nfs4_callback_svc;
+	}
 
 	if (IS_ERR(rqstp)) {
 		ret = PTR_ERR(rqstp);
-- 
1.5.4.3

