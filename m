From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: 18 Oct 2002 07:38:23 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shs8z0w1f3k.fsf@charged.uio.no>
References: <003301c275e1$0bf76810$2a060e09@beavis>
	<20021017.222602.48536782.taka@valinux.co.jp>
	<001301c275e6$f31d5970$2a060e09@beavis>
	<20021018.012618.74755132.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@us.ibm.com, neilb@cse.unsw.edu.au, davem@redhat.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021018.012618.74755132.taka@valinux.co.jp>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Hirokazu Takahashi <taka@valinux.co.jp> writes:

     > Congestion avoidance mechanism of NFS clients might cause this
     > situation.  I think the congestion window size is not enough
     > for high end machines.  You can make the window be larger as a
     > test.

The congestion avoidance window is supposed to adapt to the bandwidth
that is available. Turn congestion avoidance off if you like, but my
experience is that doing so tends to seriously degrade performance as
the number of timeouts + resends skyrockets.

Cheers,
  Trond
