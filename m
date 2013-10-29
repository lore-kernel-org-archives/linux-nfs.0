Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317Ab3J2VYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 17:24:06 -0400
Date: Tue, 29 Oct 2013 17:24:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Combine decode operations for v4 and v4.1
Message-ID: <20131029212402.GB3227@fieldses.org>
References: <1383080676-1479-1-git-send-email-bjschuma@netapp.com>
 <20131029210659.GA3227@fieldses.org>
 <527024F5.9080401@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <527024F5.9080401@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 05:13:25PM -0400, Anna Schumaker wrote:
> On Tue 29 Oct 2013 05:06:59 PM EDT, J. Bruce Fields wrote:
> > On Tue, Oct 29, 2013 at 05:04:36PM -0400, Anna Schumaker wrote:
> >> We were using a different array of function pointers to represent each
> >> minor version.  This makes adding a new minor version tedious, since it
> >> needs a step to copy, paste and modify a new version of the same
> >> functions.
> >>
> >> This patch combines the v4 and v4.1 arrays into a single instance and
> >> will check minor version support inside each decoder function.
> >
> > This also needs checks in all the new operations.  (E.g. exchange_id
> > needs to return nfserr_notsupp on minorversion=0.)
> >
> 
> nfsd4_verify_opnum() should do some of that, but I'll add the checks to 
> the new operations since it probably makes more sense there.  Should I 
> return nfserr_notsupp or nfserr_illegal in this case?

Doh, sorry I was obviously reading too fast!  What you've got looks
fine, no need to add checks to each operation.

As a nit, I'd rather avoid when possible returning an error value that's
ignored:

> >> +static __be32 nfsd4_verify_opnum(struct nfsd4_compoundargs *argp, struct nfsd4_op *op)
> >> +{
> >> +	if (op->opnum < FIRST_NFS4_OP || op->opnum > LAST_NFS4_OP)
> >> +		return nfserr_op_illegal;
> >> +	else if (argp->minorversion == 0 && op->opnum > OP_RELEASE_LOCKOWNER)
> >> +		return nfserr_op_illegal;
> >> +	else if (argp->minorversion == 1 && op->opnum > OP_RECLAIM_COMPLETE)
> >> +		return nfserr_op_illegal;
> >> +	return nfs_ok;
> >> +}
...
> >> +		if (nfsd4_verify_opnum(argp, op) == nfs_ok)
> >> +			op->status = nfsd4_dec_ops[op->opnum](argp, &op->u);
> >>  		else {
> >>  			op->opnum = OP_ILLEGAL;
> >>  			op->status = nfserr_op_illegal;

How about making it something like "static bool nfsd4_opnum_in_range"?

--b.
