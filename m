From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: Performance tuning
Date: Wed, 10 Jul 2002 14:04:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D2CA166.CD962038@attbi.com>
References: <Pine.LNX.4.33.0207100905100.27879-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SOaM-0003Oj-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 14:01:18 -0700
To: David Dougall <davidd@et.byu.edu>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi -

I gleaned that tuning info from the SPECsfs and SPECweb99 
benchmarks, and documented it on the Mission Critical Linux
servers that are still kept on line:
http://www.missioncriticallinux.com/orph/ServerNotes.pdf

The latest howtos, which have been getting updated over the 
last few months, and are just about ready to go, contain an
updated discussion about [rw]mem_*, where I use the same examples,
but note that they apply to both read and write parameters.

As for limits, my paper notes much higher values than I was 
really willing to state in the howto.  Note that benchmarks are
often not real-world environments (I should probably remove the
"often" qualifier), so be sure to treat these suggestions with
a bit of skepticism.

I also corrected the fragmentation part to refer to all kernels.
The main thing to look for is MTU, plus the number of reassambly
failures noted as "reasmfails" in /proc/net/snmp, especially when
you start using 32K in udp (which is probably not the best idea).

Regards -

Tom


David Dougall wrote:
> 
> Looking through the nfs-howto chapter 5 "Optimizing NFS Performance", I
> found a few ambiguous statements and was wondering if I could get some
> clarification.
> There is a suggestion to increase rmem_default and rmem_max in
> /proc/sys/net/core to "at least 256k".  What is the limit on that?  If I
> have a server withs gobs of memory, how high can I increase that to still
> get performance improvements.  Are there some statistics I can use to
> measure if increases in this are helping.  Also, should I also increase
> wmem_default and wmem_max.  It makes no mention of that in the howto.
> 
> With respect to Overflow of fragmented packets, it mentions the 2.2
> kernel, but never mentions the 2.4.  Is it the same?  If so, it might be
> nice to clear that up in the howto.  It also states that there is no ideal
> value for this.  Any suggestions for specific traffic patterns?
> 
> Thanks
> --David Dougall
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Two, two, TWO treats in one.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
