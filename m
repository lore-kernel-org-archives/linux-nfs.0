From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 16 - Lockd to shutdown without engaging with nfsd
Date: Thu, 12 Sep 2002 12:34:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023427.19534@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJoW-00025G-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:34:40 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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


### Comments for ChangeSet

Currently, when lockd wants to invalidate all it's
clients, it asks nfsd to iterate through them.  Now
it iterates itself.


 ----------- Diffstat output ------------
 ./fs/lockd/host.c             |   24 ++++++++++++++++++++++++
 ./fs/lockd/svc.c              |    4 ++--
 ./fs/lockd/svcsubs.c          |   15 +++++++++++++++
 ./fs/nfsd/export.c            |   12 ------------
 ./fs/nfsd/lockd.c             |    1 -
 ./include/linux/lockd/bind.h  |    1 -
 ./include/linux/lockd/lockd.h |    3 +++
 ./include/linux/nfsd/export.h |    1 -
 8 files changed, 44 insertions(+), 17 deletions(-)

--- ./include/linux/lockd/bind.h	2002/09/11 01:08:18	1.1
+++ ./include/linux/lockd/bind.h	2002/09/11 01:10:25	1.2
@@ -26,7 +26,6 @@ struct nlmsvc_binding {
 						struct nfs_fh *,
 						struct file *);
 	void			(*fclose)(struct file *);
-	void			(*detach)(void);
 };
 
 extern struct nlmsvc_binding *	nlmsvc_ops;
--- ./include/linux/lockd/lockd.h	2002/09/11 01:09:16	1.1
+++ ./include/linux/lockd/lockd.h	2002/09/11 01:10:25	1.2
@@ -150,6 +150,8 @@ void		  nlm_rebind_host(struct nlm_host 
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
+extern struct nlm_host *nlm_find_client(void);
+
 
 /*
  * Server-side lock handling
@@ -173,6 +175,7 @@ u32		  nlm_lookup_file(struct svc_rqst *
 void		  nlm_release_file(struct nlm_file *);
 void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
+void		  nlmsvc_invalidate_all(void);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- ./include/linux/nfsd/export.h	2002/09/11 01:08:18	1.1
+++ ./include/linux/nfsd/export.h	2002/09/11 01:10:25	1.2
@@ -102,7 +102,6 @@ struct svc_export *	exp_get_by_name(stru
 int			exp_rootfh(struct svc_client *, 
 					char *path, struct knfsd_fh *, int maxsize);
 int			nfserrno(int errno);
-void			exp_nlmdetach(void);
 
 
 #endif /* __KERNEL__ */
--- ./fs/nfsd/export.c	2002/09/11 01:08:18	1.1
+++ ./fs/nfsd/export.c	2002/09/11 01:10:25	1.2
@@ -878,18 +878,6 @@ again:
 }
 
 /*
- * Lockd is shutting down and tells us to unregister all clients
- */
-void
-exp_nlmdetach(void)
-{
-	struct svc_client	*clp;
-
-	for (clp = clients; clp; clp = clp->cl_next)
-		nfsd_lockd_unexport(clp);
-}
-
-/*
  * Verify that string is non-empty and does not exceed max length.
  */
 static int
--- ./fs/nfsd/lockd.c	2002/09/11 01:08:18	1.1
+++ ./fs/nfsd/lockd.c	2002/09/11 01:10:25	1.2
@@ -66,7 +66,6 @@ struct nlmsvc_binding		nfsd_nlm_ops = {
 	.exp_getclient	= exp_getclient,		/* look up NFS client */
 	.fopen		= nlm_fopen,		/* open file for locking */
 	.fclose		= nlm_fclose,		/* close file */
-	.detach		= exp_nlmdetach,		/* lockd shutdown notification */
 };
 
 /*
--- ./fs/lockd/svc.c	2002/09/11 01:07:38	1.2
+++ ./fs/lockd/svc.c	2002/09/11 01:10:25	1.3
@@ -130,7 +130,7 @@ lockd(struct svc_rqst *rqstp)
 			flush_signals(current);
 			spin_unlock_irq(&current->sigmask_lock);
 			if (nlmsvc_ops) {
-				nlmsvc_ops->detach();
+				nlmsvc_invalidate_all();
 				grace_period_expire = set_grace_period();
 			}
 		}
@@ -187,7 +187,7 @@ lockd(struct svc_rqst *rqstp)
 	 */
 	if (!nlmsvc_pid || current->pid == nlmsvc_pid) {
 		if (nlmsvc_ops)
-			nlmsvc_ops->detach();
+			nlmsvc_invalidate_all();
 		nlm_shutdown_hosts();
 		nlmsvc_pid = 0;
 	} else
--- ./fs/lockd/host.c	2002/09/11 01:08:18	1.1
+++ ./fs/lockd/host.c	2002/09/11 01:10:25	1.2
@@ -159,6 +159,30 @@ nohost:
 	return host;
 }
 
+struct nlm_host *
+nlm_find_client(void)
+{
+	/* find a nlm_host for a client for which h_killed == 0.
+	 * and return it
+	 */
+	int hash;
+	down(&nlm_host_sema);
+	for (hash = 0 ; hash < NLM_HOST_NRHASH; hash++) {
+		struct nlm_host *host, **hp;
+		for (hp = &nlm_hosts[hash]; (host = *hp) ; hp = &host->h_next) {
+			if (host->h_exportent != NULL &&
+			    host->h_killed == 0) {
+				nlm_get_host(host);
+				up(&nlm_host_sema);
+				return host;
+			}
+		}
+	}
+	up(&nlm_host_sema);
+	return NULL;
+}
+
+				
 /*
  * Create the NLM RPC client for an NLM peer
  */
--- ./fs/lockd/svcsubs.c	2002/09/11 01:08:18	1.1
+++ ./fs/lockd/svcsubs.c	2002/09/11 01:10:25	1.2
@@ -309,3 +309,18 @@ nlmsvc_invalidate_client(struct svc_clie
 		nlm_release_host(host);
 	}
 }
+
+/*
+ * delete all hosts structs for clients
+ */
+void
+nlmsvc_invalidate_all(void)
+{
+	struct nlm_host *host;
+	while ((host = nlm_find_client()) != NULL) {
+		nlmsvc_free_host_resources(host);
+		host->h_expires = 0;
+		host->h_killed = 1;
+		nlm_release_host(host);
+	}
+}


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
