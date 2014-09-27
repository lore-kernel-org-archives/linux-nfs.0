Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:61329 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbaI0WU2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 18:20:28 -0400
Received: by mail-ie0-f172.google.com with SMTP id rl12so365824iec.31
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 15:20:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Don't convert unreclaimed locks on STALE_CLIENTID
Date: Sat, 27 Sep 2014 18:20:14 -0400
Message-Id: <1411856415-4472-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1411856415-4472-1-git-send-email-trond.myklebust@primarydata.com>
References: <1411856415-4472-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server tells us that it rebooted, then we should assume that
we can reclaim all locks or none, and we should rely on the server
returning NFS4ERR_NO_GRACE if we cannot reclaim all outstanding locks.

This patch removes those instances where we deliberately convert
unreclaimed locks.

Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 22fe35104c0c..5321b8c71a35 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1648,7 +1648,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			break;
 		case -NFS4ERR_STALE_CLIENTID:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
 			break;
 		case -NFS4ERR_EXPIRED:
@@ -1761,7 +1760,6 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		break;
 	case -NFS4ERR_STALE_CLIENTID:
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
-		nfs4_state_clear_reclaim_reboot(clp);
 		nfs4_state_start_reclaim_reboot(clp);
 		break;
 	case -NFS4ERR_CLID_INUSE:
-- 
1.9.3

