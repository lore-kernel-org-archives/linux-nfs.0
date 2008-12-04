From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/17] NSM: Use C99 structure initializer to initialize
	nsm_args
Date: Thu, 04 Dec 2008 14:20:23 -0500
Message-ID: <20081204192023.8039.62166.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:49790 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbYLDTUu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:20:50 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use a C99 structure initializer instead of open-coding the
initialization of nsm_args.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4e7e958..65b4e60 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -37,7 +37,13 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
-	struct nsm_args	args;
+	struct nsm_args args = {
+		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
+		.prog		= NLM_PROGRAM,
+		.vers		= 3,
+		.proc		= NLMPROC_NSM_NOTIFY,
+		.mon_name	= nsm->sm_name,
+	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
 		.rpc_resp	= res,
@@ -49,12 +55,6 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 		goto out;
 	}
 
-	memset(&args, 0, sizeof(args));
-	args.mon_name = nsm->sm_name;
-	args.addr = nsm_addr_in(nsm)->sin_addr.s_addr;
-	args.prog = NLM_PROGRAM;
-	args.vers = 3;
-	args.proc = NLMPROC_NSM_NOTIFY;
 	memset(res, 0, sizeof(*res));
 
 	msg.rpc_proc = &clnt->cl_procinfo[proc];

