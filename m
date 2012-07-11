Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58685 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab2GKUby (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:31:54 -0400
Received: by yenl2 with SMTP id l2so1692027yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:31:53 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/15] NFS: Slow down state manager after an unhandled error
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:31:52 -0400
Message-ID: <20120711203151.3767.79006.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the state manager thread is not actually able to fully recover from
some situation, it wakes up waiters, who kick off a new state manager
thread.  Quite often the fresh invocation of the state manager is just
as successful.

This results in a livelock as the client dumps thousands of NFS
requests a second on the network in a vain attempt to recover.  Not
very friendly.

To mitigate this situation, add a delay in the state manager after
an unhandled error, so that the client sends just a few requests
every second in this case.
---

 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5e3bebc..38959eb 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2151,6 +2151,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 out_error:
 	pr_warn_ratelimited("NFS: state manager failed on NFSv4 server %s"
 			" with error %d\n", clp->cl_hostname, -status);
+	ssleep(1);
 	nfs4_end_drain_session(clp);
 	nfs4_clear_state_manager_bit(clp);
 }

