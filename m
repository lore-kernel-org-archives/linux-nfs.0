From: Joe Perches <joe@perches.com>
Subject: [PATCH 33/36] net/sunrpc: Remove unnecessary casts of private_data
Date: Mon, 12 Jul 2010 13:50:25 -0700
Message-ID: <08a3bf26a7a95d9e89662bd4cd00ddccadcd1636.1278967121.git.joe@perches.com>
References: <cover.1278967120.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1278967120.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
1.7.1.337.g6068.dirty
