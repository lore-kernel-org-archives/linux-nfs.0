Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34260 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965901AbcIVRkE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:04 -0400
Received: by mail-it0-f65.google.com with SMTP id 186so5344146itf.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:40:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 27/31] NFSv4: Mark the lock and open stateids as invalid after freeing them
Date: Thu, 22 Sep 2016 13:39:17 -0400
Message-Id: <1474565961-21303-28-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-27-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-26-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-27-git-send-email-trond.myklebust@primarydata.com>
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

