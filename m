Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449Ab1LAVme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 16:42:34 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Ensure that we handle _all_ SEQUENCE status bits.
Date: Thu,  1 Dec 2011 16:42:23 -0500
Message-Id: <1322775743-14870-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1322775743-14870-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1322775743-14870-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the code assumes that the SEQUENCE status bits are mutually
exclusive. They are not...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org [>= 2.6.34]
---
 fs/nfs/nfs4state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1da95e3..da8d73e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1530,16 +1530,16 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 {
 	if (!flags)
 		return;
-	else if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
+	if (flags & SEQ4_STATUS_RESTART_RECLAIM_NEEDED)
 		nfs41_handle_server_reboot(clp);
-	else if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
+	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
 			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
 			    SEQ4_STATUS_ADMIN_STATE_REVOKED |
 			    SEQ4_STATUS_LEASE_MOVED))
 		nfs41_handle_state_revoked(clp);
-	else if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
+	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
 		nfs41_handle_recallable_state_revoked(clp);
-	else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
+	if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
 			    SEQ4_STATUS_BACKCHANNEL_FAULT |
 			    SEQ4_STATUS_CB_PATH_DOWN_SESSION))
 		nfs41_handle_cb_path_down(clp);
-- 
1.7.7.3

