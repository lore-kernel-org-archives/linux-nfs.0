From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 13 of 16 - Separate out the multiple keys in the export hash table.
Date: Thu, 12 Sep 2002 12:36:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023606.19668@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJqL-0002bd-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:36:33 -0700
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

Currently each entry in the export table had two hash chains
going through it, one for hash-by-dev/ino,  One for hash-by-fsid.
This is contrary to the goal of a simple hash table structure.

The two hash-tables per client are replace by one which stores 'exp_key's
which contain the key (as a file handle fragment) and a pointer to the
real export entry.

The export entries are then all stored in a single hash table indexed
by client+vfsmount+dentry;

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |  209 ++++++++++++++++++++++++++++++++----------
 ./include/linux/nfsd/export.h |   16 ++-
 ./include/linux/nfsd/nfsfh.h  |   13 ++
 3 files changed, 191 insertions(+), 47 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 03:56:39	1.9
+++ ./include/linux/nfsd/export.h	2002/09/11 23:35:25	1.10
@@ -52,13 +52,11 @@ struct svc_client {
 	struct svc_client *	cl_next;
 	char			cl_ident[NFSCLNT_IDMAX];
 	struct list_head	cl_export[NFSCLNT_EXPMAX];
-	struct list_head	cl_expfsid[NFSCLNT_EXPMAX];
 	struct list_head	cl_list;
 };
 
 struct svc_export {
 	struct list_head	ex_hash;
-	struct list_head	ex_fsid_hash;
 	struct list_head	ex_list;
 	struct svc_client *	ex_client;
 	int			ex_flags;
@@ -69,6 +67,20 @@ struct svc_export {
 	int			ex_fsid;
 };
 
+/* an "export key" (expkey) maps a filehandlefragement to an
+ * svc_export for a given client.  There can be two per export, one
+ * for type 0 (dev/ino), one for type 1 (fsid)
+ */
+struct svc_expkey {
+	struct list_head	ek_hash;
+
+	struct svc_client	*ek_client;
+	int			ek_fsidtype;
+	u32			ek_fsid[2];
+
+	struct svc_export	*ek_export;
+};
+
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
 #define EX_RDONLY(exp)		((exp)->ex_flags & NFSEXP_READONLY)
--- ./include/linux/nfsd/nfsfh.h	2002/09/11 04:05:05	1.1
+++ ./include/linux/nfsd/nfsfh.h	2002/09/11 23:35:25	1.2
@@ -199,6 +199,19 @@ typedef struct svc_fh {
 
 } svc_fh;
 
+static inline void mk_fsid_v0(u32 *fsidv, dev_t dev, ino_t ino)
+{
+	fsidv[0] = htonl((MAJOR(dev)<<16) |
+			MINOR(dev));
+	fsidv[1] = ino_t_to_u32(ino);
+}
+
+static inline void mk_fsid_v1(u32 *fsidv, u32 fsid)
+{
+	fsidv[0] = fsid;
+}
+
+
 /*
  * Shorthand for dprintk()'s
  */
--- ./fs/nfsd/export.c	2002/09/11 03:56:39	1.12
+++ ./fs/nfsd/export.c	2002/09/11 23:35:25	1.13
@@ -47,9 +47,16 @@ static int		exp_verify_string(char *cp, 
 #define CLIENT_HASHMASK		(CLIENT_HASHMAX - 1)
 #define CLIENT_HASH(a) \
 		((((a)>>24) ^ ((a)>>16) ^ ((a)>>8) ^(a)) & CLIENT_HASHMASK)
-/* XXX: is this adequate for 32bit kdev_t ? */
-#define EXPORT_HASH(dev)	(MINOR(dev) & (NFSCLNT_EXPMAX - 1))
-#define EXPORT_FSID_HASH(fsid)	((fsid) & (NFSCLNT_EXPMAX - 1))
+
+static inline int expkey_hash(int type, u32 *fsidv)
+{
+	int hash = type;
+	char * cp = (char*)fsidv;
+	int len = (type==0)?8:4;
+	while (len--)
+		hash += *cp++;
+	return hash & (NFSCLNT_EXPMAX-1);
+}
 
 struct svc_clnthash {
 	struct svc_clnthash *	h_next;
@@ -59,64 +66,115 @@ struct svc_clnthash {
 static struct svc_clnthash *	clnt_hash[CLIENT_HASHMAX];
 static svc_client *		clients;
 
+/* hash table of exports indexed by dentry+client */
+#define	EXPORT_HASHBITS		8
+#define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
+#define	EXPORT_HASHMASK		(EXPORT_HASHMAX -1)
+
+struct list_head	export_table[EXPORT_HASHMAX];
+
+static int export_hash(svc_client *clp, struct dentry *dentry)
+{
+	void *k[2];
+	unsigned char *cp;
+	int rv, i;
+	k[0] = clp;
+	k[1] = dentry;
+
+	cp = (char*)k;
+	rv = 0;
+	for (i=0; i<sizeof(k); i++)
+		rv ^= cp[i];
+	return rv & EXPORT_HASHMASK;
+}
 
 /*
  * Find the client's export entry matching xdev/xino.
  */
-svc_export *
-exp_get(svc_client *clp, dev_t dev, ino_t ino)
+struct svc_expkey *
+exp_get_key(svc_client *clp, dev_t dev, ino_t ino)
 {
 	struct list_head *head;
-	svc_export *exp;
-
+	struct svc_expkey *ek;
+	u32 fsidv[2];
+	
 	if (!clp)
 		return NULL;
 
-	head = &clp->cl_export[EXPORT_HASH(dev)];
-	list_for_each_entry(exp, head, ex_hash) {
-		struct inode *inode = exp->ex_dentry->d_inode;
-		if (inode->i_ino == ino && 
-		    inode->i_sb->s_dev ==  dev)
-			return exp;
-	}
+	mk_fsid_v0(fsidv, dev, ino);
+
+	head = &clp->cl_export[expkey_hash(0, fsidv)];
+	list_for_each_entry(ek, head, ek_hash)
+		if (ek->ek_fsidtype == 0 &&
+		    fsidv[0] == ek->ek_fsid[0] &&
+		    fsidv[1] == ek->ek_fsid[1] &&
+		    clp      == ek->ek_client)
+			return ek;
+
 	return NULL;
 }
+inline svc_export *
+exp_get(svc_client *clp, dev_t dev, ino_t ino)
+{
+	struct svc_expkey *ek;
+
+	ek = exp_get_key(clp, dev, ino);
+	if (ek)
+		return ek->ek_export;
+	else
+		return NULL;
+}
 
 /*
  * Find the client's export entry matching fsid
  */
-svc_export *
-exp_get_fsid(svc_client *clp, int fsid)
+struct svc_expkey *
+exp_get_fsid_key(svc_client *clp, int fsid)
 {
-	struct list_head *head, *p;
-
+	struct list_head *head;
+	struct svc_expkey *ek;
+	u32 fsidv[2];
 
 	if (!clp)
 		return NULL;
 
-	head = &clp->cl_expfsid[EXPORT_FSID_HASH(fsid)];
-	list_for_each(p, head) {
-		svc_export *exp = list_entry(p, svc_export, ex_fsid_hash);
-		if (exp->ex_fsid == fsid)
-			return exp;
+	mk_fsid_v1(fsidv, fsid);
+
+	head = &clp->cl_export[expkey_hash(1, fsidv)];
+	list_for_each_entry(ek, head, ek_hash) {
+		if (ek->ek_fsidtype == 1 &&
+		    fsidv[0] == ek->ek_fsid[0] &&
+		    clp      == ek->ek_client)
+			return ek;
 	}
 	return NULL;
 }
+inline svc_export *
+exp_get_fsid(svc_client *clp, int fsid)
+{
+	struct svc_expkey *ek;
+
+	ek = exp_get_fsid_key(clp, fsid);
+	if (ek)
+		return ek->ek_export;
+	else
+		return NULL;
+}
 
 svc_export *
 exp_get_by_name(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry)
 {
-	struct list_head *head, *p;
-	int hash = EXPORT_HASH(mnt->mnt_sb->s_dev);
+	svc_export *exp;
+	struct list_head *head = &export_table[export_hash(clp, dentry)];
 
 	if (!clp)
 		return NULL;
 
-	head = &clp->cl_export[hash];
-	list_for_each(p, head) {
-		svc_export *exp = list_entry(p, svc_export, ex_hash);
-		if (exp->ex_dentry == dentry && exp->ex_mnt == mnt)
-			break;
+	list_for_each_entry(exp, head, ex_hash) {
+		if (exp->ex_dentry == dentry && 
+		    exp->ex_mnt    == mnt &&
+		    exp->ex_client == clp)
+			return exp;
 	}
 	return NULL;
 }
@@ -174,23 +232,75 @@ exp_writeunlock(void)
 
 static void exp_fsid_unhash(struct svc_export *exp)
 {
+	struct svc_expkey *ek;
 
 	if ((exp->ex_flags & NFSEXP_FSID) == 0)
 		return;
 
-	list_del_init(&exp->ex_fsid_hash);
+	ek = exp_get_fsid_key(exp->ex_client, exp->ex_fsid);
+	if (ek) {
+		list_del(&ek->ek_hash);
+		kfree(ek);
+	}
 }
 
-static void exp_fsid_hash(struct svc_client *clp, struct svc_export *exp)
+static int exp_fsid_hash(struct svc_client *clp, struct svc_export *exp)
 {
 	struct list_head *head;
-
+	struct svc_expkey *ek;
+ 
 	if ((exp->ex_flags & NFSEXP_FSID) == 0)
-		return;
-	head = clp->cl_expfsid + EXPORT_FSID_HASH(exp->ex_fsid);
-	list_add(&exp->ex_fsid_hash, head);
+		return 0;
+
+	ek = kmalloc(sizeof(*ek), GFP_KERNEL);
+	if (ek == NULL)
+		return -ENOMEM;
+
+	ek->ek_fsidtype = 1;
+	ek->ek_export = exp;
+	ek->ek_client = clp;
+
+	mk_fsid_v1(ek->ek_fsid, exp->ex_fsid);
+	
+	head = &clp->cl_export[expkey_hash(1, ek->ek_fsid)];
+	list_add(&ek->ek_hash, head);
+	return 0;
+}
+
+static int exp_hash(struct svc_client *clp, struct svc_export *exp)
+{
+	struct list_head *head;
+	struct svc_expkey *ek;
+	struct inode *inode;
+ 
+	ek = kmalloc(sizeof(*ek), GFP_KERNEL);
+	if (ek == NULL)
+		return -ENOMEM;
+
+	ek->ek_fsidtype = 0;
+	ek->ek_export = exp;
+	ek->ek_client = clp;
+
+	inode = exp->ex_dentry->d_inode;
+	mk_fsid_v0(ek->ek_fsid, inode->i_sb->s_dev, inode->i_ino);
+	
+	head = &clp->cl_export[expkey_hash(0, ek->ek_fsid)];
+	list_add(&ek->ek_hash, head);
+	return 0;
 }
 
+static void exp_unhash(struct svc_export *exp)
+{
+	struct svc_expkey *ek;
+	struct inode *inode = exp->ex_dentry->d_inode;
+
+	ek = exp_get_key(exp->ex_client, inode->i_sb->s_dev, inode->i_ino);
+	if (ek) {
+		list_del(&ek->ek_hash);
+		kfree(ek);
+	}
+}
+	
 extern struct dentry *
 find_exported_dentry(struct super_block *sb, void *obj, void *parent,
 		     int (*acceptable)(void *context, struct dentry *de),
@@ -237,7 +347,7 @@ exp_export(struct nfsctl_export *nxp)
 	ino = inode->i_ino;
 	err = -EINVAL;
 
-	exp = exp_get(clp, dev, ino);
+	exp = exp_get_by_name(clp, nd.mnt, nd.dentry);
 
 	/* must make sure there wont be an ex_fsid clash */
 	if ((nxp->ex_flags & NFSEXP_FSID) &&
@@ -253,8 +363,8 @@ exp_export(struct nfsctl_export *nxp)
 		exp->ex_anon_uid = nxp->ex_anon_uid;
 		exp->ex_anon_gid = nxp->ex_anon_gid;
 		exp->ex_fsid     = nxp->ex_dev;
-		exp_fsid_hash(clp, exp);
-		err = 0;
+
+		err = exp_fsid_hash(clp, exp);
 		goto finish;
 	}
 
@@ -302,13 +412,19 @@ exp_export(struct nfsctl_export *nxp)
 	exp->ex_anon_gid = nxp->ex_anon_gid;
 	exp->ex_fsid = nxp->ex_dev;
 
-	list_add(&exp->ex_hash, clp->cl_export + EXPORT_HASH(dev));
 	list_add_tail(&exp->ex_list, &clp->cl_list);
 
-	exp_fsid_hash(clp, exp);
-
+	list_add_tail(&exp->ex_hash,
+		      &export_table[export_hash(clp, nd.dentry)]);
 	err = 0;
 
+	if (exp_hash(clp, exp) ||
+	    exp_fsid_hash(clp, exp)) {
+		/* failed to create at least one index */
+		exp_do_unexport(exp);
+		err = -ENOMEM;
+	}
+
 finish:
 	path_release(&nd);
 out_unlock:
@@ -330,6 +446,7 @@ exp_do_unexport(svc_export *unexp)
 
 	list_del(&unexp->ex_list);
 	list_del(&unexp->ex_hash);
+	exp_unhash(unexp);
 	exp_fsid_unhash(unexp);
 	dentry = unexp->ex_dentry;
 	mnt = unexp->ex_mnt;
@@ -659,10 +776,9 @@ exp_addclient(struct nfsctl_client *ncp)
 		if (!(clp = kmalloc(sizeof(*clp), GFP_KERNEL)))
 			goto out_unlock;
 		memset(clp, 0, sizeof(*clp));
-		for (i = 0; i < NFSCLNT_EXPMAX; i++) {
+		for (i = 0; i < NFSCLNT_EXPMAX; i++)
 			INIT_LIST_HEAD(&clp->cl_export[i]);
-			INIT_LIST_HEAD(&clp->cl_expfsid[i]);
-		}
+
 		INIT_LIST_HEAD(&clp->cl_list);
 
 		dprintk("created client %s (%p)\n", ncp->cl_ident, clp);
@@ -814,6 +930,9 @@ nfsd_export_init(void)
 		clnt_hash[i] = NULL;
 	clients = NULL;
 
+	for (i = 0; i < EXPORT_HASHMAX ; i++)
+		INIT_LIST_HEAD(&export_table[i]);
+
 }
 
 /*


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
