Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35199 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752360AbdHIBjh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Aug 2017 21:39:37 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so3684961ioi.2
        for <linux-nfs@vger.kernel.org>; Tue, 08 Aug 2017 18:39:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Ignore NFS4ERR_OLD_STATEID in nfs41_check_open_stateid()
Date: Tue,  8 Aug 2017 21:39:28 -0400
Message-Id: <20170809013928.35475-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the call to TEST_STATEID returns NFS4ERR_OLD_STATEID, then it just
means we raced with other calls to OPEN.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15e91f003adc..1c73aa92b079 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2553,9 +2553,8 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_OPEN_STATE, &state->flags);
 		stateid->type = NFS4_INVALID_STATEID_TYPE;
-	}
-	if (status != NFS_OK)
 		return status;
+	}
 	if (nfs_open_stateid_recover_openmode(state))
 		return -NFS4ERR_OPENMODE;
 	return NFS_OK;
-- 
2.13.4

