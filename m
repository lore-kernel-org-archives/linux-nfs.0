From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 11 of 12] global/static cleanups for nfsd
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006Vq-JM@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLis-0006vH-H1
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLiq-0004Fr-OP
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The patch below contains the following cleanups:
- make some needlessly global code static

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/export.c |   22 +++++++++++-----------
 ./fs/nfsd/lockd.c  |    2 +-
 ./fs/nfsd/nfsfh.c  |   11 ++++++-----
 ./fs/nfsd/nfssvc.c |    2 +-
 ./fs/nfsd/vfs.c    |    8 ++++----
 5 files changed, 23 insertions(+), 22 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2005-02-08 10:48:31.000000000 +1100
+++ ./fs/nfsd/export.c	2005-02-08 10:48:31.000000000 +1100
@@ -79,9 +79,9 @@ void expkey_put(struct cache_head *item,
 	}
 }
 
-void expkey_request(struct cache_detail *cd,
-		    struct cache_head *h,
-		    char **bpp, int *blen)
+static void expkey_request(struct cache_detail *cd,
+			   struct cache_head *h,
+			   char **bpp, int *blen)
 {
 	/* client fsidtype \xfsid */
 	struct svc_expkey *ek = container_of(h, struct svc_expkey, h);
@@ -95,7 +95,7 @@ void expkey_request(struct cache_detail 
 }
 
 static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *, int);
-int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
+static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client fsidtype fsid [path] */
 	char *buf;
@@ -284,9 +284,9 @@ void svc_export_put(struct cache_head *i
 	}
 }
 
-void svc_export_request(struct cache_detail *cd,
-			struct cache_head *h,
-			char **bpp, int *blen)
+static void svc_export_request(struct cache_detail *cd,
+			       struct cache_head *h,
+			       char **bpp, int *blen)
 {
 	/*  client path */
 	struct svc_export *exp = container_of(h, struct svc_export, h);
@@ -340,7 +340,7 @@ static int check_export(struct inode *in
 
 }
 
-int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
+static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client path expiry [flags anonuid anongid fsid] */
 	char *buf;
@@ -510,8 +510,8 @@ exp_find_key(svc_client *clp, int fsid_t
 	return ek;
 }
 
-int exp_set_key(svc_client *clp, int fsid_type, u32 *fsidv, 
-		struct svc_export *exp)
+static int exp_set_key(svc_client *clp, int fsid_type, u32 *fsidv, 
+		       struct svc_export *exp)
 {
 	struct svc_expkey key, *ek;
 
@@ -999,7 +999,7 @@ static void e_stop(struct seq_file *m, v
 	exp_readunlock();
 }
 
-struct flags {
+static struct flags {
 	int flag;
 	char *name[2];
 } expflags[] = {

diff ./fs/nfsd/lockd.c~current~ ./fs/nfsd/lockd.c
--- ./fs/nfsd/lockd.c~current~	2005-02-08 10:48:31.000000000 +1100
+++ ./fs/nfsd/lockd.c	2005-02-08 10:48:31.000000000 +1100
@@ -60,7 +60,7 @@ nlm_fclose(struct file *filp)
 	fput(filp);
 }
 
-struct nlmsvc_binding		nfsd_nlm_ops = {
+static struct nlmsvc_binding	nfsd_nlm_ops = {
 	.fopen		= nlm_fopen,		/* open file for locking */
 	.fclose		= nlm_fclose,		/* close file */
 };

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2005-02-08 10:48:31.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2005-02-08 10:48:31.000000000 +1100
@@ -41,7 +41,7 @@ extern struct export_operations export_o
  * if not, require that we can walk up to exp->ex_dentry
  * doing some checks on the 'x' bits
  */
-int nfsd_acceptable(void *expv, struct dentry *dentry)
+static int nfsd_acceptable(void *expv, struct dentry *dentry)
 {
 	struct svc_export *exp = expv;
 	int rv;
@@ -280,8 +280,8 @@ out:
  * an inode.  In this case a call to fh_update should be made
  * before the fh goes out on the wire ...
  */
-inline int _fh_update(struct dentry *dentry, struct svc_export *exp,
-		      __u32 *datap, int *maxsize)
+static inline int _fh_update(struct dentry *dentry, struct svc_export *exp,
+			     __u32 *datap, int *maxsize)
 {
 	struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
 	
@@ -297,8 +297,9 @@ inline int _fh_update(struct dentry *den
 /*
  * for composing old style file handles
  */
-inline void _fh_update_old(struct dentry *dentry, struct svc_export *exp,
-			   struct knfsd_fh *fh)
+static inline void _fh_update_old(struct dentry *dentry,
+				  struct svc_export *exp,
+				  struct knfsd_fh *fh)
 {
 	fh->ofh_ino = ino_t_to_u32(dentry->d_inode->i_ino);
 	fh->ofh_generation = dentry->d_inode->i_generation;

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2005-02-07 15:04:35.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2005-02-08 10:48:31.000000000 +1100
@@ -63,7 +63,7 @@ struct nfsd_list {
 	struct list_head 	list;
 	struct task_struct	*task;
 };
-struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
+static struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
 
 /*
  * Maximum number of nfsd processes

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-02-07 15:05:19.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-02-08 10:48:31.000000000 +1100
@@ -708,8 +708,8 @@ nfsd_close(struct file *filp)
  * As this calls fsync (not fdatasync) there is no need for a write_inode
  * after it.
  */
-inline void nfsd_dosync(struct file *filp, struct dentry *dp, 
-			struct file_operations *fop)
+static inline void nfsd_dosync(struct file *filp, struct dentry *dp, 
+			       struct file_operations *fop)
 {
 	struct inode *inode = dp->d_inode;
 	int (*fsync) (struct file *, struct dentry *, int);
@@ -721,7 +721,7 @@ inline void nfsd_dosync(struct file *fil
 }
 	
 
-void
+static void
 nfsd_sync(struct file *filp)
 {
 	struct inode *inode = filp->f_dentry->d_inode;
@@ -731,7 +731,7 @@ nfsd_sync(struct file *filp)
 	up(&inode->i_sem);
 }
 
-void
+static void
 nfsd_sync_dir(struct dentry *dp)
 {
 	nfsd_dosync(NULL, dp, dp->d_inode->i_fop);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
