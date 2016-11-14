Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34743 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753423AbcKNQUF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 11:20:05 -0500
Received: by mail-it0-f66.google.com with SMTP id q124so15178982itd.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 08:20:05 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] NFSv4: Don't call close if the open stateid has already been cleared
Date: Mon, 14 Nov 2016 11:19:56 -0500
Message-Id: <1479140396-17779-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
 <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure we test to see if the open stateid is actually set, before we
send a CLOSE.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b7b0080977c0..b801040c9585 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3129,7 +3129,8 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	} else if (is_rdwr)
 		calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;
 
-	if (!nfs4_valid_open_stateid(state))
+	if (!nfs4_valid_open_stateid(state) ||
+	    test_bit(NFS_OPEN_STATE, &state->flags) == 0)
 		call_close = 0;
 	spin_unlock(&state->owner->so_lock);
 
-- 
2.7.4

