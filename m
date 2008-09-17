From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 17 Sep 2008 14:43:44 -0500
Message-ID: <48D15DF0.4000406@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	pnfs mailing list <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:21106 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752513AbYIQT61 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 15:58:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

since commit ff7d9756b501744540be65e172d27ee321d86103
"nfsd: use static memory for callback program and stats"
do_probe_callback uses a static callback program
(NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
as passed in by the client in setclientid (4.0)
or create_session (4.1).

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 30d3130..f555178 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -342,21 +342,6 @@ static struct rpc_version *	nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
-static struct rpc_program cb_program;
-
-static struct rpc_stat cb_stats = {
-		.program	= &cb_program
-};
-
-#define NFS4_CALLBACK 0x40000000
-static struct rpc_program cb_program = {
-		.name 		= "nfs4_cb",
-		.number		= NFS4_CALLBACK,
-		.nrvers		= ARRAY_SIZE(nfs_cb_version),
-		.version	= nfs_cb_version,
-		.stats		= &cb_stats,
-};
-
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
@@ -371,6 +356,8 @@ static int do_probe_callback(void *data)
 		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
 		.to_exponential	= 1,
 	};
+	static struct rpc_stat	cb_stats;
+	struct rpc_program	cb_program;
 	struct rpc_create_args args = {
 		.protocol	= IPPROTO_TCP,
 		.address	= (struct sockaddr *)&addr,
@@ -394,6 +381,20 @@ static int do_probe_callback(void *data)
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
 
+	/* Initialize rpc_program */
+	memset(&cb_program, 0, sizeof(cb_program));
+	cb_program.name = "nfs4_cb";
+	cb_program.number = clp->cl_callback.cb_prog;
+	cb_program.nrvers = ARRAY_SIZE(nfs_cb_version);
+	cb_program.version = nfs_cb_version;
+	cb_program.stats = &cb_stats;
+	memset(&cb_stats, 0, sizeof(cb_stats));
+	cb_stats.program = &cb_program;
+
+	dprintk("%s: program %s 0x%x nrvers %u version %u\n",
+		__func__, args.program->name, args.program->number,
+		args.program->nrvers, args.version);
+
 	/* Initialize rpc_stat */
 	memset(args.program->stats, 0, sizeof(struct rpc_stat));
 
-- 
1.6.0.1

