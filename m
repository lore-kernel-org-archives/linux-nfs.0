From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 17 - Convert export-table to use new cache code
Date: Fri, 11 Oct 2002 15:27:33 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKj-0003bO-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLM-0003hC-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:12 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:54 +1000
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

This introduces two caches, svc_export_cache (nfsd.exports) and
svc_expkey_cache (nfsd.fh).
nfsd.exports maps client+directory  ->  export options.
nfsd.fh maps client + filehandle-fragment -> directory.

A major part of this change is that export entries are now reference counted,
so we have to be careful  to keep those counts correct.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |  356 +++++++++++++++++++++++++++---------------
 ./fs/nfsd/nfsfh.c             |   20 +-
 ./fs/nfsd/vfs.c               |    6 
 ./include/linux/nfsd/export.h |   28 ++-
 4 files changed, 275 insertions(+), 135 deletions(-)

--- ./include/linux/nfsd/export.h	2002/10/11 01:00:39	1.4
+++ ./include/linux/nfsd/export.h	2002/10/11 01:41:42	1.5
@@ -46,7 +46,7 @@
 #ifdef __KERNEL__
 
 struct svc_export {
-	struct list_head	ex_hash;
+	struct cache_head	h;
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
@@ -61,7 +61,7 @@ struct svc_export {
  * for type 0 (dev/ino), one for type 1 (fsid)
  */
 struct svc_expkey {
-	struct list_head	ek_hash;
+	struct cache_head	h;
 
 	struct auth_domain *	ek_client;
 	int			ek_fsidtype;
@@ -98,14 +98,30 @@ int			exp_rootfh(struct auth_domain *, 
 int			exp_pseudoroot(struct auth_domain *, struct svc_fh *fhp);
 int			nfserrno(int errno);
 
+extern void expkey_put(struct cache_head *item, struct cache_detail *cd);
+extern void svc_export_put(struct cache_head *item, struct cache_detail *cd);
+extern struct cache_detail svc_export_cache, svc_expkey_cache;
+
+static inline void exp_put(struct svc_export *exp)
+{
+	svc_export_put(&exp->h, &svc_export_cache);
+}
+
 static inline struct svc_export *
 exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv)
 {
 	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv);
-	if (ek)
-		return ek->ek_export;
-	else
-		return NULL;
+	if (ek && !IS_ERR(ek)) {
+		struct svc_export *exp = ek->ek_export;
+		int err;
+		cache_get(&exp->h);
+		expkey_put(&ek->h, &svc_expkey_cache);
+		if (exp &&
+		    (err = cache_check(&svc_export_cache, &exp->h))) 
+			exp = ERR_PTR(err);
+		return exp;
+	} else
+		return ERR_PTR(PTR_ERR(ek));
 }
 
 #endif /* __KERNEL__ */
--- ./fs/nfsd/export.c	2002/10/11 01:17:57	1.5
+++ ./fs/nfsd/export.c	2002/10/11 01:41:42	1.6
@@ -35,43 +35,99 @@
 typedef struct auth_domain	svc_client;
 typedef struct svc_export	svc_export;
 
-static void		exp_unexport_all(svc_client *clp);
 static void		exp_do_unexport(svc_export *unexp);
 static int		exp_verify_string(char *cp, int max);
 
+/*
+ * We have two caches.
+ * One maps client+vfsmnt+dentry to export options - the export map
+ * The other maps client+filehandle-fragment to export options. - the expkey map
+ *
+ * The export options are actually stored in the first map, and the
+ * second map contains a reference to the entry in the first map.
+ */
+
 #define	EXPKEY_HASHBITS		8
 #define	EXPKEY_HASHMAX		(1 << EXPKEY_HASHBITS)
 #define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
-static struct list_head expkey_table[EXPKEY_HASHMAX];
+static struct cache_head *expkey_table[EXPKEY_HASHMAX];
 
-static inline int expkey_hash(struct auth_domain *clp, int type, u32 *fsidv)
+static inline int svc_expkey_hash(struct svc_expkey *item)
 {
-	int hash = type;
-	char * cp = (char*)fsidv;
-	int len = (type==0)?8:4;
+	int hash = item->ek_fsidtype;
+	char * cp = (char*)item->ek_fsid;
+	int len = (item->ek_fsidtype==0)?8:4;
 	while (len--)
 		hash += *cp++;
-	cp = (char*)&clp;
-	len = sizeof(clp);
+	cp = (char*)&item->ek_client;
+	len = sizeof(item->ek_client);
 	while (len--)
 		hash += *cp++;
 	return hash & EXPKEY_HASHMASK;
 }
 
-/* hash table of exports indexed by dentry+client */
+void expkey_put(struct cache_head *item, struct cache_detail *cd)
+{
+	if (cache_put(item, cd)) {
+		struct svc_expkey *key = container_of(item, struct svc_expkey, h);
+		if (key->ek_export)
+			exp_put(key->ek_export);
+		auth_domain_put(key->ek_client);
+		kfree(key);
+	}
+}
+
+struct cache_detail svc_expkey_cache = {
+	.hash_size	= EXPKEY_HASHMAX,
+	.hash_table	= expkey_table,
+	.name		= "nfsd.fh",
+	.cache_put	= expkey_put,
+};
+
+static inline int svc_expkey_match (struct svc_expkey *a, struct svc_expkey *b)
+{
+	if (a->ek_fsidtype != b->ek_fsidtype ||
+	    a->ek_client != b->ek_client)
+		return 0;
+	if (a->ek_fsid[0] != b->ek_fsid[0])
+		return 0;
+	if (a->ek_fsidtype == 1)
+		return 1;
+	if (a->ek_fsid[1] != b->ek_fsid[1])
+		return 0;
+	return 1;
+}
+
+static inline void svc_expkey_init(struct svc_expkey *new, struct svc_expkey *item)
+{
+	cache_get(&item->ek_client->h);
+	new->ek_client = item->ek_client;
+	new->ek_fsidtype = item->ek_fsidtype;
+	new->ek_fsid[0] = item->ek_fsid[0];
+	new->ek_fsid[1] = item->ek_fsid[1];
+}
+
+static inline void svc_expkey_update(struct svc_expkey *new, struct svc_expkey *item)
+{
+	cache_get(&item->ek_export->h);
+	new->ek_export = item->ek_export;
+}
+
+static DefineSimpleCacheLookup(svc_expkey)
+
 #define	EXPORT_HASHBITS		8
 #define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
 #define	EXPORT_HASHMASK		(EXPORT_HASHMAX -1)
 
-struct list_head	export_table[EXPORT_HASHMAX];
+static struct cache_head *export_table[EXPORT_HASHMAX];
 
-static int export_hash(svc_client *clp, struct dentry *dentry)
+static inline int svc_export_hash(struct svc_export *item)
 {
 	void *k[2];
 	unsigned char *cp;
 	int rv, i;
-	k[0] = clp;
-	k[1] = dentry;
+	k[0] = item->ex_client;
+	k[1] = item->ex_dentry;
 
 	cp = (char*)k;
 	rv = 0;
@@ -80,24 +136,89 @@ static int export_hash(svc_client *clp, 
 	return rv & EXPORT_HASHMASK;
 }
 
+void svc_export_put(struct cache_head *item, struct cache_detail *cd)
+{
+	if (cache_put(item, cd)) {
+		struct svc_export *exp = container_of(item, struct svc_export, h);
+		dput(exp->ex_dentry);
+		mntput(exp->ex_mnt);
+		auth_domain_put(exp->ex_client);
+		kfree(exp);
+	}
+}
+
+struct cache_detail svc_export_cache = {
+	.hash_size	= EXPORT_HASHMAX,
+	.hash_table	= export_table,
+	.name		= "nfsd.export",
+	.cache_put	= svc_export_put,
+};
+
+static inline int svc_export_match(struct svc_export *a, struct svc_export *b)
+{
+	return a->ex_client == b->ex_client &&
+		a->ex_dentry == b->ex_dentry &&
+		a->ex_mnt == b->ex_mnt;
+}
+static inline void svc_export_init(struct svc_export *new, struct svc_export *item)
+{
+	cache_get(&item->ex_client->h);
+	new->ex_client = item->ex_client;
+	new->ex_dentry = dget(item->ex_dentry);
+	new->ex_mnt = mntget(item->ex_mnt);
+}
+
+static inline void svc_export_update(struct svc_export *new, struct svc_export *item)
+{
+	new->ex_flags = item->ex_flags;
+	new->ex_anon_uid = item->ex_anon_uid;
+	new->ex_anon_gid = item->ex_anon_gid;
+	new->ex_fsid = item->ex_fsid;
+}
+
+static DefineSimpleCacheLookup(svc_export)
+
+
 struct svc_expkey *
 exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv)
 {
-	struct list_head *head;
-	struct svc_expkey *ek;
+	struct svc_expkey key, *ek;
+	int err;
 	
 	if (!clp)
 		return NULL;
 
-	head = &expkey_table[expkey_hash(clp, fsid_type, fsidv)];
-	list_for_each_entry(ek, head, ek_hash)
-		if (ek->ek_fsidtype == fsid_type &&
-		    fsidv[0] == ek->ek_fsid[0] &&
-		    (fsid_type == 1 || fsidv[1] == ek->ek_fsid[1]) &&
-		    clp      == ek->ek_client)
-			return ek;
+	key.ek_client = clp;
+	key.ek_fsidtype = fsid_type;
+	key.ek_fsid[0] = fsidv[0];
+	key.ek_fsid[1] = fsidv[1];
+
+	ek = svc_expkey_lookup(&key, 0);
+	if (ek != NULL)
+		if ((err = cache_check(&svc_expkey_cache, &ek->h)))
+			ek = ERR_PTR(err);
+	return ek;
+}
+
+int exp_set_key(svc_client *clp, int fsid_type, u32 *fsidv, 
+		struct svc_export *exp)
+{
+	struct svc_expkey key, *ek;
+
+	key.ek_client = clp;
+	key.ek_fsidtype = fsid_type;
+	key.ek_fsid[0] = fsidv[0];
+	key.ek_fsid[1] = fsidv[1];
+	key.ek_export = exp;
+	key.h.expiry_time = NEVER;
+	key.h.flags = 0;
 
-	return NULL;
+	ek = svc_expkey_lookup(&key, 1);
+	if (ek) {
+		expkey_put(&ek->h, &svc_expkey_cache);
+		return 0;
+	}
+	return -ENOMEM;
 }
 
 /*
@@ -128,19 +249,21 @@ exp_get_fsid_key(svc_client *clp, int fs
 svc_export *
 exp_get_by_name(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry)
 {
-	svc_export *exp;
-	struct list_head *head = &export_table[export_hash(clp, dentry)];
-
+	struct svc_export *exp, key;
+	
 	if (!clp)
 		return NULL;
 
-	list_for_each_entry(exp, head, ex_hash) {
-		if (exp->ex_dentry == dentry && 
-		    exp->ex_mnt    == mnt &&
-		    exp->ex_client == clp)
-			return exp;
-	}
-	return NULL;
+	key.ex_client = clp;
+	key.ex_mnt = mnt;
+	key.ex_dentry = dentry;
+
+	exp = svc_export_lookup(&key, 0);
+	if (exp != NULL) 
+		if (cache_check(&svc_export_cache, &exp->h))
+			exp = NULL;
+
+	return exp;
 }
 
 /*
@@ -202,55 +325,32 @@ static void exp_fsid_unhash(struct svc_e
 		return;
 
 	ek = exp_get_fsid_key(exp->ex_client, exp->ex_fsid);
-	if (ek) {
-		list_del(&ek->ek_hash);
-		kfree(ek);
+	if (ek && !IS_ERR(ek)) {
+		ek->h.expiry_time = CURRENT_TIME-1;
+		expkey_put(&ek->h, &svc_expkey_cache);
 	}
+	svc_expkey_cache.nextcheck = CURRENT_TIME;
 }
 
 static int exp_fsid_hash(svc_client *clp, struct svc_export *exp)
 {
-	struct list_head *head;
-	struct svc_expkey *ek;
+	u32 fsid[2];
  
 	if ((exp->ex_flags & NFSEXP_FSID) == 0)
 		return 0;
 
-	ek = kmalloc(sizeof(*ek), GFP_KERNEL);
-	if (ek == NULL)
-		return -ENOMEM;
-
-	ek->ek_fsidtype = 1;
-	ek->ek_export = exp;
-	ek->ek_client = clp;
-
-	mk_fsid_v1(ek->ek_fsid, exp->ex_fsid);
-	
-	head = &expkey_table[expkey_hash(clp, 1, ek->ek_fsid)];
-	list_add(&ek->ek_hash, head);
-	return 0;
+	mk_fsid_v1(fsid, exp->ex_fsid);
+	return exp_set_key(clp, 1, fsid, exp);
 }
 
 static int exp_hash(struct auth_domain *clp, struct svc_export *exp)
 {
-	struct list_head *head;
-	struct svc_expkey *ek;
+	u32 fsid[2];
 	struct inode *inode;
- 
-	ek = kmalloc(sizeof(*ek), GFP_KERNEL);
-	if (ek == NULL)
-		return -ENOMEM;
-
-	ek->ek_fsidtype = 0;
-	ek->ek_export = exp;
-	ek->ek_client = clp;
 
 	inode = exp->ex_dentry->d_inode;
-	mk_fsid_v0(ek->ek_fsid, inode->i_sb->s_dev, inode->i_ino);
-	
-	head = &expkey_table[expkey_hash(clp, 0, ek->ek_fsid)];
-	list_add(&ek->ek_hash, head);
-	return 0;
+	mk_fsid_v0(fsid,  inode->i_sb->s_dev, inode->i_ino);
+	return exp_set_key(clp, 0, fsid, exp);
 }
 
 static void exp_unhash(struct svc_export *exp)
@@ -259,10 +359,11 @@ static void exp_unhash(struct svc_export
 	struct inode *inode = exp->ex_dentry->d_inode;
 
 	ek = exp_get_key(exp->ex_client, inode->i_sb->s_dev, inode->i_ino);
-	if (ek) {
-		list_del(&ek->ek_hash);
-		kfree(ek);
+	if (ek && !IS_ERR(ek)) {
+		ek->h.expiry_time = CURRENT_TIME-1;
+		expkey_put(&ek->h, &svc_expkey_cache);
 	}
+	svc_expkey_cache.nextcheck = CURRENT_TIME;
 }
 	
 extern struct dentry *
@@ -276,8 +377,9 @@ int
 exp_export(struct nfsctl_export *nxp)
 {
 	svc_client	*clp;
-	svc_export	*exp = NULL;
-	struct svc_expkey	*fsid_key;
+	struct svc_export	*exp = NULL;
+	struct svc_export	new;
+	struct svc_expkey	*fsid_key = NULL;
 	struct nameidata nd;
 	struct inode	*inode = NULL;
 	int		err;
@@ -312,6 +414,7 @@ exp_export(struct nfsctl_export *nxp)
 	/* must make sure there wont be an ex_fsid clash */
 	if ((nxp->ex_flags & NFSEXP_FSID) &&
 	    (fsid_key = exp_get_fsid_key(clp, nxp->ex_dev)) &&
+	    !IS_ERR(fsid_key) &&
 	    fsid_key->ek_export &&
 	    fsid_key->ek_export != exp)
 		goto finish;
@@ -361,31 +464,39 @@ exp_export(struct nfsctl_export *nxp)
 			find_exported_dentry;
 
 	err = -ENOMEM;
-	if (!(exp = kmalloc(sizeof(*exp), GFP_USER)))
-		goto finish;
-	dprintk("nfsd: created export entry %p for client %p\n", exp, clp);
 
-	exp->ex_client = clp;
-	cache_get(&clp->h);
-	exp->ex_mnt = mntget(nd.mnt);
-	exp->ex_dentry = dget(nd.dentry);
-	exp->ex_flags = nxp->ex_flags;
-	exp->ex_anon_uid = nxp->ex_anon_uid;
-	exp->ex_anon_gid = nxp->ex_anon_gid;
-	exp->ex_fsid = nxp->ex_dev;
+	dprintk("nfsd: creating export entry %p for client %p\n", exp, clp);
+
+	new.h.expiry_time = NEVER;
+	new.h.flags = 0;
+	new.ex_client = clp;
+	new.ex_mnt = nd.mnt;
+	new.ex_dentry = nd.dentry;
+	new.ex_flags = nxp->ex_flags;
+	new.ex_anon_uid = nxp->ex_anon_uid;
+	new.ex_anon_gid = nxp->ex_anon_gid;
+	new.ex_fsid = nxp->ex_dev;
+
+	exp = svc_export_lookup(&new, 2);
+
+	if (exp == NULL)
+		goto finish;
 
-	list_add_tail(&exp->ex_hash,
-		      &export_table[export_hash(clp, nd.dentry)]);
 	err = 0;
 
 	if (exp_hash(clp, exp) ||
 	    exp_fsid_hash(clp, exp)) {
 		/* failed to create at least one index */
 		exp_do_unexport(exp);
+		cache_flush();
 		err = -ENOMEM;
 	}
 
 finish:
+	if (exp)
+		exp_put(exp);
+	if (fsid_key && !IS_ERR(fsid_key))
+		expkey_put(&fsid_key->h, &svc_expkey_cache);
 	if (clp)
 		auth_domain_put(clp);
 	path_release(&nd);
@@ -402,18 +513,10 @@ out:
 static void
 exp_do_unexport(svc_export *unexp)
 {
-	struct dentry	*dentry;
-	struct vfsmount *mnt;
-
-	list_del(&unexp->ex_hash);
+	unexp->h.expiry_time = CURRENT_TIME-1;
+	svc_export_cache.nextcheck = CURRENT_TIME;
 	exp_unhash(unexp);
 	exp_fsid_unhash(unexp);
-	dentry = unexp->ex_dentry;
-	mnt = unexp->ex_mnt;
-	dput(dentry);
-	mntput(mnt);
-
-	kfree(unexp);
 }
 
 /*
@@ -422,17 +525,16 @@ exp_do_unexport(svc_export *unexp)
 static void
 exp_unexport_all(svc_client *clp)
 {
-	struct list_head *lp, *tmp;
+	struct svc_export *exp;
 	int index;
 
 	dprintk("unexporting all fs's for clnt %p\n", clp);
 
-	for (index=0; index<EXPORT_HASHMAX; index++)
-		list_for_each_safe(lp, tmp, &export_table[index]) {
-			svc_export *exp = list_entry(lp, struct svc_export, ex_hash);
-			if (exp->ex_client == clp)
-				exp_do_unexport(exp);
-		}
+	cache_for_each(exp, &svc_export_cache, index, h)
+		if (exp->ex_client == clp)
+			exp_do_unexport(exp);
+	cache_flush();
+
 }
 
 /*
@@ -455,13 +557,15 @@ exp_unexport(struct nfsctl_export *nxp)
 
 	if (dom) {
 		struct svc_expkey *key = exp_get_key(dom, nxp->ex_dev, nxp->ex_ino);
-		if (key && key->ek_export) {
+		if (key && !IS_ERR(key) && key->ek_export) {
 			exp_do_unexport(key->ek_export);
 			err = 0;
+			expkey_put(&key->h, &svc_expkey_cache);
 		} else
 			dprintk("nfsd: no export %x/%lx for %s\n",
 				nxp->ex_dev, nxp->ex_ino, nxp->ex_client);
 		auth_domain_put(dom);
+		cache_flush();
 	} else
 		dprintk("nfsd: unexport couldn't find %s\n", nxp->ex_client);
 
@@ -525,14 +629,17 @@ int
 exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp)
 {
 	struct svc_expkey *fsid_key;
+	int rv;
 
 	fsid_key = exp_get_fsid_key(clp, 0);
 	if (!fsid_key || IS_ERR(fsid_key))
 		return nfserr_perm;
 
 	dget(fsid_key->ek_export->ex_dentry);
-	return fh_compose(fhp, fsid_key->ek_export, 
+	rv = fh_compose(fhp, fsid_key->ek_export, 
 			  fsid_key->ek_export->ex_dentry, NULL);
+	expkey_put(&fsid_key->h, &svc_expkey_cache);
+	return rv;
 }
 
 /* Iterator */
@@ -541,55 +648,58 @@ static void *e_start(struct seq_file *m,
 {
 	loff_t n = *pos;
 	unsigned hash, export;
-	svc_export  *exp;
+	struct cache_head *ch;
 	
 	exp_readlock();
+	read_lock(&svc_export_cache.hash_lock);
 	if (!n--)
 		return (void *)1;
 	hash = n >> 32;
 	export = n & ((1LL<<32) - 1);
 
-	list_for_each_entry(exp, &export_table[hash], ex_hash)
+	
+	for (ch=export_table[hash]; ch; ch=ch->next)
 		if (!export--)
-			return exp;
+			return ch;
 	n &= ~((1LL<<32) - 1);
 	do {
 		hash++;
 		n += 1LL<<32;
-	} while(hash < EXPORT_HASHMAX && list_empty(&export_table[hash]));
+	} while(hash < EXPORT_HASHMAX && export_table[hash]==NULL);
 	if (hash >= EXPORT_HASHMAX)
 		return NULL;
 	*pos = n+1;
-	return list_entry(export_table[hash].next, svc_export, ex_hash);
+	return export_table[hash];
 }
 
 static void *e_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	svc_export *exp = p;
+	struct cache_head *ch = p;
 	int hash = (*pos >> 32);
 
 	if (p == (void *)1)
 		hash = 0;
-	else if (exp->ex_hash.next == &export_table[hash]) {
+	else if (ch->next == NULL) {
 		hash++;
 		*pos += 1LL<<32;
 	} else {
 		++*pos;
-		return list_entry(exp->ex_hash.next, svc_export, ex_hash);
+		return ch->next;
 	}
 	*pos &= ~((1LL<<32) - 1);
-	while (hash < EXPORT_HASHMAX && list_empty(&export_table[hash])) {
+	while (hash < EXPORT_HASHMAX && export_table[hash] == NULL) {
 		hash++;
 		*pos += 1LL<<32;
 	}
 	if (hash >= EXPORT_HASHMAX)
 		return NULL;
 	++*pos;
-	return list_entry(export_table[hash].next, svc_export, ex_hash);
+	return export_table[hash];
 }
 
 static void e_stop(struct seq_file *m, void *p)
 {
+	read_unlock(&svc_export_cache.hash_lock);
 	exp_readunlock();
 }
 
@@ -640,7 +750,8 @@ static inline void mangle(struct seq_fil
 
 static int e_show(struct seq_file *m, void *p)
 {
-	struct svc_export *exp = p;
+	struct cache_head *cp = p;
+	struct svc_export *exp = container_of(cp, struct svc_export, h);
 	svc_client *clp;
 	char *pbuf;
 
@@ -651,7 +762,10 @@ static int e_show(struct seq_file *m, vo
 	}
 
 	clp = exp->ex_client;
-
+	cache_get(&exp->h);
+	if (cache_check(&svc_export_cache, &exp->h))
+		return 0;
+	if (cache_put(&exp->h, &svc_export_cache)) BUG();
 	pbuf = m->private;
 	mangle(m, d_path(exp->ex_dentry, exp->ex_mnt,
 			 pbuf, PAGE_SIZE));
@@ -767,15 +881,10 @@ exp_verify_string(char *cp, int max)
 void
 nfsd_export_init(void)
 {
-	int		i;
-
 	dprintk("nfsd: initializing export module.\n");
 
-	for (i = 0; i < EXPORT_HASHMAX ; i++)
-		INIT_LIST_HEAD(&export_table[i]);
-
-	for (i = 0; i < EXPKEY_HASHMAX; i++)
-		INIT_LIST_HEAD(&expkey_table[i]);
+	cache_register(&svc_export_cache);
+	cache_register(&svc_expkey_cache);
 
 }
 
@@ -793,6 +902,9 @@ nfsd_export_shutdown(void)
 	exp_unexport_all(NULL);
 	svcauth_unix_purge();
 
+	cache_unregister(&svc_export_cache);
+	cache_unregister(&svc_expkey_cache);
+
 	exp_writeunlock();
 	dprintk("nfsd: export shutdown complete.\n");
 }
--- ./fs/nfsd/vfs.c	2002/10/11 00:57:14	1.2
+++ ./fs/nfsd/vfs.c	2002/10/11 01:41:42	1.3
@@ -135,6 +135,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 				dput(dentry);
 				dentry = dget(dparent);
 			} else {
+				exp_put(exp);
 				exp = exp2;
 			}
 			mntput(mnt);
@@ -157,11 +158,14 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			exp2 = exp_get_by_name(exp->ex_client, mnt, mounts);
 			if (exp2 && EX_CROSSMNT(exp2)) {
 				/* successfully crossed mount point */
+				exp_put(exp);
 				exp = exp2;
 				dput(dentry);
 				dentry = mounts;
-			} else
+			} else {
+				if (exp2) exp_put(exp2);
 				dput(mounts);
+			}
 			mntput(mnt);
 		}
 	}
--- ./fs/nfsd/nfsfh.c	2002/10/11 00:57:14	1.2
+++ ./fs/nfsd/nfsfh.c	2002/10/11 01:41:42	1.3
@@ -86,7 +86,7 @@ u32
 fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
 {
 	struct knfsd_fh	*fh = &fhp->fh_handle;
-	struct svc_export *exp;
+	struct svc_export *exp = NULL;
 	struct dentry	*dentry;
 	struct inode	*inode;
 	u32		error = 0;
@@ -144,13 +144,12 @@ fh_verify(struct svc_rqst *rqstp, struct
 			exp = exp_find(rqstp->rq_client, 0, tfh);
 		}
 
-		/*
-		 * Look up the export entry.
-		 */
-		error = nfserr_stale; 
+		error = nfserr_dropit;
+		if (IS_ERR(exp))
+			goto out;
 
+		error = nfserr_stale; 
 		if (!exp)
-			/* export entry revoked */
 			goto out;
 
 		/* Check if the request originated from a secure port. */
@@ -221,6 +220,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 		dentry = fhp->fh_dentry;
 		exp = fhp->fh_export;
 	}
+	cache_get(&exp->h);
 
 	inode = dentry->d_inode;
 
@@ -263,6 +263,8 @@ fh_verify(struct svc_rqst *rqstp, struct
 	}
 #endif
 out:
+	if (exp && !IS_ERR(exp))
+		exp_put(exp);
 	if (error == nfserr_stale)
 		nfsdstats.fh_stale++;
 	return error;
@@ -344,6 +346,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 
 	fhp->fh_dentry = dentry; /* our internal copy */
 	fhp->fh_export = exp;
+	cache_get(&exp->h);
 
 	if (ref_fh_version == 0xca) {
 		/* old style filehandle please */
@@ -442,6 +445,7 @@ void
 fh_put(struct svc_fh *fhp)
 {
 	struct dentry * dentry = fhp->fh_dentry;
+	struct svc_export * exp = fhp->fh_export;
 	if (dentry) {
 		fh_unlock(fhp);
 		fhp->fh_dentry = NULL;
@@ -452,6 +456,10 @@ fh_put(struct svc_fh *fhp)
 #endif
 		nfsd_nr_put++;
 	}
+	if (exp) {
+		svc_export_put(&exp->h, &svc_export_cache);
+		fhp->fh_export = NULL;
+	}
 	return;
 }
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
