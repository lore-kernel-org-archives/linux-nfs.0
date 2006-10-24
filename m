From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 4] Inherit soft/intr flags from NFS mount to
	lockd requests.
Date: Tue, 24 Oct 2006 12:49:09 +1000
Message-ID: <1061024024909.4785@suse.de>
References: <20061024122646.4426.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcCLr-0001q8-SI
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:49:16 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcCLs-0001Of-6C
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:49:17 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


With this patch, lock requests with have the same soft/hard and
intr/nointr options as the mount that the lock request are for.
Without the patch all lock requests are hard/nointr

WARNING: this is only safe if the client responds to a failed lock
 request by queuing a hard, async unlock request.  I don't know if the
 current client does this.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntproc.c |    8 ++++----
 ./fs/lockd/host.c     |    7 ++++++-
 ./fs/lockd/svc4proc.c |    2 +-
 ./fs/lockd/svclock.c  |    2 +-
 ./fs/lockd/svcproc.c  |    2 +-
 5 files changed, 13 insertions(+), 8 deletions(-)

diff .prev/fs/lockd/clntproc.c ./fs/lockd/clntproc.c
--- .prev/fs/lockd/clntproc.c	2006-10-24 12:25:25.000000000 +1000
+++ ./fs/lockd/clntproc.c	2006-10-24 12:20:39.000000000 +1000
@@ -193,7 +193,7 @@ nlmclnt_proc(struct inode *inode, int cm
 		sigfillset(&current->blocked);	/* Mask all signals */
 		recalc_sigpending();
 
-		call->a_flags = RPC_TASK_ASYNC;
+		call->a_flags |= RPC_TASK_ASYNC;
 	}
 	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 
@@ -305,7 +305,7 @@ nlmclnt_call(struct nlm_rqst *req, u32 p
 		msg.rpc_proc = &clnt->cl_procinfo[proc];
 
 		/* Perform the RPC call. If an error occurs, try again */
-		if ((status = rpc_call_sync(clnt, &msg, 0)) < 0) {
+		if ((status = rpc_call_sync(clnt, &msg, req->a_flags)) < 0) {
 			dprintk("lockd: rpc_call returned error %d\n", -status);
 			switch (status) {
 			case -EPROTONOSUPPORT:
@@ -372,7 +372,7 @@ static int __nlm_async_call(struct nlm_r
 	msg->rpc_proc = &clnt->cl_procinfo[proc];
 
         /* bootstrap and kick off the async RPC call */
-        status = rpc_call_async(clnt, msg, RPC_TASK_ASYNC, tk_ops, req);
+        status = rpc_call_async(clnt, msg, req->a_flags, tk_ops, req);
 	if (status == 0)
 		return 0;
 out_err:
@@ -701,7 +701,7 @@ static int nlmclnt_cancel(struct nlm_hos
 	req = nlm_alloc_call(nlm_get_host(host));
 	if (!req)
 		return -ENOMEM;
-	req->a_flags = RPC_TASK_ASYNC;
+	req->a_flags |= RPC_TASK_ASYNC;
 
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.block = block;

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-10-24 12:25:25.000000000 +1000
+++ ./fs/lockd/host.c	2006-10-24 12:21:07.000000000 +1000
@@ -237,9 +237,14 @@ nlm_bind_host(struct nlm_host *host)
 			.authflavor	= RPC_AUTH_UNIX,
 			.flags		= (RPC_CLNT_CREATE_HARDRTRY |
 					   RPC_CLNT_CREATE_NOPING |
+					   RPC_CLNT_CREATE_INTR |
 					   RPC_CLNT_CREATE_AUTOBIND),
 		};
-
+		/* Note: The HARDRTRY and INTR flags are chosen so they
+		 * can be overrided by the flags argument to rpc_call_a?sync.
+		 * rpc_init_task forces 'soft' and 'nointr' from the client
+		 * onto the task.
+		 */
 		clnt = rpc_create(&args);
 		if (!IS_ERR(clnt))
 			host->h_rpcclnt = clnt;

diff .prev/fs/lockd/svc4proc.c ./fs/lockd/svc4proc.c
--- .prev/fs/lockd/svc4proc.c	2006-10-24 12:25:25.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2006-10-24 12:20:39.000000000 +1000
@@ -276,7 +276,7 @@ static __be32 nlm4svc_callback(struct sv
 		return stat;
 	}
 
-	call->a_flags = RPC_TASK_ASYNC;
+	call->a_flags |= RPC_TASK_ASYNC;
 	if (nlm_async_reply(call, proc, &nlm4svc_callback_ops) < 0)
 		return rpc_system_err;
 	return rpc_success;

diff .prev/fs/lockd/svclock.c ./fs/lockd/svclock.c
--- .prev/fs/lockd/svclock.c	2006-10-24 12:25:25.000000000 +1000
+++ ./fs/lockd/svclock.c	2006-10-24 12:20:39.000000000 +1000
@@ -217,7 +217,7 @@ nlmsvc_create_block(struct svc_rqst *rqs
 
 	/* Set up RPC arguments for callback */
 	block->b_call = call;
-	call->a_flags   = RPC_TASK_ASYNC;
+	call->a_flags |= RPC_TASK_ASYNC;
 	call->a_block = block;
 
 	return block;

diff .prev/fs/lockd/svcproc.c ./fs/lockd/svcproc.c
--- .prev/fs/lockd/svcproc.c	2006-10-24 12:25:25.000000000 +1000
+++ ./fs/lockd/svcproc.c	2006-10-24 12:20:39.000000000 +1000
@@ -305,7 +305,7 @@ static __be32 nlmsvc_callback(struct svc
 		return stat;
 	}
 
-	call->a_flags = RPC_TASK_ASYNC;
+	call->a_flags |= RPC_TASK_ASYNC;
 	if (nlm_async_reply(call, proc, &nlmsvc_callback_ops) < 0)
 		return rpc_system_err;
 	return rpc_success;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
