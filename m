From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: [PATCH] granted call implementation for lockd
Date: Tue, 7 May 2002 19:45:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020507194543.B6484@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17596p-0003rJ-00
	for <nfs@lists.sourceforge.net>; Tue, 07 May 2002 10:50:48 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id TAA23236
          for <nfs@lists.sourceforge.net>; Tue, 7 May 2002 19:49:53 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g47Hjhw06516
	for nfs@lists.sourceforge.net; Tue, 7 May 2002 19:45:43 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,
This is a patch which permits a server lockd to use a granted call if the
client used a lock call (and still use granted_msg in case of a lock_msg).

In order to go around clients which doesn't respond to granted calls, the
granted call is a soft call. If there is a -EIO status, it reverts to
granted_msg, and to hard call. The code which handle this isn't clean, because
the rpc client is associated with the host, thus it isn't easy to make a change
from soft to hard or the reverse for a call and forget it afterwards. 
Any idea about that ?

Pat

--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.18-granted.diff"

diff -u --new-file -r linux-2.4.18.orig/fs/lockd/svc4proc.c linux-2.4.18.clean/fs/lockd/svc4proc.c
--- linux-2.4.18.orig/fs/lockd/svc4proc.c	Mon Apr 22 14:27:46 2002
+++ linux-2.4.18.clean/fs/lockd/svc4proc.c	Tue May  7 18:45:59 2002
@@ -459,6 +459,24 @@
 }
 
 /*
+ * client sent a GRANTED_RES, let's remove the associated block
+ */
+static int
+nlm4svc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
+                                                void            *resp)
+{
+        if (!nlmsvc_ops)
+                return rpc_success;
+
+        dprintk("lockd: GRANTED_RES   called\n");
+
+        nlmsvc_grant_reply(&rqstp->rq_addr, &argp->cookie, argp->status);
+        return rpc_success;
+}
+
+
+
+/*
  * This is the generic lockd callback for async RPC calls
  */
 static u32
@@ -523,7 +541,6 @@
 #define nlm4svc_proc_lock_res	nlm4svc_proc_null
 #define nlm4svc_proc_cancel_res	nlm4svc_proc_null
 #define nlm4svc_proc_unlock_res	nlm4svc_proc_null
-#define nlm4svc_proc_granted_res	nlm4svc_proc_null
 
 struct nlm_void			{ int dummy; };
 
@@ -553,7 +570,7 @@
   PROC(lock_res,	lockres,	norep,		res,	void),
   PROC(cancel_res,	cancelres,	norep,		res,	void),
   PROC(unlock_res,	unlockres,	norep,		res,	void),
-  PROC(granted_res,	grantedres,	norep,		res,	void),
+  PROC(granted_res,	res,		norep,		res,	void),
   /* statd callback */
   PROC(sm_notify,	reboot,		void,		reboot,	void),
   PROC(none,		void,		void,		void,	void),
diff -u --new-file -r linux-2.4.18.orig/fs/lockd/svclock.c linux-2.4.18.clean/fs/lockd/svclock.c
--- linux-2.4.18.orig/fs/lockd/svclock.c	Mon Apr 22 14:27:46 2002
+++ linux-2.4.18.clean/fs/lockd/svclock.c	Tue May  7 18:45:59 2002
@@ -143,14 +143,15 @@
  * Find a block with a given NLM cookie.
  */
 static inline struct nlm_block *
-nlmsvc_find_block(struct nlm_cookie *cookie)
+nlmsvc_find_block(struct nlm_cookie *cookie,  struct sockaddr_in *sin)
 {
 	struct nlm_block *block;
 
 	for (block = nlm_blocked; block; block = block->b_next) {
 		dprintk("cookie: head of blocked queue %p, block %p\n", 
 			nlm_blocked, block);
-		if (nlm_cookie_match(&block->b_call.a_args.cookie,cookie))
+		if (nlm_cookie_match(&block->b_call.a_args.cookie,cookie)
+				&& nlm_cmp_addr(sin, &block->b_host->h_addr))
 			break;
 	}
 
@@ -206,6 +207,10 @@
 	block->b_fnext  = file->f_blocks;
 	file->f_blocks  = block;
 
+	/* set up a msg type request or not depending on the call and client */
+	if (host->h_msg || rqstp->rq_proc == NLMPROC_GRANTED_MSG)
+			block->b_msg = 1;
+					
 	/* Set up RPC arguments for callback */
 	call = &block->b_call;
 	call->a_host    = host;
@@ -501,6 +506,8 @@
 	struct nlm_file		*file = block->b_file;
 	struct nlm_lock		*lock = &block->b_call.a_args.lock;
 	struct file_lock	*conflock;
+	struct rpc_clnt *clnt;
+	u32 proc;
 	int			error;
 
 	dprintk("lockd: grant blocked lock %p\n", block);
@@ -552,7 +559,13 @@
 
 	/* Call the client */
 	nlm_get_host(block->b_call.a_host);
-	if (nlmsvc_async_call(&block->b_call, NLMPROC_GRANTED_MSG,
+	if (!block->b_msg){
+			clnt = nlm_bind_host((&block->b_call)->a_host);
+			clnt->cl_softrtry = 1;
+			proc = NLMPROC_GRANTED;
+	}
+	else proc = NLMPROC_GRANTED_MSG;
+	if (nlmsvc_async_call(&block->b_call, proc,
 						nlmsvc_grant_callback) < 0)
 		nlm_release_host(block->b_call.a_host);
 	up(&file->f_sema);
@@ -572,28 +585,45 @@
 	struct nlm_rqst		*call = (struct nlm_rqst *) task->tk_calldata;
 	struct nlm_block	*block;
 	unsigned long		timeout;
-
-	dprintk("lockd: GRANT_MSG RPC callback\n");
-	dprintk("callback: looking for cookie %x \n", 
-		*(unsigned int *)(call->a_args.cookie.data));
+	struct sockaddr_in	*peer_addr = RPC_PEERADDR(task->tk_client); 	
+	struct rpc_clnt *clnt;
+	
+	dprintk("lockd: GRANT/GRANT_MSG RPC callback\n");
+	dprintk("callback: looking for cookie %x, host (%08x) \n", 
+		*(unsigned int *)(call->a_args.cookie.data), 
+		ntohl(peer_addr->sin_addr.s_addr));
 	lock_kernel();
-	if (!(block = nlmsvc_find_block(&call->a_args.cookie))) {
-		dprintk("lockd: no block for cookie %x\n", *(u32 *)(call->a_args.cookie.data));
+	if (!(block = nlmsvc_find_block(&call->a_args.cookie, peer_addr))) {
+		dprintk("lockd: no block for cookie %x, host (%08x)\n", 
+			*(u32 *)(call->a_args.cookie.data),
+			ntohl(peer_addr->sin_addr.s_addr));
 		goto out;
 	}
 
 	/* Technically, we should down the file semaphore here. Since we
 	 * move the block towards the head of the queue only, no harm
 	 * can be done, though. */
-	if (task->tk_status < 0) {
+	if (!block->b_msg && (task->tk_status == -EIO)) {
+		/* we tried a GRANTED callback but we got a timeout. revert to
+		 * GRANTED_MSG */
+		block->b_msg = 1;
+		(&block->b_call)->a_host->h_msg = 1;
+		clnt = nlm_bind_host((&block->b_call)->a_host);
+		clnt->cl_softrtry = 0;
+		timeout = 0;
+	} else if (task->tk_status < 0) {
 		/* RPC error: Re-insert for retransmission */
 		timeout = 10 * HZ;
 	} else if (block->b_done) {
 		/* Block already removed, kill it for real */
 		timeout = 0;
-	} else {
-		/* Call was successful, now wait for client callback */
+	} else if (block->b_msg){
+		/* GRANT_MSG Call was successful, now wait for client callback */
 		timeout = 60 * HZ;
+	} else {
+		/* GRANT was successful, schedule response handling */
+		block->b_responded = 1;
+		timeout = 0;
 	}
 	nlmsvc_insert_block(block, timeout);
 	svc_wake_up(block->b_daemon);
@@ -609,36 +639,41 @@
  * block.
  */
 void
-nlmsvc_grant_reply(struct nlm_cookie *cookie, u32 status)
-{
-	struct nlm_block	*block;
-	struct nlm_file		*file;
-
-	if (!(block = nlmsvc_find_block(cookie)))
-		return;
-	file = block->b_file;
-
-	file->f_count++;
-	down(&file->f_sema);
-	if ((block = nlmsvc_find_block(cookie)) != NULL) {
-		if (status == NLM_LCK_DENIED_GRACE_PERIOD) {
-			/* Try again in a couple of seconds */
-			nlmsvc_insert_block(block, 10 * HZ);
-			block = NULL;
-		} else {
-			/* Lock is now held by client, or has been rejected.
-			 * In both cases, the block should be removed. */
-			file->f_count++;
-			up(&file->f_sema);
-			if (status == NLM_LCK_GRANTED)
-				nlmsvc_delete_block(block, 0);
-			else
-				nlmsvc_delete_block(block, 1);
-		}
-	}
-	if (!block)
-		up(&file->f_sema);
-	nlm_release_file(file);
+nlmsvc_grant_reply(struct sockaddr_in * rq_addr, struct nlm_cookie *cookie, u32
+status
+)
+{
+        struct nlm_block        *block;
+        struct nlm_file         *file;
+
+        dprintk("grant_reply: looking for cookie %x, host (%08x), s=%d \n", 
+                *(unsigned int *)(cookie->data), 
+                ntohl(rq_addr->sin_addr.s_addr), status);
+        if (!(block = nlmsvc_find_block(cookie, rq_addr)))
+                return;
+        file = block->b_file;
+
+        file->f_count++;
+        down(&file->f_sema);
+        if ((block = nlmsvc_find_block(cookie, rq_addr)) != NULL) {
+                if (status == NLM_LCK_DENIED_GRACE_PERIOD) {
+                        /* Try again in a couple of seconds */
+                        nlmsvc_insert_block(block, 10 * HZ);
+                        block = NULL;
+                } else {
+                        /* Lock is now held by client, or has been rejected.
+                         * In both cases, the block should be removed. */
+                        file->f_count++;
+                        up(&file->f_sema);
+                        if (status == NLM_LCK_GRANTED)
+                                nlmsvc_delete_block(block, 0);
+                        else
+                                nlmsvc_delete_block(block, 1);
+                }
+        }
+        if (!block)
+                up(&file->f_sema);
+        nlm_release_file(file);
 }
 
 /*
@@ -659,10 +694,12 @@
 			break;
 	        if (time_after(block->b_when,jiffies))
 			break;
-		dprintk("nlmsvc_retry_blocked(%p, when=%ld, done=%d)\n",
-			block, block->b_when, block->b_done);
+		dprintk("nlmsvc_retry_blocked(%p, when=%ld, done=%d, responded=%d)\n",
+			block, block->b_when, block->b_done, block->b_responded);
 		if (block->b_done)
 			nlmsvc_delete_block(block, 0);
+		else if (block->b_responded)
+			nlmsvc_grant_reply(&block->b_host->h_addr, &block->b_call.a_res.cookie, block->b_call.a_res.status);
 		else
 			nlmsvc_grant_blocked(block);
 	}
diff -u --new-file -r linux-2.4.18.orig/fs/lockd/svcproc.c linux-2.4.18.clean/fs/lockd/svcproc.c
--- linux-2.4.18.orig/fs/lockd/svcproc.c	Mon Apr 22 14:27:46 2002
+++ linux-2.4.18.clean/fs/lockd/svcproc.c	Tue May  7 18:45:59 2002
@@ -487,6 +487,22 @@
 }
 
 /*
+ * client sent a GRANTED_RES, let's remove the associated block
+ */
+static int
+nlmsvc_proc_granted_res(struct svc_rqst *rqstp, struct nlm_res  *argp,
+                                                void            *resp)
+{
+	if (!nlmsvc_ops)
+		return rpc_success;
+
+	dprintk("lockd: GRANTED_RES   called\n");
+
+	nlmsvc_grant_reply(&rqstp->rq_addr, &argp->cookie, argp->status);
+	return rpc_success;
+}
+
+/*
  * This is the generic lockd callback for async RPC calls
  */
 static u32
@@ -551,7 +567,6 @@
 #define nlmsvc_proc_lock_res	nlmsvc_proc_null
 #define nlmsvc_proc_cancel_res	nlmsvc_proc_null
 #define nlmsvc_proc_unlock_res	nlmsvc_proc_null
-#define nlmsvc_proc_granted_res	nlmsvc_proc_null
 
 struct nlm_void			{ int dummy; };
 
@@ -581,7 +596,7 @@
   PROC(lock_res,	lockres,	norep,		res,	void),
   PROC(cancel_res,	cancelres,	norep,		res,	void),
   PROC(unlock_res,	unlockres,	norep,		res,	void),
-  PROC(granted_res,	grantedres,	norep,		res,	void),
+  PROC(granted_res,	res,		norep,		res,	void),
   /* statd callback */
   PROC(sm_notify,	reboot,		void,		reboot,	void),
   PROC(none,		void,		void,		void,	void),
diff -u --new-file -r linux-2.4.18.orig/include/linux/lockd/lockd.h linux-2.4.18.clean/include/linux/lockd/lockd.h
--- linux-2.4.18.orig/include/linux/lockd/lockd.h	Thu Nov 22 20:47:20 2001
+++ linux-2.4.18.clean/include/linux/lockd/lockd.h	Tue May  7 18:46:11 2002
@@ -45,6 +45,7 @@
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_authflavor;	/* RPC authentication type */
+	unsigned short		h_msg;		/* use msg type callbacks */
 	unsigned short		h_reclaiming : 1,
 				h_inuse      : 1,
 				h_killed     : 1,
@@ -97,12 +98,14 @@
 	struct nlm_rqst		b_call;		/* RPC args & callback info */
 	struct svc_serv *	b_daemon;	/* NLM service */
 	struct nlm_host *	b_host;		/* host handle for RPC clnt */
+	unsigned short		b_msg;		/* use GRANTED_MSG callback */
 	unsigned long		b_when;		/* next re-xmit */
 	unsigned int		b_id;		/* block id */
 	unsigned char		b_queued;	/* re-queued */
 	unsigned char		b_granted;	/* VFS granted lock */
 	unsigned char		b_incall;	/* doing callback */
 	unsigned char		b_done;		/* callback complete */
+	unsigned char       b_responded;	/* GRANTED callback complete */
 	struct nlm_file *	b_file;		/* file in question */
 };
 
@@ -164,6 +167,7 @@
 unsigned long	  nlmsvc_retry_blocked(void);
 int		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
 					int action);
+void	  nlmsvc_grant_reply(struct sockaddr_in *, struct nlm_cookie *, u32);
 
 /*
  * File handling for the server personality

--UugvWAfsgieZRqgk--

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
