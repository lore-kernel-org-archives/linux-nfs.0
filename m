From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: [PATCH] lockd: client maintain a list of the locks held
Date: Fri, 24 May 2002 19:13:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020524191310.E15523@zeus.centre-cired.fr>
References: <20020524181545.D15523@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Dxnq1zWXvFF0Q93v"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BIdn-00035r-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 10:14:11 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id TAA19239
          for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 19:12:42 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4OHDA516667
	for nfs@lists.sourceforge.net; Fri, 24 May 2002 19:13:10 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020524181545.D15523@zeus.centre-cired.fr>; from dumas@centre-cired.fr on Fri, May 24, 2002 at 06:15:45PM +0200
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


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here is the patch ;-)

Pat

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="clntlocks-held-list.diff"

diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/clntlock.c linux-2.4.18.clean-clntlist/fs/lockd/clntlock.c
--- linux-2.4.18.trond_patch/fs/lockd/clntlock.c	Mon Oct  1 22:45:47 2001
+++ linux-2.4.18.clean-clntlist/fs/lockd/clntlock.c	Fri May 24 20:59:10 2002
@@ -24,7 +24,7 @@
  * Local function prototypes
  */
 static int			reclaimer(void *ptr);
-
+int nlmclnt_find_held_lock (struct nlm_host * host, struct file_lock * fl);
 /*
  * The following functions handle blocking and granting from the
  * client perspective.
@@ -45,6 +45,15 @@
 static struct nlm_wait *	nlm_blocked;
 
 /*
+ * This is the representation of a lock holded by the client
+ */
+
+struct nlmclnt_held_lock {
+		struct list_head 	hl_link;
+		struct file_lock *	hl_fl;
+};
+
+/*
  * Block on a lock
  */
 int
@@ -100,7 +109,7 @@
  * The server lockd has called us back to tell us the lock was granted
  */
 u32
-nlmclnt_grant(struct nlm_lock *lock)
+nlmclnt_grant(struct nlm_lock *lock, struct nlm_host *host)
 {
 	struct nlm_wait	*block;
 
@@ -109,14 +118,18 @@
 	 * Warning: must not use cookie to match it!
 	 */
 	for (block = nlm_blocked; block; block = block->b_next) {
-		if (nlm_compare_locks(block->b_lock, &lock->fl))
+		if (nlm_compare_locks(block->b_lock, &lock->fl) && 
+				(host == block->b_host))
 			break;
 	}
 
 	/* Ooops, no blocked request found. */
 	if (block == NULL)
-		return nlm_lck_denied;
-
+	{
+		if (!nlmclnt_find_held_lock(host, &lock->fl))
+			return nlm_lck_denied;
+		return nlm_granted;
+	}
 	/* Alright, we found the lock. Set the return status and
 	 * wake up the caller.
 	 */
@@ -124,6 +137,134 @@
 	wake_up(&block->b_wait);
 
 	return nlm_granted;
+}
+
+/*
+ * The following procedures deal with adding, finding and removing a lock
+ * in the list of the locks held by a client's host.
+ */
+
+int
+nlmclnt_insert_held_lock (struct nlm_host * host, struct file_lock * fl)
+{
+	struct list_head *lock_head = &host->h_clntlocks;
+	struct list_head *tmp;
+	struct nlmclnt_held_lock *clnt_lock;
+	struct inode *inode;
+	
+	dprintk ("lockd: nlmclnt_insert_held_lock %p: pd=%d %Ld-%Ld ty=%d\n",
+					fl, fl->fl_pid, (long long)fl->fl_start,
+					(long long)fl->fl_end, fl->fl_type);
+	
+	/*
+	 * sanity checks
+	 */
+	
+	inode = fl->fl_file->f_dentry->d_inode;
+	if ((inode->i_sb->s_magic != NFS_SUPER_MAGIC) ||
+					(fl->fl_u.nfs_fl.host != host))
+		dprintk ("lockd: lmclnt_insert_held_lock: Warning file_lock is bad\n");
+	
+	
+	down (&host->h_clntlock_sema);
+	list_for_each(tmp, lock_head) {
+		clnt_lock = list_entry(tmp, struct nlmclnt_held_lock, hl_link);
+		if (clnt_lock->hl_fl == fl)
+		{
+			up (&host->h_clntlock_sema);
+			return 0;
+		}
+	}
+
+	/*
+	 * The lock doesn't exist. Create it.
+	 */
+	
+	clnt_lock = NULL;
+	
+	while (!signalled()) {
+		clnt_lock = (struct nlmclnt_held_lock *) kmalloc(sizeof(struct nlmclnt_held_lock), GFP_KERNEL);
+		if (clnt_lock)
+				break;
+		printk("nlmclnt_insert_held_lock: failed, waiting for memory\n");
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(5*HZ);
+	}
+	/* if signalled, what to do ?*/
+	
+	/*
+	 * initialize the nlmclnt_held_lock
+	 */
+	
+	INIT_LIST_HEAD (&clnt_lock->hl_link);
+	clnt_lock->hl_fl = fl;
+	list_add (&clnt_lock->hl_link, lock_head);
+	dprintk ("lockd: nlmclnt_insert_held_lock inserted %p: pd=%d %Ld-%Ld ty=%d\n",
+		clnt_lock->hl_fl, clnt_lock->hl_fl->fl_pid,
+		(long long)clnt_lock->hl_fl->fl_start,
+		(long long)clnt_lock->hl_fl->fl_end, clnt_lock->hl_fl->fl_type);
+	up (&host->h_clntlock_sema);
+	
+	return 0;
+}
+
+int
+nlmclnt_remove_held_lock (struct nlm_host * host, struct file_lock * fl)
+{
+	struct list_head *lock_head = &host->h_clntlocks;
+	struct list_head *tmp;
+	struct nlmclnt_held_lock *clnt_lock;
+	
+    dprintk ("lockd: nlmclnt_remove_lock %p: pd=%d %Ld-%Ld ty=%d\n",
+		fl, fl->fl_pid, (long long)fl->fl_start,
+		(long long)fl->fl_end, fl->fl_type);
+	down (&host->h_clntlock_sema);
+	list_for_each(tmp, lock_head) {
+		clnt_lock = list_entry(tmp, struct nlmclnt_held_lock, hl_link);
+		if (clnt_lock->hl_fl == fl)
+		{
+			list_del (&clnt_lock->hl_link);
+			kfree (clnt_lock);
+			up (&host->h_clntlock_sema);
+			return 1;
+		}
+	}
+	
+	dprintk ("lockd: nlmclnt_remove_held_lock: file lock not found p=%p, pd=%d %Ld-%Ld ty=%d\n",
+		fl, fl->fl_pid, (long long)fl->fl_start, 
+		(long long)fl->fl_end, fl->fl_type);
+	up (&host->h_clntlock_sema);
+	return 0;
+}
+
+int
+nlmclnt_find_held_lock (struct nlm_host * host, struct file_lock * fl)
+{
+	struct list_head *lock_head = &host->h_clntlocks;
+	struct list_head *tmp;
+	struct nlmclnt_held_lock *clnt_lock;
+
+	down (&host->h_clntlock_sema);
+	if (list_empty(lock_head))
+	{
+		dprintk ("lockd: nlmclnt_find_held_lock: list empty\n");
+		up (&host->h_clntlock_sema);
+		return 0;
+	}
+	list_for_each(tmp, lock_head) {
+		clnt_lock = list_entry(tmp, struct nlmclnt_held_lock, hl_link);
+		dprintk("lockd: nlmclnt_find_held_lock traversing %p, pd=%d %Ld-%Ld ty=%d\n",
+			clnt_lock->hl_fl, clnt_lock->hl_fl->fl_pid, 
+			(long long)clnt_lock->hl_fl->fl_start,
+			(long long)clnt_lock->hl_fl->fl_end, clnt_lock->hl_fl->fl_type);
+	    if ((nlm_compare_locks (clnt_lock->hl_fl, fl))) /* we should compare filehandles/inodes too */
+		{
+			up (&host->h_clntlock_sema);
+			return 1;
+		}
+	}
+	up (&host->h_clntlock_sema);
+	return 0;
 }
 
 /*
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/clntproc.c linux-2.4.18.clean-clntlist/fs/lockd/clntproc.c
--- linux-2.4.18.trond_patch/fs/lockd/clntproc.c	Fri May 24 19:57:43 2002
+++ linux-2.4.18.clean-clntlist/fs/lockd/clntproc.c	Fri May 24 22:36:54 2002
@@ -264,6 +264,8 @@
 		/* If we have no RPC client yet, create one. */
 		if ((clnt = nlm_bind_host(host)) == NULL)
 			return -ENOLCK;
+		dprintk("lockd: rpc_call clnt=%p, soft=%d\n", clnt,
+			clnt->cl_softrtry );
 
 		/* Perform the RPC call. If an error occurs, try again */
 		if ((status = rpc_call_sync(clnt, &msg, 0)) < 0) {
@@ -408,11 +410,35 @@
 static
 void nlmclnt_insert_lock_callback(struct file_lock *fl)
 {
-	nlm_get_host(fl->fl_u.nfs_fl.host);
+	struct nlm_host * host = nlm_get_host(fl->fl_u.nfs_fl.host);
+	if (!host)
+	{
+		dprintk("lockd: insert_lock_callback no host ! %p pd=%d %Ld-%Ld ty=%d\n",
+			fl, fl->fl_pid, (long long)fl->fl_start,
+			(long long)fl->fl_end, fl->fl_type);
+		return;
+	}
+	dprintk("lockd: insert_lock_callback %p pd=%d %Ld-%Ld ty=%d\n",
+		fl, fl->fl_pid, (long long)fl->fl_start,
+		(long long)fl->fl_end, fl->fl_type);
+	nlmclnt_insert_held_lock(host, fl);
 }
+
 static
 void nlmclnt_remove_lock_callback(struct file_lock *fl)
 {
+	struct nlm_host * host = nlm_get_host(fl->fl_u.nfs_fl.host);
+	if (!host)
+	{
+		dprintk("lockd: remove_lock_callback no host ! %p pd=%d %Ld-%Ld ty=%d\n",
+			fl, fl->fl_pid, (long long)fl->fl_start,
+			(long long)fl->fl_end, fl->fl_type);
+			return;
+	}
+    dprintk("lockd: insert_lock_callback %p pd=%d %Ld-%Ld ty=%d\n",
+		fl, fl->fl_pid, (long long)fl->fl_start,
+		(long long)fl->fl_end, fl->fl_type);
+	nlmclnt_remove_held_lock (host, fl);
 	if (fl->fl_u.nfs_fl.host) {
 		nlm_release_host(fl->fl_u.nfs_fl.host);
 		fl->fl_u.nfs_fl.host = NULL;
@@ -544,7 +570,6 @@
 		printk("lockd: unexpected unlock status: %d\n", resp->status);
 
 	/* What to do now? I'm out of my depth... */
-
 	return -ENOLCK;
 }
 
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/host.c linux-2.4.18.clean-clntlist/fs/lockd/host.c
--- linux-2.4.18.trond_patch/fs/lockd/host.c	Mon Oct  1 22:45:47 2001
+++ linux-2.4.18.clean-clntlist/fs/lockd/host.c	Fri May 24 20:59:11 2002
@@ -147,6 +147,9 @@
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
 	host->h_exportent  = clnt;
+	/* FIXME:we should do these 2 things for clients only */
+	INIT_LIST_HEAD(&host->h_clntlocks);
+	init_MUTEX(&host->h_clntlock_sema);
 
 	host->h_next       = nlm_hosts[hash];
 	nlm_hosts[hash]    = host;
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/svc4proc.c linux-2.4.18.clean-clntlist/fs/lockd/svc4proc.c
--- linux-2.4.18.trond_patch/fs/lockd/svc4proc.c	Fri May 24 19:57:43 2002
+++ linux-2.4.18.clean-clntlist/fs/lockd/svc4proc.c	Fri May 24 20:59:11 2002
@@ -233,10 +233,18 @@
 nlm4svc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 				            struct nlm_res  *resp)
 {
-	resp->cookie = argp->cookie;
+	struct nlm_host *host;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(&argp->lock);
+	resp->cookie = argp->cookie;
+	if (!(host = nlmclnt_lookup_host(&rqstp->rq_addr,
+		rqstp->rq_prot, rqstp->rq_vers)))
+	{
+		resp->status = nlm_lck_denied;
+		return rpc_success;
+	}
+
+	resp->status = nlmclnt_grant(&argp->lock, host);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
diff -u --recursive --new-file linux-2.4.18.trond_patch/fs/lockd/svcproc.c linux-2.4.18.clean-clntlist/fs/lockd/svcproc.c
--- linux-2.4.18.trond_patch/fs/lockd/svcproc.c	Fri May 24 19:57:43 2002
+++ linux-2.4.18.clean-clntlist/fs/lockd/svcproc.c	Fri May 24 20:59:12 2002
@@ -261,10 +261,18 @@
 nlmsvc_proc_granted(struct svc_rqst *rqstp, struct nlm_args *argp,
 				            struct nlm_res  *resp)
 {
+	struct nlm_host *host;
+	
+	dprintk("lockd: GRANTED       called\n");
 	resp->cookie = argp->cookie;
+	if (!(host = nlmclnt_lookup_host(&rqstp->rq_addr,
+		rqstp->rq_prot, rqstp->rq_vers)))
+	{
+		resp->status = nlm_lck_denied;
+		return rpc_success;
+	}
 
-	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(&argp->lock);
+	resp->status = nlmclnt_grant(&argp->lock, host);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
diff -u --recursive --new-file linux-2.4.18.trond_patch/include/linux/lockd/lockd.h linux-2.4.18.clean-clntlist/include/linux/lockd/lockd.h
--- linux-2.4.18.trond_patch/include/linux/lockd/lockd.h	Thu Nov 22 20:47:20 2001
+++ linux-2.4.18.clean-clntlist/include/linux/lockd/lockd.h	Fri May 24 20:59:36 2002
@@ -41,6 +41,7 @@
 	struct sockaddr_in	h_addr;		/* peer address */
 	struct svc_client *	h_exportent;	/* NFS client */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
+	struct list_head        h_clntlocks;	/*client: locks held */
 	char			h_name[20];	/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
@@ -54,6 +55,8 @@
 	u32			h_nsmstate;	/* true remote NSM state */
 	unsigned int		h_count;	/* reference count */
 	struct semaphore	h_sema;		/* mutex for pmap binding */
+	struct semaphore	h_clntlock_sema; /* mutex for locks held
+*/
 	unsigned long		h_nextrebind;	/* next portmap call */
 	unsigned long		h_expires;	/* eligible for GC */
 };
@@ -132,7 +135,9 @@
 int		  nlmclnt_async_call(struct nlm_rqst *, u32, rpc_action);
 int		  nlmclnt_block(struct nlm_host *, struct file_lock *, u32 *);
 int		  nlmclnt_cancel(struct nlm_host *, struct file_lock *);
-u32		  nlmclnt_grant(struct nlm_lock *);
+u32		  nlmclnt_grant(struct nlm_lock *, struct nlm_host *);
+int		  nlmclnt_insert_held_lock (struct nlm_host *, struct file_lock *);
+int		  nlmclnt_remove_held_lock (struct nlm_host *, struct file_lock *);
 void		  nlmclnt_recovery(struct nlm_host *, u32);
 int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *);
 int		  nlmclnt_setgrantargs(struct nlm_rqst *, struct nlm_lock *);
@@ -200,6 +205,19 @@
 	     && fl1->fl_start == fl2->fl_start
 	     && fl1->fl_end   == fl2->fl_end
 	     &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
+}
+
+/*
+ * Check if the lock is included in another lock
+ */
+
+static __inline__ int
+nlm_included_locks(struct file_lock *fl1, struct file_lock *fl2)
+{
+	return  fl1->fl_pid   == fl2->fl_pid
+	&& fl1->fl_start >= fl2->fl_start
+	&& fl1->fl_end   <= fl2->fl_end
+	&& fl1->fl_type  == fl2->fl_type;
 }
 
 #endif /* __KERNEL__ */

--Dxnq1zWXvFF0Q93v--

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
