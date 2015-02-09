Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:27136 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760103AbbBITHW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 14:07:22 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Thomas.Haynes@primarydata.com>
Subject: [PATCH] sunrpc: Give parameter names to rpc_count_iostasts_metrics()
Date: Mon, 9 Feb 2015 14:07:18 -0500
Message-ID: <1423508838-1806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We fall back to an empty function in the case that CONFIG_PROC_FS=n, so
give this function named parameters to silence a "parameter name omitted"
warning.

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/metrics.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
index 7e61a17..b23b8ed 100644
--- a/include/linux/sunrpc/metrics.h
+++ b/include/linux/sunrpc/metrics.h
@@ -89,8 +89,8 @@ void			rpc_free_iostats(struct rpc_iostats *);
 static inline struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt) { return NULL; }
 static inline void rpc_count_iostats(const struct rpc_task *task,
 				     struct rpc_iostats *stats) {}
-static inline void rpc_count_iostats_metrics(const struct rpc_task *,
-					     struct rpc_iostats *) {}
+static inline void rpc_count_iostats_metrics(const struct rpc_task *task,
+					     struct rpc_iostats *op_metrics) {}
 static inline void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt) {}
 static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
 
-- 
2.3.0

