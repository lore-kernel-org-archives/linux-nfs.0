Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mlbefw1.ngenready.com ([192.52.233.75]:63399 "EHLO
	mlbefw1.harris.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaBKWvG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 17:51:06 -0500
From: "McAninley, Jason" <jmcaninl@harris.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Question regard NFS 4.0 buffer sizes
Date: Tue, 11 Feb 2014 22:50:51 +0000
Message-ID: <322949BF788C8D468BEA0A321B79799098BDC011@MLBMXUS20.cs.myharris.net>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
 <20140211143633.GB9918@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
 <20140211163215.GA19599@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBE83@MLBMXUS20.cs.myharris.net>
 <20140211215441.GB22695@fieldses.org>
In-Reply-To: <20140211215441.GB22695@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > I have seen the GETATTR return MAXREAD and MAXWRITE attribute values
> set to 1MB during testing with Wireshark. My educated guess is that
> this corresponds to RPCSVC_MAXPAYLOAD defined in linux/nfsd/const.h.
> Would anyone agree with this?
> 
> That's an upper limit and a server without a lot of memory may default
> to something smaller.  The GETATTR shows that it isn't, though.

Memory shouldn't be a limit. I have the system isolated for testing - the server has ~126GB memory and the client has ~94GB.


> > > If you haven't already I'd first recommend measuring your NFS read
> > > and write throughput and comparing it to what you can get from the
> > > network and the server's disk.  No point tuning something if it
> > > turns out it's already working.
> >
> > I have measured sequential writes using dd with 4k block size.
> 
> What's your dd commandline?

dd if=/dev/zero of=[nfs_dir]/foo bs=4096 count=1310720

Should result in a 5 GB file.


> > The NFS
> > share maps to a large SSD drive on the server. My understanding is
> > that we have jumbo frames enabled (i.e. MTU 8k). The share is mounted
> > with rsize/wsize of 32k. We're seeing write speeds of 200 MB/sec
> > (mega-bytes). We have 10 GigE connections between the server and
> > client with a single switch + multipathing from the client.
> 
> So both network and disk should be able to do more than that, but it
> would still be worth testing both (with e.g. tcpperf and dd) just to
> make sure there's nothing wrong with either.
> 
> > I will admit I have a weak networking background, but it seems like
> we could achieve speeds much greater than 200 MB/sec, considering the
> pipes are very wide and the MTU is large. Again, I'm concerned there is
> a buffer somewhere in the Kernel that is flushing prematurely (32k,
> instead of wsize).
> >
> > If there is detailed documentation online that I have overlooked, I
> would much appreciate a pointer in that direction!
> 
> Also, what kernel versions are you on?

RH6.3, 2.6.32-279.el6.x86_64

-Jason

