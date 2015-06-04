Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932207AbbFDQqM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:12 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 07/10] SUNRPC: restrict backchannel svc IPPROTO_TCP check to IP
Date: Thu,  4 Jun 2015 17:45:50 +0100
Message-Id: <1433436353-6761-8-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The IPPROTO_TCP check only applies to AF_INET and AF_INET6.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 78974e4..1c9c5bc 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1365,9 +1365,16 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	/* reset result send buffer "put" position */
 	resv->iov_len = 0;
 
-	if (rqstp->rq_prot != IPPROTO_TCP) {
-		printk(KERN_ERR "No support for Non-TCP transports!\n");
-		BUG();
+	switch (((struct sockaddr *)&rqstp->rq_addr)->sa_family) {
+	case AF_INET:
+	case AF_INET6:
+		if (rqstp->rq_prot != IPPROTO_TCP) {
+			printk(KERN_ERR "No support for Non-TCP transports!\n");
+			BUG();
+		}
+		break;
+	default:
+		break;
 	}
 
 	/*
-- 
2.4.2

