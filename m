Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60656 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709Ab3EOTvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 15:51:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: Fix a bug in gss_create_upcall
Date: Wed, 15 May 2013 12:50:39 -0700
Message-Id: <1368647441-24815-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If wait_event_interruptible_timeout() is successful, it returns
the number of seconds remaining until the timeout. In that
case, we should be retrying the upcall.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 7da6b45..f17f3c5 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -563,11 +563,12 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	struct rpc_cred *cred = &gss_cred->gc_base;
 	struct gss_upcall_msg *gss_msg;
 	DEFINE_WAIT(wait);
-	int err = 0;
+	int err;
 
 	dprintk("RPC:       %s for uid %u\n",
 		__func__, from_kuid(&init_user_ns, cred->cr_uid));
 retry:
+	err = 0;
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
@@ -576,7 +577,7 @@ retry:
 			warn_gssd();
 			err = -EACCES;
 		}
-		if (err)
+		if (err < 0)
 			goto out;
 		goto retry;
 	}
-- 
1.8.1.4

