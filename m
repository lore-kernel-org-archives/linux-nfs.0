Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:32774 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932692AbcITQ4y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:54 -0400
Received: by mail-qk0-f194.google.com with SMTP id n66so1454799qkf.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 27/29] NFSv4: Mark the lock and open stateids as invalid after freeing them
Date: Tue, 20 Sep 2016 12:56:09 -0400
Message-Id: <1474390571-17106-28-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474390571-17106-27-git-send-email-trond.myklebust@primarydata.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-14-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-15-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-16-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-17-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-18-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-19-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-20-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-21-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-22-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-23-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-24-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-25-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-26-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-27-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 995b646c9aea..2e1f9c30b805 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2560,6 +2560,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 			if (status == -NFS4ERR_EXPIRED ||
 			    status == -NFS4ERR_BAD_STATEID) {
 				clear_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
+				lsp->ls_stateid.type = NFS4_INVALID_STATEID_TYPE;
 				if (!recover_lost_locks)
 					set_bit(NFS_LOCK_LOST, &lsp->ls_flags);
 			} else if (status != NFS_OK) {
@@ -2605,6 +2606,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_OPEN_STATE, &state->flags);
+		stateid->type = NFS4_INVALID_STATEID_TYPE;
 	}
 	return status;
 }
-- 
2.7.4

