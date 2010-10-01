Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188Ab0JARHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 13:07:48 -0400
Date: Fri, 1 Oct 2010 13:07:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pnfs-all-latest client crash
Message-ID: <20101001170733.GA30570@fieldses.org>
References: <20100921164211.GK26473@fieldses.org>
 <4C98FCC3.50803@panasas.com>
 <20100921190108.GA4385@fieldses.org>
 <4CA4ABED.7080706@panasas.com>
 <20100930152944.GA6598@fieldses.org>
 <4CA4ADFA.2090807@panasas.com>
 <20100930154350.GB6598@fieldses.org>
 <4CA4EA74.8070701@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA4EA74.8070701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 09:52:20PM +0200, Benny Halevy wrote:
> On 2010-09-30 17:43, J. Bruce Fields wrote:
> > On Thu, Sep 30, 2010 at 05:34:18PM +0200, Benny Halevy wrote:
> >> On 2010-09-30 17:29, J. Bruce Fields wrote:
> >>> On Thu, Sep 30, 2010 at 05:25:33PM +0200, Benny Halevy wrote:
> >>>> On 2010-09-21 21:01, J. Bruce Fields wrote:
> >>>>> On Tue, Sep 21, 2010 at 08:43:15PM +0200, Benny Halevy wrote:
> >>>>>> On 2010-09-21 18:42, J. Bruce Fields wrote:
> >>>>>>> I get the following on pnfs-all-latest, while doing a non-pnfs 4.1 mount.
> >>>>>>
> >>>>>> Bruce, can you please provide you .config file?
> >>>>>> >From the registers value it's possible the calldata is used
> >>>>>> after free...
> >>>>>
> >>>>> Yep.  I ran a 'make oldconfig' on the appended and built from that.
> >>>>>
> >>>>> We've seen poisoning in trond's latest for-next as well.  Which I don't
> >>>>> think you're including.  But I'll add linux-nfs to the cc for that.
> >>>>>
> >>>>> --b.
> >>>>>
> >>>>> #
> >>>>> # Automatically generated make config: don't edit
> >>>>> # Linux kernel version: 2.6.36-rc4
> >>>>> # Wed Sep 15 14:57:18 2010
> >>>>> #
> >>> ...
> >>>>> # CONFIG_INPUT_TABL
> >>>>
> >>>> Looks like the message got truncated :-(
> >>>
> >>> Huh.  Sorry about that!
> >>
> >> And I presume you config all pNFS options as 'N', right?
> > 
> > I'm just running make oldconfig over that.  Unless the pnfs patches are
> > defaulting those options to 'Y', then yes, that must be what it's
> > doing....
> > 
> > --b.
> 
> That's really odd.
> 
> with your .config and !CONFIG_PNFSD
> and with no modules configured
> though with modules enabled:
> CONFIG_MODULES=y
> # CONFIG_MODULE_FORCE_LOAD is not set
> CONFIG_MODULE_UNLOAD=y
> # CONFIG_MODULE_FORCE_UNLOAD is not set
> # CONFIG_MODVERSIONS is not set
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> 
> when turning on rpc debugging I see the server rejecting
> I believe the EXCHANGE_ID RPC on BADCRED:
> 
> svc: svc_authenticate (1)
> svc: authentication failed (1)
> 
> I see this also over NFSv4.0...

That's odd.

> Is this what you're seeing too?

I actually haven't seen either problem manifest itself on the latest
runs, and haven't had time to go back and look at the failure on the
earlier ones.

--b.
