From: Andrew Theurer <habanero@us.ibm.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 16 Oct 2002 10:04:27 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200210161004.27314.habanero@us.ibm.com>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au> <15788.57476.858253.961941@notabene.cse.unsw.edu.au> <20021015.213102.80213000.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: taka@valinux.co.jp, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>, neilb@cse.unsw.edu.au
In-Reply-To: <20021015.213102.80213000.davem@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

On Tuesday 15 October 2002 11:31 pm, David S. Miller wrote:
>    From: Neil Brown <neilb@cse.unsw.edu.au>
>    Date: Wed, 16 Oct 2002 13:44:04 +1000
>
>    Presumably on a sufficiently large SMP machine that this became an
>    issue, there would be multiple NICs.  Maybe it would make sense to
>    have one udp socket for each NIC.  Would that make sense? or work?
>    It feels to me to be cleaner than one for each CPU.
>
> Doesn't make much sense.
>
> Usually we are talking via one IP address, and thus over
> one device.  It could be using multiple NICs via BONDING,
> but that would be transparent to anything at the socket
> level.
>
> Really, I think there is real value to making the socket
> per-cpu even on a 2 or 4 way system.

I am trying my best today to get a 4 way system up and running for this test.  
IMO, per cpu is best..  with just one socket, I seriously could not get over 
33% cpu utilization on a 4 way (back in April).  With TCP, I could max it 
out.  I'll update later today hopefully with some promising results.

-Andrew
