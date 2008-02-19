From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/4] NFS: Ensure that the asynchronous RPC calls complete
	on nfsiod.
Date: Tue, 19 Feb 2008 18:05:00 -0500
Message-ID: <20080219230500.22007.93991.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080219230459.22007.10990.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53378 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbYBSXPA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 18:15:00 -0500
In-Reply-To: <20080219230459.22007.10990.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to ensure that rpc_call_ops that involve mntput() are run on nfsiod
rather than on rpciod, so that they don't deadlock when the resulting
umount calls rpc_shutdown_client(). Hence we specify that read, write and
commit calls must complete on nfsiod.
Ditto for NFSv4 open, lock, locku and close asynchronous calls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c   |    4 ++++
 fs/nfs/nfs4proc.c |    6 ++++++
 fs/nfs/read.c     |    1 +
 fs/nfs/write.c    |    2 ++
 4 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e017040..e442005 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -280,6 +280,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		.rpc_client = NFS_CLIENT(inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs_read_direct_ops,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	unsigned int pgbase;
@@ -446,6 +447,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
 		.callback_ops = &nfs_write_direct_ops,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 
@@ -537,6 +539,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 		.rpc_message = &msg,
 		.callback_ops = &nfs_commit_direct_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 
@@ -683,6 +686,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		.rpc_client = NFS_CLIENT(inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs_write_direct_ops,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	size_t wsize = NFS_SERVER(inode)->wsize;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ce0786..b6db833 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -51,6 +51,7 @@
 
 #include "nfs4_fs.h"
 #include "delegation.h"
+#include "internal.h"
 #include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
@@ -773,6 +774,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_open_confirm_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	int status;
@@ -910,6 +912,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_open_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	int status;
@@ -1315,6 +1318,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 		.rpc_client = server->client,
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_close_ops,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	int status = -ENOMEM;
@@ -3235,6 +3239,7 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		.rpc_client = NFS_CLIENT(lsp->ls_state->inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_locku_ops,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 
@@ -3419,6 +3424,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		.rpc_client = NFS_CLIENT(state->inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_lock_ops,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	int ret;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index fab0d37..87546cd 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -177,6 +177,7 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		.rpc_message = &msg,
 		.callback_ops = call_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC | swap_flags,
 	};
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fb6232a..593218f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -803,6 +803,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		.rpc_message = &msg,
 		.callback_ops = call_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = flags,
 		.priority = priority,
 	};
@@ -1187,6 +1188,7 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 		.rpc_message = &msg,
 		.callback_ops = &nfs_commit_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = flags,
 		.priority = priority,
 	};
