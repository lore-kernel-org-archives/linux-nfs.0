From: Dumas Patrice <dumas@centre-cired.fr>
Subject: patchs for lockd: granted_res_proc, client address check, blocking check
Date: Tue, 23 Apr 2002 10:31:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020423103152.A3624@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zvmu-0004CX-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 01:36:36 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id KAA03725
          for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 10:35:16 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3N8Vqs03795
	for nfs@lists.sourceforge.net; Tue, 23 Apr 2002 10:31:52 +0200
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


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

These are 3 patches against linux-2.4.18 with NFS-ALL applied.

The first one implements nlmsvc_proc_granted_res such that when a server
receive that callback it deallocates the corresponding block, using the
nlmsvc_grant_reply function.

The second adds a check of the address in addition to the cookie value, when
looking at a callback or a reply from the client, such that even if 2 clients
have the same cookie the blocks aren't mischoosen. This patch is againts the
previous one, because it modifies nlmsvc_proc_granted_res. Maybe it should also
be against linux-2.4.18 with NFS-ALL applied ?

The third concerns the client side, it adds a check that the client is really
requesting a blocking lock instead of relaying on the server not to be broken.

Thanks

Pat

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.18-lockd_granted_res.dif"

diff -r -u linux-2.4.18.orig/fs/lockd/svc4proc.c linux-2.4.18.clean/fs/lockd/svc4proc.c
--- linux-2.4.18.orig/fs/lockd/svc4proc.c	Mon Apr 22 14:27:46 2002
+++ linux-2.4.18.clean/fs/lockd/svc4proc.c	Mon Apr 22 18:01:03 2002
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
+        nlmsvc_grant_reply(&argp->cookie, argp->status);
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
diff -r -u linux-2.4.18.orig/fs/lockd/svcproc.c linux-2.4.18.clean/fs/lockd/svcproc.c
--- linux-2.4.18.orig/fs/lockd/svcproc.c	Mon Apr 22 14:27:46 2002
+++ linux-2.4.18.clean/fs/lockd/svcproc.c	Mon Apr 22 18:01:03 2002
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
+	nlmsvc_grant_reply(&argp->cookie, argp->status);
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
diff -r -u linux-2.4.18.orig/include/linux/lockd/lockd.h linux-2.4.18.clean/include/linux/lockd/lockd.h
--- linux-2.4.18.orig/include/linux/lockd/lockd.h	Thu Nov 22 20:47:20 2001
+++ linux-2.4.18.clean/include/linux/lockd/lockd.h	Mon Apr 22 18:01:23 2002
@@ -164,6 +164,7 @@
 unsigned long	  nlmsvc_retry_blocked(void);
 int		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
 					int action);
+void	  nlmsvc_grant_reply(struct nlm_cookie *cookie, u32 status);
 
 /*
  * File handling for the server personality

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.18-addr_check.dif"

diff -u --new-file -r linux-2.4.18.clean.res/fs/lockd/svc4proc.c linux-2.4.18.clean/fs/lockd/svc4proc.c
--- linux-2.4.18.clean.res/fs/lockd/svc4proc.c	Mon Apr 22 18:01:03 2002
+++ linux-2.4.18.clean/fs/lockd/svc4proc.c	Tue Apr 23 10:10:03 2002
@@ -470,7 +470,7 @@
 
         dprintk("lockd: GRANTED_RES   called\n");
 
-        nlmsvc_grant_reply(&argp->cookie, argp->status);
+        nlmsvc_grant_reply(rqstp, &argp->cookie, argp->status);
         return rpc_success;
 }
 
diff -u --new-file -r linux-2.4.18.clean.res/fs/lockd/svclock.c linux-2.4.18.clean/fs/lockd/svclock.c
--- linux-2.4.18.clean.res/fs/lockd/svclock.c	Mon Apr 22 18:00:32 2002
+++ linux-2.4.18.clean/fs/lockd/svclock.c	Tue Apr 23 10:10:02 2002
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
 
@@ -572,13 +573,17 @@
 	struct nlm_rqst		*call = (struct nlm_rqst *) task->tk_calldata;
 	struct nlm_block	*block;
 	unsigned long		timeout;
+	struct sockaddr_in	*peer_addr = RPC_PEERADDR(task->tk_client); 	
 
 	dprintk("lockd: GRANT_MSG RPC callback\n");
-	dprintk("callback: looking for cookie %x \n", 
-		*(unsigned int *)(call->a_args.cookie.data));
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
 
@@ -609,18 +614,21 @@
  * block.
  */
 void
-nlmsvc_grant_reply(struct nlm_cookie *cookie, u32 status)
+nlmsvc_grant_reply(struct svc_rqst *rqstp, struct nlm_cookie *cookie, u32 status)
 {
 	struct nlm_block	*block;
 	struct nlm_file		*file;
 
-	if (!(block = nlmsvc_find_block(cookie)))
+	dprintk("grant_reply: looking for cookie %x, host (%08x), s=%d \n", 
+		*(unsigned int *)(cookie->data), 
+		ntohl(rqstp->rq_addr.sin_addr.s_addr), status);
+	if (!(block = nlmsvc_find_block(cookie, &rqstp->rq_addr)))
 		return;
 	file = block->b_file;
 
 	file->f_count++;
 	down(&file->f_sema);
-	if ((block = nlmsvc_find_block(cookie)) != NULL) {
+	if ((block = nlmsvc_find_block(cookie,&rqstp->rq_addr)) != NULL) {
 		if (status == NLM_LCK_DENIED_GRACE_PERIOD) {
 			/* Try again in a couple of seconds */
 			nlmsvc_insert_block(block, 10 * HZ);
diff -u --new-file -r linux-2.4.18.clean.res/fs/lockd/svcproc.c linux-2.4.18.clean/fs/lockd/svcproc.c
--- linux-2.4.18.clean.res/fs/lockd/svcproc.c	Mon Apr 22 18:01:03 2002
+++ linux-2.4.18.clean/fs/lockd/svcproc.c	Tue Apr 23 10:10:04 2002
@@ -498,7 +498,7 @@
 
 	dprintk("lockd: GRANTED_RES   called\n");
 
-	nlmsvc_grant_reply(&argp->cookie, argp->status);
+	nlmsvc_grant_reply(rqstp, &argp->cookie, argp->status);
 	return rpc_success;
 }
 
diff -u --new-file -r linux-2.4.18.clean.res/include/linux/lockd/lockd.h linux-2.4.18.clean/include/linux/lockd/lockd.h
--- linux-2.4.18.clean.res/include/linux/lockd/lockd.h	Mon Apr 22 18:01:23 2002
+++ linux-2.4.18.clean/include/linux/lockd/lockd.h	Tue Apr 23 10:10:30 2002
@@ -164,7 +164,7 @@
 unsigned long	  nlmsvc_retry_blocked(void);
 int		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
 					int action);
-void	  nlmsvc_grant_reply(struct nlm_cookie *cookie, u32 status);
+void	  nlmsvc_grant_reply(struct svc_rqst *, struct nlm_cookie *, u32);
 
 /*
  * File handling for the server personality

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.18-clnt_no_block.dif"

--- linux-2.4.18.orig/fs/lockd/clntproc.c	Mon Apr 22 14:27:46 2002
+++ linux-2.4.18.clean/fs/lockd/clntproc.c	Mon Apr 22 18:23:12 2002
@@ -460,7 +460,7 @@
 		}
 		if (status < 0)
 			return status;
-	} while (resp->status == NLM_LCK_BLOCKED);
+	} while (resp->status == NLM_LCK_BLOCKED && req->a_args.block);
 
 	if (resp->status == NLM_LCK_GRANTED) {
 		fl->fl_u.nfs_fl.state = host->h_state;

--VS++wcV0S1rZb1Fb--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
