Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33671 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbbJBPWs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 11:22:48 -0400
Received: by igbkq10 with SMTP id kq10so20867837igb.0
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2015 08:22:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Don't try to reclaim unused state owners
Date: Fri,  2 Oct 2015 11:22:45 -0400
Message-Id: <1443799365-6120-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we don't test if the state owner is in use before we try to
recover it. The problem is that if the refcount is zero, then the
state owner will be waiting on the lru list for garbage collection.
The expectation in that case is that if you bump the refcount, then
you must also remove the state owner from the lru list. Otherwise
the call to nfs4_put_state_owner will corrupt that list by trying
to add our state owner a second time.

Avoid the whole problem by just skipping state owners that hold no
state.

Reported-by: Andrew W Elble <aweits@rit.edu>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5db324635e92..d854693a15b0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1725,7 +1725,8 @@ restart:
 			if (!test_and_clear_bit(ops->owner_flag_bit,
 							&sp->so_flags))
 				continue;
-			atomic_inc(&sp->so_count);
+			if (!atomic_inc_not_zero(&sp->so_count))
+				continue;
 			spin_unlock(&clp->cl_lock);
 			rcu_read_unlock();
 
-- 
2.4.3

