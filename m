Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751885AbdBWRDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 12:03:40 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] nfs/nfsd/sunrpc: enforce congestion control protocol requirement for NFSv4
Date: Thu, 23 Feb 2017 12:03:36 -0500
Message-Id: <20170223170337.10686-4-jlayton@redhat.com>
In-Reply-To: <20170223170337.10686-1-jlayton@redhat.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 requires an "IETF approved congestion control transport". In
practical terms, that means that you should not run NFSv4 over UDP. The
server has never enforced that requirement though.

This patchset fixes that by adding a new flag to the svc_version that
states that it requires a congestion-controlled transport, and a new
flag to the svc_xprt that declares that the transport fulfills that
requirement. We then use those flags to enforce the requirement in
svc_process_common.

In practical terms, that means that we set the new xprt flag in TCP and
RDMA transports, and the the new svc_version flag in NFSv4 svc_version
structs.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_xdr.c      |  2 ++
 fs/nfsd/nfs4proc.c         | 13 +++++++------
 include/linux/sunrpc/svc.h |  3 +++
 net/sunrpc/svc.c           | 13 +++++++++++++
 4 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e9836f611d9c..fd0284c1dc32 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -1084,6 +1084,7 @@ struct svc_version nfs4_callback_version1 = {
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
 	.vs_hidden = true,
+	.vs_need_cong_ctrl = true,
 };
 
 struct svc_version nfs4_callback_version4 = {
@@ -1093,4 +1094,5 @@ struct svc_version nfs4_callback_version4 = {
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
 	.vs_hidden = true,
+	.vs_need_cong_ctrl = true,
 };
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2b73b37c2b36..f82fcaa2e1d9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2476,12 +2476,13 @@ static struct svc_procedure		nfsd_procedures4[2] = {
 };
 
 struct svc_version	nfsd_version4 = {
-		.vs_vers	= 4,
-		.vs_nproc	= 2,
-		.vs_proc	= nfsd_procedures4,
-		.vs_dispatch	= nfsd_dispatch,
-		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
-		.vs_rpcb_optnl	= true,
+	.vs_vers		= 4,
+	.vs_nproc		= 2,
+	.vs_proc		= nfsd_procedures4,
+	.vs_dispatch		= nfsd_dispatch,
+	.vs_xdrsize		= NFS4_SVC_XDRSIZE,
+	.vs_rpcb_optnl		= true,
+	.vs_need_cong_ctrl	= true,
 };
 
 /*
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 96467c95f02e..65b1c707c40b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -406,6 +406,9 @@ struct svc_version {
 	/* Don't care if the rpcbind registration fails */
 	bool			vs_rpcb_optnl;
 
+	/* Only allowed on IETF-approved congestion controlled xprts */
+	bool			vs_need_cong_ctrl;
+
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
 	 * vs_dispatch == NULL means use default dispatcher.
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 85bcdea67a3f..028c91a07950 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1169,6 +1169,19 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	  !(versp = progp->pg_vers[vers]))
 		goto err_bad_vers;
 
+	/*
+	 * Some protocol versions (namely NFSv4) require "IETF approved
+	 * congestion control protocols". IOW, UDP is not allowed. We mark
+	 * those when setting up the svc_xprt, and verify that for them here.
+	 *
+	 * The spec is not very clear about what error should be returned when
+	 * someone tries to access a server that is listening on UDP for lower
+	 * versions though. RPC_PROG_MISMATCH seems to be the closest fit.
+	 */
+	if (versp->vs_need_cong_ctrl &&
+	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
+		goto err_bad_vers;
+
 	procp = versp->vs_proc + proc;
 	if (proc >= versp->vs_nproc || !procp->pc_func)
 		goto err_bad_proc;
-- 
2.9.3

