From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: persistent, quasi-random -ESTALE at mount time
Date: Sun, 6 Feb 2011 14:23:07 -0500
Message-ID: <20110206192307.GA14850@fieldses.org>
References: <20110203034844.GA30641@fieldses.org>
 <20110203042814.6364.qmail@science.horizon.com>
 <20110203044010.GC30641@fieldses.org>
 <87zkqdo6yv.fsf@spindle.srvr.nix>
 <20110203134035.GA18325@fieldses.org>
 <87sjw156yx.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: George Spelvin <linux@horizon.com>, linux-nfs@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43038 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753724Ab1BFTXK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Feb 2011 14:23:10 -0500
In-Reply-To: <87sjw156yx.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 06, 2011 at 06:54:46PM +0000, Nix wrote:
> On 3 Feb 2011, J. Bruce Fields uttered the following:
> > On Thu, Feb 03, 2011 at 08:30:48AM +0000, Nix wrote:
> >> I can give you a packet dump from my (completely reproducible) failure
> >> with the same symptoms, if you like. (Again, it is fixed by running
> >> exportfs repeatedly, each time fixing another few mounts: currently,
> >> I have to run it six times.)
> >
> > That would be great, thanks.  And could you collect the contents of
> > /proc/net/rpc/{nfsd.fh,nfsd.export}/content at the same time?  (I think
> > you already sent some; but I'd be curious to match them up with the
> > packet trace.)  Also, the output of "blkid" might help diagnose any
> > problems with uuid's.
> 
> I jinxed it. I just recompiled and the problem went away. The only
> differences between the old and new kernel are a so-far-entirely-
> unconfigured IPv6 setup (so nothing but link-local private addresses, no
> routing, nothing) and a new compiler (4.5.x rather than 4.4.x).
> 
> Which of these caused the change in behaviour I do not yet know, but
> will try to figure out (by turning IPv6 off again and seeing if
> the problem recurs).

OK, thanks.

--b.
