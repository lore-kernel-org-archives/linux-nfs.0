Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36344 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbcFYXUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2016 19:20:55 -0400
Received: by mail-io0-f196.google.com with SMTP id s63so20585725ioi.3
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2016 16:20:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix another OPEN_DOWNGRADE bug
Date: Sat, 25 Jun 2016 19:19:28 -0400
Message-Id: <1466896768-23657-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Olga Kornievskaia reports that the following test fails to trigger
an OPEN_DOWNGRADE on the wire, and only triggers the final CLOSE.

	fd0 = open(foo, RDRW)   -- should be open on the wire for "both"
	fd1 = open(foo, RDONLY)  -- should be open on the wire for "read"
	close(fd0) -- should trigger an open_downgrade
	read(fd1)
	close(fd1)

The issue is that we're missing a check for whether or not the current
state transitioned from an O_RDWR state as opposed to having transitioned
from a combination of O_RDONLY and O_WRONLY.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: cd9288ffaea4 ("NFSv4: Fix another bug in the close/open_downgrade code")
Cc: stable@vger.kernel.org # 2.6.33+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 406dd3eb68e2..ff416d0e24bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2882,12 +2882,11 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 			call_close |= is_wronly;
 		else if (is_wronly)
 			calldata->arg.fmode |= FMODE_WRITE;
+		if (calldata->arg.fmode != (FMODE_READ|FMODE_WRITE))
+			call_close |= is_rdwr;
 	} else if (is_rdwr)
 		calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;
 
-	if (calldata->arg.fmode == 0)
-		call_close |= is_rdwr;
-
 	if (!nfs4_valid_open_stateid(state))
 		call_close = 0;
 	spin_unlock(&state->owner->so_lock);
-- 
2.7.4

