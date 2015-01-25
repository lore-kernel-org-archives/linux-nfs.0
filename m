Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:51164 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAYAR0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:17:26 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so3316306ier.10
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:17:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Always do open_to_lock_owner if the lock stateid is uninitialised
Date: Sat, 24 Jan 2015 19:17:18 -0500
Message-Id: <1422145041-81669-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145041-81669-2-git-send-email-trond.myklebust@primarydata.com>
References: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The original text in RFC3530 was terribly confusing since it conflated
lockowners and lock stateids. RFC3530bis clarifies that you must use
open_to_lock_owner when there is no lock state for that file+lockowner
combination.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index db9d98eda07b..f12ded041a42 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5611,7 +5611,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
 		goto out_wait;
 	/* Do we need to do an open_to_lock_owner? */
-	if (!(data->arg.lock_seqid->sequence->flags & NFS_SEQID_CONFIRMED)) {
+	if (!test_bit(NFS_LOCK_INITIALIZED, &data->lsp->ls_flags)) {
 		if (nfs_wait_on_sequence(data->arg.open_seqid, task) != 0) {
 			goto out_release_lock_seqid;
 		}
-- 
2.1.0

