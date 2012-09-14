Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:54524 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124Ab2INVX1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:23:27 -0400
Received: by ggdk6 with SMTP id k6so1097291ggd.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:23:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] NFS: Slow down state manager after an unhandled error
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:23:23 -0400
Message-ID: <20120914212323.1635.78058.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 55148de..d6e0d63 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2008,6 +2008,7 @@ out_error:
 	pr_warn_ratelimited("NFS: state manager%s%s failed on NFSv4 server %s"
 			" with error %d\n", section_sep, section,
 			clp->cl_hostname, -status);
+	ssleep(1);
 	nfs4_end_drain_session(clp);
 	nfs4_clear_state_manager_bit(clp);
 }

