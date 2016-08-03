Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46104 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757964AbcHCUMB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 16:12:01 -0400
Subject: [RFC PATCH] sunrpc: do not allow process to freeze within RPC state
 machine
From: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com,
        davem@davemloft.net, devel@openvz.org
Date: Wed, 03 Aug 2016 20:54:50 +0400
Message-ID: <20160803165412.22407.47399.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise freezer cgroup state might never become "FROZEN".

Here is a deadlock scheme for 2 processes in one freezer cgroup, which is
freezing:

CPU 0                                   CPU 1
--------                                --------
do_last
inode_lock(dir->d_inode)
vfs_create
nfs_create
...
__rpc_execute
rpc_wait_bit_killable
__refrigerator
                                        do_last
                                        inode_lock(dir->d_inode)

So, the problem is that one process takes directory inode mutex, executes
creation request and goes to refrigerator.
Another one waits till directory lock is released, remains "thawed" and thus
freezer cgroup state never becomes "FROZEN".

Notes:
1) Interesting, that this is not a pure deadlock: one can thaw cgroup and then
freeze it again.
2) The issue was introduced by commit d310310cbff18ec385c6ab4d58f33b100192a96a.
3) This patch is not aimed to fix the issue, but to show the problem root.
Look like this problem moght be applicable to other hunks from the commit,
mentioned above.


Signed-off-by: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
---
 net/sunrpc/sched.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9ae5885..ec7ccc1 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -253,7 +253,6 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
 
 static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
 {
-	freezable_schedule_unsafe();
 	if (signal_pending_state(mode, current))
 		return -ERESTARTSYS;
 	return 0;

