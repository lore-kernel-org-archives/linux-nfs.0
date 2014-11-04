Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:51762 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaKDXgh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 18:36:37 -0500
Received: by mail-ie0-f170.google.com with SMTP id tp5so8688906ieb.29
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2014 15:36:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Don't try to reclaim delegation open state if recovery failed
Date: Tue,  4 Nov 2014 17:36:28 -0600
Message-Id: <1415144188-17193-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415144188-17193-2-git-send-email-trond.myklebust@primarydata.com>
References: <1415144188-17193-1-git-send-email-trond.myklebust@primarydata.com>
 <1415144188-17193-2-git-send-email-trond.myklebust@primarydata.com>
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
index 5853f53db732..4904a1dba937 100644
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

