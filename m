Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:45586 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758114AbdELQSp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:45 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 31/33] sunrpc: mark all struct svc_procinfo instances as const
Date: Fri, 12 May 2017 18:16:59 +0200
Message-Id: <20170512161701.22468-32-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

struct svc_procinfo contains function pointers, and marking it as
constant avoids it being able to be used as an attach vector for
code injections.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/svc4proc.c         | 2 +-
 fs/lockd/svcproc.c          | 2 +-
 fs/nfs/callback_xdr.c       | 2 +-
 fs/nfsd/nfs2acl.c           | 2 +-
 fs/nfsd/nfs3acl.c           | 2 +-
 fs/nfsd/nfs3proc.c          | 2 +-
 fs/nfsd/nfs4proc.c          | 2 +-
 fs/nfsd/nfsproc.c           | 2 +-
 fs/nfsd/nfssvc.c            | 4 ++--
 include/linux/lockd/lockd.h | 4 ++--
 include/linux/sunrpc/svc.h  | 4 ++--
 net/sunrpc/svc.c            | 2 +-
 12 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index fed016155791..82925f17ec45 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -507,7 +507,7 @@ struct nlm_void			{ int dummy; };
 #define	No	(1+1024/4)				/* netobj */
 #define	St	1					/* status */
 #define	Rg	4					/* range (offset + length) */
-struct svc_procedure		nlmsvc_procedures4[] = {
+const struct svc_procedure nlmsvc_procedures4[] = {
   PROC(null,		void,		void,		void,	void, 1),
   PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
   PROC(lock,		lockargs,	res,		args,	res, Ck+St),
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 14648b051eba..07915162581d 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -551,7 +551,7 @@ struct nlm_void			{ int dummy; };
 #define	No	(1+1024/4)			/* Net Obj */
 #define	Rg	2				/* range - offset + size */
 
-struct svc_procedure		nlmsvc_procedures[] = {
+const struct svc_procedure nlmsvc_procedures[] = {
   PROC(null,		void,		void,		void,	void, 1),
   PROC(test,		testargs,	testres,	args,	res, Ck+St+2+No+Rg),
   PROC(lock,		lockargs,	res,		args,	res, Ck+St),
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index ecd46b8c0985..ae249f27297f 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -995,7 +995,7 @@ static struct callback_op callback_ops[] = {
 /*
  * Define NFS4 callback procedures
  */
-static struct svc_procedure nfs4_callback_procedures1[] = {
+static const struct svc_procedure nfs4_callback_procedures1[] = {
 	[CB_NULL] = {
 		.pc_func = nfs4_callback_null,
 		.pc_decode = nfs4_decode_void,
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 026edfe73fd5..c3f6b8a6b659 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -370,7 +370,7 @@ struct nfsd3_voidargs { int dummy; };
 #define pAT (1+AT)	/* post attributes - conditional */
 #define ACL (1+NFS_ACL_MAX_ENTRIES*3)  /* Access Control List */
 
-static struct svc_procedure		nfsd_acl_procedures2[] = {
+static const struct svc_procedure nfsd_acl_procedures2[] = {
   PROC(null,	void,		void,		void,	  RC_NOCACHE, ST),
   PROC(getacl,	getacl,		getacl,		getacl,	  RC_NOCACHE, ST+1+2*(1+ACL)),
   PROC(setacl,	setacl,		attrstat,	attrstat, RC_NOCACHE, ST+AT),
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 73c0970ccefb..1a482ac9d4e9 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -257,7 +257,7 @@ struct nfsd3_voidargs { int dummy; };
 #define pAT (1+AT)	/* post attributes - conditional */
 #define ACL (1+NFS_ACL_MAX_ENTRIES*3)  /* Access Control List */
 
-static struct svc_procedure		nfsd_acl_procedures3[] = {
+static const struct svc_procedure nfsd_acl_procedures3[] = {
   PROC(null,	void,		void,		void,	  RC_NOCACHE, ST),
   PROC(getacl,	getacl,		getacl,		getacl,	  RC_NOCACHE, ST+1+2*(1+ACL)),
   PROC(setacl,	setacl,		setacl,		fhandle,  RC_NOCACHE, ST+pAT),
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index b5823802e278..96e0e6a2af51 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -674,7 +674,7 @@ struct nfsd3_voidargs { int dummy; };
 #define pAT (1+AT)	/* post attributes - conditional */
 #define WC (7+pAT)	/* WCC attributes */
 
-static struct svc_procedure		nfsd_procedures3[22] = {
+static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFS3PROC_NULL] = {
 		.pc_func = nfsd3_proc_null,
 		.pc_encode = nfs3svc_encode_voidres,
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bad5fec0ebc7..a4d8aa3abc63 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2533,7 +2533,7 @@ static const char *nfsd4_op_name(unsigned opnum)
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
 
-static struct svc_procedure		nfsd_procedures4[2] = {
+static const struct svc_procedure nfsd_procedures4[2] = {
 	[NFSPROC4_NULL] = {
 		.pc_func = nfsd4_proc_null,
 		.pc_encode = nfs4svc_encode_voidres,
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 44b157553733..a68b686fda12 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -573,7 +573,7 @@ struct nfsd_void { int dummy; };
 #define FH 8		/* filehandle */
 #define	AT 18		/* attributes */
 
-static struct svc_procedure		nfsd_procedures2[18] = {
+static const struct svc_procedure nfsd_procedures2[18] = {
 	[NFSPROC_NULL] = {
 		.pc_func = nfsd_proc_null,
 		.pc_decode = nfssvc_decode_void,
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 555233664124..379b310c445d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -756,7 +756,7 @@ static __be32 map_new_errors(u32 vers, __be32 nfserr)
  * problem, we enforce these assumptions here:
  */
 static bool nfs_request_too_big(struct svc_rqst *rqstp,
-				struct svc_procedure *proc)
+				const struct svc_procedure *proc)
 {
 	/*
 	 * The ACL code has more careful bounds-checking and is not
@@ -781,7 +781,7 @@ static bool nfs_request_too_big(struct svc_rqst *rqstp,
 int
 nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 {
-	struct svc_procedure	*proc;
+	const struct svc_procedure *proc;
 	__be32			nfserr;
 	__be32			*nfserrp;
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 41f7b6a04d69..3eca67728366 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -192,9 +192,9 @@ struct nlm_block {
  * Global variables
  */
 extern const struct rpc_program	nlm_program;
-extern struct svc_procedure	nlmsvc_procedures[];
+extern const struct svc_procedure nlmsvc_procedures[];
 #ifdef CONFIG_LOCKD_V4
-extern struct svc_procedure	nlmsvc_procedures4[];
+extern const struct svc_procedure nlmsvc_procedures4[];
 #endif
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 9f00384153f4..984e6b9c3043 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -237,7 +237,7 @@ struct svc_rqst {
 
 	struct svc_serv *	rq_server;	/* RPC service definition */
 	struct svc_pool *	rq_pool;	/* thread pool */
-	struct svc_procedure *	rq_procinfo;	/* procedure info */
+	const struct svc_procedure *rq_procinfo;/* procedure info */
 	struct auth_ops *	rq_authop;	/* authentication flavour */
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
@@ -396,7 +396,7 @@ struct svc_program {
 struct svc_version {
 	u32			vs_vers;	/* version number */
 	u32			vs_nproc;	/* number of procedures */
-	struct svc_procedure *	vs_proc;	/* per-procedure info */
+	const struct svc_procedure *vs_proc;	/* per-procedure info */
 	unsigned int		*vs_count;	/* call counts */
 	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6452592194ac..049963d676a7 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1152,7 +1152,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 {
 	struct svc_program	*progp;
 	struct svc_version	*versp = NULL;	/* compiler food */
-	struct svc_procedure	*procp = NULL;
+	const struct svc_procedure *procp = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
 	__be32			*statp;
 	u32			prog, vers, proc;
-- 
2.11.0

