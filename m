Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:46892 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbaBKXS4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 18:18:56 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 11 Feb 2014 16:18:56 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1EE8BC90042
	for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 18:18:51 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1BNIrPu5112064
	for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 23:18:53 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1BNIrXQ025634
	for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 18:18:53 -0500
Date: Tue, 11 Feb 2014 17:18:52 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "McAninley, Jason" <jmcaninl@harris.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question regard NFS 4.0 buffer sizes
Message-ID: <20140211231852.GA27855@us.ibm.com>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
 <20140211143633.GB9918@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
 <20140211163215.GA19599@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBE83@MLBMXUS20.cs.myharris.net>
 <20140211215441.GB22695@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDC011@MLBMXUS20.cs.myharris.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <322949BF788C8D468BEA0A321B79799098BDC011@MLBMXUS20.cs.myharris.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

McAninley, Jason [jmcaninl@harris.com] wrote:
> > > I have seen the GETATTR return MAXREAD and MAXWRITE attribute values
> > set to 1MB during testing with Wireshark. My educated guess is that
> > this corresponds to RPCSVC_MAXPAYLOAD defined in linux/nfsd/const.h.
> > Would anyone agree with this?
> > 
> > That's an upper limit and a server without a lot of memory may default
> > to something smaller.  The GETATTR shows that it isn't, though.
> 
> Memory shouldn't be a limit. I have the system isolated for testing - the server has ~126GB memory and the client has ~94GB.
> 
> 
> > > > If you haven't already I'd first recommend measuring your NFS read
> > > > and write throughput and comparing it to what you can get from the
> > > > network and the server's disk.  No point tuning something if it
> > > > turns out it's already working.
> > >
> > > I have measured sequential writes using dd with 4k block size.
> > 
> > What's your dd commandline?
> 
> dd if=/dev/zero of=[nfs_dir]/foo bs=4096 count=1310720

This ends up caching and the write back should happen with larger sizes.
Is this an issue with write size only or read size as well? Did you test
read size something like below?

dd if=[nfs_dir]/foo bs=1M count=500 of=/dev/null

You can create sparse "foo" file using truncate command.

> 
> Should result in a 5 GB file.
> 
> 
> > > The NFS
> > > share maps to a large SSD drive on the server. My understanding is
> > > that we have jumbo frames enabled (i.e. MTU 8k). The share is mounted
> > > with rsize/wsize of 32k. We're seeing write speeds of 200 MB/sec
> > > (mega-bytes). We have 10 GigE connections between the server and
> > > client with a single switch + multipathing from the client.
> > 
> > So both network and disk should be able to do more than that, but it
> > would still be worth testing both (with e.g. tcpperf and dd) just to
> > make sure there's nothing wrong with either.
> > 
> > > I will admit I have a weak networking background, but it seems like
> > we could achieve speeds much greater than 200 MB/sec, considering the
> > pipes are very wide and the MTU is large. Again, I'm concerned there is
> > a buffer somewhere in the Kernel that is flushing prematurely (32k,
> > instead of wsize).
> > >
> > > If there is detailed documentation online that I have overlooked, I
> > would much appreciate a pointer in that direction!
> > 
> > Also, what kernel versions are you on?
> 
> RH6.3, 2.6.32-279.el6.x86_64

NFS client and NFS server both using the same distro/kernel?

Regards, Malahal.

