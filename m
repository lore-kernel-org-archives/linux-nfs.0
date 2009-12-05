From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 1/3] nfs41: Mark stateids in need of reclaim if state manager gets stale clientid
Date: Sat,  5 Dec 2009 12:11:22 -0800
Message-ID: <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46956 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757931AbZLEURG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:17:06 -0500
In-Reply-To: <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The state manager was not marking the stateids as needing to be reclaimed
after reestablishing the clientid.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 630199d..ae90df8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1157,6 +1157,7 @@ static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
 	case -NFS4ERR_STALE_CLIENTID:
 		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 		set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+		nfs4_state_start_reclaim_reboot(clp);
 	}
 }
 
-- 
1.5.4.3

