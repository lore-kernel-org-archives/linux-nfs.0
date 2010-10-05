Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moo.pl ([217.149.240.132]:55469 "EHLO moo.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755894Ab0JEV3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 17:29:19 -0400
Date: Tue, 5 Oct 2010 23:29:13 +0200
From: Leszek Urbanski <tygrys@moo.pl>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        virtualization@lists.linux-foundation.org
Subject: Re: BUG - qdev - partial loss of network connectivity
Message-ID: <20101005212913.GA27869@moo.pl>
References: <20100922171832.GA28721@moo.pl> <4C9A3FAF.9090503@codemonkey.ws> <20100922182049.GA29263@moo.pl> <4C9A4C77.2080806@codemonkey.ws> <20100923140437.GA9256@moo.pl> <20100926154324.GD21843@redhat.com> <20100927213203.GA28089@moo.pl>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20100927213203.GA28089@moo.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

<20100927213203.GA28089@moo.pl>; from Leszek Urbanski on Mon, Sep 27, 2010 at 23:32:03 +0200

> > > > >It's vanilla 2.6.32.22, but I also reproduced this on Debian's 2.6.32-23
> > > > >(based on 2.6.32.21).
> > > > >
> > > > >If offload is the only difference, I'll play with different offload
> > > > >options and check which one causes it.
> > > > >   
> > > > 
> > > > It's not technically the only difference but it's the most likely 
> > > > culprit IMHO.
> > > 
> > > udp fragmentation offload is definitely the culprit.
> > 
> > I see. Most likely guest bug - won't be the first bug around UFO.
> > If so pls copy netdev linux-nfs and virtualization.
> > Do you see anything in dmesg? Can try 2.6.36-rc5?
> 
> (for reference: first post is at:
> http://lists.nongnu.org/archive/html/qemu-devel/2010-09/msg01685.html )
> 
> I can't reproduce it on 2.6.36-rc5. Do you have an idea which patch may have

This one definitely fixes it: http://patchwork.ozlabs.org/patch/55643/

(Herbert Xu: udp: Fix bogus UFO packet generation)

The patch works with 2.6.32.24 too - it should probably be backported to
2.6.32.x.


-- 
Leszek "Tygrys" Urbanski, SCSA, SCNA
 "Unix-to-Unix Copy Program;" said PDP-1. "You will never find a more
  wretched hive of bugs and flamers. We must be cautious." -- DECWARS
     http://cygnus.moo.pl/ -- Cygnus High Altitude Balloon
