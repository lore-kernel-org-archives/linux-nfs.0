From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 16 Oct 2002 13:44:04 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15788.57476.858253.961941@notabene.cse.unsw.edu.au>
References: <20020918.171431.24608688.taka@valinux.co.jp>
	<15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021014.210144.74732842.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <davem@redhat.com>)
	(for <linux-kernel@vger.kernel.org>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 16 Oct 2002 13:44:09 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Monday October 14
List-ID: <nfs.lists.sourceforge.net>

On Monday October 14, taka@valinux.co.jp wrote:
> >  I'm bit I'm not very sure about is the 'shadowsock' patch for having
> >  several xmit sockets, one per CPU.  What sort of speedup do you get
> >  from this?  How important is it really?
> 
> It's not so important.
> 
> davem> Personally, it seems rather essential for scalability on SMP.
> 
> Yes.
> It will be effective on large scale SMP machines as all kNFSd shares
> one NFS port. A udp socket can't send data on each CPU at the same
> time while MSG_MORE/UDP_CORK options are set.
> The UDP socket have to block any other requests during making a UDP frame.
> 

After thinking about this some more, I suspect it would have to be
quite large scale SMP to get much contention.
The only contention on the udp socket is, as you say, assembling a udp
frame, and it would be surprised if that takes a substantial faction
of the time to handle a request.

Presumably on a sufficiently large SMP machine that this became an
issue, there would be multiple NICs.  Maybe it would make sense to
have one udp socket for each NIC.  Would that make sense? or work?
It feels to me to be cleaner than one for each CPU.

NeilBrown
