From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/2] sunrpc: document the rpc_pipefs kernel api
Date: Tue, 6 Nov 2007 13:06:03 -0500
Message-ID: <20071106180603.GC21755@fieldses.org>
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

Add kerneldoc comments for the rpc_pipefs.c functions that are exported.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpc_pipe.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index c59f3ca..5364e2e 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -76,6 +76,16 @@ rpc_timeout_upcall_queue(struct work_struct *work)
 	rpc_purge_list(rpci, &free_list, destroy_msg, -ETIMEDOUT);
 }
 
+/**
+ * rpc_queue_upcall
+ * @inode: inode of upcall pipe on which to queue given message
+ * @msg: message to queue
+ *
+ * Call with an @inode created by rpc_mkpipe() to queue an upcall.
+ * A userspace process may then later read the upcall by performing a
+ * read on an open file for this inode.  It is up to the caller to
+ * initialize the fields of @msg (other than @msg->list) appropriately.
+ */
 int
 rpc_queue_upcall(struct inode *inode, struct rpc_pipe_msg *msg)
 {
@@ -663,7 +673,16 @@ rpc_lookup_negative(char *path, struct nameidata *nd)
 	return dentry;
 }
 
-
+/**
+ * rpc_mkdir - Create a new directory in rpc_pipefs
+ * @path: path from the rpc_pipefs root to the new directory
+ * @rpc_clnt: rpc client to associate with this directory
+ *
+ * This creates a directory at the given @path associated with
+ * @rpc_clnt, which will contain a file named "info" with some basic
+ * information about the client, together with any "pipes" that may
+ * later be created using rpc_mkpipe().
+ */
 struct dentry *
 rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
 {
@@ -699,6 +718,10 @@ err_dput:
 	goto out;
 }
 
+/**
+ * rpc_rmdir - Remove a directory created with rpc_mkdir()
+ * @dentry: directory to remove
+ */
 int
 rpc_rmdir(struct dentry *dentry)
 {
@@ -717,6 +740,25 @@ rpc_rmdir(struct dentry *dentry)
 	return error;
 }
 
+/**
+ * rpc_mkpipe - make an rpc_pipefs file for kernel<->userspace communication
+ * @parent: dentry of directory to create new "pipe" in
+ * @name: name of pipe
+ * @private: private data to associate with the pipe, for the caller's use
+ * @ops: operations defining the behavior of the pipe: upcall, downcall,
+ *	release_pipe, and destroy_msg.
+ *
+ * Data is made available for userspace to read by calls to
+ * rpc_queue_upcall().  The actual reads will result in calls to
+ * @ops->upcall, which will be called with the file pointer,
+ * message, and userspace buffer to copy to.
+ *
+ * Writes can come at any time, and do not necessarily have to be
+ * responses to upcalls.  They will result in calls to @msg->downcall.
+ *
+ * The @private argument passed here will be available to all these methods
+ * from the file pointer, via RPC_I(file->f_dentry->d_inode)->private.
+ */
 struct dentry *
 rpc_mkpipe(struct dentry *parent, const char *name, void *private, struct rpc_pipe_ops *ops, int flags)
 {
@@ -764,6 +806,14 @@ err_dput:
 	goto out;
 }
 
+/**
+ * rpc_unlink - remove a pipe
+ * @dentry: dentry for the pipe, as returned from rpc_mkpipe
+ *
+ * After this call, lookups will no longer find the pipe, and any
+ * attempts to read or write using preexisting opens of the pipe will
+ * return -EPIPE.
+ */
 int
 rpc_unlink(struct dentry *dentry)
 {
-- 
1.5.3.5.561.g140d
