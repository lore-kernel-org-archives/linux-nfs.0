From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 16 Oct 2002 20:09:00 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021016.200900.128068491.taka@valinux.co.jp>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021014.210144.74732842.taka@valinux.co.jp>
	<15788.57476.858253.961941@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: davem@redhat.com, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: neilb@cse.unsw.edu.au
In-Reply-To: <15788.57476.858253.961941@notabene.cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

Hello,

> > It will be effective on large scale SMP machines as all kNFSd shares
> > one NFS port. A udp socket can't send data on each CPU at the same
> > time while MSG_MORE/UDP_CORK options are set.
> > The UDP socket have to block any other requests during making a UDP frame.
> > 

> After thinking about this some more, I suspect it would have to be
> quite large scale SMP to get much contention.

I have no idea how much contention will happen. I haven't checked the
performance of it on large scale SMP yet as I don't have such a great
machines.

Does anyone help us?

> The only contention on the udp socket is, as you say, assembling a udp
> frame, and it would be surprised if that takes a substantial faction
> of the time to handle a request.

After assembling a udp frame, kNFSd may drive a NIC to transmit the frame.

> Presumably on a sufficiently large SMP machine that this became an
> issue, there would be multiple NICs.  Maybe it would make sense to
> have one udp socket for each NIC.  Would that make sense? or work?

Some CPUs often share one GbE NIC today as a NIC can handle much data
than one CPU can. I think that CPU seems likely to become bottleneck.
Personally I guess several CPUs will share one 10GbE NIC in the near
future even if it's a high end machine. (It's just my guess)

But I don't know how effective this patch works......

devem> Doesn't make much sense.
devem> 
devem> Usually we are talking via one IP address, and thus over
devem> one device.  It could be using multiple NICs via BONDING,
devem> but that would be transparent to anything at the socket
devem> level.
devem> 
devem> Really, I think there is real value to making the socket
devem> per-cpu even on a 2 or 4 way system.

I wish so.
