Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970Ab3KET6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Nov 2013 14:58:11 -0500
Date: Tue, 5 Nov 2013 14:58:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Shyam Kaushik <shyamnfs1@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Need help with NFS Server SUNRPC performance issue
Message-ID: <20131105195810.GC23329@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
 <20131031141538.GA621@fieldses.org>
 <CA+uAZNO7VrBA1MLgGoqGpXGPHMMy0VF_3KBr93Y5w1M=ZO7s4w@mail.gmail.com>
 <20131104230244.GD8828@fieldses.org>
 <CA+uAZNOJg3Jeu8uyCEeHx71JwHwC0P0d=mx1BiyKnyoS04KUsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+uAZNOJg3Jeu8uyCEeHx71JwHwC0P0d=mx1BiyKnyoS04KUsw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 05, 2013 at 07:14:50PM +0530, Shyam Kaushik wrote:
> Hi Bruce,
> 
> You are spot on this issue. I did a quicker option of just fixing
> 
> fs/nfsd/nfs4proc.c
> 
> nfsd_procedures4[]
> 
> NFSPROC4_COMPOUND
> instead of
> .pc_xdrressize = NFSD_BUFSIZE/4
> 
> I made it by /8 & I got double the IOPs. I moved it /16 & now I see
> that 30 NFSD threads out of 32 that I have configured are doing the
> nfsd_write() job. So yes this is the exact problematic area.

Yes, that looks like good evidence we're on the right track, thanks very
much for the testing.

> Now for a permanent fixture for this issue, what do you suggest? Is it
> that before processing the compound we adjust svc_reserve()?

I think decode_compound() needs to do some estimate of the maximum total
reply size and call svc_reserve() with that new estimate.

And for the current code I think it really could be as simple as
checking whether the compound includes a READ op.

That's because that's all the current xdr encoding handles.  We need to
fix that: people need to be able to fetch ACLs larger than 4k, and
READDIR would be faster if it could return more than 4k of data at a go.

After we do that, we'll need to know more than just the list of ops,
we'll need to e.g.  know which attributes exactly a GETATTR requested.
And we don't have any automatic way to figure that out so it'll all be a
lot of manual arithmetic.  On the other hand the good news is we only
need a rough upper bound, so this will may be doable.

Beyond that it would also be good to think about whether using
worst-case reply sizes to decide when to accept requests is really
right.

Anyway here's the slightly improved hack--totally untested except to fix
some compile errors.

--b.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d9454fe..947f268 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1617,6 +1617,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	struct nfsd4_op *op;
 	struct nfsd4_minorversion_ops *ops;
 	bool cachethis = false;
+	bool foundread = false;
 	int i;
 
 	READ_BUF(4);
@@ -1667,10 +1668,15 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		 * op in the compound wants to be cached:
 		 */
 		cachethis |= nfsd4_cache_this_op(op);
+
+		foundread |= op->opnum == OP_READ;
 	}
 	/* Sessions make the DRC unnecessary: */
 	if (argp->minorversion)
 		cachethis = false;
+	if (!foundread)
+		/* XXX: use tighter estimates, and svc_reserve_auth: */
+		svc_reserve(argp->rqstp, PAGE_SIZE);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
 	DECODE_TAIL;
