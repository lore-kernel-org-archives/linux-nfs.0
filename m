Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38519 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755099Ab3DXPAk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 11:00:40 -0400
Date: Wed, 24 Apr 2013 11:00:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/5] SUNRPC: allow disabling idle timeout
Message-ID: <20130424150037.GA20275@fieldses.org>
References: <1366054508-27604-1-git-send-email-bfields@redhat.com>
 <1366054508-27604-3-git-send-email-bfields@redhat.com>
 <20130418170020.GA31075@fieldses.org>
 <1366304823.58246.22.camel@leira.trondhjem.org>
 <20130418171424.GA30837@pad.fieldses.org>
 <F9B356AC-18C0-4BF1-8FBF-1F719801F72F@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F9B356AC-18C0-4BF1-8FBF-1F719801F72F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 18, 2013 at 10:25:49AM -0700, Chuck Lever wrote:
> 
> On Apr 18, 2013, at 10:14 AM, "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > On Thu, Apr 18, 2013 at 05:07:03PM +0000, Myklebust, Trond wrote:
> >> On Thu, 2013-04-18 at 13:00 -0400, J. Bruce Fields wrote:
> >>> On Mon, Apr 15, 2013 at 03:35:04PM -0400, J. Bruce Fields wrote:
> >>>> From: "J. Bruce Fields" <bfields@redhat.com>
> >>>> 
> >>>> In the gss-proxy case we don't want to have to reconnect at random--we
> >>>> want to connect only on gss-proxy startup when we can steal gss-proxy's
> >>>> context to do the connect in the right namespace.
> >>>> 
> >>>> So, provide a flag that allows the rpc_create caller to turn off the
> >>>> idle timeout.
> >>> 
> >>> Chuck, the basic ideas was your suggestion, does the executation look OK
> >>> here?  I had to copy the rpc_create flags down to the xprt_create, I
> >>> don't know if that's reasonable.
> >> 
> >> This patch will conflict with commit
> >> b7993cebb841b0da7a33e9d5ce301a9fd3209165 (SUNRPC: Allow rpc_create() to
> >> request that TCP slots be unlimited) that was posted on this list
> >> earlier this week.
> > 
> > Oh, sorry, I missed that.
> > 
> > Presumably then I should just work on top of that and do the same
> > thing--define a pair of flags
> > {RP_CLNT_CREATE|XPRT_CREATE}_NO_IDLE_TIMEOUT and translate between the
> > two in rpc_create.
> 
> Agree.

The result (untested) looks like this.

If this is OK--Trond, do you mind if I merge this commit (or
nfs-for-next) into my tree, and then the rest of the gss-proxy patches
on top?

Or is the nfs-for-next branch still potentially subject to rewriting?

--b.

commit 17728da224288679811a9b305ae1211c3c7a6e7e
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Apr 11 15:06:36 2013 -0400

    SUNRPC: allow disabling idle timeout
    
    In the gss-proxy case we don't want to have to reconnect at random--we
    want to connect only on gss-proxy startup when we can steal gss-proxy's
    context to do the connect in the right namespace.
    
    So, provide a flag that allows the rpc_create caller to turn off the
    idle timeout.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index e7d492c..bfe11be 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -125,6 +125,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
 #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
 #define RPC_CLNT_CREATE_INFINITE_SLOTS	(1UL << 7)
+#define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 8)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ff53924..cec7b9b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -256,6 +256,7 @@ static inline int bc_prealloc(struct rpc_rqst *req)
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
 #define XPRT_CREATE_INFINITE_SLOTS	(1U)
+#define XPRT_CREATE_NO_IDLE_TIMEOUT	(1U << 1)
 
 struct xprt_create {
 	int			ident;		/* XPRT_TRANSPORT identifier */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 651245a..80cf232 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -416,6 +416,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 
 	if (args->flags & RPC_CLNT_CREATE_INFINITE_SLOTS)
 		xprtargs.flags |= XPRT_CREATE_INFINITE_SLOTS;
+	if (args->flags & RPC_CLNT_CREATE_NO_IDLE_TIMEOUT)
+		xprtargs.flags |= XPRT_CREATE_NO_IDLE_TIMEOUT;
 	/*
 	 * If the caller chooses not to specify a hostname, whip
 	 * up a string representation of the passed-in address.
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 745fca3..095363e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1300,6 +1300,8 @@ found:
 				-PTR_ERR(xprt));
 		goto out;
 	}
+	if (args->flags & XPRT_CREATE_NO_IDLE_TIMEOUT)
+		xprt->idle_timeout = 0;
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
 	if (xprt_has_timer(xprt))
 		setup_timer(&xprt->timer, xprt_init_autodisconnect,
