From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Mon, 14 Oct 2002 21:01:44 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021014.210144.74732842.taka@valinux.co.jp>
References: <20020918.171431.24608688.taka@valinux.co.jp>
	<15786.23306.84580.323313@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: davem@redhat.com, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: neilb@cse.unsw.edu.au
In-Reply-To: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

Hello, Neil

> > I ported the zerocopy NFS patches against linux-2.5.36.
> 
> hi,
>  I finally got around to looking at this.
>  It looks good.

Thanks!

>  However it really needs the MSG_MORE support for udp_sendmsg to be
>  accepted before there is any point merging the rpc/nfsd bits.
> 
>  Would you like to see if davem is happy with that bit first and get
>  it in?  Then I will be happy to forward the nfsd specific bit.

Yes.

>  I'm bit I'm not very sure about is the 'shadowsock' patch for having
>  several xmit sockets, one per CPU.  What sort of speedup do you get
>  from this?  How important is it really?

It's not so important.

davem> Personally, it seems rather essential for scalability on SMP.

Yes.
It will be effective on large scale SMP machines as all kNFSd shares
one NFS port. A udp socket can't send data on each CPU at the same
time while MSG_MORE/UDP_CORK options are set.
The UDP socket have to block any other requests during making a UDP frame.


Thank you,
Hirokazu Takahashi.
