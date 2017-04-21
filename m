Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54802 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1042338AbdDUVMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Apr 2017 17:12:53 -0400
Date: Fri, 21 Apr 2017 17:12:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170421211253.GE19775@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <20170420161935.GB4782@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170420161935.GB4782@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 20, 2017 at 12:19:35PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 18, 2017 at 01:13:51PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
> > >  I can't say that I like this patch at all.
> > > 
> > > The problem is that:
> > > 
> > > 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
> > > 				       * We assume one is at most one page
> > > 				       */
> > > 
> > > this assumption is never verified.
> > > To my mind, the "obvious" way to verify this assumption is that an
> > > attempt to generate a multi-page reply should fail if there was a
> > > multi-page request.
> > 
> > A third option, by the way, which Ari Kauppi argued for, is adding a
> > null check each time we increment rq_next_page, since we seem to arrange
> > for the page array to always be NULL-terminated.
> > 
> > > Failing if there was a little bit of extra noise at the end of the
> > > request seems harsher than necessary, and could result in a regression.
> > 
> > You're worrying there might be a weird old client out there somewhere?
> > I guess it seems like a small enough risk to me.  I'm more worried the
> > extra garbage might violate assumptions elsewhere in the code.
> > 
> > But, this looks good too:
> 
> But, I'm not too happy about putting that NFSv2/v3-specific check in
> common rpc code.

Well, but it should work just as well in nfsd_dispatch, I think?
(Untested).  So, maybe that's simplest as a first step:

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 31e1f9593457..b6298d30a01f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -759,6 +759,22 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 				rqstp->rq_vers, rqstp->rq_proc);
 	proc = rqstp->rq_procinfo;
 
+	if (rqstp->rq_vers < 4 &&
+	    (proc->pc_xdrressize == 0
+			|| proc->pc_xdrressize > XDR_QUADLEN(PAGE_SIZE))
+		&& rqstp->rq_arg.len > PAGE_SIZE) {
+		/*
+		 * NFSv2 and v3 assume that an operation may have either a
+		 * large argument, or a large reply, but never both.
+		 *
+		 * NFSv4 may handle compounds with both argument and
+		 * reply larger than a reply; it has more xdr careful
+		 * xdr decoding which can handle such calls safely.
+		 */
+		dprintk("nfsd: NFSv%d argument too large\n", rqstp->rq_vers);
+		*statp = rpc_garbage_args;
+		return 1;
+	}
 	/*
 	 * Give the xdr decoder a chance to change this if it wants
 	 * (necessary in the NFSv4.0 compound case)
