Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:37786 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752344AbeC0Ota (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:49:30 -0400
Received: by mail-io0-f193.google.com with SMTP id y128so27931072iod.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:49:30 -0700 (PDT)
Subject: [PATCH v2 01/18] sunrpc: Remove unneeded pointer dereference
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:49:22 -0400
Message-ID: <20180327144922.7710.36847.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Noticed during code inspection that there is already a
local automatic variable "xprt" so dereferencing rqst->rq_xprt
again is unnecessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc_xprt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f9307bd..6dca0f5 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -492,7 +492,7 @@ static void svc_xprt_release(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
-	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
+	xprt->xpt_ops->xpo_release_rqst(rqstp);
 
 	kfree(rqstp->rq_deferred);
 	rqstp->rq_deferred = NULL;
@@ -889,7 +889,7 @@ int svc_send(struct svc_rqst *rqstp)
 		goto out;
 
 	/* release the receive skb before sending the reply */
-	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
+	xprt->xpt_ops->xpo_release_rqst(rqstp);
 
 	/* calculate over-all length */
 	xb = &rqstp->rq_res;

