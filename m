From: pwitting@Cyveillance.com
Subject: Re: RedHat 8.0 nfs
Date: Wed, 26 Mar 2003 13:34:38 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A94E5@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Cc: neilb@cse.unsw.edu.au, davidd@et.byu.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.69] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yFjp-0007oa-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Mar 2003 10:35:01 -0800
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

From: Neil Brown <neilb@cse.unsw.edu.au>

> Well.... I wrote some of the code, so hopefully I understand what is
> going on, but don't bet on it :-)
> 
> Firstly, for kernels later than about 2.4.20-pre4, this setting is not
> needed and is ignored.  The nfsd code does 'the right thing'.
> The setting is only needed for earlier kernels.

While this sounds great, what exactly is the right thing? Is the code itself
adjusting the buffers to 256k? 512k? Or is it addressing the problem from a
different angle? (Could be why I saw a 10-15% speed improvement going from
RH's 2.4.18 kernel to a stock 2.4.20 kernel.)

Does this mean that altering the queue no longer has an effect?

> The amount of memory you assign when you write a number out to  
> /proc/sys/net/core/rmem_default is a per-socket (not per-thread) maximum.

So is a socket an ip:port thing, or is it an srcip:srcport>dstip:dstport
pair. 

> The memory is *not* pre-allocated and is *not* guaranteed to be
> available.

Hence no easy test for how much memory is consumed, though it makes me feel
better about cranking the queue size up another notch.
 
> The current nfsd code leaves UDP packets on the incoming queue while
> processing them.  This means that we need this limit to be fairly
> high: high enough that one request per thread does not block the queue
> so atleast a few further requests can arrive.
> 
> With this number at the default (64k), I fairly often noticed incoming
> requests being silently dropped because there wasn't enough buffer
> space, even though there were plenty of idle threads.
>
> I raised it to "average packet size * number of threads" and the
> problem went away.  256K seems a reasonable sort of number.

Which comes back to my original post, 

NFS_QS >= RPCNFSDCOUNT * MTU [ Currently 220 * 1500 = 330000, suggesting I
should up my NFSQS from 262144 to 524288 ]

Or should I be thinking at a higher level of the network stack, 

NFS_QS >= RPCNFSDCOUNT * MAX(rsize,wsize) [ Currently 220 * 8192 = 1802240,
suggesting I should up my NFSQS from 262144 to 2097152 ]

While it sounds like a huge number, were only talking about 2MB RAM on a
machine more or less dedicated to NFS.  

> This doesn't means that 256K *will* be using, but that (if it is
> available) it *may* be used.  Certainly 256K * number-of-threads will
> NOT be used.

Ah, which raises the question: When will it not be used? I assume we dump
file cache to open these queues, would we swap stuff out of RAM into VM? Or
do we only not get them when there's a real live RAM crunch?

Sorry to be a pain, but I'm very interested in getting the performance of my
NFS servers close to the performance of their disk subsystems so I can
convince the developers to stop running code on them. Last night my backup
copied a 59.53GB file in 7304 sec, by my math that's a rate of 8150.51KB/s
or 65.2kbps, fairly close to the peak I should see from Full Duplex
Ethernet. A quick test of my disk subsystem:

# SECONDS=0; dd if=/dev/zero of=./Zero.tmp bs=1024 count=25000000; echo
$SECONDS
25000000+0 records in
25000000+0 records out
2254

says I can write files at about 11,091 KB/s, so I'm not that far off.


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
