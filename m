Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36216 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbaI1DzE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 23:55:04 -0400
Received: by mail-ig0-f178.google.com with SMTP id l13so45401iga.5
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 20:55:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFSv4: Fix lock recovery when CREATE_SESSION/SETCLIENTID_CONFIRM fails
Date: Sat, 27 Sep 2014 23:54:57 -0400
Message-Id: <1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
References: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a NFSv4.x server returns NFS4ERR_STALE_CLIENTID in response to a
CREATE_SESSION or SETCLIENTID_CONFIRM in order to tell us that it rebooted
a second time, then the client will currently take this to mean that it must
declare all locks to be stale, and hence ineligible for reboot recovery.

RFC3530 and RFC5661 both suggest that the client should instead rely on the
server to respond to inelegible open share, lock and delegation reclaim
requests with NFS4ERR_NO_GRACE in this situation.

Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 22fe35104c0c..26d510d11efd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1761,7 +1761,6 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		break;
 	case -NFS4ERR_STALE_CLIENTID:
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
-		nfs4_state_clear_reclaim_reboot(clp);
 		nfs4_state_start_reclaim_reboot(clp);
 		break;
 	case -NFS4ERR_CLID_INUSE:
-- 
1.9.3

