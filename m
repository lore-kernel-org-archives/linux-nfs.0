From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: [PATCH] lockd separate clients rpc options
Date: Wed, 24 Jul 2002 12:11:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020724121100.A27792@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17XJLE-0006mC-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Jul 2002 03:26:00 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id MAA06636
          for <nfs@lists.sourceforge.net>; Wed, 24 Jul 2002 12:23:02 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g6OAB0527857
	for nfs@lists.sourceforge.net; Wed, 24 Jul 2002 12:11:00 +0200
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


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

With this patch there is a rpc_clnt for each client options set (softrtry,
chatty, intr). These clients are associated with a host. They are destroyed 
when performing nlm_gc_hosts.

The client, once allocated is kept in the nlm_rqst structure, thus the client
may call nlm_bind_host with the reference on the allready allocated rpc_clnt
with the right rpc call options (in nlmclnt_async_call, nlmclnt_call).

On the server side, nlm_bind_host is called with a NULL rpc_clnt, and this
trigger nlm_bind_host to use h_rpcclnt as a client.

On the client side, there are 2 situation in which the h_rpcclnt is used, 
with default options:

* when there is a cancel call
   In that case, the nlm_rqst isn't used, a new one is allocated instead. Is
   it a correct behavior ?
   Even if it is the correct behavior, it should be quite easy to get a 
   client with the right options.

* when the client responds to a granted_msg call, as it uses nlmsvc_callback.
   Should it be fixed ?

Pat
   



--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.18-separated_clnt.dif"

diff -u --recursive ../linux-2.4.18.trond_patch/fs/lockd/clntproc.c ./fs/lockd/clntproc.c
--- ../linux-2.4.18.trond_patch/fs/lockd/clntproc.c	Mon Apr 22 14:27:46 2002
+++ ./fs/lockd/clntproc.c	Tue Jul 23 19:06:47 2002
@@ -109,6 +109,7 @@
 	sigset_t		oldset;
 	unsigned long		flags;
 	int			status, proto, vers;
+	struct rpc_clnt *	clnt;
 
 	vers = (NFS_PROTO(inode)->version == 3) ? 4 : 1;
 	if (NFS_PROTO(inode)->version > 3) {
@@ -124,18 +125,12 @@
 
 	/* Create RPC client handle if not there, and copy soft
 	 * and intr flags from NFS client. */
-	if (host->h_rpcclnt == NULL) {
-		struct rpc_clnt	*clnt;
 
-		/* Bind an rpc client to this host handle (does not
-		 * perform a portmapper lookup) */
-		if (!(clnt = nlm_bind_host(host))) {
-			status = -ENOLCK;
-			goto done;
-		}
-		clnt->cl_softrtry = nfssrv->client->cl_softrtry;
-		clnt->cl_intr     = nfssrv->client->cl_intr;
-		clnt->cl_chatty   = nfssrv->client->cl_chatty;
+	if ((clnt = nlm_find_clnt(host, nfssrv->client->cl_softrtry,
+			nfssrv->client->cl_intr, nfssrv->client->cl_chatty))
+				== NULL){
+		status = -ENOLCK;
+		goto done;
 	}
 
 	/* Keep the old signal mask */
@@ -164,6 +159,7 @@
 		locks_init_lock(&call->a_res.lock.fl);
 	}
 	call->a_host = host;
+	call->a_clnt = clnt;
 
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
@@ -237,7 +233,7 @@
 nlmclnt_call(struct nlm_rqst *req, u32 proc)
 {
 	struct nlm_host	*host = req->a_host;
-	struct rpc_clnt	*clnt;
+	struct rpc_clnt	*clnt = req->a_clnt;
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_res	*resp = &req->a_res;
 	struct file	*filp = argp->lock.fl.fl_file;
@@ -262,7 +258,7 @@
 		}
 
 		/* If we have no RPC client yet, create one. */
-		if ((clnt = nlm_bind_host(host)) == NULL)
+		if ((clnt = nlm_bind_host(host, clnt)) == NULL)
 			return -ENOLCK;
 
 		/* Perform the RPC call. If an error occurs, try again */
@@ -330,14 +326,14 @@
 			nlm_procname(proc), host->h_name);
 
 	/* If we have no RPC client yet, create one. */
-	if ((clnt = nlm_bind_host(host)) == NULL)
+	if ((clnt = nlm_bind_host(host, NULL)) == NULL)
 		return -ENOLCK;
 
         /* bootstrap and kick off the async RPC call */
 	msg.rpc_proc = proc;
 	msg.rpc_argp = argp;
 	msg.rpc_resp =resp;
-	msg.rpc_cred = NULL;	
+	msg.rpc_cred = NULL;
         status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, callback, req);
 
 	return status;
@@ -347,7 +343,7 @@
 nlmclnt_async_call(struct nlm_rqst *req, u32 proc, rpc_action callback)
 {
 	struct nlm_host	*host = req->a_host;
-	struct rpc_clnt	*clnt;
+	struct rpc_clnt	*clnt = req->a_clnt;
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_res	*resp = &req->a_res;
 	struct file	*file = argp->lock.fl.fl_file;
@@ -358,7 +354,7 @@
 			nlm_procname(proc), host->h_name);
 
 	/* If we have no RPC client yet, create one. */
-	if ((clnt = nlm_bind_host(host)) == NULL)
+	if ((clnt = nlm_bind_host(host, clnt)) == NULL)
 		return -ENOLCK;
 
         /* bootstrap and kick off the async RPC call */
diff -u --recursive ../linux-2.4.18.trond_patch/fs/lockd/host.c ./fs/lockd/host.c
--- ../linux-2.4.18.trond_patch/fs/lockd/host.c	Mon Oct  1 22:45:47 2001
+++ ./fs/lockd/host.c	Tue Jul 23 19:06:47 2002
@@ -139,6 +139,7 @@
 	host->h_proto      = proto;
 	host->h_authflavor = RPC_AUTH_UNIX;
 	host->h_rpcclnt    = NULL;
+	INIT_LIST_HEAD(&host->h_clnts);
 	init_MUTEX(&host->h_sema);
 	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
 	host->h_expires    = jiffies + NLM_HOST_EXPIRE;
@@ -160,16 +161,79 @@
 }
 
 /*
- * Create the NLM RPC client for an NLM peer
+ * Create a rpc clnt
  */
 struct rpc_clnt *
-nlm_bind_host(struct nlm_host *host)
+nlm_create_clnt(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
 	struct rpc_xprt	*xprt;
+	uid_t saved_fsuid = current->fsuid;
+	kernel_cap_t saved_cap = current->cap_effective;
 
-	dprintk("lockd: nlm_bind_host(%08x)\n",
-			(unsigned)ntohl(host->h_addr.sin_addr.s_addr));
+
+	dprintk("lockd: nlm_create_clnt(%08x)\n",
+		(unsigned)ntohl(host->h_addr.sin_addr.s_addr));
+
+	/* Create RPC socket as root user so we get a priv port */
+	current->fsuid = 0;
+	cap_raise (current->cap_effective, CAP_NET_BIND_SERVICE);
+	xprt = xprt_create_proto(host->h_proto, &host->h_addr, NULL);
+	current->fsuid = saved_fsuid;
+	current->cap_effective = saved_cap;
+	if (xprt == NULL)
+		return NULL;
+	xprt_set_timeout(&xprt->timeout, 5, nlmsvc_timeout);
+
+	clnt = rpc_create_client(xprt, host->h_name, &nlm_program,
+				host->h_version, host->h_authflavor);
+	if (clnt == NULL) {
+		xprt_destroy(xprt);
+		return NULL;
+	}
+	clnt->cl_autobind = 1;	/* turn on pmap queries */
+	xprt->nocong = 1;	/* No congestion control for NLM */
+	return clnt;
+}
+
+/*
+ * allocate memory for a struct nlm_clnt and initialize it. If clnt is NULL
+ */
+struct nlm_clnt *
+nlm_alloc_clnt(struct nlm_host *host, struct rpc_clnt *clnt)
+{
+	struct nlm_clnt *nlm_clnt;
+
+	 while (!signalled()) {
+		nlm_clnt = (struct nlm_clnt *) kmalloc(sizeof(struct nlm_clnt), GFP_KERNEL);
+		if (clnt)
+		{
+			INIT_LIST_HEAD(&nlm_clnt->c_link);
+			nlm_clnt->c_clnt = clnt;
+			nlm_clnt->c_nextrebind = jiffies + NLM_HOST_REBIND;
+			return nlm_clnt;
+		}
+		printk("nlmclnt_alloc_clnt: failed, waiting for memory\n");
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(5*HZ);
+	}
+	return NULL;
+}
+
+/*
+ * Create the NLM RPC client for an NLM peer or retrieve the existing one
+ */
+struct rpc_clnt *
+nlm_bind_host(struct nlm_host *host, struct rpc_clnt *clnt)
+{
+	struct rpc_xprt	*xprt;
+	unsigned long * nextrebind;
+	struct nlm_clnt *nlm_clnt;
+	struct list_head *tmp;
+	struct list_head *clnt_head = &host->h_clnts;
+
+	dprintk("lockd: nlm_bind_host(%08x), client %p\n",
+		(unsigned)ntohl(host->h_addr.sin_addr.s_addr), clnt);
 
 	/* Lock host handle */
 	down(&host->h_sema);
@@ -178,38 +242,46 @@
 	 * RPC rebind is required
 	 * Note: why keep rebinding if we're on a tcp connection?
 	 */
-	if ((clnt = host->h_rpcclnt) != NULL) {
+
+	if (clnt == NULL) {
+		clnt = host->h_rpcclnt;
+		nextrebind = &host->h_nextrebind;
+	} else {
+		list_for_each(tmp, clnt_head) {
+			nlm_clnt = list_entry(tmp, struct nlm_clnt, c_link);
+			if (nlm_clnt->c_clnt == clnt)
+			{
+				nextrebind = &nlm_clnt->c_nextrebind;
+				break;
+			}
+		}
+		/* this shouldn't happen */
+		printk("bug: no nlm_clnt for %p\n",clnt);
+		clnt = NULL;
+		if ((clnt = nlm_create_clnt(host)) == NULL)
+			 goto forgetit;
+		if ((nlm_clnt = nlm_alloc_clnt(host, clnt)) == NULL)
+		{
+			rpc_destroy_client(clnt);
+			goto forgetit;
+		}
+		list_add (&nlm_clnt->c_link, clnt_head);
+		up(&host->h_sema);
+		return clnt;
+	}
+
+	if (clnt != NULL) {
 		xprt = clnt->cl_xprt;
-		if (!xprt->stream && time_after_eq(jiffies, host->h_nextrebind)) {
+		if (!xprt->stream && time_after_eq(jiffies, *nextrebind)) {
 			clnt->cl_port = 0;
-			host->h_nextrebind = jiffies + NLM_HOST_REBIND;
+			(*nextrebind) = jiffies + NLM_HOST_REBIND;
 			dprintk("lockd: next rebind in %ld jiffies\n",
-					host->h_nextrebind - jiffies);
+					(*nextrebind) - jiffies);
 		}
 	} else {
-		uid_t saved_fsuid = current->fsuid;
-		kernel_cap_t saved_cap = current->cap_effective;
-
-		/* Create RPC socket as root user so we get a priv port */
-		current->fsuid = 0;
-		cap_raise (current->cap_effective, CAP_NET_BIND_SERVICE);
-		xprt = xprt_create_proto(host->h_proto, &host->h_addr, NULL);
-		current->fsuid = saved_fsuid;
-		current->cap_effective = saved_cap;
-		if (xprt == NULL)
-			goto forgetit;
-
-		xprt_set_timeout(&xprt->timeout, 5, nlmsvc_timeout);
-
-		clnt = rpc_create_client(xprt, host->h_name, &nlm_program,
-					host->h_version, host->h_authflavor);
-		if (clnt == NULL) {
-			xprt_destroy(xprt);
+		clnt = nlm_create_clnt(host);
+		if (clnt == NULL)
 			goto forgetit;
-		}
-		clnt->cl_autobind = 1;	/* turn on pmap queries */
-		xprt->nocong = 1;	/* No congestion control for NLM */
-
 		host->h_rpcclnt = clnt;
 	}
 
@@ -223,16 +295,75 @@
 }
 
 /*
+ * find a rpc_clnt with given options or create it
+ */
+struct rpc_clnt *
+nlm_find_clnt(struct nlm_host *host, unsigned int softrtry, unsigned int intr,
+			unsigned int chatty)
+{
+	struct list_head *clnt_head = &host->h_clnts;
+	struct list_head *tmp;
+	struct rpc_clnt *clnt;
+	struct nlm_clnt *nlm_clnt;
+
+
+	/* Lock host handle */
+	down(&host->h_sema);
+
+	list_for_each(tmp, clnt_head) {
+		nlm_clnt = list_entry(tmp, struct nlm_clnt, c_link);
+		clnt = nlm_clnt->c_clnt;
+		if (clnt->cl_softrtry == softrtry
+				&& clnt->cl_intr == intr
+				&& clnt->cl_chatty == chatty)
+		{
+			up(&host->h_sema);
+			return clnt;
+		}
+	}
+
+	if ((clnt = nlm_create_clnt(host)) == NULL)
+		 goto forgetit;
+	if ((nlm_clnt = nlm_alloc_clnt(host, clnt)) == NULL)
+	{
+		rpc_destroy_client(clnt);
+		goto forgetit;
+	}
+	clnt->cl_softrtry = softrtry;
+	clnt->cl_intr = intr;
+	clnt->cl_chatty = chatty;
+	list_add (&nlm_clnt->c_link, clnt_head);
+	up(&host->h_sema);
+	return clnt;
+forgetit:
+	printk("lockd: nlm_find_clnt couldn't create RPC handle for %s\n", host->h_name);
+	up(&host->h_sema);
+	return NULL;
+}
+
+/*
  * Force a portmap lookup of the remote lockd port
  */
 void
 nlm_rebind_host(struct nlm_host *host)
 {
+	struct list_head *tmp;
+	struct list_head *clnt_head = &host->h_clnts;
+	struct nlm_clnt *nlm_clnt;
+
 	dprintk("lockd: rebind host %s\n", host->h_name);
 	if (host->h_rpcclnt && time_after_eq(jiffies, host->h_nextrebind)) {
 		host->h_rpcclnt->cl_port = 0;
 		host->h_nextrebind = jiffies + NLM_HOST_REBIND;
 	}
+
+	list_for_each(tmp, clnt_head) {
+		nlm_clnt = list_entry(tmp, struct nlm_clnt, c_link);
+		if (time_after_eq(jiffies, nlm_clnt->c_nextrebind)) {
+			nlm_clnt->c_clnt->cl_port = 0;
+			nlm_clnt->c_nextrebind = jiffies + NLM_HOST_REBIND;
+		}
+	}
 }
 
 /*
@@ -307,6 +438,9 @@
 {
 	struct nlm_host	**q, *host;
 	struct rpc_clnt	*clnt;
+	struct list_head *tmp;
+	struct list_head *clnt_head;
+	struct nlm_clnt *nlm_clnt;
 	int		i;
 
 	dprintk("lockd: host garbage collection\n");
@@ -321,6 +455,7 @@
 	for (i = 0; i < NLM_HOST_NRHASH; i++) {
 		q = &nlm_hosts[i];
 		while ((host = *q) != NULL) {
+			clnt_head = &host->h_clnts;
 			if (host->h_count || host->h_inuse
 			 || time_before(jiffies, host->h_expires)) {
 				q = &host->h_next;
@@ -340,6 +475,19 @@
 					rpc_destroy_client(host->h_rpcclnt);
 				}
 			}
+			list_for_each(tmp, clnt_head) {
+				nlm_clnt = list_entry(tmp, struct nlm_clnt, c_link);
+				clnt = nlm_clnt->c_clnt;
+				if (atomic_read(&clnt->cl_users)) {
+					printk(KERN_WARNING
+						"lockd: active RPC handle\n");
+					clnt->cl_dead = 1;
+				} else {
+					rpc_destroy_client(clnt);
+				}
+				list_del (&nlm_clnt->c_link);
+				kfree(nlm_clnt);
+			}
 			kfree(host);
 			nrhosts--;
 		}
diff -u --recursive ../linux-2.4.18.trond_patch/include/linux/lockd/lockd.h ./include/linux/lockd/lockd.h
--- ../linux-2.4.18.trond_patch/include/linux/lockd/lockd.h	Thu Nov 22 20:47:20 2001
+++ ./include/linux/lockd/lockd.h	Tue Jul 23 19:07:09 2002
@@ -54,17 +54,28 @@
 	u32			h_nsmstate;	/* true remote NSM state */
 	unsigned int		h_count;	/* reference count */
 	struct semaphore	h_sema;		/* mutex for pmap binding */
+	struct list_head	h_clnts;	/* rpc clients with options set */
 	unsigned long		h_nextrebind;	/* next portmap call */
 	unsigned long		h_expires;	/* eligible for GC */
 };
 
 /*
+ * RPC client with options set
+ */
+struct nlm_clnt {
+	struct list_head	c_link;
+	struct rpc_clnt *	c_clnt;
+	unsigned long		c_nextrebind;	/* next portmap call */
+};
+
+/*
  * Memory chunk for NLM client RPC request.
  */
 #define NLMCLNT_OHSIZE		(sizeof(system_utsname.nodename)+10)
 struct nlm_rqst {
 	unsigned int		a_flags;	/* initial RPC task flags */
 	struct nlm_host *	a_host;		/* host handle */
+	struct rpc_clnt *	a_clnt;		/* client */
 	struct nlm_args		a_args;		/* arguments */
 	struct nlm_res		a_res;		/* result */
 	char			a_owner[NLMCLNT_OHSIZE];
@@ -145,7 +156,9 @@
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *);
 struct nlm_host * nlm_lookup_host(struct svc_client *,
 					struct sockaddr_in *, int, int);
-struct rpc_clnt * nlm_bind_host(struct nlm_host *);
+struct rpc_clnt * nlm_bind_host(struct nlm_host *, struct rpc_clnt *);
+struct rpc_clnt * nlm_find_clnt(struct nlm_host *, unsigned int, unsigned int,
+			unsigned int);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
Only in ../linux-2.4.18.trond_patch/: linux-2.4.18-NFS_ALL.dif

--KsGdsel6WgEHnImy--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
