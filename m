From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: slow NFS performance extracting bits from large files
Date: Mon, 16 Dec 2002 12:30:02 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.21.0212161146420.5571-100000@dirac.phys.uwm.edu>
References: <Pine.LNX.4.30.0212161206240.7322-100000@bandit.sdrc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from uwm.edu ([129.89.7.2] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O00Y-0001M8-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 10:30:26 -0800
To: Paul Haas <paulh@iware.com>, paulh@hamjudo.com, nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.30.0212161206240.7322-100000@bandit.sdrc.com>
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

Hi Paul,

Thanks for the quick reply.

> > I am working on a scientific data analysis application which needs to
> > extract a little bit of data from around 10,000 files.  The files
> > themselves are each around 1 MB in size. The application does:
> >
> > for (i=0; i<10000; i++){
> >   open() ith file
> >   read() 32 bytes from beginning
> >   lseek() to somewhere in the middle of the file
> >   read() 620 bytes from the middle of the file
> >   close() ith file
> > }
> 
> So that's 20,000 reads.  Readahead wouldn't help much with this access
> pattern, so it looks like 20,000 reads and 20,000 seeks.
 
> > If I run this with the data set on a local disk, the total run time is
> > around 1 sec -- very reasonable since I am transferring around 6 MB of
> > data.
> 
> Ok, 20,000 seeks per second, shows an average seek time of 50
> microseconds.  You can't do that with a spinning disk.  You've discovered
> how well disk caching works.

Thank you very much. This is a reasonable (obvious!) explanation.  Let me
see if I undertand correctly.

I just looked up the specs for the local disk that I was using for the
comparison testing.  It averages around 600 512-byte sectors (300 kB) per
track, and 1ms average track to track seek time.  So (assuming little
fragmentation) a typical file is spread across 3 to 4 tracks of the disk.  
Thus, if I seek to a data set in the middle of a file, and assuming that
the files are "more or less" contiguous on the disk, a typical iteration
of the loop above starting from the first read, should involve:

read 32 bytes
seek to middle    (2 tracks) 2 msec
read 620 bytes
seek to next file (2 tracks) 2 msec

hence 4 msec/file x 10k files = 40 sec read time if the kernel disk cache
buffers are all dirty.  Does the estimate above look reasonable?

I'll do the experiment that you suggest, using wc to clear the cache
first, and see how this compares to what's above.

> > If I run this on an NFS-mounted disk the performance is 100 times worse.
> > Both client and server are stock RH 7.3.  Note that if I run it a second
> > time, when the data is presumably cached, it takes just a few seconds to
> > run.
> 
> 20000 seeks in 100 seconds, that's an average seek time of 5 ms.  That's
> possible on real hardware.

The files on the NFS server live on an ATA RAID array, made of 3-ware 7850
controller running in hardware RAID-5 with the data striped across 7 disks
(the 8th disk is a hot spare).  I think the stripe size is configured to
the maximum value, but I have forgotten what that is.  I have no idea what
the equivalent "seek time" on such a system is.

The client and the server are networked via gigabit ethernet, through a
Foundry Networks switch.  Neither the switch nor the client or server are
oversubscribed.

> > Is it obvious what needs to be changed/tuned to improve this performance?
> > Or if not, could someone suggest a tool and a strategy for tracing down
> > the cause of the poor performance?
> 
> Clear the cache in the system with the local disk and measure the
> performance.  You can clear the cache by reading files bigger than all of
> RAM.  I tend to use "wc *" in a directory with some large tar files.  wc
> kindly tells me how many bytes I've read, so I know if I've read enough.
> 
> With a clear cache you'll see local performance numbers that are closer to
> the NFS numbers.

OK, I'll try this.  In retrospect, it's obvious.

> What's the ping time?  The NFS performance should have a penalty of
> something like 3 network transactions per file, so your NFS times should
> be 30,000 packet round trips longer than the local case.  (maybe 4 network
> transactions per file if there is also a stat call, a network trace would
> show all the transactions).

There's no stat call -- I've used strace to verify that I am only doing
the operations described in my pseudo-code above.

open("/scratch/xavi/CAL_L1_Data//CAL_SFT.714299460", O_RDONLY) = 3
read(3, "\0\0\0\0\0\0\360?DX\223*\0\0\0\0\0\0\0\0\0\0N@\270\v\0"..., 32) =
32
lseek(3, 460776, SEEK_CUR)              = 460808
read(3, "\336\203z&\tM\216&/\342\227\244\307\333\352\245\233\27"...,
620) = 620
close(3)                                = 0
open("/scratch/xavi/CAL_L1_Data//CAL_SFT.714299520", O_RDONLY) = 3

There's no stat().  So I think it's 3 not 4.  Here are the ping times:

[ballen@medusa-slave123 ballen]$ ping storage1
PING storage1.medusa.phys.uwm.edu (129.89.201.244) from 129.89.200.133
: 56(84) bytes of data.
64 bytes from storage1.medusa.phys.uwm.edu (129.89.201.244): icmp_seq=1
ttl=255 time=0.197 ms
64 bytes from storage1.medusa.phys.uwm.edu (129.89.201.244): icmp_seq=2
ttl=255 time=0.264 ms
....
--- storage1.medusa.phys.uwm.edu ping statistics ---
26 packets transmitted, 26 received, 0% loss, time 25250ms
rtt min/avg/max/mdev = 0.156/0.230/0.499/0.063 ms

so 230 usec (average) x 30,000 = 7 seconds

OK, so if all is well, then if I run the code locally on the NFS server
itself (with disk cache buffers all dirty) it should take around 7
seconds less time than if I run it on an NFS client.

I'll check the numbers and report back.

Thanks again for the help.  I'd not thought carefully enough about what
the disk was really doing.  The point being that reading a contiguous 6 MB
file from the local disk only involves ~20 track-to-track seeks, which is
negligable in comparison with what I am doing.

Cheers,
	Bruce



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
