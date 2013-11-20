Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab3KTQsx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 11:48:53 -0500
From: Susant Sahani <ssahani@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] race in clnt_vc_create
Date: Wed, 20 Nov 2013 22:19:32 +0530
Message-Id: <1384966173-6229-3-git-send-email-ssahani@redhat.com>
In-Reply-To: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
References: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/clnt_vc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index 2eab9e4..bf3f13c 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -173,14 +173,17 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	struct timeval now;
 	struct rpc_msg call_msg;
 	static u_int32_t disrupt;
+	static pthread_mutex_t disrupt_lock = PTHREAD_MUTEX_INITIALIZER;
 	sigset_t mask;
 	sigset_t newmask;
 	struct sockaddr_storage ss;
 	socklen_t slen;
 	struct __rpc_sockinfo si;
 
+	mutex_lock(&disrupt_lock);
 	if (disrupt == 0)
 		disrupt = (u_int32_t)(long)raddr;
+	mutex_unlock(&disrupt_lock);
 
 	cl = (CLIENT *)mem_alloc(sizeof (*cl));
 	ct = (struct ct_data *)mem_alloc(sizeof (*ct));
@@ -270,7 +273,9 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	 * Initialize call message
 	 */
 	(void)gettimeofday(&now, NULL);
+	mutex_lock(&disrupt_lock);
 	call_msg.rm_xid = ((u_int32_t)++disrupt) ^ __RPC_GETXID(&now);
+	mutex_unlock(&disrupt_lock);
 	call_msg.rm_direction = CALL;
 	call_msg.rm_call.cb_rpcvers = RPC_MSG_VERSION;
 	call_msg.rm_call.cb_prog = (u_int32_t)prog;
-- 
1.8.4.2

