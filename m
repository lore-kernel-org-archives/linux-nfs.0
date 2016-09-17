Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35286 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756486AbcIQFN7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:59 -0400
Received: by mail-io0-f193.google.com with SMTP id q92so2389835ioi.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 25/25] NFSv4: Mark the lock and open stateids as invalid after freeing them
Date: Sat, 17 Sep 2016 01:13:33 -0400
Message-Id: <1474089213-104014-26-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-25-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-17-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-18-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-19-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-20-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-21-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-22-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-23-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-24-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-25-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e4f2008cde7d..b44ea0b2ed23 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2556,6 +2556,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 			if (status == -NFS4ERR_EXPIRED ||
 			    status == -NFS4ERR_BAD_STATEID) {
 				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
+				lsp->ls_stateid.type = NFS4_INVALID_STATEID_TYPE;
 				if (!recover_lost_locks)
 					set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
 			} else if (status != NFS_OK) {
@@ -2601,6 +2602,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_OPEN_STATE, &state->flags);
+		stateid->type = NFS4_INVALID_STATEID_TYPE;
 	}
 	return status;
 }
-- 
2.7.4

