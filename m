From: David Dougall <davidd@et.byu.edu>
Subject: Re: RedHat 8.0 nfs
Date: Tue, 25 Mar 2003 15:50:21 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.51.0303251547190.3799@lewis.et.byu.edu>
References: <D38AFB3080F3D311807300B0D0203E53033A94D5@MERCURY>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from postal2.et.byu.edu ([128.187.122.132])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xxGA-0006OT-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 14:51:11 -0800
To: "pwitting@Cyveillance.com" <pwitting@cyveillance.com>
In-Reply-To: <D38AFB3080F3D311807300B0D0203E53033A94D5@MERCURY>
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

This doesn't agree with what I have heard before.  I was always told that
this memory amount( 256k default) was shared by all threads.  Therefore
the more threads you had, the more contention for memory, less each thread
had, etc.  You are now saying that each thread gets its own amount.
Which one is correct.  This drastically affects the number of threads and
the value that I assign in this parameter.
Anyone who authoritatively knows, please advise.
--David Dougall


On Mon, 24 Mar 2003, pwitting@Cyveillance.com wrote:

>
> >>Also, what would be a good number for NFS_QS? Both rmem.default and
> >>rmem.max will be set to this number; should it be a multiple of threads?
> >>Say something like smallest binary power (2^n) greater than 1500 (MTU
> size) >>* $RPCNFSDCOUNT
>
> > Again this dependent on how much memory you have...
>
> I was reviewing this topic in "Red Hat Linux Security & Optimization", it
> claims that each nfsd daemon will receive a queue of size NFS_QS, so I
> assume the above concerns aren't relevant. (aside from memory concerns,
> using 256kb * 200 threads/daemon = 50Mb for input queues :^)
>
> As a side note, with the new RH scripts upping the queue size, and revamped
> client mount scripts upping the rsize/wsize, thread utilization seems to be
> way down and performance up
>
> Th 120 5652 4721.126 892.199 136.818 25.683 5.923 2.136 1.755 1.833 1.689
> 3.267
>
> In the past my 100% numbers would have spiked sharply upwards (And this is
> with a recompiled official RedHat kernel, not the known faster 2.4.20
> kernel). 'Course, its also with a new core system, running Dual 1.3Ghz cpu
> instead of Dual 667Mhz; but the IO is pretty much the same, a FC attached
> IBM ESS Shark. But I expect that the CPU's aren't a huge factor, since the
> old system never went above about 60% utilization in a pure nfs mode.
>
> So all in all, life is good. Thanks for the help.
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>

______________________________________
Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
Queries to: postmaster@et.byu.edu


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
