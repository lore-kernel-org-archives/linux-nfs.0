From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 17 Oct 2002 11:31:26 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021017.113126.102592502.taka@valinux.co.jp>
References: <15788.57476.858253.961941@notabene.cse.unsw.edu.au>
	<20021015.213102.80213000.davem@redhat.com>
	<012d01c27581$677d2180$2a060e09@beavis>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, davem@redhat.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: habanero@us.ibm.com
In-Reply-To: <012d01c27581$677d2180$2a060e09@beavis>
List-ID: <nfs.lists.sourceforge.net>

Hello,

Thanks for testing my patches.

> I am still seeing some sort of problem on an 8 way (hyperthreaded 8
> logical/4 physical) on UDP with these patches.  I cannot get more than 2
> NFSd threads in a run state at one time.  TCP usually has 8 or more.  The
> test involves 40 100Mbit clients reading a 200 MB file on one server (4
> acenic adapters) in cache.  I am fighting some other issues at the moment
> (acpi wierdness), but so far before the patches, 82 MB/sec for NFSv2,UDP and
> 138 MB/sec for NFSv2,TCP.  With the patches, 115 MB/sec for NFSv2,UDP and
> 181 MB/sec for NFSv2,TCP.  One CPU is maxed due to acpi int storm, so I
> think the results will get better.  I'm not sure what other lock or
> contention point this is hitting on UDP.  If there is anything I can do to
> help, please let me know, thanks.

I guess some UDP packets might be lost. It may happen easily as UDP protocol
doesn't support flow control.
Can you check how many errors has happened? 
You can see them in /proc/net/snmp of the server and the clients.

And how many threads did you start on your machine?
Buffer size of a UDP socket depends on number of kNFS threads.
Large number of threads might help you.
