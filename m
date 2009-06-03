From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH]  bug in old-cache handling in mountd.
Date: Thu, 4 Jun 2009 08:45:38 +1000
Message-ID: <18982.64786.654330.415419@notabene.brown>
References: <18975.16159.264056.854413@notabene.brown>
	<4A26D2D8.5090200@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53737 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069AbZFCWpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 18:45:12 -0400
In-Reply-To: message from Steve Dickson on Wednesday June 3
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday June 3, SteveD@redhat.com wrote:
> 
> 
> Neil Brown wrote:
> > Hi,
> >  there is a bug in the old-cache behaviour of mountd.
> >  Hopefully no-one is using this but you never know....
> > 
> >  The bug was reported to redhat
> >     https://bugzilla.redhat.com/show_bug.cgi?id=164186
> > 
> >  It was fixed incorrectly and never (that I recall) reported
> >  upstream. :-(
> > 
> >  A SLES customer thinks they have hit the same problem, which is why
> >  I'm looking at it.  (They shouldn't really hit it because that
> >  version of sles uses 'new_cache' but maybe nfsdfs was disabled
> >  somehow - don't know yet).
> > 
> >  Anyway, when mountd gets a mount request, it tells the kernel about it
> >  and remembers that it told the kernel so it doesn't have to tell the
> >  kernel again.
> >  It is possible that "exportfs -r" will tell the kernel to forget that
> >  information if the client has since unmounted.
> >  So mountd really needs to tell the kernel even if it thinks the
> >  kernel should already know.
> > 
> >  The following patch does this if the kernel refuses to provide a
> >  valid filehandle.
> > 
> >  Does RHEL3 use old-cache or new-cache ??
> The new cache, if it exists...

That's what I would have thought... which leave me wondering how both
your customer and our customer hit the bug...  I must be missing
something important.

> 
> Committed..

Thanks.

NeilBrown
