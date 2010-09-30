From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: pnfs-all-latest client crash
Date: Thu, 30 Sep 2010 09:28:08 -0400
Message-ID: <20100930132808.GC751@fieldses.org>
References: <20100921164211.GK26473@fieldses.org>
 <4C98FCC3.50803@panasas.com>
 <20100921190108.GA4385@fieldses.org>
 <20100928155117.GK24465@fieldses.org>
 <4CA35C9B.5050307@panasas.com>
 <20100930131520.GB751@fieldses.org>
 <4CA48F89.1050906@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab0I3N2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 09:28:20 -0400
In-Reply-To: <4CA48F89.1050906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 30, 2010 at 03:24:25PM +0200, Benny Halevy wrote:
> On 2010-09-30 15:15, J. Bruce Fields wrote:
> > On Wed, Sep 29, 2010 at 05:34:51PM +0200, Benny Halevy wrote:
> >> On 2010-09-28 17:51, J. Bruce Fields wrote:
> >>> On Tue, Sep 21, 2010 at 03:01:08PM -0400, J. Bruce Fields wrote:
> >>>> On Tue, Sep 21, 2010 at 08:43:15PM +0200, Benny Halevy wrote:
> >>>>> On 2010-09-21 18:42, J. Bruce Fields wrote:
> >>>>>> I get the following on pnfs-all-latest, while doing a non-pnfs 4.1 mount.
> >>>>>
> >>>>> Bruce, can you please provide you .config file?
> >>>>> >From the registers value it's possible the calldata is used
> >>>>> after free...
> >>>>
> >>>> Yep.  I ran a 'make oldconfig' on the appended and built from that.
> >>>>
> >>>> We've seen poisoning in trond's latest for-next as well.  Which I don't
> >>>> think you're including.  But I'll add linux-nfs to the cc for that.
> >>>
> >>> By the way, nightly tests on pnfs code havn't been running due to lack
> >>> of upstream writeback fixes:
> >>> 	b76b4014f9d988d2412b873e4d4c13c7f9afc4e4
> >>> and
> >>> 	6628bc74f1aa9c35dd386320bf7ec04f12edb1b3
> >>>
> >>> (both in -rc4, I believe).
> >>>
> >>> --b.
> >>
> >> OK, now that I've rebased onto -rc6 they should be there.
> > 
> > Thanks.  Looks like v4 is happier now, but v4.1 mounts fail with -EIO.
> > 
> > (That's on pnfs-all-latest; pnfs-submit is OK.)
> 
> what client and server?

Both pnfs-all-latest (b992647).

--b.
