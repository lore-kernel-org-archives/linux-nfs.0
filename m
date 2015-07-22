Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34516 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbbGVSU5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 14:20:57 -0400
Received: by oigd21 with SMTP id d21so107050451oig.1
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 11:20:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: We must set NFS_OPEN_STATE flag in nfs_resync_open_stateid_locked
Date: Wed, 22 Jul 2015 13:59:13 -0400
Message-Id: <1437587953-11120-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, nfs4_select_rw_stateid() will always return the zero stateid
instead of the correct open stateid.

Fixes: f95549cf24660 ("NFSv4: More CLOSE/OPEN races")
Cc: stable@vger.kernel.org # 4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4ec0c9524c1d..c85ffe67b5f3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1200,12 +1200,15 @@ static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 
 static void nfs_resync_open_stateid_locked(struct nfs4_state *state)
 {
+	if (!(state->n_wronly || state->n_rdonly || state->n_rdwr))
+		return;
 	if (state->n_wronly)
 		set_bit(NFS_O_WRONLY_STATE, &state->flags);
 	if (state->n_rdonly)
 		set_bit(NFS_O_RDONLY_STATE, &state->flags);
 	if (state->n_rdwr)
 		set_bit(NFS_O_RDWR_STATE, &state->flags);
+	set_bit(NFS_OPEN_STATE, &state->flags);
 }
 
 static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
-- 
2.4.3

