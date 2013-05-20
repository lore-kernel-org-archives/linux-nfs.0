Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36180 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab3ETRSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 13:18:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] NFSv4.1: Enable state protection
Date: Mon, 20 May 2013 13:17:07 -0400
Message-Id: <1369070227-40671-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369070227-40671-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-4-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the EXCHGID4_FLAG_BIND_PRINC_STATEID exchange_id flag to enable
stateid protection. This means that if we create a stateid using a
particular principal, then we must use the same principal if we
want to change that state.
IOW: if we OPEN a file using a particular credential, then we have
to use the same credential in subsequent OPEN_DOWNGRADE, CLOSE,
or DELEGRETURN operations that use that stateid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7cdc706..3e21d43 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5528,7 +5528,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	struct nfs41_exchange_id_args args = {
 		.verifier = &verifier,
 		.client = clp,
-		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
+		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
+			EXCHGID4_FLAG_BIND_PRINC_STATEID,
 	};
 	struct nfs41_exchange_id_res res = {
 		0
-- 
1.8.1.4

