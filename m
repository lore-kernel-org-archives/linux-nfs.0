Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54822 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033422AbdEWUi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 16:38:27 -0400
Date: Tue, 23 May 2017 16:38:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: trond.myklebust@primarydata.com, stable@vger.kernel.org,
        stable-commits@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Patch "nfsd: Fix up the "supattr_exclcreat" attributes" has been
 added to the 4.4-stable tree
Message-ID: <20170523203824.GG7556@parsley.fieldses.org>
References: <14955646521694@kroah.com>
 <20170523192339.GA30111@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170523192339.GA30111@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 23, 2017 at 09:23:39PM +0200, Greg KH wrote:
> Oops, nope, this breaks the build on 4.4, can someone please provide a
> working backport as it is "supposed" to be added to that kernel...

The issue is

	916d2d844afd "nfsd: clean up supported attribute handling"
	dcd208697707 "nfsd: fix supported attributes for acl & labels"

which replaced 3 numbered constants by an array, and went in between 4.8
and 4.10.

But for the purposes of older stable branches, best is probably just to
use the old constants.  I'll send an updated patch.

--b.

> 
> thanks,
> 
> greg k-h
> 
> On Tue, May 23, 2017 at 08:37:32PM +0200, gregkh@linuxfoundation.org wrote:
> > 
> > This is a note to let you know that I've just added the patch titled
> > 
> >     nfsd: Fix up the "supattr_exclcreat" attributes
> > 
> > to the 4.4-stable tree which can be found at:
> >     http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary
> > 
> > The filename of the patch is:
> >      nfsd-fix-up-the-supattr_exclcreat-attributes.patch
> > and it can be found in the queue-4.4 subdirectory.
> > 
> > If you, or anyone else, feels it should not be added to the stable tree,
> > please let <stable@vger.kernel.org> know about it.
> > 
> > 
> > >From b26b78cb726007533d81fdf90a62e915002ef5c8 Mon Sep 17 00:00:00 2001
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > Date: Tue, 9 May 2017 16:24:59 -0400
> > Subject: nfsd: Fix up the "supattr_exclcreat" attributes
> > 
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > commit b26b78cb726007533d81fdf90a62e915002ef5c8 upstream.
> > 
> > If an NFSv4 client asks us for the supattr_exclcreat, then we must
> > not return attributes that are unsupported by this minor version.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > Fixes: 75976de6556f ("NFSD: Return word2 bitmask if setting security..,")
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > 
> > ---
> >  fs/nfsd/nfs4xdr.c |   11 ++++++++---
> >  1 file changed, 8 insertions(+), 3 deletions(-)
> > 
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -2753,9 +2753,14 @@ out_acl:
> >  	}
> >  #endif /* CONFIG_NFSD_PNFS */
> >  	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
> > -		status = nfsd4_encode_bitmap(xdr, NFSD_SUPPATTR_EXCLCREAT_WORD0,
> > -						  NFSD_SUPPATTR_EXCLCREAT_WORD1,
> > -						  NFSD_SUPPATTR_EXCLCREAT_WORD2);
> > +		u32 supp[3];
> > +
> > +		memcpy(supp, nfsd_suppattrs[minorversion], sizeof(supp));
> > +		supp[0] &= NFSD_SUPPATTR_EXCLCREAT_WORD0;
> > +		supp[1] &= NFSD_SUPPATTR_EXCLCREAT_WORD1;
> > +		supp[2] &= NFSD_SUPPATTR_EXCLCREAT_WORD2;
> > +
> > +		status = nfsd4_encode_bitmap(xdr, supp[0], supp[1], supp[2]);
> >  		if (status)
> >  			goto out;
> >  	}
> > 
> > 
> > Patches currently in stable-queue which might be from trond.myklebust@primarydata.com are
> > 
> > queue-4.4/nfsd-fix-up-the-supattr_exclcreat-attributes.patch
