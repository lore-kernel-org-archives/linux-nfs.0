From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] SUNRPC: Make svc_addr's argument a constant
Date: Wed, 27 Aug 2008 16:57:46 -0400
Message-ID: <20080827205745.17837.85496.stgit@manray.1015granger.net>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:44779 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445AbYH0U6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 16:58:01 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

