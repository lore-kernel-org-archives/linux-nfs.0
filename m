From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Make svc_addr's argument a constant
Date: Fri, 22 Aug 2008 12:43:16 -0400
Message-ID: <20080822164315.20600.28603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34117 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbYHVQoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 12:44:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Add extra type safety and squelch a few compiler complaints
in upcoming patches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2a41d29..564e045 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -266,17 +266,17 @@ struct svc_rqst {
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

