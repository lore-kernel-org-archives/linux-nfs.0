From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 16 - New structure initialisers for lockd.
Date: Thu, 12 Sep 2002 12:34:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023422.19518@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJoT-0001wS-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:34:37 -0700
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

Here begins a series of 16 patches for NFSd with the overall goal
of simplifying the exports table.
I want to change the exports table into a demand-filled cache:  when the kernel
gets a request that the export table doesn't make a clear statement about it,
it will ask user-space to provide a definitive answer, rather than the current
practice of denying anything not explicitly allowed.  The problem with the
current practice it that it depends on rmtab being maintained correctly,
and there are a number of situations where rmtab cannot be maintained reliably.

So: I want caches that can be filled on demand.  I want these caches to have
a nice regular structure so that I can have a lot of common code and a uniform
user/kernel interface for cache management.  To do this, I first simplify 
the structure of the current export table.

The complexity is mostly in the export table, rather than the client table.
Entries in the export table potentially have two keys and so each is on two
hash chains.  Also, there is a separate hash table for  each client.

By the end there will be three hash table:

 +  map IP address to CLIENT structure
 +  map CLIENT+DENTRY+VFSMOUNT to export structure
 +  map CLIENT + filehandlefragement to export structure

plus fewer interactions with lockd and other general clean up.

This first patch doesn't actually touch export tables at all.  But I saw the need
for it while working on the code, so here it is....

NeilBrown


### Comments for ChangeSet

Just the new structure initialisers.

 ----------- Diffstat output ------------
 ./fs/lockd/mon.c      |   65 ++++++++++++++++++++++++--------------------------
 ./fs/lockd/svc.c      |   40 ++++++++++++++----------------
 ./fs/lockd/svc4proc.c |   16 +++++-------
 ./fs/lockd/svcproc.c  |   16 +++++-------
 ./fs/lockd/xdr.c      |   30 ++++++++++-------------
 ./fs/lockd/xdr4.c     |    6 ++--
 6 files changed, 82 insertions(+), 91 deletions(-)

--- ./fs/lockd/xdr4.c	2002/09/11 01:03:26	1.1
+++ ./fs/lockd/xdr4.c	2002/09/11 01:07:38	1.2
@@ -608,7 +608,7 @@ static struct rpc_procinfo	nlm4_procedur
 };
 
 struct rpc_version	nlm_version4 = {
-	number:		4,
-	nrprocs:	24,
-	procs:		nlm4_procedures,
+	.number		= 4,
+	.nrprocs	= 24,
+	.procs		= nlm4_procedures,
 };
--- ./fs/lockd/svc.c	2002/09/11 01:03:26	1.1
+++ ./fs/lockd/svc.c	2002/09/11 01:07:38	1.2
@@ -369,29 +369,27 @@ __setup("lockd.tcpport=", tcpport_set);
  * Define NLM program and procedures
  */
 static struct svc_version	nlmsvc_version1 = {
-		vs_vers:	1,
-		vs_nproc:	17,
-		vs_proc:	nlmsvc_procedures,
+		.vs_vers	= 1,
+		.vs_nproc	= 17,
+		.vs_proc	= nlmsvc_procedures,
 };
 static struct svc_version	nlmsvc_version3 = {
-		vs_vers:	3,
-		vs_nproc:	24,
-		vs_proc:	nlmsvc_procedures,
+		.vs_vers	= 3,
+		.vs_nproc	= 24,
+		.vs_proc	= nlmsvc_procedures,
 };
 #ifdef CONFIG_LOCKD_V4
 static struct svc_version	nlmsvc_version4 = {
-		vs_vers:	4,
-		vs_nproc:	24,
-		vs_proc:	nlmsvc_procedures4,
+		.vs_vers	= 4,
+		.vs_nproc	= 24,
+		.vs_proc	= nlmsvc_procedures4,
 };
 #endif
 static struct svc_version *	nlmsvc_version[] = {
-	NULL,
-	&nlmsvc_version1,
-	NULL,
-	&nlmsvc_version3,
+	[1] = &nlmsvc_version1,
+	[3] = &nlmsvc_version3,
 #ifdef CONFIG_LOCKD_V4
-	&nlmsvc_version4,
+	[4] = &nlmsvc_version4,
 #endif
 };
 
@@ -399,11 +397,11 @@ static struct svc_stat		nlmsvc_stats;
 
 #define NLM_NRVERS	(sizeof(nlmsvc_version)/sizeof(nlmsvc_version[0]))
 struct svc_program	nlmsvc_program = {
-	pg_prog:	NLM_PROGRAM,		/* program number */
-	pg_lovers:	1,			// version
-	pg_hivers:	NLM_NRVERS-1,		// range
-	pg_nvers:	NLM_NRVERS,		/* number of entries in nlmsvc_version */
-	pg_vers:	nlmsvc_version,		/* version table */
-	pg_name:	"lockd",		/* service name */
-	pg_stats:	&nlmsvc_stats,		/* stats table */
+	.pg_prog	= NLM_PROGRAM,		/* program number */
+	.pg_lovers	= 1,			/* version */
+	.pg_hivers	= NLM_NRVERS-1,		/* range */
+	.pg_nvers	= NLM_NRVERS,		/* number of entries in nlmsvc_version */
+	.pg_vers	= nlmsvc_version,	/* version table */
+	.pg_name	= "lockd",		/* service name */
+	.pg_stats	= &nlmsvc_stats,	/* stats table */
 };
--- ./fs/lockd/mon.c	2002/09/11 01:03:26	1.1
+++ ./fs/lockd/mon.c	2002/09/11 01:07:38	1.2
@@ -206,61 +206,60 @@ xdr_decode_stat(struct rpc_rqst *rqstp, 
 
 static struct rpc_procinfo	nsm_procedures[] = {
         {
-		p_procname:	"sm_null",
-		p_encode:	(kxdrproc_t) xdr_error,
-		p_decode:	(kxdrproc_t) xdr_error,
+		.p_procname	= "sm_null",
+		.p_encode	= (kxdrproc_t) xdr_error,
+		.p_decode	= (kxdrproc_t) xdr_error,
 	},
         {
-		p_procname:	"sm_stat",
-		p_encode:	(kxdrproc_t) xdr_error,
-		p_decode:	(kxdrproc_t) xdr_error,
+		.p_procname	= "sm_stat",
+		.p_encode	= (kxdrproc_t) xdr_error,
+		.p_decode	= (kxdrproc_t) xdr_error,
 	},
         {
-		p_procname:	"sm_mon",
-		p_encode:	(kxdrproc_t) xdr_encode_mon,
-		p_decode:	(kxdrproc_t) xdr_decode_stat_res,
-		p_bufsiz:	MAX(SM_mon_sz, SM_monres_sz) << 2,
+		.p_procname	= "sm_mon",
+		.p_encode	= (kxdrproc_t) xdr_encode_mon,
+		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
+		.p_bufsiz	= MAX(SM_mon_sz, SM_monres_sz) << 2,
 	},
         {
-		p_procname:	"sm_unmon",
-		p_encode:	(kxdrproc_t) xdr_encode_mon,
-		p_decode:	(kxdrproc_t) xdr_decode_stat,
-		p_bufsiz:	MAX(SM_mon_id_sz, SM_unmonres_sz) << 2,
+		.p_procname	= "sm_unmon",
+		.p_encode	= (kxdrproc_t) xdr_encode_mon,
+		.p_decode	= (kxdrproc_t) xdr_decode_stat,
+		.p_bufsiz	= MAX(SM_mon_id_sz, SM_unmonres_sz) << 2,
 	},
         {
-		p_procname:	"sm_unmon_all",
-		p_encode:	(kxdrproc_t) xdr_error,
-		p_decode:	(kxdrproc_t) xdr_error,
+		.p_procname	= "sm_unmon_all",
+		.p_encode	= (kxdrproc_t) xdr_error,
+		.p_decode	= (kxdrproc_t) xdr_error,
 	},
         {
-		p_procname:	"sm_simu_crash",
-		p_encode:	(kxdrproc_t) xdr_error,
-		p_decode:	(kxdrproc_t) xdr_error, 0, 0
+		.p_procname	= "sm_simu_crash",
+		.p_encode	= (kxdrproc_t) xdr_error,
+		.p_decode	= (kxdrproc_t) xdr_error,
 	},
         {
-		p_procname:	"sm_notify",
-		p_encode:	(kxdrproc_t) xdr_error,
-		p_decode:	(kxdrproc_t) xdr_error,
+		.p_procname	= "sm_notify",
+		.p_encode	= (kxdrproc_t) xdr_error,
+		.p_decode	= (kxdrproc_t) xdr_error,
 	},
 };
 
 static struct rpc_version	nsm_version1 = {
-		number:		1, 
-		nrprocs:	sizeof(nsm_procedures)/sizeof(nsm_procedures[0]),
-		procs:		nsm_procedures
+		.number		= 1, 
+		.nrprocs	= sizeof(nsm_procedures)/sizeof(nsm_procedures[0]),
+		.procs		= nsm_procedures
 };
 
 static struct rpc_version *	nsm_version[] = {
-	NULL,
-	&nsm_version1,
+	[1] = &nsm_version1,
 };
 
 static struct rpc_stat		nsm_stats;
 
 struct rpc_program		nsm_program = {
-		name:		"statd",
-		number:		SM_PROGRAM,
-		nrvers:		sizeof(nsm_version)/sizeof(nsm_version[0]),
-		version:	nsm_version,
-		stats:		&nsm_stats
+		.name		= "statd",
+		.number		= SM_PROGRAM,
+		.nrvers		= sizeof(nsm_version)/sizeof(nsm_version[0]),
+		.version	= nsm_version,
+		.stats		= &nsm_stats
 };
--- ./fs/lockd/svc4proc.c	2002/09/11 01:03:26	1.1
+++ ./fs/lockd/svc4proc.c	2002/09/11 01:07:38	1.2
@@ -527,15 +527,13 @@ nlm4svc_callback_exit(struct rpc_task *t
 struct nlm_void			{ int dummy; };
 
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
- { (svc_procfunc) nlm4svc_proc_##name,	\
-   (kxdrproc_t) nlm4svc_decode_##xargt,	\
-   (kxdrproc_t) nlm4svc_encode_##xrest,	\
-   NULL,				\
-   sizeof(struct nlm_##argt),		\
-   sizeof(struct nlm_##rest),		\
-   0,					\
-   0,					\
-   respsize,				\
+ { .pc_func	= (svc_procfunc) nlm4svc_proc_##name,	\
+   .pc_decode	= (kxdrproc_t) nlm4svc_decode_##xargt,	\
+   .pc_encode	= (kxdrproc_t) nlm4svc_encode_##xrest,	\
+   .pc_release	= NULL,					\
+   .pc_argsize	= sizeof(struct nlm_##argt),		\
+   .pc_ressize	= sizeof(struct nlm_##rest),		\
+   .pc_xdrressize = respsize,				\
  }
 #define	Ck	(1+8)	/* cookie */
 #define	No	(1+1024/4)	/* netobj */
--- ./fs/lockd/svcproc.c	2002/09/11 01:03:26	1.1
+++ ./fs/lockd/svcproc.c	2002/09/11 01:07:38	1.2
@@ -555,15 +555,13 @@ nlmsvc_callback_exit(struct rpc_task *ta
 struct nlm_void			{ int dummy; };
 
 #define PROC(name, xargt, xrest, argt, rest, respsize)	\
- { (svc_procfunc) nlmsvc_proc_##name,	\
-   (kxdrproc_t) nlmsvc_decode_##xargt,	\
-   (kxdrproc_t) nlmsvc_encode_##xrest,	\
-   NULL,				\
-   sizeof(struct nlm_##argt),		\
-   sizeof(struct nlm_##rest),		\
-   0,					\
-   0,					\
-   respsize,				\
+ { .pc_func	= (svc_procfunc) nlmsvc_proc_##name,	\
+   .pc_decode	= (kxdrproc_t) nlmsvc_decode_##xargt,	\
+   .pc_encode	= (kxdrproc_t) nlmsvc_encode_##xrest,	\
+   .pc_release	= NULL,					\
+   .pc_argsize	= sizeof(struct nlm_##argt),		\
+   .pc_ressize	= sizeof(struct nlm_##rest),		\
+   .pc_xdrressize = respsize,				\
  }
 
 #define	Ck	(1+8)	/* cookie */
--- ./fs/lockd/xdr.c	2002/09/11 01:03:26	1.1
+++ ./fs/lockd/xdr.c	2002/09/11 01:07:38	1.2
@@ -602,15 +602,15 @@ static struct rpc_procinfo	nlm_procedure
 };
 
 static struct rpc_version	nlm_version1 = {
-		number:		1,
-		nrprocs:	16,
-		procs:		nlm_procedures,
+		.number		= 1,
+		.nrprocs	= 16,
+		.procs		= nlm_procedures,
 };
 
 static struct rpc_version	nlm_version3 = {
-		number:		3,
-		nrprocs:	24,
-		procs:		nlm_procedures,
+		.number		= 3,
+		.nrprocs	= 24,
+		.procs		= nlm_procedures,
 };
 
 #ifdef 	CONFIG_LOCKD_V4
@@ -618,23 +618,21 @@ extern struct rpc_version nlm_version4;
 #endif
 
 static struct rpc_version *	nlm_versions[] = {
-	NULL,
-	&nlm_version1,
-	NULL,
-	&nlm_version3,
+	[1] = &nlm_version1,
+	[3] = &nlm_version3,
 #ifdef 	CONFIG_LOCKD_V4
-	&nlm_version4,
+	[4] = &nlm_version4,
 #endif
 };
 
 static struct rpc_stat		nlm_stats;
 
 struct rpc_program		nlm_program = {
-		name:		"lockd",
-		number:		NLM_PROGRAM,
-		nrvers:		sizeof(nlm_versions) / sizeof(nlm_versions[0]),
-		version:	nlm_versions,
-		stats:		&nlm_stats,
+		.name		= "lockd",
+		.number		= NLM_PROGRAM,
+		.nrvers		= sizeof(nlm_versions) / sizeof(nlm_versions[0]),
+		.version	= nlm_versions,
+		.stats		= &nlm_stats,
 };
 
 #ifdef LOCKD_DEBUG


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
