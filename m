From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 16 Oct 2002 21:03:33 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <012d01c27581$677d2180$2a060e09@beavis>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au><20021014.210144.74732842.taka@valinux.co.jp><15788.57476.858253.961941@notabene.cse.unsw.edu.au> <20021015.213102.80213000.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <taka@valinux.co.jp>, <linux-kernel@vger.kernel.org>,
	<nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: <neilb@cse.unsw.edu.au>, "David S. Miller" <davem@redhat.com>
List-ID: <nfs.lists.sourceforge.net>

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


I am still seeing some sort of problem on an 8 way (hyperthreaded 8
logical/4 physical) on UDP with these patches.  I cannot get more than 2
NFSd threads in a run state at one time.  TCP usually has 8 or more.  The
test involves 40 100Mbit clients reading a 200 MB file on one server (4
acenic adapters) in cache.  I am fighting some other issues at the moment
(acpi wierdness), but so far before the patches, 82 MB/sec for NFSv2,UDP and
138 MB/sec for NFSv2,TCP.  With the patches, 115 MB/sec for NFSv2,UDP and
181 MB/sec for NFSv2,TCP.  One CPU is maxed due to acpi int storm, so I
think the results will get better.  I'm not sure what other lock or
contention point this is hitting on UDP.  If there is anything I can do to
help, please let me know, thanks.

Andrew Theurer
