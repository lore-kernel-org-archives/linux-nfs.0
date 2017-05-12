Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:59607 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758047AbdELQSm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:42 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 30/33] sunrpc: move pc_count out of struct svc_procinfo
Date: Fri, 12 May 2017 18:16:58 +0200
Message-Id: <20170512161701.22468-31-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pc_count is the only writeable memeber of struct svc_procinfo, which is
a good candidate to be const-ified as it contains function pointers.

This patch moves it into out out struct svc_procinfo, and into a
separate writable array that is pointed to by struct svc_version.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/svc.c             |  6 ++++++
 fs/nfs/callback_xdr.c      |  4 ++++
 fs/nfsd/nfs2acl.c          |  2 ++
 fs/nfsd/nfs3acl.c          |  2 ++
 fs/nfsd/nfs3proc.c         |  2 ++
 fs/nfsd/nfs4proc.c         |  2 ++
 fs/nfsd/nfsproc.c          |  2 ++
 include/linux/sunrpc/svc.h |  2 +-
 net/sunrpc/stats.c         | 11 ++++++-----
 net/sunrpc/svc.c           |  2 +-
 10 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 5d481e8a1b5d..cc6abe6280bc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -739,23 +739,29 @@ module_exit(exit_nlm);
 /*
  * Define NLM program and procedures
  */
+static unsigned int nlmsvc_version1_count[17];
 static struct svc_version	nlmsvc_version1 = {
 		.vs_vers	= 1,
 		.vs_nproc	= 17,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_count	= nlmsvc_version1_count,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
+static unsigned int nlmsvc_version3_count[24];
 static struct svc_version	nlmsvc_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_count	= nlmsvc_version3_count,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
+static unsigned int nlmsvc_version4_count[24];
 static struct svc_version	nlmsvc_version4 = {
 		.vs_vers	= 4,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures4,
+		.vs_count	= nlmsvc_version4_count,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index acf75dc63e14..ecd46b8c0985 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -1011,20 +1011,24 @@ static struct svc_procedure nfs4_callback_procedures1[] = {
 	}
 };
 
+static unsigned int nfs4_callback_count1[ARRAY_SIZE(nfs4_callback_procedures1)];
 struct svc_version nfs4_callback_version1 = {
 	.vs_vers = 1,
 	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
 	.vs_proc = nfs4_callback_procedures1,
+	.vs_count = nfs4_callback_count1,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
 	.vs_hidden = true,
 	.vs_need_cong_ctrl = true,
 };
 
+static unsigned int nfs4_callback_count4[ARRAY_SIZE(nfs4_callback_procedures1)];
 struct svc_version nfs4_callback_version4 = {
 	.vs_vers = 4,
 	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
 	.vs_proc = nfs4_callback_procedures1,
+	.vs_count = nfs4_callback_count4,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
 	.vs_dispatch = NULL,
 	.vs_hidden = true,
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index fc6b179c8fff..026edfe73fd5 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -378,10 +378,12 @@ static struct svc_procedure		nfsd_acl_procedures2[] = {
   PROC(access,	access,		access,		access,   RC_NOCACHE, ST+AT+1),
 };
 
+static unsigned int nfsd_acl_count2[ARRAY_SIZE(nfsd_acl_procedures2)];
 struct svc_version	nfsd_acl_version2 = {
 		.vs_vers	= 2,
 		.vs_nproc	= 5,
 		.vs_proc	= nfsd_acl_procedures2,
+		.vs_count	= nfsd_acl_count2,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 9437b758cbfd..73c0970ccefb 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -263,10 +263,12 @@ static struct svc_procedure		nfsd_acl_procedures3[] = {
   PROC(setacl,	setacl,		setacl,		fhandle,  RC_NOCACHE, ST+pAT),
 };
 
+static unsigned int nfsd_acl_count3[ARRAY_SIZE(nfsd_acl_procedures3)];
 struct svc_version	nfsd_acl_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 3,
 		.vs_proc	= nfsd_acl_procedures3,
+		.vs_count	= nfsd_acl_count3,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 17c90c41a3a6..b5823802e278 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -890,10 +890,12 @@ static struct svc_procedure		nfsd_procedures3[22] = {
 	},
 };
 
+static unsigned int nfsd_count3[ARRAY_SIZE(nfsd_procedures3)];
 struct svc_version	nfsd_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 22,
 		.vs_proc	= nfsd_procedures3,
+		.vs_count	= nfsd_count3,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
 };
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a947dcef5e4e..bad5fec0ebc7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2554,10 +2554,12 @@ static struct svc_procedure		nfsd_procedures4[2] = {
 	},
 };
 
+static unsigned int nfsd_count3[ARRAY_SIZE(nfsd_procedures4)];
 struct svc_version	nfsd_version4 = {
 	.vs_vers		= 4,
 	.vs_nproc		= 2,
 	.vs_proc		= nfsd_procedures4,
+	.vs_count		= nfsd_count3,
 	.vs_dispatch		= nfsd_dispatch,
 	.vs_xdrsize		= NFS4_SVC_XDRSIZE,
 	.vs_rpcb_optnl		= true,
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0ef88d0e67d9..44b157553733 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -743,10 +743,12 @@ static struct svc_procedure		nfsd_procedures2[18] = {
 };
 
 
+static unsigned int nfsd_count2[ARRAY_SIZE(nfsd_procedures2)];
 struct svc_version	nfsd_version2 = {
 		.vs_vers	= 2,
 		.vs_nproc	= 18,
 		.vs_proc	= nfsd_procedures2,
+		.vs_count	= nfsd_count2,
 		.vs_dispatch	= nfsd_dispatch,
 		.vs_xdrsize	= NFS2_SVC_XDRSIZE,
 };
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6cfe41db7f31..9f00384153f4 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -397,6 +397,7 @@ struct svc_version {
 	u32			vs_vers;	/* version number */
 	u32			vs_nproc;	/* number of procedures */
 	struct svc_procedure *	vs_proc;	/* per-procedure info */
+	unsigned int		*vs_count;	/* call counts */
 	u32			vs_xdrsize;	/* xdrsize needed for this version */
 
 	/* Don't register with rpcbind */
@@ -429,7 +430,6 @@ struct svc_procedure {
 	void			(*pc_release)(struct svc_rqst *);
 	unsigned int		pc_argsize;	/* argument struct size */
 	unsigned int		pc_ressize;	/* result struct size */
-	unsigned int		pc_count;	/* call count */
 	unsigned int		pc_cachetype;	/* cache info (NFS) */
 	unsigned int		pc_xdrressize;	/* maximum size of XDR reply */
 };
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 8b6c35ae1d57..1e671333c3d5 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -77,9 +77,9 @@ static const struct file_operations rpc_proc_fops = {
 /*
  * Get RPC server stats
  */
-void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
+void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp)
+{
 	const struct svc_program *prog = statp->program;
-	const struct svc_procedure *proc;
 	const struct svc_version *vers;
 	unsigned int i, j;
 
@@ -98,11 +98,12 @@ void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
 			statp->rpcbadclnt);
 
 	for (i = 0; i < prog->pg_nvers; i++) {
-		if (!(vers = prog->pg_vers[i]) || !(proc = vers->vs_proc))
+		vers = prog->pg_vers[i];
+		if (!vers)
 			continue;
 		seq_printf(seq, "proc%d %u", i, vers->vs_nproc);
-		for (j = 0; j < vers->vs_nproc; j++, proc++)
-			seq_printf(seq, " %u", proc->pc_count);
+		for (j = 0; j < vers->vs_nproc; j++)
+			seq_printf(seq, " %u", vers->vs_count[j]);
 		seq_putc(seq, '\n');
 	}
 }
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index aa643a29fdc6..6452592194ac 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1261,7 +1261,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	svc_putnl(resv, RPC_SUCCESS);
 
 	/* Bump per-procedure stats counter */
-	procp->pc_count++;
+	versp->vs_count[proc]++;
 
 	/* Initialize storage for argp and resp */
 	memset(rqstp->rq_argp, 0, procp->pc_argsize);
-- 
2.11.0

