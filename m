From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 47/69] sunrpc: get rid of rpc_rqst.rq_bufsize
Date: Tue, 23 Dec 2008 18:02:19 -0500
Message-ID: <20081223230219.13743.28041.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbYLWXYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:44 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0Z006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

rq_bufsize is not used.

Signed-off-by: Mike Sager <Mike.Sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)


diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 4d80a11..11fc71d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -76,8 +76,7 @@ struct rpc_rqst {
 	struct list_head	rq_list;
 
 	__u32 *			rq_buffer;	/* XDR encode buffer */
-	size_t			rq_bufsize,
-				rq_callsize,
+	size_t			rq_callsize,
 				rq_rcvsize;
 
 	struct xdr_buf		rq_private_buf;		/* The receive buffer

