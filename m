Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34687 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbaBMSVv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Feb 2014 13:21:51 -0500
Date: Thu, 13 Feb 2014 13:21:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "McAninley, Jason" <jmcaninl@harris.com>
Cc: Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question regard NFS 4.0 buffer sizes
Message-ID: <20140213182148.GA20694@fieldses.org>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
 <20140211143633.GB9918@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
 <20140211163215.GA19599@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBE83@MLBMXUS20.cs.myharris.net>
 <20140211215441.GB22695@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDC011@MLBMXUS20.cs.myharris.net>
 <20140211231852.GA27855@us.ibm.com>
 <322949BF788C8D468BEA0A321B79799098BDCA8E@MLBMXUS20.cs.myharris.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <322949BF788C8D468BEA0A321B79799098BDCA8E@MLBMXUS20.cs.myharris.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 13, 2014 at 12:21:13PM +0000, McAninley, Jason wrote:
> Sorry for the delay.
> 
> > This ends up caching and the write back should happen with larger
> > sizes.
> > Is this an issue with write size only or read size as well? Did you
> > test
> > read size something like below?
> > 
> > dd if=[nfs_dir]/foo bs=1M count=500 of=/dev/null
> > 
> > You can create sparse "foo" file using truncate command.
> 
> I have not tested read speeds yet since this is a bit trickier due to avoiding the client cache. I would suspect similar results since we have mirrored read/write settings in all locations (we're aware of).
> 
>  
> > >
> > > 
> > > > Also, what kernel versions are you on?
> > >
> > > RH6.3, 2.6.32-279.el6.x86_64
> > 
> > NFS client and NFS server both using the same distro/kernel?
> 
> Yes - identical.
> 
> 
> Would multipath play any role here? I would suspect it would only help, not hinder. I have run Wireshark against the slave and the master ports with the same result - a max of ~32K packet size, regardless of the settings I listed in my original post.

I doubt it.  I don't know what's going there.

The write size might actually be too small to keep the necessary amount
of write data in flight; increasing tcp_slot_table_entries might work
around that?

Of course, since this is a Red Hat kernel that'd be a place to ask for
support unless the problem's also reproduceable on upstream kernels.

--b.
