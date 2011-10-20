Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529Ab1JTM0J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 08:26:09 -0400
Date: Thu, 20 Oct 2011 08:26:01 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Benny Halevy <benny@tonian.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
Message-ID: <20111020122601.GK28630@pad.fieldses.org>
References: <956652236-1319113365-cardhu_decombobulator_blackberry.rim.net-813536196-@b18.c3.bise3.blackberry>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <956652236-1319113365-cardhu_decombobulator_blackberry.rim.net-813536196-@b18.c3.bise3.blackberry>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 12:22:41PM +0000, Benny Halevy wrote:
> The other patch was for the deny bits this is for the want mask...
> Similar bug, different place :)

Oog, sorry!  OK, applying.

(And in fact I made the same ! for ~ mistake in one other place in the
last week that got caught by regression testing before I posted it.  I
need to teach my editor to highlight !'s in blinking red, or
something....)

--b.

> 
> Benny
> ------Original Message------
> From: J. Bruce Fields
> To: Benny Halevy
> Cc: J. Bruce Fields
> Cc: linux-nfs@vger.kernel.org
> Cc: Benny Halevy
> Subject: Re: [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
> Sent: Oct 20, 2011 04:53
> 
> Yep, bad mistake on my part--but someone else already caught this, and
> it's already committed to my 3.2 branch.--b.
> 
> On Wed, Oct 19, 2011 at 07:13:29PM -0700, Benny Halevy wrote:
> > From: Benny Halevy <bhalevy@tonian.com>
> > 
> > Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> > ---
> >  fs/nfsd/nfs4xdr.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 1a419c0..1a5cb7e 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -671,7 +671,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
> >  	default:
> >  		return nfserr_bad_xdr;
> >  	}
> > -	w &= !NFS4_SHARE_WANT_MASK;
> > +	w &= ~NFS4_SHARE_WANT_MASK;
> >  	if (!w)
> >  		return nfs_ok;
> >  	switch (w) {
> > -- 
> > 1.7.6
> > 
> 
