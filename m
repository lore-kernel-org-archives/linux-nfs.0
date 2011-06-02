Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39381 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932803Ab1FBKpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2011 06:45:14 -0400
Received: from [10.30.3.27] ([10.30.3.27])
	(authenticated bits=0)
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p52Al4IH024870
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Jun 2011 14:47:05 +0400 (MSD)
Message-ID: <4DE769B7.7080704@parallels.com>
Date: Thu, 02 Jun 2011 14:45:11 +0400
From: Vasily Averin <vvs@parallels.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCHv2 1/2] SUNRPC: Use dprint_status() macro in call_decode()
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

common dprint_status() macro is used in all callbacks but not in call_decode()

Signed-off-by: Vasily Averin <vvs@sw.ru>
---
 net/sunrpc/clnt.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b84d739..ab55369 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1548,8 +1548,7 @@ call_decode(struct rpc_task *task)
 	kxdrdproc_t	decode = task->tk_msg.rpc_proc->p_decode;
 	__be32		*p;

-	dprintk("RPC: %5u call_decode (status %d)\n",
-			task->tk_pid, task->tk_status);
+	dprint_status(task);

 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
 		if (clnt->cl_chatty)
-- 
1.7.4.1

