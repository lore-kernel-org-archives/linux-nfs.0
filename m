Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1393 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab0IEBxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Sep 2010 21:53:12 -0400
From: Joe Perches <joe@perches.com>
To: Jiri Kosina <trivial@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 12/13] net/sunrpc/rpc_pipe.c: Remove unnecessary casts of private_data
Date: Sat,  4 Sep 2010 18:52:53 -0700
Message-Id: <dda96f0e94bd038179ae11dab4d73a7ab704276b.1283650107.git.joe@perches.com>
In-Reply-To: <cover.1283650107.git.joe@perches.com>
References: <cover.1283650107.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/rpc_pipe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 95ccbcf..1f7fc50 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -204,7 +204,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 	mutex_lock(&inode->i_mutex);
 	if (rpci->ops == NULL)
 		goto out;
-	msg = (struct rpc_pipe_msg *)filp->private_data;
+	msg = filp->private_data;
 	if (msg != NULL) {
 		spin_lock(&inode->i_lock);
 		msg->errno = -EAGAIN;
@@ -322,7 +322,7 @@ rpc_pipe_ioctl_unlocked(struct file *filp, unsigned int cmd, unsigned long arg)
 		len = rpci->pipelen;
 		if (filp->private_data) {
 			struct rpc_pipe_msg *msg;
-			msg = (struct rpc_pipe_msg *)filp->private_data;
+			msg = filp->private_data;
 			len += msg->len - msg->copied;
 		}
 		return put_user(len, (int __user *)arg);
-- 
1.7.2.19.g9a302

