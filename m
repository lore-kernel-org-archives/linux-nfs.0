Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:51327 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab2FKODw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 10:03:52 -0400
Received: by vbbff1 with SMTP id ff1so2230037vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jun 2012 07:03:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
Cc: jplatte@naasa.net, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        jmdebruin@xmsnet.nl
Subject: [PATCH] rpc_pipefs: allow rpc_purge_list to take a NULL waitq pointer
Date: Mon, 11 Jun 2012 10:03:42 -0400
Message-Id: <1339423422-22474-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1339340441.4751.1.camel@lade.trondhjem.org>
References: <1339340441.4751.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the event that we don't have a dentry for a rpc_pipefs pipe, we still
need to allow the queue_timeout job to clean out the queue. There's just
no waitq to wake up in that event.

Cc: stable@kernel.org
Reported-by: Hans de Bruin <jmdebruin@xmsnet.nl>
Reported-by: Joerg Platte <jplatte@naasa.net>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 0404047..21fde99 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -71,7 +71,9 @@ static void rpc_purge_list(wait_queue_head_t *waitq, struct list_head *head,
 		msg->errno = err;
 		destroy_msg(msg);
 	} while (!list_empty(head));
-	wake_up(waitq);
+
+	if (waitq)
+		wake_up(waitq);
 }
 
 static void
@@ -91,11 +93,9 @@ rpc_timeout_upcall_queue(struct work_struct *work)
 	}
 	dentry = dget(pipe->dentry);
 	spin_unlock(&pipe->lock);
-	if (dentry) {
-		rpc_purge_list(&RPC_I(dentry->d_inode)->waitq,
-			       &free_list, destroy_msg, -ETIMEDOUT);
-		dput(dentry);
-	}
+	rpc_purge_list(dentry ? &RPC_I(dentry->d_inode)->waitq : NULL,
+			&free_list, destroy_msg, -ETIMEDOUT);
+	dput(dentry);
 }
 
 ssize_t rpc_pipe_generic_upcall(struct file *filp, struct rpc_pipe_msg *msg,
-- 
1.7.7.6

