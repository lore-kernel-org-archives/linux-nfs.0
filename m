Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35432 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcLEAzd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2016 19:55:33 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so11312355ioe.2
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2016 16:55:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Don't schedule lease recovery in nfs4_schedule_session_recovery()
Date: Sun,  4 Dec 2016 19:40:23 -0500
Message-Id: <20161205004023.40957-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161205004023.40957-1-trond.myklebust@primarydata.com>
References: <20161205004023.40957-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the session has an error, then we want to start by recovering the
session, as any SEQUENCE we send is going to fail with a session
error.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 26b6b8b0cae3..95baf7d340f0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2193,7 +2193,7 @@ void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 		set_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
 	}
-	nfs4_schedule_lease_recovery(clp);
+	nfs4_schedule_state_manager(clp);
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_session_recovery);
 
-- 
2.9.3

