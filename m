From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [PATCH 10/14] SQUASHME: nfs41: sunrpc: Don't skip past the RPC call direction
Date: Mon, 15 Jun 2009 08:37:51 -0700
Message-ID: <273FE88A07F5D445824060902F70034406334CE0@SACMVEXC1-PRD.hq.netapp.com>
References: <4A350A7A.7000008@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	<pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
To: "Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43740 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762003AbZFOPhx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 11:37:53 -0400
In-Reply-To: <4A350A7A.7000008@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@panasas.com]
> Sent: Sunday, June 14, 2009 7:35 AM
> To: Labiaga, Ricardo
> Cc: Myklebust, Trond; pnfs@linux-nfs.org; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 10/14] SQUASHME: nfs41: sunrpc: Don't skip past
the
> RPC call direction
> 
> On Jun. 12, 2009, 1:54 -0400, Ricardo Labiaga
<Ricardo.Labiaga@netapp.com>
> wrote:
> > [squash with: nfs41: Skippast the RPC call direction]
> >
> > xs_tcp_read_data() has been modified to include the RPC call
direction
> in the
> > XDR buffer.  We need to read the direction during the header
> verification.
> >
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > ---
> >  net/sunrpc/clnt.c |   12 ++++++------
> >  1 files changed, 6 insertions(+), 6 deletions(-)
> >
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index e7fffd2..d5a85a9 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1507,12 +1507,12 @@ rpc_verify_header(struct rpc_task *task)
> >  	if ((len -= 3) < 0)
> >  		goto out_overflow;
> >
> > -	/*
> > -	 * Skip the XID and call direction.
> > -	 * The underlying transport has read the XID and RPC call
direction
> > -	 * to determine this is an RPC reply.
> > -	 */
> > -	p += 2;
> > +	p += 1; /* skip XID */
> > +	if ((n = ntohl(*p++)) != RPC_REPLY) {
> > +		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
> > +			task->tk_pid, __func__, n);
> > +		goto out_garbage;
> > +	}
> >
> >  	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
> >  		if (--len < 0)
> 
> BTW, for bisectability reasons it looks like this patch needs to
> be part of the previous patch:
> "[PATCH 09/14] SQUASHME: nfs41: sunrpc: Add RPC direction back into
the
> XDR buffer"
> Otherwise it introduces a bug that this patch fixes.
> (just a nit, not that it matters much if both are to be squashed
> into the same patch eventually)
> 

This patch obliterates the patch that introduced this functionality
completely.  It removes the changes made by the original patch " nfs41:
Skip past the RPC call direction" line by line.  The reason it's a
separate patch is because it makes the original patch disappear - we'll
never submit it.  I was intending to simply remove the initial patch
(and this one) using git-rebase this week at bakeathon.

- ricardo

> Benny
