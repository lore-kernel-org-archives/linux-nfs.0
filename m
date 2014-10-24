Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f173.google.com ([209.85.212.173]:42919 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaJXKIf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 06:08:35 -0400
Received: by mail-wi0-f173.google.com with SMTP id ex7so803405wid.0
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 03:08:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeffrey Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd: Ensure that NFSv4 always drops the connection when dropping a request
Date: Fri, 24 Oct 2014 13:08:28 +0300
Message-Id: <1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both RFC3530 and RFC5661 impose a requirement on the server that it MUST NOT
drop a request unless the connection is broken.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c         | 6 ++++++
 include/linux/sunrpc/svc.h | 1 +
 net/sunrpc/svc.c           | 4 ++++
 3 files changed, 11 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cdeb3cfd6f32..500ac76662a8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1960,6 +1960,11 @@ static const char *nfsd4_op_name(unsigned opnum)
 	return "unknown_operation";
 }
 
+static void nfsd4_dropme(struct svc_rqst *rqstp)
+{
+	svc_close_xprt(rqstp->rq_xprt);
+}
+
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
 
@@ -1989,6 +1994,7 @@ struct svc_version	nfsd_version4 = {
 		.vs_nproc	= 2,
 		.vs_proc	= nfsd_procedures4,
 		.vs_dispatch	= nfsd_dispatch,
+		.vs_dropme	= nfsd4_dropme,
 		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
 		.vs_rpcb_optnl	= 1,
 };
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 21678464883a..824656da1f6d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -400,6 +400,7 @@ struct svc_version {
 	 * vs_dispatch == NULL means use default dispatcher.
 	 */
 	int			(*vs_dispatch)(struct svc_rqst *, __be32 *);
+	void			(*vs_dropme)(struct svc_rqst *);
 };
 
 /*
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ca8a7958f4e6..09136abfef26 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1071,6 +1071,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	struct svc_version	*versp = NULL;	/* compiler food */
 	struct svc_procedure	*procp = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
+	void (*dropme)(struct svc_rqst *rqstp) = NULL;
 	kxdrproc_t		xdr;
 	__be32			*statp;
 	u32			prog, vers, proc;
@@ -1151,6 +1152,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	if (vers >= progp->pg_nvers ||
 	  !(versp = progp->pg_vers[vers]))
 		goto err_bad_vers;
+	dropme = versp->vs_dropme;
 
 	procp = versp->vs_proc + proc;
 	if (proc >= versp->vs_nproc || !procp->pc_func)
@@ -1228,6 +1230,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
  dropit:
 	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
 	dprintk("svc: svc_process dropit\n");
+	if (dropme != NULL)
+		dropme(rqstp);
 	return 0;
 
 err_short_len:
-- 
1.9.3

