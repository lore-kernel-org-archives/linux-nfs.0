From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 16 of 16 - Remove per-client list of exports.
Date: Thu, 12 Sep 2002 12:36:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023616.19699@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJqZ-0002rC-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:36:48 -0700
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

This is used:
  to iterate all exports when making /proc/fs/nfs/exports
  to find all exports of a client to unexport them.

The first can just as easily be done by iterating the export_table
hash table.
The second is very rarely called and can be done by iterating the
hash table looking for exports for the given client.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   64 +++++++++++++++++-------------------------
 ./include/linux/nfsd/export.h |    2 -
 2 files changed, 27 insertions(+), 39 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/12 00:05:48	1.12
+++ ./include/linux/nfsd/export.h	2002/09/12 00:33:42	1.13
@@ -48,12 +48,10 @@
 struct svc_client {
 	struct svc_client *	cl_next;
 	char			cl_ident[NFSCLNT_IDMAX];
-	struct list_head	cl_list;
 };
 
 struct svc_export {
 	struct list_head	ex_hash;
-	struct list_head	ex_list;
 	struct svc_client *	ex_client;
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
--- ./fs/nfsd/export.c	2002/09/12 00:05:48	1.15
+++ ./fs/nfsd/export.c	2002/09/12 00:33:42	1.16
@@ -322,8 +322,6 @@ exp_export(struct nfsctl_export *nxp)
 	struct nameidata nd;
 	struct inode	*inode = NULL;
 	int		err;
-	dev_t		dev;
-	ino_t		ino;
 
 	/* Consistency check */
 	err = -EINVAL;
@@ -348,8 +346,6 @@ exp_export(struct nfsctl_export *nxp)
 	if (err)
 		goto out_unlock;
 	inode = nd.dentry->d_inode;
-	dev = inode->i_sb->s_dev;
-	ino = inode->i_ino;
 	err = -EINVAL;
 
 	exp = exp_get_by_name(clp, nd.mnt, nd.dentry);
@@ -417,8 +413,6 @@ exp_export(struct nfsctl_export *nxp)
 	exp->ex_anon_gid = nxp->ex_anon_gid;
 	exp->ex_fsid = nxp->ex_dev;
 
-	list_add_tail(&exp->ex_list, &clp->cl_list);
-
 	list_add_tail(&exp->ex_hash,
 		      &export_table[export_hash(clp, nd.dentry)]);
 	err = 0;
@@ -449,7 +443,6 @@ exp_do_unexport(svc_export *unexp)
 	struct vfsmount *mnt;
 	struct inode	*inode;
 
-	list_del(&unexp->ex_list);
 	list_del(&unexp->ex_hash);
 	exp_unhash(unexp);
 	exp_fsid_unhash(unexp);
@@ -468,14 +461,17 @@ exp_do_unexport(svc_export *unexp)
 static void
 exp_unexport_all(svc_client *clp)
 {
-	struct list_head *p = &clp->cl_list;
+	struct list_head *lp, *tmp;
+	int index;
 
 	dprintk("unexporting all fs's for clnt %p\n", clp);
 
-	while (!list_empty(p)) {
-		svc_export *exp = list_entry(p->next, svc_export, ex_list);
-		exp_do_unexport(exp);
-	}
+	for (index=0; index<EXPORT_HASHMAX; index++)
+		list_for_each_safe(lp, tmp, &export_table[index]) {
+			svc_export *exp = list_entry(lp, struct svc_export, ex_hash);
+			if (exp->ex_client == clp)
+				exp_do_unexport(exp);
+		}
 }
 
 /*
@@ -611,56 +607,52 @@ exp_getclientbyname(char *ident)
 static void *e_start(struct seq_file *m, loff_t *pos)
 {
 	loff_t n = *pos;
-	unsigned client, export;
-	svc_client *clp;
-	struct list_head *p;
+	unsigned hash, export;
+	svc_export  *exp;
 	
 	exp_readlock();
 	if (!n--)
 		return (void *)1;
-	client = n >> 32;
+	hash = n >> 32;
 	export = n & ((1LL<<32) - 1);
-	for (clp = clients; client && clp; clp = clp->cl_next, client--)
-		;
-	if (!clp)
-		return NULL;
-	list_for_each(p, &clp->cl_list)
+
+	list_for_each_entry(exp, &export_table[hash], ex_hash)
 		if (!export--)
-			return list_entry(p, svc_export, ex_list);
+			return exp;
 	n &= ~((1LL<<32) - 1);
 	do {
-		clp = clp->cl_next;
+		hash++;
 		n += 1LL<<32;
-	} while(clp && list_empty(&clp->cl_list));
-	if (!clp)
+	} while(hash < EXPORT_HASHMAX && list_empty(&export_table[hash]));
+	if (hash >= EXPORT_HASHMAX)
 		return NULL;
 	*pos = n+1;
-	return list_entry(clp->cl_list.next, svc_export, ex_list);
+	return list_entry(export_table[hash].next, svc_export, ex_hash);
 }
 
 static void *e_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	svc_export *exp = p;
-	svc_client *clp;
+	int hash = (*pos >> 32);
 
 	if (p == (void *)1)
-		clp = clients;
-	else if (exp->ex_list.next == &exp->ex_client->cl_list) {
-		clp = exp->ex_client->cl_next;
+		hash = 0;
+	else if (exp->ex_hash.next == &export_table[hash]) {
+		hash++;
 		*pos += 1LL<<32;
 	} else {
 		++*pos;
-		return list_entry(exp->ex_list.next, svc_export, ex_list);
+		return list_entry(exp->ex_hash.next, svc_export, ex_hash);
 	}
 	*pos &= ~((1LL<<32) - 1);
-	while (clp && list_empty(&clp->cl_list)) {
-		clp = clp->cl_next;
+	while (hash < EXPORT_HASHMAX && list_empty(&export_table[hash])) {
+		hash++;
 		*pos += 1LL<<32;
 	}
-	if (!clp)
+	if (hash >= EXPORT_HASHMAX)
 		return NULL;
 	++*pos;
-	return list_entry(clp->cl_list.next, svc_export, ex_list);
+	return list_entry(export_table[hash].next, svc_export, ex_hash);
 }
 
 static void e_stop(struct seq_file *m, void *p)
@@ -782,8 +774,6 @@ exp_addclient(struct nfsctl_client *ncp)
 			goto out_unlock;
 		memset(clp, 0, sizeof(*clp));
 
-		INIT_LIST_HEAD(&clp->cl_list);
-
 		dprintk("created client %s (%p)\n", ncp->cl_ident, clp);
 
 		strcpy(clp->cl_ident, ncp->cl_ident);


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
