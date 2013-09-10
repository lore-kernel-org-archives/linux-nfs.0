Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9838 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab3IJWop (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 18:44:45 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 4/4] NFSv4.1: sp4_mach_cred: WARN_ON -> WARN_ON_ONCE
Date: Tue, 10 Sep 2013 18:44:33 -0400
Message-ID: <1378853073-13256-5-git-send-email-dros@netapp.com>
In-Reply-To: <1378853073-13256-1-git-send-email-dros@netapp.com>
References: <1378853073-13256-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to spam the logs

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 07a8aa9..28842ab 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -286,8 +286,8 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 		msg->rpc_cred = newcred;
 
 		flavor = clp->cl_rpcclient->cl_auth->au_flavor;
-		WARN_ON(flavor != RPC_AUTH_GSS_KRB5I &&
-			flavor != RPC_AUTH_GSS_KRB5P);
+		WARN_ON_ONCE(flavor != RPC_AUTH_GSS_KRB5I &&
+			     flavor != RPC_AUTH_GSS_KRB5P);
 		*clntp = clp->cl_rpcclient;
 
 		return true;
-- 
1.7.12.4 (Apple Git-37)

