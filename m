Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33326 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758685AbbGHSZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:25:23 -0400
Received: by laar3 with SMTP id r3so231569577laa.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:25:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4.1: Handle SEQ4_STATUS_BACKCHANNEL_FAULT correctly
Date: Wed,  8 Jul 2015 20:25:11 +0200
Message-Id: <1436379913-3338-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436379913-3338-2-git-send-email-trond.myklebust@primarydata.com>
References: <1436379913-3338-1-git-send-email-trond.myklebust@primarydata.com>
 <1436379913-3338-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 states:

      The server has encountered an unrecoverable fault with the
      backchannel (e.g., it has lost track of the sequence ID for a slot
      in the backchannel).  The client MUST stop sending more requests
      on the session's fore channel, wait for all outstanding requests
      to complete on the fore and back channel, and then destroy the
      session.

Ensure we do so...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 469452996154..f2e2ad894461 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2217,9 +2217,9 @@ static void nfs41_handle_recallable_state_revoked(struct nfs_client *clp)
 
 static void nfs41_handle_backchannel_fault(struct nfs_client *clp)
 {
-	nfs_expire_all_delegations(clp);
-	if (test_and_set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state) == 0)
-		nfs4_schedule_state_manager(clp);
+	set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+	nfs4_schedule_state_manager(clp);
+
 	dprintk("%s: server %s declared a backchannel fault\n", __func__,
 			clp->cl_hostname);
 }
-- 
2.4.3

