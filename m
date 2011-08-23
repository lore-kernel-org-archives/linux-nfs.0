Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34654 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873Ab1HWTse (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Aug 2011 15:48:34 -0400
Date: Tue, 23 Aug 2011 15:48:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: Problems with kerberos auth - possibly against ADS - since
 nfs-utils-1.2.3
Message-ID: <20110823194831.GA24935@fieldses.org>
References: <20110804092141.3461c9ce@notabene.brown>
 <CAKnQG+cs4SLD-YmLwpnXU_gDWrjfmx9+z-E=7J-SUcsP=KhfSg@mail.gmail.com>
 <20110804111357.0d0a6e85@notabene.brown>
 <CAKnQG+dViSmrjhZV1cFZHj98kM0ixyKRLek9OWkJjFUS6YO3cw@mail.gmail.com>
 <20110811154239.322dee1d@notabene.brown>
 <CAKnQG+eV_OCk60wN6E2ub-TxA+6NoALYn8C+1PD51fWUZTpcGQ@mail.gmail.com>
 <20110818191906.13a6261f@notabene.brown>
 <20110818164307.GA24533@fieldses.org>
 <20110823101614.7b597933@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110823101614.7b597933@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 23, 2011 at 10:16:14AM +1000, NeilBrown wrote:
> On Thu, 18 Aug 2011 12:43:07 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, Aug 18, 2011 at 07:19:06PM +1000, NeilBrown wrote:
> > > I think that does exactly describes what we were seeing.
> > > We ended up working around it by adding 
> > > 
> > >   default_tkt_enctypes = des-cbc-md5 des-cbc-crc des3-cbc-sha1
> > > 
> > > to the client config, and recommending a server upgrade.
> > > 
> > > 
> > > BTW I've been trying to track down why a successful kerberos negotiation
> > > sends a corrupted RPCSEC_GSS_DESTROY request just before closing the
> > > connection.
> > 
> > (No useful comment here, just: thanks!  That was driving me crazy, till
> > it just stopped happening for no apparent reason, before I got a chance
> > to look any closer...)
> 
> It stopped happening?  You mean it is already fix?  Have I been look at old
> code AGAIN ??

I just assumed it was intermittent.

And, OK, all I noticed was that my tests started working again--I didn't
look to see if the bogus DESTROY's were still being sent.  They may have
been unrelated to whatever test failure I was seeing at the time!

--b.
