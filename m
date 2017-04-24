Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59638 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S977778AbdDXVTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 17:19:21 -0400
Date: Mon, 24 Apr 2017 17:19:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170424211920.GA1585@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <20170420161935.GB4782@fieldses.org>
 <20170421211253.GE19775@fieldses.org>
 <87vapurci7.fsf@notabene.neil.brown.name>
 <20170424140642.GB30046@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170424140642.GB30046@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 24, 2017 at 10:06:42AM -0400, J. Bruce Fields wrote:
> On Mon, Apr 24, 2017 at 08:21:36AM +1000, NeilBrown wrote:
> > I like this.  I think this should be the basis of what goes to -stable,
> > and other improvements should stay in mainline.
> > 
> > The only change I would suggest would be to be explicit about where the
> > nfsacl protocol fits with this.
> 
> Oh, good point, I'd forgotten nfsd_dispatch handles multiple protocols!

That was getting to be kind of a pile of conditions for one "if", and
the comments were getting a little long-winded, so I split it out, but
otherwise it's the same idea.

--b.

commit 43e06bcafea8
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Apr 21 16:10:18 2017 -0400

    nfsd: check for oversized NFSv2/v3 arguments
    
    A client can append random data to the end of an NFSv2 or NFSv3 RPC call
    without our complaining; we'll just stop parsing at the end of the
    expected data and ignore the rest.
    
    Encoded arguments and replies are stored together in an array of pages,
    and if a call is too large it could leave inadequate space for the
    reply.  This is normally OK because NFS RPC's typically have either
    short arguments and long replies (like READ) or long arguments and short
    replies (like WRITE).  But a client that sends an incorrectly long reply
    can violate those assumptions.  This was observed to cause crashes.
    
    Also, several operations increment rq_next_page in the decode routine
    before checking the argument size, which can leave rq_next_page pointing
    well past the end of the page array, causing trouble later in
    svc_free_pages.
    
    So, following a suggestion from Neil Brown, add a central check to
    enforce our expectation that no NFSv2/v3 call has both a large call and
    a large reply.
    
    As followup we may also want to rewrite the encoding routines to check
    more carefully that they aren't running off the end of the page array.
    
    We may also consider rejecting calls that have any extra garbage
    appended.  That would be safer, and within our rights by spec, but given
    the age of our server and the NFS protocol, and the fact that we've
    never enforced this before, we may need to balance that against the
    possibility of breaking some oddball client.
    
    Reported-by: Tuomas Haanpää <thaan@synopsys.com>
    Reported-by: Ari Kauppi <ari@synopsys.com>
    Cc: stable@vger.kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 31e1f9593457..59979f0bbd4b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -747,6 +747,37 @@ static __be32 map_new_errors(u32 vers, __be32 nfserr)
 	return nfserr;
 }
 
+/*
+ * A write procedure can have a large argument, and a read procedure can
+ * have a large reply, but no NFSv2 or NFSv3 procedure has argument and
+ * reply that can both be larger than a page.  The xdr code has taken
+ * advantage of this assumption to be a sloppy about bounds checking in
+ * some cases.  Pending a rewrite of the NFSv2/v3 xdr code to fix that
+ * problem, we enforce these assumptions here:
+ */
+static bool nfs_request_too_big(struct svc_rqst *rqstp,
+				struct svc_procedure *proc)
+{
+	/*
+	 * The ACL code has more careful bounds-checking and is not
+	 * susceptible to this problem:
+	 */
+	if (rqstp->rq_prog != NFS_PROGRAM)
+		return false;
+	/*
+	 * Ditto NFSv4 (which can in theory have argument and reply both
+	 * more than a page):
+	 */
+	if (rqstp->rq_vers >= 4)
+		return false;
+	/* The reply will be small, we're OK: */
+	if (proc->pc_xdrressize > 0 &&
+	    proc->pc_xdrressize < XDR_QUADLEN(PAGE_SIZE))
+		return false;
+
+	return rqstp->rq_arg.len > PAGE_SIZE;
+}
+
 int
 nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 {
@@ -759,6 +790,11 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 				rqstp->rq_vers, rqstp->rq_proc);
 	proc = rqstp->rq_procinfo;
 
+	if (nfs_request_too_big(rqstp, proc)) {
+		dprintk("nfsd: NFSv%d argument too large\n", rqstp->rq_vers);
+		*statp = rpc_garbage_args;
+		return 1;
+	}
 	/*
 	 * Give the xdr decoder a chance to change this if it wants
 	 * (necessary in the NFSv4.0 compound case)
