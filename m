Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34330 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752021AbdC0Mjj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 08:39:39 -0400
Received: by mail-qt0-f194.google.com with SMTP id x35so7316925qtc.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Mar 2017 05:39:23 -0700 (PDT)
Message-ID: <1490618353.6879.3.camel@poochiereds.net>
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>,
        Chuck Lever <chucklever@gmail.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 08:39:13 -0400
In-Reply-To: <1490612833.2808.1.camel@poochiereds.net>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
         <1490577699.6879.1.camel@poochiereds.net>
         <62622BEB-E234-4035-94FE-0C34E00693AE@gmail.com>
         <FBC1AD99-AF91-42B7-9C38-C68DA5454C94@oracle.com>
         <1490612833.2808.1.camel@poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-03-27 at 07:07 -0400, Jeff Layton wrote:
> On Sun, 2017-03-26 at 22:41 -0400, Chuck Lever wrote:
> > > On Mar 26, 2017, at 10:38 PM, Chuck Lever <chucklever@gmail.com> wrote:
> > > 
> > > Hey Jeff-
> > > 
> > > 
> > > > > On Mar 26, 2017, at 9:21 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> > > > > 
> > > > > On Sun, 2017-03-26 at 19:27 -0400, Chuck Lever wrote:
> > > > > Same change as Kinglong Mee's fix for the TCP backchannel service.
> > > > > 
> > > > 
> > > > Good catch. I guess I didn't do a good job of hunting down all of the
> > > > transports where this needed to be set. I'll give them another pass
> > > > again tomorrow to make sure I didn't miss any others.
> > > > 
> > > > > Fixes: 5283b03ee5cd ("nfs/nfsd/sunrpc: enforce transport...")
> > > > > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > > > > ---
> > > > > Some (perhaps late) review comments on 5283b03ee5cd:
> > > > > 
> > > > > I have reservations about returning RPC_PROG_MISMATCH in this case.
> > > > > RPC_PROG_UNAVAIL is more sensible. But the use of UDP with NFSv4 is
> > > > > not an RPC-level error, thus reporting the problem here seems like a
> > > > > layering violation.
> > > > > 
> > > > > I'm not sure why an explicit check is needed: if the server isn't
> > > > > listening on UDP, wouldn't clients see a transport-level rejection
> > > > > (like ECONNREFUSED)?
> > > > > 
> > > > 
> > > > Sure, if the server isn't listening on UDP...
> > > > 
> > > > The point of that patch is to enforce not allowing v4 over UDP when the
> > > > server is listening on UDP to serve earlier versions.
> > > > 
> > > > As far as the error...From RFC 5531:
> > > > 
> > > >            PROG_UNAVAIL  = 1, /* remote hasn't exported program  */
> > > >            PROG_MISMATCH = 2, /* remote can't support version #  */
> > > > 
> > > > Consider the case where the server is listening on both TCP and UDP,
> > > > and is serving both v3 and v4. Someone tries to send a v4 RPC over UDP.
> > > > 
> > > > The RPC program in that case (nfs) is supported over UDP, but the
> > > > version (v4) is not. So I disagree here. PROG_MISMATCH seems like the
> > > > better fit to me.
> > > 
> > > Then the server should report the correct version range in the
> > > rejection. The RPC response I saw on the wire claimed that 4
> > > was the maximum supported version.
> > 
Of course, versions 2 and 3 do not make sense for
> > the backchannel. So I'm not sure what you would report
> > in that case.
> > 
> 
> Yeah, that's clearly a bug. The problem is that we currently track
> min/max versions on a per-program basis, but really we need to track
> them per-program + per-transport.
> 
> Another way to fix it would be to set that info more dynamically at the
> time of the error. Walk the pg_vers array and if we're on a non-
> congestion control transport, skip any entries that require it.
> 

Something like this patch maybe? Builds but is otherwise untested. It
might not DTRT though in the (nonsensical) case where you have a server
that is listening on UDP but doesn't support v2 or v3. Not sure I
really care about that too much.

[PATCH] sunrpc: dynamically set versions in PROG_MISMATCH error reply

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc.h |  2 --
 net/sunrpc/svc.c           | 47 ++++++++++++++++++++++++++++++++++------------
 2 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index e770abeed32d..f19321cfcf21 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -381,8 +381,6 @@ struct svc_deferred_req {
 struct svc_program {
 	struct svc_program *	pg_next;	/* other programs (same xprt) */
 	u32			pg_prog;	/* program number */
-	unsigned int		pg_lovers;	/* lowest version */
-	unsigned int		pg_hivers;	/* highest version */
 	unsigned int		pg_nvers;	/* number of versions */
 	struct svc_version **	pg_vers;	/* version array */
 	char *			pg_name;	/* service name */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a08aeb56b8e4..c81f68064313 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -441,18 +441,13 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	serv->sv_ops = ops;
 	xdrsize = 0;
 	while (prog) {
-		prog->pg_lovers = prog->pg_nvers-1;
 		for (vers=0; vers<prog->pg_nvers ; vers++)
-			if (prog->pg_vers[vers]) {
-				prog->pg_hivers = vers;
-				if (prog->pg_lovers > vers)
-					prog->pg_lovers = vers;
-				if (prog->pg_vers[vers]->vs_xdrsize > xdrsize)
-					xdrsize = prog->pg_vers[vers]->vs_xdrsize;
-			}
+			if (prog->pg_vers[vers] &&
+			    prog->pg_vers[vers]->vs_xdrsize > xdrsize)
+				xdrsize = prog->pg_vers[vers]->vs_xdrsize;
 		prog = prog->pg_next;
 	}
-	serv->sv_xdrsize   = xdrsize;
+	serv->sv_xdrsize = xdrsize;
 	INIT_LIST_HEAD(&serv->sv_tempsocks);
 	INIT_LIST_HEAD(&serv->sv_permsocks);
 	init_timer(&serv->sv_temptimer);
@@ -1086,6 +1081,36 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...) {}
 #endif
 
+static void
+svc_set_prog_mismatch(struct svc_rqst *rqstp, struct svc_program *prog,
+		      struct kvec *resv)
+{
+	unsigned int vers, hi = 0, lo = prog->pg_nvers - 1;
+	struct svc_version *versp;
+
+	for (vers = 0; vers < prog->pg_nvers ; vers++) {
+		versp = prog->pg_vers[vers];
+		if (!versp)
+			continue;
+
+		/*
+		 * Don't report this version if it needs congestion control
+		 * and the xprt doesn't provide it.
+		 */
+		if (versp->vs_need_cong_ctrl &&
+		    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
+			continue;
+
+		hi = vers;
+		if (lo > vers)
+			lo = vers;
+	}
+
+	svc_putnl(resv, RPC_PROG_MISMATCH);
+	svc_putnl(resv, lo);
+	svc_putnl(resv, hi);
+}
+
 /*
  * Common routine for processing the RPC request.
  */
@@ -1315,9 +1340,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		       vers, prog, progp->pg_name);
 
 	serv->sv_stats->rpcbadfmt++;
-	svc_putnl(resv, RPC_PROG_MISMATCH);
-	svc_putnl(resv, progp->pg_lovers);
-	svc_putnl(resv, progp->pg_hivers);
+	svc_set_prog_mismatch(rqstp, progp, resv);
 	goto sendit;
 
 err_bad_proc:
-- 
2.9.3

