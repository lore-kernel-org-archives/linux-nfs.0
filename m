From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Mon, 14 Oct 2002 15:50:02 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
References: <20020918.171431.24608688.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <davem@redhat.com>)
	(for <linux-kernel@vger.kernel.org>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Mon, 14 Oct 2002 15:50:08 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Wednesday September 18
List-ID: <nfs.lists.sourceforge.net>

On Wednesday September 18, taka@valinux.co.jp wrote:
> Hello,
> 
> I ported the zerocopy NFS patches against linux-2.5.36.
> 

hi,
 I finally got around to looking at this.
 It looks good.

 However it really needs the MSG_MORE support for udp_sendmsg to be
 accepted before there is any point merging the rpc/nfsd bits.

 Would you like to see if davem is happy with that bit first and get
 it in?  Then I will be happy to forward the nfsd specific bit.

 I'm bit I'm not very sure about is the 'shadowsock' patch for having
 several xmit sockets, one per CPU.  What sort of speedup do you get
 from this?  How important is it really?

NeilBrown
