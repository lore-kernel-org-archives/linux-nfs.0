From: pwitting@Cyveillance.com
Subject: Re: RedHat 8.0 nfs
Date: Mon, 24 Mar 2003 13:42:59 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A94D5@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.69] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xWuj-0005J7-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Mar 2003 10:43:17 -0800
To: nfs@lists.sourceforge.net
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


>>Also, what would be a good number for NFS_QS? Both rmem.default and
>>rmem.max will be set to this number; should it be a multiple of threads?
>>Say something like smallest binary power (2^n) greater than 1500 (MTU
size) >>* $RPCNFSDCOUNT

> Again this dependent on how much memory you have...

I was reviewing this topic in "Red Hat Linux Security & Optimization", it
claims that each nfsd daemon will receive a queue of size NFS_QS, so I
assume the above concerns aren't relevant. (aside from memory concerns,
using 256kb * 200 threads/daemon = 50Mb for input queues :^)

As a side note, with the new RH scripts upping the queue size, and revamped
client mount scripts upping the rsize/wsize, thread utilization seems to be
way down and performance up

Th 120 5652 4721.126 892.199 136.818 25.683 5.923 2.136 1.755 1.833 1.689
3.267

In the past my 100% numbers would have spiked sharply upwards (And this is
with a recompiled official RedHat kernel, not the known faster 2.4.20
kernel). 'Course, its also with a new core system, running Dual 1.3Ghz cpu
instead of Dual 667Mhz; but the IO is pretty much the same, a FC attached
IBM ESS Shark. But I expect that the CPU's aren't a huge factor, since the
old system never went above about 60% utilization in a pure nfs mode. 

So all in all, life is good. Thanks for the help.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
