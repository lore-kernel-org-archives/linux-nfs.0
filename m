From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: RedHat 8.0 nfs
Date: Wed, 26 Mar 2003 10:53:52 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16000.60432.81570.583777@notabene.cse.unsw.edu.au>
References: <D38AFB3080F3D311807300B0D0203E53033A94D5@MERCURY>
	<Pine.LNX.4.51.0303251547190.3799@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "pwitting@Cyveillance.com" <pwitting@cyveillance.com>,
    "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xyFv-0006n3-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 15:54:59 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <davidd@et.byu.edu>) (for <pwitting@cyveillance.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 26 Mar 2003 10:54:17 +1100
To: David Dougall <davidd@et.byu.edu>
In-Reply-To: message from David Dougall on Tuesday March 25
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tuesday March 25, davidd@et.byu.edu wrote:
> This doesn't agree with what I have heard before.  I was always told that
> this memory amount( 256k default) was shared by all threads.  Therefore
> the more threads you had, the more contention for memory, less each thread
> had, etc.  You are now saying that each thread gets its own amount.
> Which one is correct.  This drastically affects the number of threads and
> the value that I assign in this parameter.
> Anyone who authoritatively knows, please advise.

Well.... I wrote some of the code, so hopefully I understand what is
going on, but don't bet on it :-)

Firstly, for kernels later than about 2.4.20-pre4, this setting is not
needed and is ignored.  The nfsd code does 'the right thing'.  
The setting is only needed for earlier kernels.

The amount of memory you assign when you write a number out to
 /proc/sys/net/core/rmem_default
is a per-socket (not per-thread) maximum.

The memory is *not* pre-allocated and is *not* guaranteed to be
available.

When a packet arrives on a socket, it sits on an 'input queue' until
it is taken off by some process.  The networking layer limits the
amount of memory that can be used by the input queue of any socket.
This number that is being changed is that limit.

The current nfsd code leaves UDP packets on the incoming queue while
processing them.  This means that we need this limit to be fairly
high: high enough that one request per thread does not block the queue
so atleast a few further requests can arrive.

With this number at the default (64k), I fairly often noticed incoming
requests being silently dropped because there wasn't enough buffer
space, even though there were plenty of idle threads.

I raised it to "average packet size * number of threads" and the
problem went away.  256K seems a reasonable sort of number.

This doesn't means that 256K *will* be using, but that (if it is
available) it *may* be used.  Certainly 256K * number-of-threads will
NOT be used.

Hope that helps.

NeilBrown


> --David Dougall
> 
> 
> On Mon, 24 Mar 2003, pwitting@Cyveillance.com wrote:
> 
> >
> > >>Also, what would be a good number for NFS_QS? Both rmem.default and
> > >>rmem.max will be set to this number; should it be a multiple of threads?
> > >>Say something like smallest binary power (2^n) greater than 1500 (MTU
> > size) >>* $RPCNFSDCOUNT
> >
> > > Again this dependent on how much memory you have...
> >
> > I was reviewing this topic in "Red Hat Linux Security & Optimization", it
> > claims that each nfsd daemon will receive a queue of size NFS_QS, so I
> > assume the above concerns aren't relevant. (aside from memory concerns,
> > using 256kb * 200 threads/daemon = 50Mb for input queues :^)
> >
> > As a side note, with the new RH scripts upping the queue size, and revamped
> > client mount scripts upping the rsize/wsize, thread utilization seems to be
> > way down and performance up
> >
> > Th 120 5652 4721.126 892.199 136.818 25.683 5.923 2.136 1.755 1.833 1.689
> > 3.267
> >
> > In the past my 100% numbers would have spiked sharply upwards (And this is
> > with a recompiled official RedHat kernel, not the known faster 2.4.20
> > kernel). 'Course, its also with a new core system, running Dual 1.3Ghz cpu
> > instead of Dual 667Mhz; but the IO is pretty much the same, a FC attached
> > IBM ESS Shark. But I expect that the CPU's aren't a huge factor, since the
> > old system never went above about 60% utilization in a pure nfs mode.
> >
> > So all in all, life is good. Thanks for the help.
> >
> >
> > -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
> 
> ______________________________________
> Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
> Queries to: postmaster@et.byu.edu
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by:
> The Definitive IT and Networking Event. Be There!
> NetWorld+Interop Las Vegas 2003 -- Register today!
> http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
