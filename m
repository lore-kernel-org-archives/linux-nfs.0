Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:49183 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaKLWcO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 17:32:14 -0500
Received: by mail-ig0-f178.google.com with SMTP id a13so3878525igq.5
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 14:32:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/5] NFSv4: Ensure that we remove NFSv4.0 delegations when state has expired
Date: Wed, 12 Nov 2014 17:31:50 -0500
Message-Id: <1415831514-47005-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
References: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 does not have TEST_STATEID/FREE_STATEID functionality, so
unlike NFSv4.1, the recovery procedure when stateids have expired or
have been revoked requires us to just forget the delegation.

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dca174ce8309..bdd880bddba4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2109,6 +2109,28 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
+static void nfs_finish_clear_delegation_stateid(struct nfs4_state *state)
+{
+	nfs_remove_bad_delegation(state->inode);
+	write_seqlock(&state->seqlock);
+	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
+	write_sequnlock(&state->seqlock);
+	clear_bit(NFS_DELEGATED_STATE, &state->flags);
+}
+
+static void nfs40_clear_delegation_stateid(struct nfs4_state *state)
+{
+	if (rcu_access_pointer(NFS_I(state->inode)->delegation) != NULL)
+		nfs_finish_clear_delegation_stateid(state);
+}
+
+static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+{
+	/* NFSv4.0 doesn't allow for delegation recovery on open expire */
+	nfs40_clear_delegation_stateid(state);
+	return nfs4_open_expired(sp, state);
+}
+
 #if defined(CONFIG_NFS_V4_1)
 static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 {
@@ -8330,7 +8352,7 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
-	.recover_open	= nfs4_open_expired,
+	.recover_open	= nfs40_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 	.establish_clid = nfs4_init_clientid,
 };
-- 
1.9.3

