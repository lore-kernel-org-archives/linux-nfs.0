Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33027 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbaGKTTD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 15:19:03 -0400
Date: Fri, 11 Jul 2014 15:19:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Fix bad checking of space for padding in splice
 read
Message-ID: <20140711191903.GG9775@fieldses.org>
References: <53BD48DF.2050506@gmail.com>
 <20140711191747.GF9775@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140711191747.GF9775@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 11, 2014 at 03:17:47PM -0400, J. Bruce Fields wrote:
> On Wed, Jul 09, 2014 at 09:51:27PM +0800, Kinglong Mee wrote:
> > Fix commit dc97618ddd (nfsd4: separate splice and readv cases).
> > xdr->end and xdr->p are type of __be32 *, so padding needs one here.
> 
> I agree with the patch, but not the changelog.
> 
> The problem here is that xdr->p isn't that those are __be32 *'s, but
> that xdr->p has already advanced past the eof and the count, right?
> 
> Applying with an updated changelog.

(And applying for 3.17 (not 3.16) as this looks hard to hit.)

--b.


> 
> --b.
> 
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  fs/nfsd/nfs4xdr.c | 7 ++-----
> >  1 file changed, 2 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 523c666..8a2fbb2 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -3067,11 +3067,8 @@ static __be32 nfsd4_encode_splice_read(
> >  	__be32 nfserr;
> >  	__be32 *p = xdr->p - 2;
> >  
> > -	/*
> > -	 * Don't inline pages unless we know there's room for eof,
> > -	 * count, and possible padding:
> > -	 */
> > -	if (xdr->end - xdr->p < 3)
> > +	/* Make sure there will be room for padding if needed */
> > +	if (xdr->end - xdr->p < 1)
> >  		return nfserr_resource;
> >  
> >  	nfserr = nfsd_splice_read(read->rd_rqstp, file,
> > -- 
> > 1.9.3
> > 
