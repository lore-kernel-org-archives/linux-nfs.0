From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Fri, 18 Oct 2002 16:19:52 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021018.161952.41628057.taka@valinux.co.jp>
References: <001301c275e6$f31d5970$2a060e09@beavis>
	<20021018.012618.74755132.taka@valinux.co.jp>
	<shs8z0w1f3k.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: habanero@us.ibm.com, neilb@cse.unsw.edu.au, davem@redhat.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: trond.myklebust@fys.uio.no
In-Reply-To: <shs8z0w1f3k.fsf@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

Hello,

>      > Congestion avoidance mechanism of NFS clients might cause this
>      > situation.  I think the congestion window size is not enough
>      > for high end machines.  You can make the window be larger as a
>      > test.
> 
> The congestion avoidance window is supposed to adapt to the bandwidth
> that is available. Turn congestion avoidance off if you like, but my
> experience is that doing so tends to seriously degrade performance as
> the number of timeouts + resends skyrockets.

Yes, you must be right.

But I guess Andrew may use a great machine so that the transfer rate
has exeeded the maximum size of the congestion avoidance window.
Can we determin preferable maximum window size dynamically?

Thank you,
Hirokazu Takahashi.
