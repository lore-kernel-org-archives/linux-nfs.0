Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:42734 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841Ab3GCUZq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jul 2013 16:25:46 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Waiman Long <Waiman.Long@hp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Andi Kleen <andi@firstfloor.org>,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>
Subject: [PATCH v3 24/25] sunrpc: Change how dentry's d_lock field is accessed
Date: Wed,  3 Jul 2013 16:25:32 -0400
Message-Id: <1372883132-23410-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ingo Molnar <mingo@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because of the changes made in dcache.h header file, files that
use the d_lock field of the dentry structure need to be changed
accordingly. All the d_lock's spin_lock() and spin_unlock() calls
are replaced by the corresponding d_lock() and d_unlock() calls.
There is no change in logic and everything should just work.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 net/sunrpc/rpc_pipe.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e7ce4b3..58bc128 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -427,14 +427,14 @@ rpc_info_open(struct inode *inode, struct file *file)
 	if (!ret) {
 		struct seq_file *m = file->private_data;
 
-		spin_lock(&file->f_path.dentry->d_lock);
+		d_lock(file->f_path.dentry);
 		if (!d_unhashed(file->f_path.dentry))
 			clnt = RPC_I(inode)->private;
 		if (clnt != NULL && atomic_inc_not_zero(&clnt->cl_count)) {
-			spin_unlock(&file->f_path.dentry->d_lock);
+			d_unlock(file->f_path.dentry);
 			m->private = clnt;
 		} else {
-			spin_unlock(&file->f_path.dentry->d_lock);
+			d_unlock(file->f_path.dentry);
 			single_release(inode, file);
 			ret = -EINVAL;
 		}
-- 
1.7.1

