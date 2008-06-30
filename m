From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/16] SUNRPC: Make svc_addr's argument a constant
Date: Mon, 30 Jun 2008 18:58:46 -0400
Message-ID: <20080630225845.25407.15311.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:52859 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763272AbYF3XEr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:04:47 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Add extra type safety and squash a few compiler complaints (in
upcoming patches).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)


diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 05312e7..8798342 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -267,17 +267,17 @@ struct svc_rqst {
 /*
  * Rigorous type checking on sockaddr type conversions
  */
-static inline struct sockaddr_in *svc_addr_in(struct svc_rqst *rqst)
+static inline struct sockaddr_in *svc_addr_in(const struct svc_rqst *rqst)
 {
 	return (struct sockaddr_in *) &rqst->rq_addr;
 }
 
-static inline struct sockaddr_in6 *svc_addr_in6(struct svc_rqst *rqst)
+static inline struct sockaddr_in6 *svc_addr_in6(const struct svc_rqst *rqst)
 {
 	return (struct sockaddr_in6 *) &rqst->rq_addr;
 }
 
-static inline struct sockaddr *svc_addr(struct svc_rqst *rqst)
+static inline struct sockaddr *svc_addr(const struct svc_rqst *rqst)
 {
 	return (struct sockaddr *) &rqst->rq_addr;
 }

