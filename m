Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752236AbdDMP3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Apr 2017 11:29:48 -0400
Date: Thu, 13 Apr 2017 11:29:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: NFSD oops when it receives operation it doesn't support
Message-ID: <20170413152947.GA17915@parsley.fieldses.org>
References: <CAN-5tyE-HXkpiuF9WGu_r9oda0SvjyV8SpgnfYzFS=HNCwQvrg@mail.gmail.com>
 <20170324155926.GB29655@parsley.fieldses.org>
 <CAN-5tyG4YkP4uyVxprG-U1-0gS=zQ5cSLJmcZv8wOZm=Kq0ZBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyG4YkP4uyVxprG-U1-0gS=zQ5cSLJmcZv8wOZm=Kq0ZBg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 24, 2017 at 01:45:02PM -0400, Olga Kornievskaia wrote:
> On Fri, Mar 24, 2017 at 11:59 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Mar 23, 2017 at 02:36:20PM -0400, Olga Kornievskaia wrote:
> >> I'm getting this oops when client sends an operation the server doesn't support.
> >>
> >> in nfsd4_max_reply() it checks for NULL rsize_bop but non-supported
> >> operation wouldn't have that set.
> >>
> >> So maybe something like this for the fix:
> >
> > Ouch, thanks, did you notice whether this was a recent regression?
> >
> > I thought we had a pynfs test for this--I'll check.
> 
> Seems like regression though i don't know when. I tried against RHEL
> 3.10.0.-514 kernel and it doesn't oops when it receives CLONE,COPY ops
> (returns ILLEGAL and NOTSUPP respectively).

Sorry for the delay handling this.  I haven't tested, but it's almost
certainly a regression from 2282cd2c05e2 "NFSD: Get response size before
operation for all RPCs", which added that BUG().  Applying for 4.11 as
follows.

--b.

commit 05b7278d510a
Author: Olga Kornievskaia <aglo@umich.edu>
Date:   Thu Mar 23 14:36:20 2017 -0400

    nfsd: fix oops on unsupported operation
    
    I'm hitting the BUG in nfsd4_max_reply() at fs/nfsd/nfs4proc.c:2495 when
    client sends an operation the server doesn't support.
    
    in nfsd4_max_reply() it checks for NULL rsize_bop but a non-supported
    operation wouldn't have that set.
    
    Cc: Kinglong Mee <kinglongmee@gmail.com>
    Fixes: 2282cd2c05e2 "NFSD: Get response size before operation..."
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cbeeda1e94a2..d86031b6ad79 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2489,7 +2489,7 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
-	if (op->opnum == OP_ILLEGAL)
+	if (op->opnum == OP_ILLEGAL || op->status == nfserr_notsupp)
 		return op_encode_hdr_size * sizeof(__be32);
 
 	BUG_ON(OPDESC(op)->op_rsize_bop == NULL);
