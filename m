Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9838 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab3IJWoo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 18:44:44 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/4] NFSv4.1: sp4_mach_cred: no need to ref count creds
Date: Tue, 10 Sep 2013 18:44:32 -0400
Message-ID: <1378853073-13256-4-git-send-email-dros@netapp.com>
In-Reply-To: <1378853073-13256-1-git-send-email-dros@netapp.com>
References: <1378853073-13256-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cl_machine_cred doesn't need to be reference counted here -
a reference is held is for the lifetime of the struct nfs_client.
Also, no need to put_rpccred the rpc_message.rpc_cred.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f520a11..07a8aa9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -279,10 +279,10 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
 		spin_lock(&clp->cl_lock);
 		if (clp->cl_machine_cred != NULL)
-			newcred = get_rpccred(clp->cl_machine_cred);
+			/* don't call get_rpccred on the machine cred -
+			 * a reference will be held for life of clp */
+			newcred = clp->cl_machine_cred;
 		spin_unlock(&clp->cl_lock);
-		if (msg->rpc_cred)
-			put_rpccred(msg->rpc_cred);
 		msg->rpc_cred = newcred;
 
 		flavor = clp->cl_rpcclient->cl_auth->au_flavor;
-- 
1.7.12.4 (Apple Git-37)

