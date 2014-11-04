Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:48593 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaKDXgd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 18:36:33 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so8385575iga.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2014 15:36:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4: Ensure that we remove delegations before recovering
Date: Tue,  4 Nov 2014 17:36:26 -0600
Message-Id: <1415144188-17193-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 does not have TEST_STATEID/FREE_STATEID functionality, so
unlike NFSv4.1, the recovery procedure when stateids have expired
requires us to just forget the delegation.

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 405bd95c1f58..d8f352d8c75f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2109,6 +2109,14 @@ static int nfs4_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
+static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *state)
+{
+	/* NFSv4.0 doesn't allow for delegation recovery on open expire */
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
+		nfs_remove_bad_delegation(state->inode);
+	return nfs4_open_expired(sp, state);
+}
+
 #if defined(CONFIG_NFS_V4_1)
 static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 {
@@ -8341,7 +8349,7 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
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

