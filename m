From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 8 - Reorganise rpc program version management.
Date: Wed, 16 Oct 2002 16:03:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH1-0000Iz-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHC-0002ml-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 16 Oct 2002 16:03:17 +1000
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

An rpc service like NFSD knows about a number of 
versions (2,3,4) and needs to know the max and min valid
version numbers, and also the maximum xdr buffer size used 
by any version.

These max/mins are currently computed at compile time which means
we need to include all the xdr*.h headers into nfssvc.c just for
computing a couple of numbers.

With this patch, these max/mins are calculated at run time from
information in the svc_version structure which has been extended to
include per-version xdrsize.

Also the nfsd_version2, nfsd_version3, and nfsd_version4
structures are moved from nfssvc.c to their more correct home
of nfs*proc.c

Code gets neated, xdr*.h are no-longer included in
nfssvc.c, and the ugly ifdef can be removed fom xdr4.h




 ----------- Diffstat output ------------
 ./fs/lockd/svc.c             |    9 +++++----
 ./fs/nfsd/nfs3proc.c         |   10 +++++++++-
 ./fs/nfsd/nfs4proc.c         |   10 +++++++++-
 ./fs/nfsd/nfsproc.c          |   10 +++++++++-
 ./fs/nfsd/nfssvc.c           |   35 ++++-------------------------------
 ./include/linux/nfsd/nfsd.h  |   13 +++----------
 ./include/linux/nfsd/xdr4.h  |    2 --
 ./include/linux/sunrpc/svc.h |    3 ++-
 ./net/sunrpc/svc.c           |   14 +++++++++++++-
 9 files changed, 54 insertions(+), 52 deletions(-)

--- ./fs/nfsd/nfssvc.c	2002/10/16 04:45:35	1.1
+++ ./fs/nfsd/nfssvc.c	2002/10/16 04:45:56	1.2
@@ -31,9 +31,6 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
-#include <linux/nfsd/xdr3.h>
-#include <linux/nfsd/xdr4.h>
 #include <linux/lockd/bind.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
@@ -93,7 +90,7 @@ nfsd_svc(unsigned short port, int nrserv
 	if (!nfsd_serv) {
 		atomic_set(&nfsd_busy, 0);
 		error = -ENOMEM;
-		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE, NFSSVC_XDRSIZE);
+		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
 		if (nfsd_serv == NULL)
 			goto out;
 		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
@@ -258,7 +255,7 @@ nfsd(struct svc_rqst *rqstp)
 	MOD_DEC_USE_COUNT;
 }
 
-static int
+int
 nfsd_dispatch(struct svc_rqst *rqstp, u32 *statp)
 {
 	struct svc_procedure	*proc;
@@ -319,34 +316,12 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	return 1;
 }
 
-static struct svc_version	nfsd_version2 = {
-		.vs_vers	= 2,
-		.vs_nproc	= 18,
-		.vs_proc	= nfsd_procedures2,
-		.vs_dispatch	= nfsd_dispatch
-};
-#ifdef CONFIG_NFSD_V3
-static struct svc_version	nfsd_version3 = {
-		.vs_vers	= 3,
-		.vs_nproc	= 22,
-		.vs_proc	= nfsd_procedures3,
-		.vs_dispatch	= nfsd_dispatch
-};
-#endif
-#ifdef CONFIG_NFSD_V4
-static struct svc_version	nfsd_version4 = {
-		.vs_vers	= 4,
-		.vs_nproc	= 2,
-		.vs_proc	= nfsd_procedures4,
-		.vs_dispatch	= nfsd_dispatch
-};
-#endif
+extern struct svc_version nfsd_version2, nfsd_version3, nfsd_version4;
+
 static struct svc_version *	nfsd_version[] = {
 	[2] = &nfsd_version2,
 #if defined(CONFIG_NFSD_V3)
 	[3] = &nfsd_version3,
-#elif defined(CONFIG_NFSD_V4)
-	[3] = NULL,
 #endif
 #if defined(CONFIG_NFSD_V4)
 	[4] = &nfsd_version4,
@@ -356,8 +331,6 @@ static struct svc_version *	nfsd_version
 #define NFSD_NRVERS		(sizeof(nfsd_version)/sizeof(nfsd_version[0]))
 struct svc_program		nfsd_program = {
 	.pg_prog		= NFS_PROGRAM,		/* program number */
-	.pg_lovers		= 2,			// version
-	.pg_hivers		= NFSD_NRVERS-1,	// range
 	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
 	.pg_vers		= nfsd_version,		/* version table */
 	.pg_name		= "nfsd",		/* program name */
--- ./fs/nfsd/nfsproc.c	2002/10/16 04:45:35	1.1
+++ ./fs/nfsd/nfsproc.c	2002/10/16 04:45:56	1.2
@@ -539,7 +539,7 @@ struct nfsd_void { int dummy; };
 #define FH 8		/* filehandle */
 #define	AT 18		/* attributes */
 
-struct svc_procedure		nfsd_procedures2[18] = {
+static struct svc_procedure		nfsd_procedures2[18] = {
   PROC(null,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(getattr,	 fhandle,	attrstat,	fhandle,	RC_NOCACHE, ST+AT),
   PROC(setattr,  sattrargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
@@ -561,6 +561,14 @@ struct svc_procedure		nfsd_procedures2[1
 };
 
 
+struct svc_version	nfsd_version2 = {
+		.vs_vers	= 2,
+		.vs_nproc	= 18,
+		.vs_proc	= nfsd_procedures2,
+		.vs_dispatch	= nfsd_dispatch,
+		.vs_xdrsize	= NFS2_SVC_XDRSIZE,
+};
+
 /*
  * Map errnos to NFS errnos.
  */
--- ./fs/nfsd/nfs3proc.c	2002/10/16 04:45:35	1.1
+++ ./fs/nfsd/nfs3proc.c	2002/10/16 04:45:56	1.2
@@ -664,7 +664,7 @@ struct nfsd3_voidargs { int dummy; };
 #define pAT (1+AT)	/* post attributes - conditional */
 #define WC (7+pAT)	/* WCC attributes */
 
-struct svc_procedure		nfsd_procedures3[22] = {
+static struct svc_procedure		nfsd_procedures3[22] = {
   PROC(null,	 void,		void,		void,	  RC_NOCACHE, ST),
   PROC(getattr,	 fhandle,	attrstat,	fhandle,  RC_NOCACHE, ST+AT),
   PROC(setattr,  sattr,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
@@ -688,3 +688,11 @@ struct svc_procedure		nfsd_procedures3[2
   PROC(pathconf, fhandle,	pathconf,	void,     RC_NOCACHE, ST+pAT+6),
   PROC(commit,	 commit,	commit,		fhandle,  RC_NOCACHE, ST+WC+2),
 };
+
+struct svc_version	nfsd_version3 = {
+		.vs_vers	= 3,
+		.vs_nproc	= 22,
+		.vs_proc	= nfsd_procedures3,
+		.vs_dispatch	= nfsd_dispatch,
+		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
+};
--- ./fs/nfsd/nfs4proc.c	2002/10/16 04:45:35	1.1
+++ ./fs/nfsd/nfs4proc.c	2002/10/16 04:45:56	1.2
@@ -732,11 +732,19 @@ struct nfsd4_voidargs { int dummy; };
  * XID's liberally, so I've left it unimplemented until pynfs generates
  * better XID's.
  */
-struct svc_procedure		nfsd_procedures4[2] = {
+static struct svc_procedure		nfsd_procedures4[2] = {
   PROC(null,	 void,		void,		void,	  RC_NOCACHE, 1),
   PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE)
 };
 
+struct svc_version	nfsd_version4 = {
+		.vs_vers	= 4,
+		.vs_nproc	= 2,
+		.vs_proc	= nfsd_procedures4,
+		.vs_dispatch	= nfsd_dispatch,
+		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
+};
+
 /*
  * Local variables:
  *  c-basic-offset: 8
--- ./fs/lockd/svc.c	2002/10/16 04:45:35	1.1
+++ ./fs/lockd/svc.c	2002/10/16 04:45:57	1.2
@@ -36,7 +36,7 @@
 #include <linux/nfs.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
-#define LOCKD_BUFSIZE		(1024 + NLMSSVC_XDRSIZE)
+#define LOCKD_BUFSIZE		(1024 + NLMSVC_XDRSIZE)
 #define ALLOWED_SIGS		(sigmask(SIGKILL))
 
 extern struct svc_program	nlmsvc_program;
@@ -223,7 +223,7 @@ lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, 0, NLMSVC_XDRSIZE);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;
@@ -358,17 +358,20 @@ static struct svc_version	nlmsvc_version
 		.vs_vers	= 1,
 		.vs_nproc	= 17,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 static struct svc_version	nlmsvc_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
 static struct svc_version	nlmsvc_version4 = {
 		.vs_vers	= 4,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures4,
+		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif
 static struct svc_version *	nlmsvc_version[] = {
@@ -384,8 +387,6 @@ static struct svc_stat		nlmsvc_stats;
 #define NLM_NRVERS	(sizeof(nlmsvc_version)/sizeof(nlmsvc_version[0]))
 struct svc_program	nlmsvc_program = {
 	.pg_prog	= NLM_PROGRAM,		/* program number */
-	.pg_lovers	= 1,			/* version */
-	.pg_hivers	= NLM_NRVERS-1,		/* range */
 	.pg_nvers	= NLM_NRVERS,		/* number of entries in nlmsvc_version */
 	.pg_vers	= nlmsvc_version,	/* version table */
 	.pg_name	= "lockd",		/* service name */
--- ./include/linux/sunrpc/svc.h	2002/10/16 04:45:35	1.1
+++ ./include/linux/sunrpc/svc.h	2002/10/16 04:45:57	1.2
@@ -167,6 +167,7 @@ struct svc_version {
 	u32			vs_vers;	/* version number */
 	u32			vs_nproc;	/* number of procedures */
 	struct svc_procedure *	vs_proc;	/* per-procedure info */
+	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
 	/* Override dispatch function (e.g. when caching replies).
 	 * A return value of 0 means drop the request. 
@@ -199,7 +200,7 @@ typedef void		(*svc_thread_fn)(struct sv
 /*
  * Function prototypes.
  */
-struct svc_serv *  svc_create(struct svc_program *, unsigned int, unsigned int);
+struct svc_serv *  svc_create(struct svc_program *, unsigned int);
 int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
 void		   svc_exit_thread(struct svc_rqst *);
 void		   svc_destroy(struct svc_serv *);
--- ./include/linux/nfsd/xdr4.h	2002/10/16 04:45:35	1.1
+++ ./include/linux/nfsd/xdr4.h	2002/10/16 04:45:57	1.2
@@ -298,7 +298,6 @@ struct nfsd4_compoundres {
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
 
-#if CONFIG_NFSD_V3
 static inline void
 set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 {
@@ -309,7 +308,6 @@ set_change_info(struct nfsd4_change_info
 	cinfo->after_size = fhp->fh_post_size;
 	cinfo->after_ctime = fhp->fh_post_ctime;
 }
-#endif
 
 int nfs4svc_encode_voidres(struct svc_rqst *, u32 *, void *);
 int nfs4svc_decode_compoundargs(struct svc_rqst *, u32 *, struct nfsd4_compoundargs *);
--- ./include/linux/nfsd/nfsd.h	2002/10/16 04:45:35	1.1
+++ ./include/linux/nfsd/nfsd.h	2002/10/16 04:45:57	1.2
@@ -63,22 +63,15 @@ typedef int		(*encode_dent_fn)(struct re
 						int, loff_t, ino_t, unsigned int);
 typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
 
-/*
- * Procedure table for NFSv2
- */
-extern struct svc_procedure	nfsd_procedures2[];
-#ifdef CONFIG_NFSD_V3
-extern struct svc_procedure	nfsd_procedures3[];
-#endif /* CONFIG_NFSD_V3 */
-#ifdef CONFIG_NFSD_V4
-extern struct svc_procedure	nfsd_procedures4[];
-#endif /* CONFIG_NFSD_V4 */
 extern struct svc_program	nfsd_program;
+extern struct svc_version	nfsd_version2, nfsd_version3,
+				nfsd_version4;
 
 /*
  * Function prototypes.
  */
 int		nfsd_svc(unsigned short port, int nrservs);
+int		nfsd_dispatch(struct svc_rqst *rqstp, u32 *statp);
 
 /* nfsd/vfs.c */
 int		fh_lock_parent(struct svc_fh *, struct dentry *);
--- ./net/sunrpc/svc.c	2002/10/16 04:45:36	1.1
+++ ./net/sunrpc/svc.c	2002/10/16 04:45:57	1.2
@@ -27,9 +27,11 @@
  * Create an RPC service
  */
 struct svc_serv *
-svc_create(struct svc_program *prog, unsigned int bufsize, unsigned int xdrsize)
+svc_create(struct svc_program *prog, unsigned int bufsize)
 {
 	struct svc_serv	*serv;
+	int vers;
+	unsigned int xdrsize;
 
 	if (!(serv = (struct svc_serv *) kmalloc(sizeof(*serv), GFP_KERNEL)))
 		return NULL;
@@ -39,6 +41,16 @@ svc_create(struct svc_program *prog, uns
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
 	serv->sv_bufsz	   = bufsize? bufsize : 4096;
+	prog->pg_lovers = prog->pg_nvers-1;
+	xdrsize = 0;
+	for (vers=0; vers<prog->pg_nvers ; vers++)
+		if (prog->pg_vers[vers]) {
+			prog->pg_hivers = vers;
+			if (prog->pg_lovers > vers)
+				prog->pg_lovers = vers;
+			if (prog->pg_vers[vers]->vs_xdrsize > xdrsize)
+				xdrsize = prog->pg_vers[vers]->vs_xdrsize;
+		}
 	serv->sv_xdrsize   = xdrsize;
 	INIT_LIST_HEAD(&serv->sv_threads);
 	INIT_LIST_HEAD(&serv->sv_sockets);


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
