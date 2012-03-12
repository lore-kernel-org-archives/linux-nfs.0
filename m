Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755789Ab2CLPSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 11:18:34 -0400
Date: Mon, 12 Mar 2012 11:04:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Fix nfs4_verifier memory alignment
Message-ID: <20120312150408.GA17153@pad.fieldses.org>
References: <20120302221251.13019.46002.stgit@degas.1015granger.net>
 <20120312142049.GB4752@fieldses.org>
 <2418988F-A737-42F6-8AA0-99E85B9B8C66@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2418988F-A737-42F6-8AA0-99E85B9B8C66@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 10:57:32AM -0400, Chuck Lever wrote:
> 
> On Mar 12, 2012, at 10:20 AM, J. Bruce Fields wrote:
> 
> > On Fri, Mar 02, 2012 at 05:13:50PM -0500, Chuck Lever wrote:
> >> Clean up due to code review.
> >> 
> >> The nfs4_verifier's data field is not guaranteed to be u32-aligned.
> >> Casting an array of chars to a u32 * is considered generally
> >> hazardous.
> >> 
> >> We can fix most of this by using a __be32 array to generate the
> >> verifier's contents and then byte-copying it into the verifier field.
> >> 
> >> However, there is one spot where there is a backwards compatibility
> >> constraint: the do_nfsd_create() call expects a verifier which is
> >> 32-bit aligned.  Fix this spot by forcing the alignment of the create
> >> verifier in the nfsd4_open args structure.
> >> 
> >> Also, sizeof(nfs4_verifer) is the size of the in-core verifier data
> >> structure, but NFS4_VERIFIER_SIZE is the number of octets in an XDR'd
> >> verifier.  The two are not interchangeable, even if they happen to
> >> have the same value.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> Hi Bruce-
> >> 
> >> Compile-tested only.  Does this look reasonable?
> > 
> > Looks fine, but the setclientid verifier stuff belongs in a separate
> > patch.
> 
> Thanks for the review.  I'm not clear on exactly which hunks you would like split.

This:

> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index c5cddd6..9f0e139 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -1138,12 +1138,12 @@ static void gen_clid(struct nfs4_client *clp)
> >> 
> >> static void gen_confirm(struct nfs4_client *clp)
> >> {
> >> +	__be32 verf[2];
> >> 	static u32 i;
> >> -	u32 *p;
> >> 
> >> -	p = (u32 *)clp->cl_confirm.data;
> >> -	*p++ = get_seconds();
> >> -	*p++ = i++;
> >> +	verf[0] = (__be32)get_seconds();
> >> +	verf[1] = (__be32)i++;
> >> +	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));

This cl_confirm verifier really has nothing to do with the write
verifier (though maybe it has a similar problem).

--b.
