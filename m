From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: RedHat 8.0 nfs
Date: Thu, 27 Mar 2003 10:43:51 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16002.15159.815179.262920@notabene.cse.unsw.edu.au>
References: <D38AFB3080F3D311807300B0D0203E53033A94E5@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    davidd@et.byu.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yKZ8-0002g1-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Mar 2003 15:44:18 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <pwitting@cyveillance.com>) (for <nfs@lists.sourceforge.net>)
	(for <davidd@et.byu.edu>) By tone With Smtp ;
	Thu, 27 Mar 2003 10:44:06 +1100
To: pwitting@Cyveillance.com
In-Reply-To: message from pwitting@Cyveillance.com on Wednesday March 26
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

On Wednesday March 26, pwitting@Cyveillance.com wrote:
> From: Neil Brown <neilb@cse.unsw.edu.au>
> 
> > Well.... I wrote some of the code, so hopefully I understand what is
> > going on, but don't bet on it :-)
> > 
> > Firstly, for kernels later than about 2.4.20-pre4, this setting is not
> > needed and is ignored.  The nfsd code does 'the right thing'.
> > The setting is only needed for earlier kernels.
> 
> While this sounds great, what exactly is the right thing? Is the code itself
> adjusting the buffers to 256k? 512k? Or is it addressing the problem from a
> different angle? (Could be why I saw a 10-15% speed improvement going from
> RH's 2.4.18 kernel to a stock 2.4.20 kernel.)

Check the calls to "svc_sock_setbufsize" in net/sunrpc/svcsock.c

For UDP, rsize and wsize are (nr_threads+3) * bufsize
For TCP, rsize and wsize are 3 * bufsize

Bufsize is 8K, so you can work it out yourself.

Remember, all this is doing is allowing the networking layer to
allocate enough memory for all threads to working on something
concurrently.

> 
> Does this mean that altering the queue no longer has an effect?

Yes.  The setting no longer has any effect on nfsd.

> 
> > The amount of memory you assign when you write a number out to  
> > /proc/sys/net/core/rmem_default is a per-socket (not per-thread) maximum.
> 
> So is a socket an ip:port thing, or is it an srcip:srcport>dstip:dstport
> pair. 

For UDP, which is the only protocol supported in kernels where this
tuning has any effect, it is *:port.  An NFSd only listens on one
socket (no matter how many IP addresses you machine has).

> >
> > I raised it to "average packet size * number of threads" and the
> > problem went away.  256K seems a reasonable sort of number.
> 
> Which comes back to my original post, 
> 
> NFS_QS >= RPCNFSDCOUNT * MTU [ Currently 220 * 1500 = 330000, suggesting I
> should up my NFSQS from 262144 to 524288 ]
> 
> Or should I be thinking at a higher level of the network stack, 
> 
> NFS_QS >= RPCNFSDCOUNT * MAX(rsize,wsize) [ Currently 220 * 8192 = 1802240,
> suggesting I should up my NFSQS from 262144 to 2097152 ]
> 

Yes. MTU is not relevant.  We are talking about NFS requests, not ethernet
packets.  The largest NFS request is a full sized WRITE, which would
be slightly more than 8K.
To be sure that all your 220 threads can be processing a full sized
write concurrently (which is unlikely, as there tend to be a lot of
getattrs spread around) you would need about 1.8Meg.


> While it sounds like a huge number, were only talking about 2MB RAM on a
> machine more or less dedicated to NFS.  

Exactly.  If you're machine has 32Meg of ram, probably you don't need
220 threads.  But if you have 1Gig of RAM, then you won't notice 220
threads (or even more).

> 
> > This doesn't means that 256K *will* be using, but that (if it is
> > available) it *may* be used.  Certainly 256K * number-of-threads will
> > NOT be used.
> 
> Ah, which raises the question: When will it not be used? I assume we dump
> file cache to open these queues, would we swap stuff out of RAM into VM? Or
> do we only not get them when there's a real live RAM crunch?

That's all up to the VM subsystem.
The VM tries to keep some amount of free memory.  When a network
packet comes in, some of the free memory will be allocated to store
the packet.  If there is no free memory, the packet will be dropped,
but if there is no  free memory then the VM system is already trying
to dump file cache or write out to SWAP to make some free memory.

Also, most of the time your server will have maybe a dozen threads
active and they will be handling small (read/lookup/getatrr etc)
requests that don't take up so much memory.  It is just when lots of
write come in that you use the memory.  And when that happens, you
really want the memory to be used to hold the requests rather than
having the requests be silently dropped.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
