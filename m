Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:41735 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbaKLWcY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 17:32:24 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so3882679igb.4
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 14:32:24 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] NFS: Don't try to reclaim delegation open state if recovery failed
Date: Wed, 12 Nov 2014 17:31:54 -0500
Message-Id: <1415831514-47005-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415831514-47005-5-git-send-email-trond.myklebust@primarydata.com>
References: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-2-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-3-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-4-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If state recovery failed, then we should not attempt to reclaim delegated
state.

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index e5f473d13e24..7f3f60641344 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -125,6 +125,8 @@ again:
 			continue;
 		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
 			continue;
+		if (!nfs4_valid_open_stateid(state))
+			continue;
 		if (!nfs4_stateid_match(&state->stateid, stateid))
 			continue;
 		get_nfs_open_context(ctx);
-- 
1.9.3

