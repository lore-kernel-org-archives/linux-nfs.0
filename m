From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 15 of 16 - Unite per-client export key hash tables.
Date: Thu, 12 Sep 2002 12:36:14 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023614.19695@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJqX-0002lU-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:36:46 -0700
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

Instead of a separate hash table per client we now
have one hash table which includes the client in the key.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   24 +++++++++++++++++-------
 ./include/linux/nfsd/export.h |    4 ----
 2 files changed, 17 insertions(+), 11 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 23:55:44	1.11
+++ ./include/linux/nfsd/export.h	2002/09/12 00:05:48	1.12
@@ -45,13 +45,9 @@
 
 #ifdef __KERNEL__
 
-/* The following are hashtable sizes and must be powers of 2 */
-#define NFSCLNT_EXPMAX		16
-
 struct svc_client {
 	struct svc_client *	cl_next;
 	char			cl_ident[NFSCLNT_IDMAX];
-	struct list_head	cl_export[NFSCLNT_EXPMAX];
 	struct list_head	cl_list;
 };
 
--- ./fs/nfsd/export.c	2002/09/11 23:55:44	1.14
+++ ./fs/nfsd/export.c	2002/09/12 00:05:48	1.15
@@ -48,14 +48,23 @@ static int		exp_verify_string(char *cp, 
 #define CLIENT_HASH(a) \
 		((((a)>>24) ^ ((a)>>16) ^ ((a)>>8) ^(a)) & CLIENT_HASHMASK)
 
-static inline int expkey_hash(int type, u32 *fsidv)
+#define	EXPKEY_HASHBITS		8
+#define	EXPKEY_HASHMAX		(1 << EXPKEY_HASHBITS)
+#define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
+static struct list_head expkey_table[EXPKEY_HASHMAX];
+
+static inline int expkey_hash(struct svc_client *clp, int type, u32 *fsidv)
 {
 	int hash = type;
 	char * cp = (char*)fsidv;
 	int len = (type==0)?8:4;
 	while (len--)
 		hash += *cp++;
-	return hash & (NFSCLNT_EXPMAX-1);
+	cp = (char*)&clp;
+	len = sizeof(clp);
+	while (len--)
+		hash += *cp++;
+	return hash & EXPKEY_HASHMASK;
 }
 
 struct svc_clnthash {
@@ -97,7 +106,7 @@ exp_find_key(svc_client *clp, int fsid_t
 	if (!clp)
 		return NULL;
 
-	head = &clp->cl_export[expkey_hash(fsid_type, fsidv)];
+	head = &expkey_table[expkey_hash(clp, fsid_type, fsidv)];
 	list_for_each_entry(ek, head, ek_hash)
 		if (ek->ek_fsidtype == fsid_type &&
 		    fsidv[0] == ek->ek_fsid[0] &&
@@ -258,7 +267,7 @@ static int exp_fsid_hash(struct svc_clie
 
 	mk_fsid_v1(ek->ek_fsid, exp->ex_fsid);
 	
-	head = &clp->cl_export[expkey_hash(1, ek->ek_fsid)];
+	head = &expkey_table[expkey_hash(clp, 1, ek->ek_fsid)];
 	list_add(&ek->ek_hash, head);
 	return 0;
 }
@@ -280,7 +289,7 @@ static int exp_hash(struct svc_client *c
 	inode = exp->ex_dentry->d_inode;
 	mk_fsid_v0(ek->ek_fsid, inode->i_sb->s_dev, inode->i_ino);
 	
-	head = &clp->cl_export[expkey_hash(0, ek->ek_fsid)];
+	head = &expkey_table[expkey_hash(clp, 0, ek->ek_fsid)];
 	list_add(&ek->ek_hash, head);
 	return 0;
 }
@@ -772,8 +781,6 @@ exp_addclient(struct nfsctl_client *ncp)
 		if (!(clp = kmalloc(sizeof(*clp), GFP_KERNEL)))
 			goto out_unlock;
 		memset(clp, 0, sizeof(*clp));
-		for (i = 0; i < NFSCLNT_EXPMAX; i++)
-			INIT_LIST_HEAD(&clp->cl_export[i]);
 
 		INIT_LIST_HEAD(&clp->cl_list);
 
@@ -929,6 +936,9 @@ nfsd_export_init(void)
 	for (i = 0; i < EXPORT_HASHMAX ; i++)
 		INIT_LIST_HEAD(&export_table[i]);
 
+	for (i = 0; i < EXPKEY_HASHMAX; i++)
+		INIT_LIST_HEAD(&expkey_table[i]);
+
 }
 
 /*


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
