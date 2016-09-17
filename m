Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34317 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756504AbcIQFN7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:59 -0400
Received: by mail-io0-f194.google.com with SMTP id y139so2395586ioy.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 24/25] NFSv4: Don't test open_stateid unless it is set
Date: Sat, 17 Sep 2016 01:13:32 -0400
Message-Id: <1474089213-104014-25-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-24-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to test the NFS_OPEN_STATE flag for whether or not the
open_stateid is valid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 08c6e46c5b95..e4f2008cde7d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2583,6 +2583,11 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 	struct rpc_cred *cred = state->owner->so_cred;
 	int status;
 
+	if (test_bit(NFS_OPEN_STATE, &state->flags) == 0) {
+		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+			return NFS_OK;
+		return -NFS4ERR_BAD_STATEID;
+	}
 	/* If a state reset has been done, test_stateid is unneeded */
 	if ((test_bit(NFS_O_RDONLY_STATE, &state->flags) == 0) &&
 	    (test_bit(NFS_O_WRONLY_STATE, &state->flags) == 0) &&
-- 
2.7.4

