From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 17 - Use new cache infrastructure for auth_unix specific lookups.
Date: Fri, 11 Oct 2002 15:27:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKh-0003b4-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLD-0003fx-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:04 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:47 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

This patch introduces two caches using the new infrastucture, and the
concept of a 'domain'.

A 'domain' refers to a collection of clients that all have the same
view of the nfs server, and all have the same access rights (modulo
different users on the clients).  For AUTH_UNIX (and AUTH_NULL), the
domain is determined from the IP address.  For other authentication
styles, the domain might be determined directly from the credentials.

Each auth flavour knows how to allocate and free it's domain-specific
infomation.

auth_domain_cache maps a name to a domain which is owned by
an auth flavour.

ip_map_cache is a cache specific to AUTH_UNIX which maps
IP address to domain.

With this patch, svcauth_unix.c is created to store all
auth_unix related code.

The IP address lookup code is removed from nfsd/exports.c

sunrpc module initilisation is moved out of stats.c into sunrpc_syms
which seemed to be the most central .c file.  It now registers these
two caches.

Now that the caches are being used, nfsd needs to call cache_clean
periodically. 


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c               |  236 ++++++-----------------------
 ./fs/nfsd/lockd.c                |    2 
 ./fs/nfsd/nfsctl.c               |   12 +
 ./fs/nfsd/nfssvc.c               |    7 
 ./include/linux/lockd/bind.h     |    1 
 ./include/linux/nfsd/export.h    |   28 +--
 ./include/linux/nfsd/nfsd.h      |    1 
 ./include/linux/sunrpc/svc.h     |    2 
 ./include/linux/sunrpc/svcauth.h |   41 +++++
 ./net/sunrpc/Makefile            |    2 
 ./net/sunrpc/stats.c             |   22 --
 ./net/sunrpc/sunrpc_syms.c       |   32 ++++
 ./net/sunrpc/svcauth.c           |  186 ++++++++++-------------
 ./net/sunrpc/svcauth_unix.c      |  310 +++++++++++++++++++++++++++++++++++++++
 14 files changed, 543 insertions(+), 339 deletions(-)

--- ./include/linux/lockd/bind.h	2002/10/11 00:42:25	1.1
+++ ./include/linux/lockd/bind.h	2002/10/11 00:51:15	1.2
@@ -13,7 +13,6 @@
 
 /* Dummy declarations */
 struct svc_rqst;
-struct svc_client;		/* opaque type */
 
 /*
  * This is the set of functions for lockd->nfsd communication
--- ./include/linux/nfsd/export.h	2002/10/10 23:16:29	1.2
+++ ./include/linux/nfsd/export.h	2002/10/11 00:51:15	1.3
@@ -45,14 +45,9 @@
 
 #ifdef __KERNEL__
 
-struct svc_client {
-	struct svc_client *	cl_next;
-	char			cl_ident[NFSCLNT_IDMAX];
-};
-
 struct svc_export {
 	struct list_head	ex_hash;
-	struct svc_client *	ex_client;
+	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
 	struct dentry *		ex_dentry;
@@ -68,11 +63,11 @@ struct svc_export {
 struct svc_expkey {
 	struct list_head	ek_hash;
 
-	struct svc_client	*ek_client;
+	struct auth_domain *	ek_client;
 	int			ek_fsidtype;
 	u32			ek_fsid[2];
 
-	struct svc_export	*ek_export;
+	struct svc_export *	ek_export;
 };
 
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
@@ -90,21 +85,22 @@ void			nfsd_export_init(void);
 void			nfsd_export_shutdown(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
-struct svc_client *	exp_getclient(struct sockaddr_in *sin);
-void			exp_putclient(struct svc_client *clp);
-struct svc_expkey *	exp_find_key(struct svc_client *clp, int fsid_type, u32 *fsidv);
-struct svc_export *	exp_get_by_name(struct svc_client *clp,
+struct auth_domain *	exp_getclient(struct sockaddr_in *sin);
+struct svc_expkey *	exp_find_key(struct auth_domain *clp, 
+				     int fsid_type, u32 *fsidv);
+struct svc_export *	exp_get_by_name(struct auth_domain *clp,
 					struct vfsmount *mnt,
 					struct dentry *dentry);
-struct svc_export *	exp_parent(struct svc_client *clp, struct vfsmount *mnt,
+struct svc_export *	exp_parent(struct auth_domain *clp,
+				   struct vfsmount *mnt,
 				   struct dentry *dentry);
-int			exp_rootfh(struct svc_client *, 
+int			exp_rootfh(struct auth_domain *, 
 					char *path, struct knfsd_fh *, int maxsize);
-int			exp_pseudoroot(struct svc_client *, struct svc_fh *fhp);
+int			exp_pseudoroot(struct auth_domain *, struct svc_fh *fhp);
 int			nfserrno(int errno);
 
 static inline struct svc_export *
-exp_find(struct svc_client *clp, int fsid_type, u32 *fsidv)
+exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv)
 {
 	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv);
 	if (ek)
--- ./include/linux/nfsd/nfsd.h	2002/10/10 23:24:44	1.2
+++ ./include/linux/nfsd/nfsd.h	2002/10/11 00:51:15	1.3
@@ -139,7 +139,6 @@ int		nfsd_permission(struct svc_export *
  */
 void		nfsd_lockd_init(void);
 void		nfsd_lockd_shutdown(void);
-void		nfsd_lockd_unexport(struct svc_client *);
 
 
 /*
--- ./include/linux/sunrpc/svc.h	2002/10/11 00:41:07	1.2
+++ ./include/linux/sunrpc/svc.h	2002/10/11 00:51:15	1.3
@@ -122,7 +122,7 @@ struct svc_rqst {
 						 */
 
 	/* Catering to nfsd */
-	struct svc_client *	rq_client;	/* RPC peer info */
+	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct knfsd_fh *	rq_reffh;	/* Referrence filehandle, used to
 						 * determine what device number
--- ./include/linux/sunrpc/svcauth.h	2002/10/11 00:41:07	1.2
+++ ./include/linux/sunrpc/svcauth.h	2002/10/11 00:51:15	1.3
@@ -12,6 +12,7 @@
 #ifdef __KERNEL__
 
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/sunrpc/cache.h>
 
 struct svc_cred {
 	uid_t			cr_uid;
@@ -20,6 +21,30 @@ struct svc_cred {
 };
 
 struct svc_rqst;		/* forward decl */
+
+/* Authentication is done in the context of a domain.
+ * For a server, a domain represents a group of clients using
+ * a common mechanism for authentication and having a common mapping
+ * between local identity (uid) and network identity.  All clients
+ * in a domain have similar general access rights.  Each domain can
+ * contain multiple principals which will have different specific right
+ * based on normal Discretionary Access Control.
+ *
+ * For a client, a domain represents a number of servers which all
+ * use a common authentication mechanism and network identity name space.
+ *
+ * A domain is created by an authentication flavour module based on name
+ * only.  Userspace then fills in detail on demand.
+ *
+ * The creation of a domain typically implies creation of one or
+ * more caches for storing domain specific information.
+ */
+struct auth_domain {
+	struct	cache_head	h;
+	char			*name;
+	int			flavour;
+};
+
 /*
  * Each authentication flavour registers an auth_ops
  * structure.
@@ -49,12 +74,16 @@ struct svc_rqst;		/* forward decl */
  *    DROP - the reply should be quitely dropped
  *    DENIED - authp holds a reason for MSG_DENIED
  *    SYSERR - rpc system_err
+ *
+ * domain_release()
+ *   This call releases a domain.
  */
 struct auth_ops {
 	char *	name;
 	int	flavour;
 	int	(*accept)(struct svc_rqst *rq, u32 *authp, int proc);
 	int	(*release)(struct svc_rqst *rq);
+	void	(*domain_release)(struct auth_domain *);
 };
 extern struct auth_ops	*authtab[RPC_AUTH_MAXFLAVOR];
 
@@ -73,6 +102,18 @@ extern int	svc_authorise(struct svc_rqst
 extern int	svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops);
 extern void	svc_auth_unregister(rpc_authflavor_t flavor);
 
+extern struct auth_domain *unix_domain_find(char *name);
+extern void auth_domain_put(struct auth_domain *item);
+extern int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom);
+extern struct auth_domain *auth_domain_lookup(struct auth_domain *item, int set);
+extern struct auth_domain *auth_domain_find(char *name);
+extern struct auth_domain *auth_unix_lookup(struct in_addr addr);
+extern int auth_unix_forget_old(struct auth_domain *dom);
+extern void svcauth_unix_purge(void);
+
+extern int name_hash(char *name, int size);
+
+extern struct cache_detail auth_domain_cache, ip_map_cache;
 
 #endif /* __KERNEL__ */
 
--- ./fs/nfsd/export.c	2002/10/10 23:16:29	1.2
+++ ./fs/nfsd/export.c	2002/10/11 00:51:15	1.3
@@ -32,28 +32,19 @@
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 #define NFSD_PARANOIA 1
 
-typedef struct svc_client	svc_client;
+typedef struct auth_domain	svc_client;
 typedef struct svc_export	svc_export;
 
 static void		exp_unexport_all(svc_client *clp);
 static void		exp_do_unexport(svc_export *unexp);
-static svc_client *	exp_getclientbyname(char *name);
-static void		exp_freeclient(svc_client *clp);
-static void		exp_unhashclient(svc_client *clp);
 static int		exp_verify_string(char *cp, int max);
 
-#define CLIENT_HASHBITS		6
-#define CLIENT_HASHMAX		(1 << CLIENT_HASHBITS)
-#define CLIENT_HASHMASK		(CLIENT_HASHMAX - 1)
-#define CLIENT_HASH(a) \
-		((((a)>>24) ^ ((a)>>16) ^ ((a)>>8) ^(a)) & CLIENT_HASHMASK)
-
 #define	EXPKEY_HASHBITS		8
 #define	EXPKEY_HASHMAX		(1 << EXPKEY_HASHBITS)
 #define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
 static struct list_head expkey_table[EXPKEY_HASHMAX];
 
-static inline int expkey_hash(struct svc_client *clp, int type, u32 *fsidv)
+static inline int expkey_hash(struct auth_domain *clp, int type, u32 *fsidv)
 {
 	int hash = type;
 	char * cp = (char*)fsidv;
@@ -67,14 +58,6 @@ static inline int expkey_hash(struct svc
 	return hash & EXPKEY_HASHMASK;
 }
 
-struct svc_clnthash {
-	struct svc_clnthash *	h_next;
-	struct in_addr		h_addr;
-	struct svc_client *	h_client;
-};
-static struct svc_clnthash *	clnt_hash[CLIENT_HASHMAX];
-static svc_client *		clients;
-
 /* hash table of exports indexed by dentry+client */
 #define	EXPORT_HASHBITS		8
 #define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
@@ -249,7 +232,7 @@ static void exp_fsid_unhash(struct svc_e
 	}
 }
 
-static int exp_fsid_hash(struct svc_client *clp, struct svc_export *exp)
+static int exp_fsid_hash(svc_client *clp, struct svc_export *exp)
 {
 	struct list_head *head;
 	struct svc_expkey *ek;
@@ -272,7 +255,7 @@ static int exp_fsid_hash(struct svc_clie
 	return 0;
 }
 
-static int exp_hash(struct svc_client *clp, struct svc_export *exp)
+static int exp_hash(struct auth_domain *clp, struct svc_export *exp)
 {
 	struct list_head *head;
 	struct svc_expkey *ek;
@@ -337,7 +320,7 @@ exp_export(struct nfsctl_export *nxp)
 	exp_writelock();
 
 	/* Look up client info */
-	if (!(clp = exp_getclientbyname(nxp->ex_client)))
+	if (!(clp = auth_domain_find(nxp->ex_client)))
 		goto out_unlock;
 
 
@@ -406,6 +389,7 @@ exp_export(struct nfsctl_export *nxp)
 	dprintk("nfsd: created export entry %p for client %p\n", exp, clp);
 
 	exp->ex_client = clp;
+	cache_get(&clp->h);
 	exp->ex_mnt = mntget(nd.mnt);
 	exp->ex_dentry = dget(nd.dentry);
 	exp->ex_flags = nxp->ex_flags;
@@ -425,6 +409,8 @@ exp_export(struct nfsctl_export *nxp)
 	}
 
 finish:
+	if (clp)
+		auth_domain_put(clp);
 	path_release(&nd);
 out_unlock:
 	exp_writeunlock();
@@ -441,14 +427,12 @@ exp_do_unexport(svc_export *unexp)
 {
 	struct dentry	*dentry;
 	struct vfsmount *mnt;
-	struct inode	*inode;
 
 	list_del(&unexp->ex_hash);
 	exp_unhash(unexp);
 	exp_fsid_unhash(unexp);
 	dentry = unexp->ex_dentry;
 	mnt = unexp->ex_mnt;
-	inode = dentry->d_inode;
 	dput(dentry);
 	mntput(mnt);
 
@@ -480,7 +464,7 @@ exp_unexport_all(svc_client *clp)
 int
 exp_unexport(struct nfsctl_export *nxp)
 {
-	svc_client	*clp;
+	struct auth_domain *dom;
 	int		err;
 
 	/* Consistency check */
@@ -490,14 +474,19 @@ exp_unexport(struct nfsctl_export *nxp)
 	exp_writelock();
 
 	err = -EINVAL;
-	clp = exp_getclientbyname(nxp->ex_client);
-	if (clp) {
-		svc_export *exp = exp_get(clp, nxp->ex_dev, nxp->ex_ino);
+	dom = auth_domain_find(nxp->ex_client);
+
+	if (dom) {
+		svc_export *exp = exp_get(dom, nxp->ex_dev, nxp->ex_ino);
 		if (exp) {
 			exp_do_unexport(exp);
 			err = 0;
-		}
-	}
+		} else
+			dprintk("nfsd: no export %x/%lx for %s\n",
+				nxp->ex_dev, nxp->ex_ino, nxp->ex_client);
+		auth_domain_put(dom);
+	} else
+		dprintk("nfsd: unexport couldn't find %s\n", nxp->ex_client);
 
 	exp_writeunlock();
 	return err;
@@ -509,7 +498,7 @@ exp_unexport(struct nfsctl_export *nxp)
  * since its harder to fool a kernel module than a user space program.
  */
 int
-exp_rootfh(struct svc_client *clp, char *path, struct knfsd_fh *f, int maxsize)
+exp_rootfh(svc_client *clp, char *path, struct knfsd_fh *f, int maxsize)
 {
 	struct svc_export	*exp;
 	struct nameidata	nd;
@@ -526,7 +515,7 @@ exp_rootfh(struct svc_client *clp, char 
 	inode = nd.dentry->d_inode;
 
 	dprintk("nfsd: exp_rootfh(%s [%p] %s:%s/%ld)\n",
-		 path, nd.dentry, clp->cl_ident,
+		 path, nd.dentry, clp->name,
 		 inode->i_sb->s_id, inode->i_ino);
 	exp = exp_parent(clp, nd.mnt, nd.dentry);
 	if (!exp) {
@@ -556,7 +545,7 @@ out:
  * export point with fsid==0
  */
 int
-exp_pseudoroot(struct svc_client *clp, struct svc_fh *fhp)
+exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp)
 {
 	struct svc_export *exp;
 
@@ -574,50 +563,12 @@ exp_pseudoroot(struct svc_client *clp, s
  * future lookups.
  * Locking against other processes is the responsibility of the caller.
  */
-struct svc_client *
+svc_client *
 exp_getclient(struct sockaddr_in *sin)
 {
-	struct svc_clnthash	**hp, **head, *tmp;
-	unsigned long		addr = sin->sin_addr.s_addr;
-
-	head = &clnt_hash[CLIENT_HASH(addr)];
-
-	for (hp = head; (tmp = *hp) != NULL; hp = &(tmp->h_next)) {
-		if (tmp->h_addr.s_addr == addr) {
-#if 0
-/* If we really want to do this, we need a spin
-lock to protect against multiple access (as we only
-have an exp_readlock) and need to protect
-the code in e_show() that walks this list too.
-*/
-			/* Move client to the front */
-			if (head != hp) {
-				*hp = tmp->h_next;
-				tmp->h_next = *head;
-				*head = tmp;
-			}
-#endif
-			return tmp->h_client;
-		}
-	}
-
-	return NULL;
+	return auth_unix_lookup(sin->sin_addr);
 }
 
-/*
- * Find a client given its identifier.
- */
-static svc_client *
-exp_getclientbyname(char *ident)
-{
-	svc_client *	clp;
-
-	for (clp = clients; clp; clp = clp->cl_next) {
-		if (!strcmp(clp->cl_ident, ident))
-			return clp;
-	}
-	return NULL;
-}
 
 /* Iterator */
 
@@ -725,7 +676,7 @@ static inline void mangle(struct seq_fil
 static int e_show(struct seq_file *m, void *p)
 {
 	struct svc_export *exp = p;
-	struct svc_client *clp;
+	svc_client *clp;
 	char *pbuf;
 
 	if (p == (void *)1) {
@@ -741,7 +692,7 @@ static int e_show(struct seq_file *m, vo
 			 pbuf, PAGE_SIZE));
 
 	seq_putc(m, '\t');
-	mangle(m, clp->cl_ident);
+	mangle(m, clp->name);
 	seq_putc(m, '(');
 	exp_flags(m, exp->ex_flags, exp->ex_fsid, 
 		  exp->ex_anon_uid, exp->ex_anon_gid);
@@ -764,13 +715,12 @@ struct seq_operations nfs_exports_op = {
 int
 exp_addclient(struct nfsctl_client *ncp)
 {
-	struct svc_clnthash *	ch[NFSCLNT_ADDRMAX];
-	svc_client *		clp;
-	int			i, err, change = 0, ilen;
+	struct auth_domain	*dom;
+	int			i, err;
 
 	/* First, consistency check. */
 	err = -EINVAL;
-	if (!(ilen = exp_verify_string(ncp->cl_ident, NFSCLNT_IDMAX)))
+	if (! exp_verify_string(ncp->cl_ident, NFSCLNT_IDMAX))
 		goto out;
 	if (ncp->cl_naddr > NFSCLNT_ADDRMAX)
 		goto out;
@@ -778,56 +728,19 @@ exp_addclient(struct nfsctl_client *ncp)
 	/* Lock the hashtable */
 	exp_writelock();
 
-	/* First check if this is a change request for a client. */
-	for (clp = clients; clp; clp = clp->cl_next)
-		if (!strcmp(clp->cl_ident, ncp->cl_ident))
-			break;
+	dom = unix_domain_find(ncp->cl_ident);
 
 	err = -ENOMEM;
-	if (clp) {
-		change = 1;
-	} else {
-		if (!(clp = kmalloc(sizeof(*clp), GFP_KERNEL)))
-			goto out_unlock;
-		memset(clp, 0, sizeof(*clp));
-
-		dprintk("created client %s (%p)\n", ncp->cl_ident, clp);
-
-		strcpy(clp->cl_ident, ncp->cl_ident);
-	}
-
-	/* Allocate hash buckets */
-	for (i = 0; i < ncp->cl_naddr; i++) {
-		ch[i] = kmalloc(sizeof(struct svc_clnthash), GFP_KERNEL);
-		if (!ch[i]) {
-			while (i--)
-				kfree(ch[i]);
-			if (!change)
-				kfree(clp);
-			goto out_unlock;
-		}
-	}
-
-	/* Remove old client hash entries. */
-	if (change)
-		exp_unhashclient(clp);
+	if (!dom)
+		goto out_unlock;
 
 	/* Insert client into hashtable. */
-	for (i = 0; i < ncp->cl_naddr; i++) {
-		struct in_addr	addr = ncp->cl_addrlist[i];
-		int		hash;
-
-		hash = CLIENT_HASH(addr.s_addr);
-		ch[i]->h_client = clp;
-		ch[i]->h_addr = addr;
-		ch[i]->h_next = clnt_hash[hash];
-		clnt_hash[hash] = ch[i];
-	}
+	for (i = 0; i < ncp->cl_naddr; i++)
+		auth_unix_add_addr(ncp->cl_addrlist[i], dom);
+
+	auth_unix_forget_old(dom);
+	auth_domain_put(dom);
 
-	if (!change) {
-		clp->cl_next = clients;
-		clients = clp;
-	}
 	err = 0;
 
 out_unlock:
@@ -842,8 +755,8 @@ out:
 int
 exp_delclient(struct nfsctl_client *ncp)
 {
-	svc_client	**clpp, *clp;
 	int		err;
+	struct auth_domain *dom;
 
 	err = -EINVAL;
 	if (!exp_verify_string(ncp->cl_ident, NFSCLNT_IDMAX))
@@ -852,14 +765,14 @@ exp_delclient(struct nfsctl_client *ncp)
 	/* Lock the hashtable */
 	exp_writelock();
 
-	for (clpp = &clients; (clp = *clpp); clpp = &(clp->cl_next))
-		if (!strcmp(ncp->cl_ident, clp->cl_ident))
-			break;
-
-	if (clp) {
-		*clpp = clp->cl_next;
-		exp_freeclient(clp);
-		err = 0;
+	dom = auth_domain_find(ncp->cl_ident);
+	/* just make sure that no addresses work 
+	 * and that it will expire soon 
+	 */
+	if (dom) {
+		err = auth_unix_forget_old(dom);
+		dom->h.expiry_time = CURRENT_TIME;
+		auth_domain_put(dom);
 	}
 
 	exp_writeunlock();
@@ -868,49 +781,6 @@ out:
 }
 
 /*
- * Free a client. The caller has already removed it from the client list.
- */
-static void
-exp_freeclient(svc_client *clp)
-{
-	exp_unhashclient(clp);
-
-	exp_unexport_all(clp);
-	kfree (clp);
-}
-
-/*
- * Remove client from hashtable. We first collect all hashtable
- * entries and free them in one go.
- * The hash table must be writelocked by the caller.
- */
-static void
-exp_unhashclient(svc_client *clp)
-{
-	struct svc_clnthash	**hpp, *hp, *ch[NFSCLNT_ADDRMAX];
-	int			i, count, err;
-
-again:
-	err = 0;
-	for (i = 0, count = 0; i < CLIENT_HASHMAX && !err; i++) {
-		hpp = clnt_hash + i;
-		while ((hp = *hpp) && !err) {
-			if (hp->h_client == clp) {
-				*hpp = hp->h_next;
-				ch[count++] = hp;
-				err = (count >= NFSCLNT_ADDRMAX);
-			} else {
-				hpp = &(hp->h_next);
-			}
-		}
-	}
-	if (err)
-		goto again;
-	for (i = 0; i < count; i++)
-		kfree (ch[i]);
-}
-
-/*
  * Verify that string is non-empty and does not exceed max length.
  */
 static int
@@ -936,10 +806,6 @@ nfsd_export_init(void)
 
 	dprintk("nfsd: initializing export module.\n");
 
-	for (i = 0; i < CLIENT_HASHMAX; i++)
-		clnt_hash[i] = NULL;
-	clients = NULL;
-
 	for (i = 0; i < EXPORT_HASHMAX ; i++)
 		INIT_LIST_HEAD(&export_table[i]);
 
@@ -954,18 +820,14 @@ nfsd_export_init(void)
 void
 nfsd_export_shutdown(void)
 {
-	int	i;
 
 	dprintk("nfsd: shutting down export module.\n");
 
 	exp_writelock();
 
-	for (i = 0; i < CLIENT_HASHMAX; i++) {
-		while (clnt_hash[i])
-			exp_freeclient(clnt_hash[i]->h_client);
-	}
-	clients = NULL; /* we may be restarted before the module unloads */
-	
+	exp_unexport_all(NULL);
+	svcauth_unix_purge();
+
 	exp_writeunlock();
 	dprintk("nfsd: export shutdown complete.\n");
 }
--- ./fs/nfsd/nfssvc.c	2002/10/11 00:41:07	1.4
+++ ./fs/nfsd/nfssvc.c	2002/10/11 00:51:15	1.5
@@ -27,6 +27,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/cache.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
@@ -196,7 +197,7 @@ nfsd(struct svc_rqst *rqstp)
 		 */
 		while ((err = svc_recv(serv, rqstp,
 				       5*60*HZ)) == -EAGAIN)
-		    ;
+			cache_clean();
 		if (err < 0)
 			break;
 		update_thread_usage(atomic_read(&nfsd_busy));
@@ -218,6 +219,10 @@ nfsd(struct svc_rqst *rqstp)
 		svc_process(serv, rqstp);
 
 		/* Unlock export hash tables */
+		if (rqstp->rq_client) {
+			auth_domain_put(rqstp->rq_client);
+			rqstp->rq_client = NULL;
+		}
 		exp_readunlock();
 		update_thread_usage(atomic_read(&nfsd_busy));
 		atomic_dec(&nfsd_busy);
--- ./fs/nfsd/lockd.c	2002/10/11 00:42:25	1.1
+++ ./fs/nfsd/lockd.c	2002/10/11 00:51:15	1.2
@@ -42,6 +42,8 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 		mntget(filp->f_vfsmnt);
 	}
 	fh_put(&fh);
+	if (rqstp->rq_client)
+		auth_domain_put(rqstp->rq_client);
 	rqstp->rq_client = NULL;
 	exp_readunlock();
  	/* nlm and nfsd don't share error codes.
--- ./fs/nfsd/nfsctl.c	2002/10/11 00:42:25	1.1
+++ ./fs/nfsd/nfsctl.c	2002/10/11 00:51:15	1.2
@@ -226,7 +226,7 @@ static ssize_t write_getfs(struct file *
 {
 	struct nfsctl_fsparm data;
 	struct sockaddr_in *sin;
-	struct svc_client *clp;
+	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
 
@@ -248,8 +248,10 @@ static ssize_t write_getfs(struct file *
 	exp_readlock();
 	if (!(clp = exp_getclient(sin)))
 		err = -EPERM;
-	else
+	else {
 		err = exp_rootfh(clp, data.gd_path, res, data.gd_maxlen);
+		auth_domain_put(clp);
+	}
 	exp_readunlock();
 
 	down(&file->f_dentry->d_inode->i_sem);
@@ -271,7 +273,7 @@ static ssize_t write_getfd(struct file *
 {
 	struct nfsctl_fdparm data;
 	struct sockaddr_in *sin;
-	struct svc_client *clp;
+	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh fh;
 	char *res;
@@ -293,8 +295,10 @@ static ssize_t write_getfd(struct file *
 	exp_readlock();
 	if (!(clp = exp_getclient(sin)))
 		err = -EPERM;
-	else
+	else {
 		err = exp_rootfh(clp, data.gd_path, &fh, NFS_FHSIZE);
+		auth_domain_put(clp);
+	}
 	exp_readunlock();
 
 	down(&file->f_dentry->d_inode->i_sem);
--- ./net/sunrpc/svcauth.c	2002/10/11 00:41:07	1.2
+++ ./net/sunrpc/svcauth.c	2002/10/11 00:51:16	1.3
@@ -13,37 +13,19 @@
 #include <linux/sched.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
-#include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/svcauth.h>
 #include <linux/err.h>
 
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
-/*
- * Builtin auth flavors
- */
-static int	svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc);
-static int	svcauth_null_release(struct svc_rqst *rqstp);
-static int	svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc);
-static int	svcauth_unix_release(struct svc_rqst *rqstp);
-
-struct auth_ops svcauth_null = {
-	.name		= "null",
-	.flavour	= RPC_AUTH_NULL,
-	.accept 	= svcauth_null_accept,
-	.release	= svcauth_null_release,
-};
-
-struct auth_ops svcauth_unix = {
-	.name		= "unix",
-	.flavour	= RPC_AUTH_UNIX,
-	.accept 	= svcauth_unix_accept,
-	.release	= svcauth_unix_release,
-};
 
 /*
  * Table of authenticators
  */
+extern struct auth_ops svcauth_null;
+extern struct auth_ops svcauth_unix;
+
 static struct auth_ops	*authtab[RPC_AUTH_MAXFLAVOR] = {
 	[0] = &svcauth_null,
 	[1] = &svcauth_unix,
@@ -119,97 +101,91 @@ svc_auth_unregister(rpc_authflavor_t fla
 		authtab[flavor] = NULL;
 }
 
-static int
-svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
-{
-	struct svc_buf	*argp = &rqstp->rq_argbuf;
-	struct svc_buf	*resp = &rqstp->rq_resbuf;
+/**************************************************
+ * cache for domain name to auth_domain
+ * Entries are only added by flavours which will normally
+ * have a structure that 'inherits' from auth_domain.
+ * e.g. when an IP -> domainname is given to  auth_unix,
+ * and the domain name doesn't exist, it will create a
+ * auth_unix_domain and add it to this hash table.
+ * If it finds the name does exist, but isn't AUTH_UNIX,
+ * it will complain.
+ */
 
-	if ((argp->len -= 3) < 0) {
-		return SVC_GARBAGE;
-	}
-	if (*(argp->buf)++ != 0) {	/* we already skipped the flavor */
-		dprintk("svc: bad null cred\n");
-		*authp = rpc_autherr_badcred;
-		return SVC_DENIED;
-	}
-	if (*(argp->buf)++ != RPC_AUTH_NULL || *(argp->buf)++ != 0) {
-		dprintk("svc: bad null verf\n");
-		*authp = rpc_autherr_badverf;
-		return SVC_DENIED;
+int name_hash(char *name, int size)
+{
+	int hash = 0;
+	while (*name) {
+		hash += *name;
+		name++;
 	}
+	return hash % size;
+}
 
-	/* Signal that mapping to nobody uid/gid is required */
-	rqstp->rq_cred.cr_uid = (uid_t) -1;
-	rqstp->rq_cred.cr_gid = (gid_t) -1;
-	rqstp->rq_cred.cr_groups[0] = NOGROUP;
-
-	/* Put NULL verifier */
-	svc_putu32(resp, RPC_AUTH_NULL);
-	svc_putu32(resp, 0);
-	return SVC_OK;
-}
-
-static int
-svcauth_null_release(struct svc_rqst *rqstp)
-{
-	return 0; /* don't drop */
-}
-
-static int
-svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
-{
-	struct svc_buf	*argp = &rqstp->rq_argbuf;
-	struct svc_buf	*resp = &rqstp->rq_resbuf;
-	struct svc_cred	*cred = &rqstp->rq_cred;
-	u32		*bufp = argp->buf, slen, i;
-	int		len   = argp->len;
-
-	if ((len -= 3) < 0)
-		return SVC_GARBAGE;
-
-	bufp++;					/* length */
-	bufp++;					/* time stamp */
-	slen = XDR_QUADLEN(ntohl(*bufp++));	/* machname length */
-	if (slen > 64 || (len -= slen + 3) < 0)
-		goto badcred;
-	bufp += slen;				/* skip machname */
-
-	cred->cr_uid = ntohl(*bufp++);		/* uid */
-	cred->cr_gid = ntohl(*bufp++);		/* gid */
-
-	slen = ntohl(*bufp++);			/* gids length */
-	if (slen > 16 || (len -= slen + 2) < 0)
-		goto badcred;
-	for (i = 0; i < NGROUPS && i < slen; i++)
-		cred->cr_groups[i] = ntohl(*bufp++);
-	if (i < NGROUPS)
-		cred->cr_groups[i] = NOGROUP;
-	bufp += (slen - i);
-
-	if (*bufp++ != RPC_AUTH_NULL || *bufp++ != 0) {
-		*authp = rpc_autherr_badverf;
-		return SVC_DENIED;
-	}
 
-	argp->buf = bufp;
-	argp->len = len;
+/*
+ * Auth auth_domain cache is somewhat different to other caches,
+ * largely because the entries are possibly of different types:
+ * each auth flavour has it's own type.
+ * One consequence of this that DefineCacheLookup cannot
+ * allocate a new structure as it cannot know the size.
+ * Notice that the "INIT" code fragment is quite different
+ * from other caches.  When auth_domain_lookup might be
+ * creating a new domain, the new domain is passed in
+ * complete and it is used as-is rather than being copied into
+ * another structure.
+ */
+#define	DN_HASHBITS	6
+#define	DN_HASHMAX	(1<<DN_HASHBITS)
+#define	DN_HASHMASK	(DN_HASHMAX-1)
+
+static struct cache_head	*auth_domain_table[DN_HASHMAX];
+void auth_domain_drop(struct cache_head *item, struct cache_detail *cd)
+{
+	struct auth_domain *dom = container_of(item, struct auth_domain, h);
+	if (cache_put(item,cd))
+		authtab[dom->flavour]->domain_release(dom);
+}
 
-	/* Put NULL verifier */
-	svc_putu32(resp, RPC_AUTH_NULL);
-	svc_putu32(resp, 0);
 
-	return SVC_OK;
+struct cache_detail auth_domain_cache = {
+	.hash_size	= DN_HASHMAX,
+	.hash_table	= auth_domain_table,
+	.name		= "auth.domain",
+	.cache_put	= auth_domain_drop,
+};
 
-badcred:
-	*authp = rpc_autherr_badcred;
-	return SVC_DENIED;
+void auth_domain_put(struct auth_domain *dom)
+{
+	auth_domain_drop(&dom->h, &auth_domain_cache);
 }
 
-static int
-svcauth_unix_release(struct svc_rqst *rqstp)
+static inline int auth_domain_hash(struct auth_domain *item)
 {
-	/* Verifier (such as it is) is already in place.
-	 */
-	return 0;
+	return name_hash(item->name, DN_HASHMAX);
+}
+static inline int auth_domain_match(struct auth_domain *tmp, struct auth_domain *item)
+{
+	return strcmp(tmp->name, item->name) == 0;
+}
+DefineCacheLookup(struct auth_domain,
+		  h,
+		  auth_domain_lookup,
+		  (struct auth_domain *item, int set),
+		  /* no setup */,
+		  &auth_domain_cache,
+		  auth_domain_hash(item),
+		  auth_domain_match(tmp, item),
+		  kfree(new); if(!set) return NULL;
+		  new=item; atomic_inc(&new->h.refcnt),
+		  /* no update */
+		  )
+
+struct auth_domain *auth_domain_find(char *name)
+{
+	struct auth_domain *rv, ad;
+
+	ad.name = name;
+	rv = auth_domain_lookup(&ad, 0);
+	return rv;
 }
--- ./net/sunrpc/Makefile	2002/10/11 00:42:00	1.2
+++ ./net/sunrpc/Makefile	2002/10/11 00:51:16	1.3
@@ -8,7 +8,7 @@ export-objs := sunrpc_syms.o
 
 sunrpc-y := clnt.o xprt.o sched.o \
 	    auth.o auth_null.o auth_unix.o \
-	    svc.o svcsock.o svcauth.o \
+	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    pmap_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
--- ./net/sunrpc/stats.c	2002/10/11 00:42:26	1.1
+++ ./net/sunrpc/stats.c	2002/10/11 00:51:16	1.2
@@ -183,25 +183,3 @@ rpc_proc_exit(void)
 	}
 }
 
-
-static int __init
-init_sunrpc(void)
-{
-#ifdef RPC_DEBUG
-	rpc_register_sysctl();
-#endif
-	rpc_proc_init();
-	return 0;
-}
-
-static void __exit
-cleanup_sunrpc(void)
-{
-#ifdef RPC_DEBUG
-	rpc_unregister_sysctl();
-#endif
-	rpc_proc_exit();
-}
-MODULE_LICENSE("GPL");
-module_init(init_sunrpc);
-module_exit(cleanup_sunrpc);
--- ./net/sunrpc/svcauth_unix.c	2002/10/11 00:42:26	1.1
+++ ./net/sunrpc/svcauth_unix.c	2002/10/11 00:51:16	1.2
@@ -0,0 +1,310 @@
+#include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/sunrpc/types.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/svcauth.h>
+#include <linux/err.h>
+
+#define RPCDBG_FACILITY	RPCDBG_AUTH
+
+
+/*
+ * AUTHUNIX and AUTHNULL credentials are both handled here.
+ * AUTHNULL is treated just like AUTHUNIX except that the uid/gid
+ * are always nobody (-2).  i.e. we do the same IP address checks for
+ * AUTHNULL as for AUTHUNIX, and that is done here.
+ */
+
+
+char *strdup(char *s)
+{
+	char *rv = kmalloc(strlen(s)+1, GFP_KERNEL);
+	if (rv)
+		strcpy(rv, s);
+	return rv;
+}
+
+struct unix_domain {
+	struct auth_domain	h;
+	int	addr_changes;
+	/* other stuff later */
+};
+
+struct auth_domain *unix_domain_find(char *name)
+{
+	struct auth_domain *rv, ud;
+	struct unix_domain *new;
+
+	ud.name = name;
+	
+	rv = auth_domain_lookup(&ud, 0);
+
+ foundit:
+	if (rv && rv->flavour != RPC_AUTH_UNIX) {
+		auth_domain_put(rv);
+		return NULL;
+	}
+	if (rv)
+		return rv;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	cache_init(&new->h.h);
+	atomic_inc(&new->h.h.refcnt);
+	new->h.name = strdup(name);
+	new->h.flavour = RPC_AUTH_UNIX;
+	new->addr_changes = 0;
+	new->h.h.expiry_time = NEVER;
+	new->h.h.flags = 0;
+
+	rv = auth_domain_lookup(&new->h, 2);
+	if (rv == &new->h) {
+		if (atomic_dec_and_test(&new->h.h.refcnt)) BUG();
+	} else {
+		auth_domain_put(&new->h);
+		goto foundit;
+	}
+
+	return rv;
+}
+
+
+/**************************************************
+ * cache for IP address to unix_domain
+ * as needed by AUTH_UNIX
+ */
+#define	IP_HASHBITS	8
+#define	IP_HASHMAX	(1<<IP_HASHBITS)
+#define	IP_HASHMASK	(IP_HASHMAX-1)
+
+struct ip_map {
+	struct cache_head	h;
+	char			*m_class; /* e.g. "nfsd" */
+	struct in_addr		m_addr;
+	struct unix_domain	*m_client;
+	int			m_add_change;
+};
+static struct cache_head	*ip_table[IP_HASHMAX];
+
+void ip_map_put(struct cache_head *item, struct cache_detail *cd)
+{
+	struct ip_map *im = container_of(item, struct ip_map,h);
+	if (cache_put(item, cd)) {
+		auth_domain_put(&im->m_client->h);
+		kfree(im);
+	}
+}
+
+static inline int ip_map_hash(struct ip_map *item)
+{
+	return (name_hash(item->m_class, IP_HASHMAX) ^ item->m_addr.s_addr) & IP_HASHMASK;
+}
+static inline int ip_map_match(struct ip_map *item, struct ip_map *tmp)
+{
+	return strcmp(tmp->m_class, item->m_class) == 0
+		&& tmp->m_addr.s_addr == item->m_addr.s_addr;
+}
+static inline void ip_map_init(struct ip_map *new, struct ip_map *item)
+{
+	new->m_class = strdup(item->m_class);
+	new->m_addr.s_addr = item->m_addr.s_addr;
+}
+static inline void ip_map_update(struct ip_map *new, struct ip_map *item)
+{
+	cache_get(&item->m_client->h.h);
+	new->m_client = item->m_client;
+	new->m_add_change = item->m_add_change;
+}
+
+struct cache_detail ip_map_cache = {
+	.hash_size	= IP_HASHMAX,
+	.hash_table	= ip_table,
+	.name		= "auth.unix.ip",
+	.cache_put	= ip_map_put,
+};
+
+static DefineSimpleCacheLookup(ip_map)
+
+
+int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
+{
+	struct unix_domain *udom;
+	struct ip_map ip, *ipmp;
+
+	if (dom->flavour != RPC_AUTH_UNIX)
+		return -EINVAL;
+	udom = container_of(dom, struct unix_domain, h);
+	ip.m_class = "nfsd";
+	ip.m_addr = addr;
+	ip.m_client = udom;
+	ip.m_add_change = udom->addr_changes+1;
+	ip.h.flags = 0;
+	ip.h.expiry_time = NEVER;
+	
+	ipmp = ip_map_lookup(&ip, 1);
+	if (ipmp) {
+		ip_map_put(&ipmp->h, &ip_map_cache);
+		return 0;
+	} else
+		return -ENOMEM;
+}
+
+int auth_unix_forget_old(struct auth_domain *dom)
+{
+	struct unix_domain *udom;
+	
+	if (dom->flavour != RPC_AUTH_UNIX)
+		return -EINVAL;
+	udom = container_of(dom, struct unix_domain, h);
+	udom->addr_changes++;
+	return 0;
+}
+
+struct auth_domain *auth_unix_lookup(struct in_addr addr)
+{
+	struct ip_map key, *ipm;
+	struct auth_domain *rv;
+
+	key.m_class = "nfsd";
+	key.m_addr = addr;
+
+	ipm = ip_map_lookup(&key, 0);
+
+	if (!ipm)
+		return NULL;
+
+	if (test_bit(CACHE_VALID, &ipm->h.flags) &&
+	    (ipm->m_client->addr_changes - ipm->m_add_change) >0)
+		set_bit(CACHE_NEGATIVE, &ipm->h.flags);
+
+	if (!test_bit(CACHE_VALID, &ipm->h.flags))
+		rv = NULL;
+	else if (test_bit(CACHE_NEGATIVE, &ipm->h.flags))
+		rv = NULL;
+	else {
+		rv = &ipm->m_client->h;
+		cache_get(&rv->h);
+	}
+	if (ipm) ip_map_put(&ipm->h, &ip_map_cache);
+	return rv;
+}
+
+void svcauth_unix_purge(void)
+{
+	cache_purge(&ip_map_cache);
+	cache_purge(&auth_domain_cache);
+}
+
+
+static int
+svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
+{
+	struct svc_buf	*argp = &rqstp->rq_argbuf;
+	struct svc_buf	*resp = &rqstp->rq_resbuf;
+
+	if ((argp->len -= 3) < 0) {
+		return SVC_GARBAGE;
+	}
+	if (*(argp->buf)++ != 0) {	/* we already skipped the flavor */
+		dprintk("svc: bad null cred\n");
+		*authp = rpc_autherr_badcred;
+		return SVC_DENIED;
+	}
+	if (*(argp->buf)++ != RPC_AUTH_NULL || *(argp->buf)++ != 0) {
+		dprintk("svc: bad null verf\n");
+		*authp = rpc_autherr_badverf;
+		return SVC_DENIED;
+	}
+
+	/* Signal that mapping to nobody uid/gid is required */
+	rqstp->rq_cred.cr_uid = (uid_t) -1;
+	rqstp->rq_cred.cr_gid = (gid_t) -1;
+	rqstp->rq_cred.cr_groups[0] = NOGROUP;
+
+	/* Put NULL verifier */
+	svc_putu32(resp, RPC_AUTH_NULL);
+	svc_putu32(resp, 0);
+	return SVC_OK;
+}
+
+static int
+svcauth_null_release(struct svc_rqst *rqstp)
+{
+	return 0; /* don't drop */
+}
+
+
+struct auth_ops svcauth_null = {
+	.name		= "null",
+	.flavour	= RPC_AUTH_NULL,
+	.accept 	= svcauth_null_accept,
+	.release	= svcauth_null_release,
+};
+
+
+int
+svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
+{
+	struct svc_buf	*argp = &rqstp->rq_argbuf;
+	struct svc_buf	*resp = &rqstp->rq_resbuf;
+	struct svc_cred	*cred = &rqstp->rq_cred;
+	u32		*bufp = argp->buf, slen, i;
+	int		len   = argp->len;
+
+	if ((len -= 3) < 0)
+		return SVC_GARBAGE;
+
+	bufp++;					/* length */
+	bufp++;					/* time stamp */
+	slen = XDR_QUADLEN(ntohl(*bufp++));	/* machname length */
+	if (slen > 64 || (len -= slen + 3) < 0)
+		goto badcred;
+	bufp += slen;				/* skip machname */
+
+	cred->cr_uid = ntohl(*bufp++);		/* uid */
+	cred->cr_gid = ntohl(*bufp++);		/* gid */
+
+	slen = ntohl(*bufp++);			/* gids length */
+	if (slen > 16 || (len -= slen + 2) < 0)
+		goto badcred;
+	for (i = 0; i < NGROUPS && i < slen; i++)
+		cred->cr_groups[i] = ntohl(*bufp++);
+	if (i < NGROUPS)
+		cred->cr_groups[i] = NOGROUP;
+	bufp += (slen - i);
+
+	if (*bufp++ != RPC_AUTH_NULL || *bufp++ != 0) {
+		*authp = rpc_autherr_badverf;
+		return SVC_DENIED;
+	}
+
+	argp->buf = bufp;
+	argp->len = len;
+
+	/* Put NULL verifier */
+	svc_putu32(resp, RPC_AUTH_NULL);
+	svc_putu32(resp, 0);
+
+	return SVC_OK;
+
+badcred:
+	*authp = rpc_autherr_badcred;
+	return SVC_DENIED;
+}
+
+int
+svcauth_unix_release(struct svc_rqst *rqstp)
+{
+	/* Verifier (such as it is) is already in place.
+	 */
+	return 0;
+}
+
+
+struct auth_ops svcauth_unix = {
+	.name		= "unix",
+	.flavour	= RPC_AUTH_UNIX,
+	.accept 	= svcauth_unix_accept,
+	.release	= svcauth_unix_release,
+};
+
--- ./net/sunrpc/sunrpc_syms.c	2002/10/11 00:42:26	1.1
+++ ./net/sunrpc/sunrpc_syms.c	2002/10/11 00:51:16	1.2
@@ -15,6 +15,7 @@
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/unistd.h>
+#include <linux/init.h>
 
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
@@ -22,6 +23,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/auth.h>
 
+
 /* RPC scheduler */
 EXPORT_SYMBOL(rpc_allocate);
 EXPORT_SYMBOL(rpc_free);
@@ -108,3 +110,33 @@ EXPORT_SYMBOL(nfs_debug);
 EXPORT_SYMBOL(nfsd_debug);
 EXPORT_SYMBOL(nlm_debug);
 #endif
+
+static int __init
+init_sunrpc(void)
+{
+#ifdef RPC_DEBUG
+	rpc_register_sysctl();
+#endif
+#ifdef CONFIG_PROC_FS
+	rpc_proc_init();
+#endif
+	cache_register(&auth_domain_cache);
+	cache_register(&ip_map_cache);
+	return 0;
+}
+
+static void __exit
+cleanup_sunrpc(void)
+{
+	cache_unregister(&auth_domain_cache);
+	cache_unregister(&ip_map_cache);
+#ifdef RPC_DEBUG
+	rpc_unregister_sysctl();
+#endif
+#ifdef CONFIG_PROCFS
+	rpc_proc_exit();
+#endif
+}
+MODULE_LICENSE("GPL");
+module_init(init_sunrpc);
+module_exit(cleanup_sunrpc);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
