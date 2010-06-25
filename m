Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab0FYPtQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 11:49:16 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@fys.uio.no, Staubach_Peter@emc.com, bfields@fieldses.org
Subject: [PATCH 2/2] nfsd: reject NFSv4 requests over UDP
Date: Fri, 25 Jun 2010 11:49:06 -0400
Message-Id: <1277480946-23844-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1277480946-23844-1-git-send-email-jlayton@redhat.com>
References: <1277480946-23844-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

RFC3530 states:

   Where an NFS version 4 implementation supports operation over the IP
   network protocol, the supported transports between NFS and IP MUST be
   among the IETF-approved congestion control transport protocols, which
   include TCP and SCTP

This patch makes nfsd_dispatch check for NFSv4 requests over UDP and
reject them with a PROG_MISMATCH RPC error.

It also has the NFS server skip rpcbind registration of the NFSv4 UDP
port.

Reported-by: Sachin Prabhu <sprabhu@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4proc.c |    1 +
 fs/nfsd/nfssvc.c   |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 59ec449..4dfbf08 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1365,6 +1365,7 @@ struct svc_version	nfsd_version4 = {
 		.vs_proc	= nfsd_procedures4,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
+		.vs_hidden_udp	= true,
 };
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6b59d32..9ae06ba 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -535,6 +535,13 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 				rqstp->rq_vers, rqstp->rq_proc);
 	proc = rqstp->rq_procinfo;
 
+	/* Reject any NFSv4 request over UDP. Don't bother caching it. */
+	if (rqstp->rq_vers == 4 && rqstp->rq_prot == IPPROTO_UDP) {
+		dprintk("%s: rejecting vers 4 request over UDP\n", __func__);
+		*statp = rpc_prog_mismatch;
+		return 1;
+	}
+
 	/* Check whether we have this call in the cache. */
 	switch (nfsd_cache_lookup(rqstp, proc->pc_cachetype)) {
 	case RC_INTR:
-- 
1.5.5.6

