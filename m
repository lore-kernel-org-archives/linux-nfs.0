Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:50927 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbaDRSpK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:10 -0400
Received: by mail-ig0-f173.google.com with SMTP id hl10so950093igb.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/70] NFSd: call rpc_destroy_wait_queue() from free_client()
Date: Fri, 18 Apr 2014 14:43:57 -0400
Message-Id: <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mainly to ensure that we don't leave any hanging timers.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 230d21cb1717..32b699bebb9c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1107,6 +1107,7 @@ free_client(struct nfs4_client *clp)
 		WARN_ON_ONCE(atomic_read(&ses->se_ref));
 		free_session(ses);
 	}
+	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
 	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
 	idr_destroy(&clp->cl_stateids);
-- 
1.9.0

