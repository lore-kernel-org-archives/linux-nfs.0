From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 16 Oct 2002 07:04:44 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54F85@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: taka@valinux.co.jp, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, "'David S. Miller'" <davem@redhat.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: neilb@cse.unsw.edu.au
List-ID: <nfs.lists.sourceforge.net>

> -----Original Message-----
> From: David S. Miller [mailto:davem@redhat.com]
> Sent: Wednesday, October 16, 2002 12:31 AM
>
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

having a local socket per CPU is very good for SMP scaling.
it multiplies input buffer space, and reduces socket lock
and CPU cache contention.

sorry, i don't have measurements.
