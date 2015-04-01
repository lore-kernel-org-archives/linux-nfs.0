Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbbDARuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2015 13:50:23 -0400
Date: Wed, 1 Apr 2015 13:50:21 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Cyril Brulebois <kibi@debian.org>
Subject: Re: [PATCH 1/2] nfs-utils: cross-reference nfsd.7 from nfsd.8 and
 vice versa
Message-ID: <20150401175021.GC3040@fieldses.org>
References: <1427876624-28066-1-git-send-email-hch@lst.de>
 <20150401082453.GA7000@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150401082453.GA7000@infradead.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2015 at 01:24:53AM -0700, Christoph Hellwig wrote:
> Ooops, forgot to add the intro mail - this is a resync of the man page
> updates in the Debian package with mainline nfs-utils.

both look good to me.--b.

> 
> On Wed, Apr 01, 2015 at 10:23:43AM +0200, Christoph Hellwig wrote:
> > From: Cyril Brulebois <kibi@debian.org>
> > 
> > It'd be nice if one could notice nfsd(7) when reading nfsd(8) and the
> > other way round, without having to have to resort to ???dpkg -L $pkg??? to
> > figure out what documentation is available.
> > ---
> >  utils/exportfs/nfsd.man | 1 +
> >  utils/nfsd/nfsd.man     | 1 +
> >  2 files changed, 2 insertions(+)
> > 
> > diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
> > index 47b73be..0c516fa 100644
> > --- a/utils/exportfs/nfsd.man
> > +++ b/utils/exportfs/nfsd.man
> > @@ -196,6 +196,7 @@ classes of tracing to be enabled.  Consult the kernel header files to
> >  find out what number correspond to what tracing.
> >  
> >  .SH SEE ALSO
> > +.BR nfsd (8),
> >  .BR rpc.nfsd (8),
> >  .BR exports (5),
> >  .BR nfsstat (8),
> > diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
> > index be21ed4..3ba847e 100644
> > --- a/utils/nfsd/nfsd.man
> > +++ b/utils/nfsd/nfsd.man
> > @@ -121,6 +121,7 @@ address family combinations that are marked visible in the
> >  database.
> >  
> >  .SH SEE ALSO
> > +.BR nfsd (7),
> >  .BR rpc.mountd (8),
> >  .BR exports (5),
> >  .BR exportfs (8),
> > -- 
> > 1.9.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> ---end quoted text---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
