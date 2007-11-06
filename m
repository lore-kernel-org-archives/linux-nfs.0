From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1/2] sunrpc: rpc_pipe_poll may miss available data in some
	cases
Date: Tue, 6 Nov 2007 13:05:36 -0500
Message-ID: <20071106180536.GB21755@fieldses.org>
References: <20071106180419.GA21755@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071106180419.GA21755@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@citi.umich.edu>

Pipe messages start out life on a queue on the inode, but when first
read they're moved to the filp's private pointer.  So it's possible for
a poll here to return null even though there's a partially read message
available.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpc_pipe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 18f0a8d..c59f3ca 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -280,7 +280,7 @@ rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
 	mask = POLLOUT | POLLWRNORM;
 	if (rpci->ops == NULL)
 		mask |= POLLERR | POLLHUP;
-	if (!list_empty(&rpci->pipe))
+	if (filp->private_data || !list_empty(&rpci->pipe))
 		mask |= POLLIN | POLLRDNORM;
 	return mask;
 }
-- 
1.5.3.5.561.g140d
