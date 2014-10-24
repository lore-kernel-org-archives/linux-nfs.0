Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:38136 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbaJXObA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 10:31:00 -0400
Received: by mail-wg0-f49.google.com with SMTP id x12so1228935wgg.8
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 07:30:59 -0700 (PDT)
Message-ID: <1414161055.21776.2.camel@leira.trondhjem.org>
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection
 when dropping a request
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        bfields@fieldses.org
Date: Fri, 24 Oct 2014 17:30:55 +0300
In-Reply-To: <20141024093459.70a29d80@tlielax.poochiereds.net>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
	 <1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
	 <20141024072644.6643f9ed@tlielax.poochiereds.net>
	 <20141024093459.70a29d80@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-10-24 at 09:34 -0400, Jeff Layton wrote:
> On Fri, 24 Oct 2014 07:26:44 -0400
> Jeff Layton <jlayton@primarydata.com> wrote:
>  
> > I guess the theory here is that the client sent the request, and got a
> > TCP ACK and then the server never responded because it dropped the
> > request? That sounds plausible and we almost certainly want something
> > like the above for v4.0.
> > 
> > If the above patch fixes Christoph's problem with v4.1 though, then I
> > think we'll need more investigation into why. I don't see a way to get
> > a dropped request with v4.1. Those mainly occur due to interaction with
> > the DRC (disabled for v4.1) or with svc_defer (disabled for all v4
> > requests).
> > 
> > Is it possible that one of the nfsd threads is just hung while
> > processing an RPC and that's why you're not getting a response?
> > 
> 
> Ok, I'm able to reproduce this too and got a network trace. I think
> Trond is correct as to the cause:
> 
> I see a SETATTR call go out and then see a TCP ACK for it a little
> later, but didn't see a reply sent for it.
> 
> I sprinkled in some printks around the "dropit" codepath above and in
> some other areas however and none of them fired. So while Trond's patch
> looks like it might be correct, I don't think it'll fix the problem I'm
> seeing.
> 
> Sniffing a little later, it seems like the server replies are being
> delayed somehow:

You can get deferrals in the authentication code which trigger drops.
Here is a variant which tries to deal with that:

8<-----------------------------------------------------
>From a9be1292152af2cb651415c44fd3d91b3d017240 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 24 Oct 2014 12:54:47 +0300
Subject: [PATCH v2] nfsd: Ensure that NFSv4 always drops the connection when
 dropping a request

Both RFC3530 and RFC5661 impose a requirement on the server that it MUST NOT
drop a request unless the connection is broken. This is in order to allow
clients to assume that they can always expect an answer unless the
connection is broken.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org
---
v2: Also deal with NFSv4 requests dropped due to authentication issues

 fs/nfsd/nfs4proc.c         |  6 ++++++
 include/linux/sunrpc/svc.h |  1 +
 net/sunrpc/svc.c           | 13 +++++++++----
 3 files changed, 16 insertions(+), 4 deletions(-)

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
index ca8a7958f4e6..a178496ce2c1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1111,9 +1111,13 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
 	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */
 
-	for (progp = serv->sv_program; progp; progp = progp->pg_next)
-		if (prog == progp->pg_prog)
+	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
+		if (prog == progp->pg_prog) {
+			if (vers < progp->pg_nvers)
+				versp = progp->pg_vers[vers];
 			break;
+		}
+	}
 
 	/*
 	 * Decode auth data, and add verifier to reply buffer.
@@ -1148,8 +1152,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	if (progp == NULL)
 		goto err_bad_prog;
 
-	if (vers >= progp->pg_nvers ||
-	  !(versp = progp->pg_vers[vers]))
+	if (versp == NULL)
 		goto err_bad_vers;
 
 	procp = versp->vs_proc + proc;
@@ -1228,6 +1231,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
  dropit:
 	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
 	dprintk("svc: svc_process dropit\n");
+	if (versp && versp->vs_dropme)
+		versp->vs_dropme(rqstp);
 	return 0;
 
 err_short_len:
-- 
1.9.3




