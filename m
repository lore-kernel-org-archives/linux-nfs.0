From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re:slow NFS performance extracting bits from large files
Date: Tue, 17 Dec 2002 14:38:33 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.21.0212171429350.10375-100000@dirac.phys.uwm.edu>
References: <5CA6F03EF05E0046AC5594562398B9160C77AF@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from uwm.edu ([129.89.7.2] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OOUC-0003ff-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 12:38:41 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9160C77AF@POEXMB3.conoco.net>
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

Hi Roger,

> > the files are "more or less" contiguous on the disk, a typical iteration
> > of the loop above starting from the first read, should involve:
> > 
> > read 32 bytes
> > seek to middle    (2 tracks) 2 msec
> > read 620 bytes
> > seek to next file (2 tracks) 2 msec
> > 
> > hence 4 msec/file x 10k files = 40 sec read time if the kernel disk cache
> > buffers are all dirty.  Does the estimate above look reasonable?
> > 
> > I'll do the experiment that you suggest, using wc to clear the cache
> > first, and see how this compares to what's above.
> > 
> 	Track to track does not really count.  The average time per io is
> 	1/2 of the rotational latency.   If it is a 7200 rpm disk, it means
> 	that even once you get to the proper track it takes 1/2 * 60/7200 seconds
> 	for the proper data to come under the head on average.   The number
> 	for the above is 4.2ms and then you need to add in the track-to-track
> 	number to get 5.2ms or so per operation.

I realized this myself a few hours after I sent my email.  I completely
agree with the analysis.  It also explains why my measured times where
about four times longer than I had predicted.

So I completely agree with this. 


>       And probably you have a operation
> 	also to open each file.   And given that the filename entry data (name, and such) may
> 	not be close, it may not be a short quick seek, it may take longer.  Exactly
> 	how many seeks you have depends on exactly how the filesystem
>       lays
> 	the data out on disk.

It happens that all the files are in the same directory, and were created
at the same time during an otherwise quiescent period of operation.  So in
fact I think that the directory is probably read at the very start, and
then sits in cache after that.  If so, I think that the other operations
associated with the file access are probably all to/from cache.

> 	So you have open, read32b, read620b, each taking 5.2ms or so, so a total
> 	of 15.6ms per file, times 10k files = 156 seconds, and that is in a perfect
> 	world.   You may also have a operation to update the file access time since

It's within 10% of what I measure.  I think that the explanation is that
the directory info is all in cache. [I must say I find it quite satisfying
to be able to predict the code's performance this closely.]

> 	you have read the file, and each of the seeks could require a read to figure
> 	out exactly where that block actually is on disk.  So there could be as
> 	many as 4 reads and a write going on on the far end.   And then on top
> 	of that you have the network latency of around a 1 ms or so to send
> 	the packets back and forth for each operation.   And my experience in
> 	the past has been that opens by themselves are pretty expensive, so
> 	there may be alot of operations going on in the background to make an
> 	open happen.   

And indeed the additional time taken by the NFS-based accesses is also
very close to 30000*ping_time.

> > ttl=255 time=0.264 ms
> > ....
> > --- storage1.medusa.phys.uwm.edu ping statistics ---
> > 26 packets transmitted, 26 received, 0% loss, time 25250ms
> > rtt min/avg/max/mdev = 0.156/0.230/0.499/0.063 ms
> > 
> > so 230 usec (average) x 30,000 = 7 seconds
> > 
> > OK, so if all is well, then if I run the code locally on the NFS server
> > itself (with disk cache buffers all dirty) it should take around 7
> > seconds less time than if I run it on an NFS client.
> > 
> > I'll check the numbers and report back.
> > 
> > 
> 	On the ping, you really need to ping for at least an hour or more, my
> 	experience is that if you are ping 1/second for an hour and you are
> 	losing 1 of 3600 pings (losing 1 ping per hour) it is very obvious to 
> 	anything or anyone running that things are being affected, and this
> 	needs to be fixed.    A clean network will lose the pings at a rate
> 	of less than 1 of 3600.   And if you are losing 1 of 3600
> 	packets this will have ugly results on UDP nfs and even on
> 	other applications.

In our case, the network is completely under control.  I'm running on our
research group's beowulf cluster, so it's a private network -- the only
packets on it come from our own applications.  So again, I am highly
confident that at least while I am running the code, the round-trip ping
times I showed are reprsentative.

Thanks again for your comments.  I completely agree about the
time-per-read above being at least 1msec plus half a rotation period.

Cheers,
	Bruce Allen



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
