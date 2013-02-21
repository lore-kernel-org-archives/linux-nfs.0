Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755202Ab3BUQjx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 11:39:53 -0500
Date: Thu, 21 Feb 2013 11:39:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: synchronous AF_LOCAL connect
Message-ID: <20130221163952.GD9743@fieldses.org>
References: <20130220154751.GH14606@fieldses.org>
 <2F275139-9861-4414-8C9F-BD74544C9AD7@oracle.com>
 <20130220160350.GJ14606@fieldses.org>
 <EA9EE56A-73BB-4866-AA86-1EE4150AFE87@oracle.com>
 <20130220163424.GK14606@fieldses.org>
 <FB21B277-FA7D-490C-B389-58A91C46B490@oracle.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235D7E49@SACEXCMBX04-PRD.hq.netapp.com>
 <1361381561.12328.441.camel@willson.li.ssimo.org>
 <20130220230337.GC3575@fieldses.org>
 <20130221162139.GB9743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130221162139.GB9743@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2013 at 11:21:39AM -0500, J. Bruce Fields wrote:
> On Wed, Feb 20, 2013 at 06:03:37PM -0500, J. Bruce Fields wrote:
> > OK, I've added that check and fixed some other bugs (thanks to Chuck for
> > some help in IRC).
> > 
> > I think that gets rpcbind working in containers fine.
> > 
> > gss-proxy has one more problem: it needs to do upcalls from nfsd threads
> > which won't have the right filesystem namespace.
> > 
> > I get a write from gss-proxy when it starts and can do an initial
> > connect then using its context.  But if we disconnect after that I'm
> > stuck.
> > 
> > Does it cause any problems if I just set the idle_timeout to 0 for
> > AF_LOCAL?
> 
> That gives me the following three patches.  They work for me.
> 
> Would it make more sense to make the idle timeout configurable?  I
> couldn't see why disconnecting idle AF_LOCAL rpcbind connections would
> be particularly important anyway.

Also posted a new version of the gss-proxy series including these
patches.

--b.
