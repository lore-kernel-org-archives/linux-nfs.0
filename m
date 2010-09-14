Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60415 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753100Ab0INI7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 04:59:50 -0400
Message-ID: <4C8F3971.1050306@cn.fujitsu.com>
Date: Tue, 14 Sep 2010 16:59:29 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: [RFC][PATCH] rpc_pipe_msg should be protected by inode->i_lock when
 purge it.
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Maybe rpc_pipe_msg should be protected by inode->i_lock when purge the free_list.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 net/sunrpc/rpc_pipe.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8d63f8f..24b2714 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -47,8 +47,10 @@ static void rpc_purge_list(struct rpc_inode *rpci, struct list_head *head,
 		return;
 	do {
 		msg = list_entry(head->next, struct rpc_pipe_msg, list);
+		spin_lock(&rpci->vfs_inode->i_lock);
 		list_del(&msg->list);
 		msg->errno = err;
+		spin_unlock(&rpci->vfs_inode->i_lock);
 		destroy_msg(msg);
 	} while (!list_empty(head));
 	wake_up(&rpci->waitq);
-- 
1.6.5.2



-- 
Regards
Bian Naimeng

