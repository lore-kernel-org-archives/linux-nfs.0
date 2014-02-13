Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mlbefw2.harris.com ([192.52.233.80]:55226 "EHLO
	mlbefw2.harris.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbaBMMap convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Feb 2014 07:30:45 -0500
From: "McAninley, Jason" <jmcaninl@harris.com>
To: Malahal Naineni <malahal@us.ibm.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Question regard NFS 4.0 buffer sizes
Date: Thu, 13 Feb 2014 12:21:13 +0000
Message-ID: <322949BF788C8D468BEA0A321B79799098BDCA8E@MLBMXUS20.cs.myharris.net>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
 <20140211143633.GB9918@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
 <20140211163215.GA19599@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBE83@MLBMXUS20.cs.myharris.net>
 <20140211215441.GB22695@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDC011@MLBMXUS20.cs.myharris.net>
 <20140211231852.GA27855@us.ibm.com>
In-Reply-To: <20140211231852.GA27855@us.ibm.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay.

> This ends up caching and the write back should happen with larger
> sizes.
> Is this an issue with write size only or read size as well? Did you
> test
> read size something like below?
> 
> dd if=[nfs_dir]/foo bs=1M count=500 of=/dev/null
> 
> You can create sparse "foo" file using truncate command.

I have not tested read speeds yet since this is a bit trickier due to avoiding the client cache. I would suspect similar results since we have mirrored read/write settings in all locations (we're aware of).

 
> >
> > 
> > > Also, what kernel versions are you on?
> >
> > RH6.3, 2.6.32-279.el6.x86_64
> 
> NFS client and NFS server both using the same distro/kernel?

Yes - identical.


Would multipath play any role here? I would suspect it would only help, not hinder. I have run Wireshark against the slave and the master ports with the same result - a max of ~32K packet size, regardless of the settings I listed in my original post.

-Jason

