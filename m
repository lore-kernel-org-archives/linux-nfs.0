Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:32785 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbFAPFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 11:05:47 -0400
Received: by yhpn97 with SMTP id n97so33436834yhp.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Jun 2015 08:05:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Always drain the slot table before re-establishing the lease
Date: Mon,  1 Jun 2015 11:05:42 -0400
Message-Id: <1433171142-76930-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While the NFSv4.1 code has always drained the slot tables in order to stop
non-recovery related RPC calls when doing lease recovery, the NFSv4 code
did not.
The reason for the difference in behaviour is that NFSv4 does not have
session state, and so RPC calls can in theory proceed while recovery is
happening. In practice, however, anything I/O or state related needs to
wait until recovery is over.

This patch changes the behaviour of NFSv4 to match that of NFSv4.1 so that
we can simplify the state recovery code by assuming that we do not have to
deal with races between recovery and ordinary I/O.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2782cfca2265..ffb66f5db078 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -309,7 +309,6 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 
 	if (test_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state))
 		goto do_confirm;
-	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_exchange_id(clp, cred);
 	if (status != 0)
 		goto out;
@@ -1830,6 +1829,7 @@ static int nfs4_establish_lease(struct nfs_client *clp)
 		clp->cl_mvops->reboot_recovery_ops;
 	int status;
 
+	nfs4_begin_drain_session(clp);
 	cred = nfs4_get_clid_cred(clp);
 	if (cred == NULL)
 		return -ENOENT;
-- 
2.4.2

