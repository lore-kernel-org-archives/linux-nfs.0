Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42282 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751515AbeCRMhG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Mar 2018 08:37:06 -0400
From: Jeff Layton <jlayton@kernel.org>
To: trondmy@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] nfs4: always reset notified flag to false before repolling for lock
Date: Sun, 18 Mar 2018 08:37:01 -0400
Message-Id: <20180318123703.11256-2-jlayton@kernel.org>
In-Reply-To: <20180318123703.11256-1-jlayton@kernel.org>
References: <20180318123703.11256-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

We may get a notification and lose the race to another client. Ensure
that we wait again for a notification in that case.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47f3c273245e..5ab28454f117 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6673,6 +6673,7 @@ nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 	add_wait_queue(q, &wait);
 
 	while(!signalled()) {
+		waiter.notified = false;
 		status = nfs4_proc_setlk(state, cmd, request);
 		if ((status != -EAGAIN) || IS_SETLK(cmd))
 			break;
-- 
2.14.3

