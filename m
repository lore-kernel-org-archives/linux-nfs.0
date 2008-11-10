From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Mon, 10 Nov 2008 16:27:59 -0500
Message-ID: <20081110212759.GM19053@fieldses.org>
References: <1226264683-28650-6-git-send-email-bfields@citi.umich.edu> <1226344297.7599.41.camel@heimdal.trondhjem.org> <20081110194900.GD19053@fieldses.org> <1226347279.7599.47.camel@heimdal.trondhjem.org> <20081110200727.GE19053@fieldses.org> <1226347898.7599.49.camel@heimdal.trondhjem.org> <20081110201708.GF19053@fieldses.org> <1226348515.7599.52.camel@heimdal.trondhjem.org> <20081110202640.GG19053@fieldses.org> <1226351883.7599.103.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58053 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbYKJV2B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 16:28:01 -0500
In-Reply-To: <1226351883.7599.103.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2008 at 04:18:03PM -0500, Trond Myklebust wrote:
> On Mon, 2008-11-10 at 15:26 -0500, J. Bruce Fields wrote:
> > Yep.  And when we're in that situation, last_close is true, so
> > 
> > 	if (last_close && ops->release_pipe)
> > 		ops->release_pipe(inode)
> > 
> > does ensure that calls to the ->open_pipe() and ->release_pipe() methods
> > balance, as originally claimed.
> > 
> > Maybe it'd be clearer to call that variable "still_open", or something?
> > 
> > 	still_open = rpci->nreaders != 0 || rpci->nwriters != 0;
> > 	...
> > 	if (still_open && ops->release_pipe)
> > 		ops->release_pipe(inode)
> 
> Call it 'need_release'. It is definitely confusing right now...

Sure.

--b.

commit 572df09a77f3cfdca9d5fba4ca736919294eb177
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Nov 7 18:53:24 2008 -0500

    rpc: call release_pipe only on last close
    
    I can't see any reason we need to call this until either the kernel or
    the last gssd closes the pipe.
    
    Also, this allows to guarantee that open_pipe and release_pipe are
    called strictly in pairs; open_pipe on gssd's first open, release_pipe
    on gssd's last close (or on the close of the kernel side of the pipe, if
    that comes first).
    
    That will make it very easy for the gss code to keep track of which
    pipes gssd is using.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 4171ab7..a68aaac 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -126,13 +126,14 @@ rpc_close_pipes(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_ops *ops;
+	int need_release;
 
 	mutex_lock(&inode->i_mutex);
 	ops = rpci->ops;
 	if (ops != NULL) {
 		LIST_HEAD(free_list);
-
 		spin_lock(&inode->i_lock);
+		need_release = rpci->nreaders != 0 || rpci->nwriters != 0;
 		rpci->nreaders = 0;
 		list_splice_init(&rpci->in_upcall, &free_list);
 		list_splice_init(&rpci->pipe, &free_list);
@@ -141,7 +142,7 @@ rpc_close_pipes(struct inode *inode)
 		spin_unlock(&inode->i_lock);
 		rpc_purge_list(rpci, &free_list, ops->destroy_msg, -EPIPE);
 		rpci->nwriters = 0;
-		if (ops->release_pipe)
+		if (need_release && ops->release_pipe)
 			ops->release_pipe(inode);
 		cancel_delayed_work_sync(&rpci->queue_timeout);
 	}
@@ -169,12 +170,13 @@ static int
 rpc_pipe_open(struct inode *inode, struct file *filp)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
-	int first_open = rpci->nreaders == 0 && rpci->nwriters == 0;
+	int first_open;
 	int res = -ENXIO;
 
 	mutex_lock(&inode->i_mutex);
 	if (rpci->ops == NULL)
 		goto out;
+	first_open = rpci->nreaders == 0 && rpci->nwriters == 0;
 	if (first_open && rpci->ops->open_pipe) {
 		res = rpci->ops->open_pipe(inode);
 		if (res)
@@ -195,6 +197,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_msg *msg;
+	int last_close;
 
 	mutex_lock(&inode->i_mutex);
 	if (rpci->ops == NULL)
@@ -221,7 +224,8 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 					rpci->ops->destroy_msg, -EAGAIN);
 		}
 	}
-	if (rpci->ops->release_pipe)
+	last_close = rpci->nwriters == 0 && rpci->nreaders == 0;
+	if (last_close && rpci->ops->release_pipe)
 		rpci->ops->release_pipe(inode);
 out:
 	mutex_unlock(&inode->i_mutex);
