From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 016 of 28] nfsd4: make needlessly global code static
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006iV-3B@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3W-0005y0-4x
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:22 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3T-0002S7-Oi
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:21 -0700
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


This patch contains the following possible cleanups:
- make needlessly global code static

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4acl.c          |    4 +--
 ./fs/nfsd/nfs4callback.c     |    7 ++---
 ./fs/nfsd/nfs4idmap.c        |   12 ++++-----
 ./fs/nfsd/nfs4state.c        |   57 ++++++++++++++++++++++---------------------
 ./fs/nfsd/nfs4xdr.c          |    4 +--
 ./include/linux/nfsd/state.h |    8 ------
 6 files changed, 43 insertions(+), 49 deletions(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2005-05-31 14:21:03.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2005-05-31 14:21:03.000000000 +1000
@@ -125,7 +125,7 @@ static short ace2type(struct nfs4_ace *)
 static int _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *, unsigned int);
 static struct posix_acl *_nfsv4_to_posix_one(struct nfs4_acl *, unsigned int);
 int nfs4_acl_add_ace(struct nfs4_acl *, u32, u32, u32, int, uid_t);
-int nfs4_acl_split(struct nfs4_acl *, struct nfs4_acl *);
+static int nfs4_acl_split(struct nfs4_acl *, struct nfs4_acl *);
 
 struct nfs4_acl *
 nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl, struct posix_acl *dpacl,
@@ -775,7 +775,7 @@ out_err:
 	return pacl;
 }
 
-int
+static int
 nfs4_acl_split(struct nfs4_acl *acl, struct nfs4_acl *dacl)
 {
 	struct list_head *h, *n;

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-05-31 14:20:58.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2005-05-31 14:21:03.000000000 +1000
@@ -54,7 +54,6 @@
 
 /* declarations */
 static void nfs4_cb_null(struct rpc_task *task);
-extern spinlock_t recall_lock;
 
 /* Index of predefined Linux callback client operations */
 
@@ -329,12 +328,12 @@ out:
         .p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,  \
 }
 
-struct rpc_procinfo     nfs4_cb_procedures[] = {
+static struct rpc_procinfo     nfs4_cb_procedures[] = {
     PROC(CB_NULL,      NULL,     enc_cb_null,     dec_cb_null),
     PROC(CB_RECALL,    COMPOUND,   enc_cb_recall,      dec_cb_recall),
 };
 
-struct rpc_version              nfs_cb_version4 = {
+static struct rpc_version       nfs_cb_version4 = {
         .number                 = 1,
         .nrprocs                = sizeof(nfs4_cb_procedures)/sizeof(nfs4_cb_procedures[0]),
         .procs                  = nfs4_cb_procedures
@@ -348,7 +347,7 @@ static struct rpc_version *	nfs_cb_versi
 /*
  * Use the SETCLIENTID credential
  */
-struct rpc_cred *
+static struct rpc_cred *
 nfsd4_lookupcred(struct nfs4_client *clp, int taskflags)
 {
         struct auth_cred acred;

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2005-05-31 14:21:03.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2005-05-31 14:21:03.000000000 +1000
@@ -104,7 +104,7 @@ ent_update(struct ent *new, struct ent *
 	ent_init(new, itm);
 }
 
-void
+static void
 ent_put(struct cache_head *ch, struct cache_detail *cd)
 {
 	if (cache_put(ch, cd)) {
@@ -186,7 +186,7 @@ warn_no_idmapd(struct cache_detail *deta
 static int         idtoname_parse(struct cache_detail *, char *, int);
 static struct ent *idtoname_lookup(struct ent *, int);
 
-struct cache_detail idtoname_cache = {
+static struct cache_detail idtoname_cache = {
 	.hash_size	= ENT_HASHMAX,
 	.hash_table	= idtoname_table,
 	.name		= "nfs4.idtoname",
@@ -277,7 +277,7 @@ nametoid_hash(struct ent *ent)
 	return hash_str(ent->name, ENT_HASHBITS);
 }
 
-void
+static void
 nametoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
     int *blen)
 {
@@ -317,9 +317,9 @@ nametoid_show(struct seq_file *m, struct
 }
 
 static struct ent *nametoid_lookup(struct ent *, int);
-int                nametoid_parse(struct cache_detail *, char *, int);
+static int         nametoid_parse(struct cache_detail *, char *, int);
 
-struct cache_detail nametoid_cache = {
+static struct cache_detail nametoid_cache = {
 	.hash_size	= ENT_HASHMAX,
 	.hash_table	= nametoid_table,
 	.name		= "nfs4.nametoid",
@@ -330,7 +330,7 @@ struct cache_detail nametoid_cache = {
 	.warn_no_listener = warn_no_idmapd,
 };
 
-int
+static int
 nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
 {
 	struct ent ent, *res;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:02.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:03.000000000 +1000
@@ -54,18 +54,21 @@
 /* Globals */
 static time_t lease_time = 90;     /* default lease time */
 static time_t user_lease_time = 90;
-time_t boot_time;
+static time_t boot_time;
 static int in_grace = 1;
 static u32 current_clientid = 1;
 static u32 current_ownerid = 1;
 static u32 current_fileid = 1;
 static u32 current_delegid = 1;
 static u32 nfs4_init;
-stateid_t zerostateid;             /* bits all 0 */
-stateid_t onestateid;              /* bits all 1 */
+static stateid_t zerostateid;             /* bits all 0 */
+static stateid_t onestateid;              /* bits all 1 */
+
+#define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
+#define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
 /* forward declarations */
-struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
+static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static void release_stateid_lockowners(struct nfs4_stateid *open_stp);
 
@@ -77,10 +80,10 @@ static void release_stateid_lockowners(s
  */
 static DECLARE_MUTEX(client_sema);
 
-kmem_cache_t *stateowner_slab = NULL;
-kmem_cache_t *file_slab = NULL;
-kmem_cache_t *stateid_slab = NULL;
-kmem_cache_t *deleg_slab = NULL;
+static kmem_cache_t *stateowner_slab = NULL;
+static kmem_cache_t *file_slab = NULL;
+static kmem_cache_t *stateid_slab = NULL;
+static kmem_cache_t *deleg_slab = NULL;
 
 void
 nfs4_lock_state(void)
@@ -116,7 +119,7 @@ static void release_stateid(struct nfs4_
  */
 
 /* recall_lock protects the del_recall_lru */
-spinlock_t recall_lock = SPIN_LOCK_UNLOCKED;
+static spinlock_t recall_lock = SPIN_LOCK_UNLOCKED;
 static struct list_head del_recall_lru;
 
 static void
@@ -456,7 +459,7 @@ check_name(struct xdr_netobj name) {
 	return 1;
 }
 
-void
+static void
 add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
 {
 	unsigned int idhashval;
@@ -468,7 +471,7 @@ add_to_unconfirmed(struct nfs4_client *c
 	clp->cl_time = get_seconds();
 }
 
-void
+static void
 move_to_confirmed(struct nfs4_client *clp)
 {
 	unsigned int idhashval = clientid_hashval(clp->cl_clientid.cl_id);
@@ -567,7 +570,7 @@ parse_octet(unsigned int *lenp, char **a
 }
 
 /* parse and set the setclientid ipv4 callback address */
-int
+static int
 parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigned short *cbportp)
 {
 	int temp = 0;
@@ -603,7 +606,7 @@ parse_ipv4(unsigned int addr_len, char *
 	return 1;
 }
 
-void
+static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
 	struct nfs4_callback *cb = &clp->cl_callback;
@@ -1186,7 +1189,7 @@ release_stateid(struct nfs4_stateid *stp
 	stp = NULL;
 }
 
-void
+static void
 move_to_close_lru(struct nfs4_stateowner *sop)
 {
 	dprintk("NFSD: move_to_close_lru nfs4_stateowner %p\n", sop);
@@ -1196,7 +1199,7 @@ move_to_close_lru(struct nfs4_stateowner
 	sop->so_time = get_seconds();
 }
 
-void
+static void
 release_state_owner(struct nfs4_stateid *stp, int flag)
 {
 	struct nfs4_stateowner *sop = stp->st_stateowner;
@@ -1250,7 +1253,7 @@ find_file(struct inode *ino)
 #define TEST_ACCESS(x) ((x > 0 || x < 4)?1:0)
 #define TEST_DENY(x) ((x >= 0 || x < 5)?1:0)
 
-void
+static void
 set_access(unsigned int *access, unsigned long bmap) {
 	int i;
 
@@ -1261,7 +1264,7 @@ set_access(unsigned int *access, unsigne
 	}
 }
 
-void
+static void
 set_deny(unsigned int *deny, unsigned long bmap) {
 	int i;
 
@@ -1287,7 +1290,7 @@ test_share(struct nfs4_stateid *stp, str
  * Called to check deny when READ with all zero stateid or
  * WRITE with all zero or all one stateid
  */
-int
+static int
 nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
 	struct inode *ino = current_fh->fh_dentry->d_inode;
@@ -1442,7 +1445,7 @@ int nfsd_change_deleg_cb(struct file_loc
 		return -EAGAIN;
 }
 
-struct lock_manager_operations nfsd_lease_mng_ops = {
+static struct lock_manager_operations nfsd_lease_mng_ops = {
 	.fl_break = nfsd_break_deleg_cb,
 	.fl_release_private = nfsd_release_deleg_cb,
 	.fl_copy_lock = nfsd_copy_lock_deleg_cb,
@@ -1915,7 +1918,7 @@ end_grace(void)
 	in_grace = 0;
 }
 
-time_t
+static time_t
 nfs4_laundromat(void)
 {
 	struct nfs4_client *clp;
@@ -1996,7 +1999,7 @@ laundromat_main(void *not_used)
 /* search ownerid_hashtbl[] and close_lru for stateid owner
  * (stateid->si_stateownerid)
  */
-struct nfs4_stateowner *
+static struct nfs4_stateowner *
 find_openstateowner_id(u32 st_id, int flags) {
 	struct nfs4_stateowner *local = NULL;
 
@@ -2170,7 +2173,7 @@ out:
 /* 
  * Checks for sequence id mutating operations. 
  */
-int
+static int
 nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp, clientid_t *lockclid)
 {
 	int status;
@@ -2486,7 +2489,7 @@ static struct list_head lock_ownerid_has
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
 static struct list_head lockstateid_hashtbl[STATEID_HASH_SIZE];
 
-struct nfs4_stateid *
+static struct nfs4_stateid *
 find_stateid(stateid_t *stid, int flags)
 {
 	struct nfs4_stateid *local = NULL;
@@ -2550,7 +2553,7 @@ nfs4_transform_lock_offset(struct file_l
 		lock->fl_end = OFFSET_MAX;
 }
 
-int
+static int
 nfs4_verify_lock_stateowner(struct nfs4_stateowner *sop, unsigned int hashval)
 {
 	struct nfs4_stateowner *local = NULL;
@@ -2660,7 +2663,7 @@ alloc_init_lock_stateowner(unsigned int 
 	return sop;
 }
 
-struct nfs4_stateid *
+static struct nfs4_stateid *
 alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struct nfs4_stateid *open_stp)
 {
 	struct nfs4_stateid *stp;
@@ -2691,7 +2694,7 @@ out:
 	return stp;
 }
 
-int
+static int
 check_lock_length(u64 offset, u64 length)
 {
 	return ((length == 0)  || ((length != ~(u64)0) &&
@@ -3149,7 +3152,7 @@ nfs4_release_reclaim(void)
 
 /*
  * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
-struct nfs4_client_reclaim *
+static struct nfs4_client_reclaim *
 nfs4_find_reclaim_client(clientid_t *clid)
 {
 	unsigned int strhashval;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2005-05-31 14:21:03.000000000 +1000
@@ -136,7 +136,7 @@ xdr_error:					\
 	}					\
 } while (0)
 
-u32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
+static u32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
 {
 	/* We want more bytes than seem to be available.
 	 * Maybe we need a new page, maybe we have just run out
@@ -190,7 +190,7 @@ defer_free(struct nfsd4_compoundargs *ar
 	return 0;
 }
 
-char *savemem(struct nfsd4_compoundargs *argp, u32 *p, int nbytes)
+static char *savemem(struct nfsd4_compoundargs *argp, u32 *p, int nbytes)
 {
 	void *new = NULL;
 	if (p == argp->tmp) {

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-05-31 14:21:02.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-05-31 14:21:03.000000000 +1000
@@ -61,11 +61,6 @@ typedef struct {
 #define si_stateownerid   si_opaque.so_stateownerid
 #define si_fileid         si_opaque.so_fileid
 
-extern stateid_t zerostateid;
-extern stateid_t onestateid;
-
-#define ZERO_STATEID(stateid)       (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
-#define ONE_STATEID(stateid)        (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
 struct nfs4_cb_recall {
 	u32			cbr_ident;
@@ -271,12 +266,9 @@ struct nfs4_stateid {
 	((err) != nfserr_stale_stateid) &&      \
 	((err) != nfserr_bad_stateid))
 
-extern time_t nfs4_laundromat(void);
 extern int nfsd4_renew(clientid_t *clid);
 extern int nfs4_preprocess_stateid_op(struct svc_fh *current_fh, 
 		stateid_t *stateid, int flags, struct file **filp);
-extern int nfs4_share_conflict(struct svc_fh *current_fh, 
-		unsigned int deny_type);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
