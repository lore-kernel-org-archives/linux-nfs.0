From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: Re:slow NFS performance extracting bits from large files
Date: Tue, 17 Dec 2002 10:04:44 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C77AF@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <ballen@gravity.phys.uwm.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OKDh-0003Uj-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 08:05:21 -0800
To: <nfs@lists.sourceforge.net>
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




> Thank you very much. This is a reasonable (obvious!) explanation.  Let =
me
> see if I undertand correctly.
>=20
> I just looked up the specs for the local disk that I was using for the
> comparison testing.  It averages around 600 512-byte sectors (300 kB) =
per
> track, and 1ms average track to track seek time.  So (assuming little
> fragmentation) a typical file is spread across 3 to 4 tracks of the =
disk. =20
> Thus, if I seek to a data set in the middle of a file, and assuming =
that
> the files are "more or less" contiguous on the disk, a typical =
iteration
> of the loop above starting from the first read, should involve:
>=20
> read 32 bytes
> seek to middle    (2 tracks) 2 msec
> read 620 bytes
> seek to next file (2 tracks) 2 msec
>=20
> hence 4 msec/file x 10k files =3D 40 sec read time if the kernel disk =
cache
> buffers are all dirty.  Does the estimate above look reasonable?
>=20
> I'll do the experiment that you suggest, using wc to clear the cache
> first, and see how this compares to what's above.
>=20
	Track to track does not really count.  The average time per io is
	1/2 of the rotational latency.   If it is a 7200 rpm disk, it means
	that even once you get to the proper track it takes 1/2 * 60/7200 =
seconds
	for the proper data to come under the head on average.   The number
	for the above is 4.2ms and then you need to add in the track-to-track
	number to get 5.2ms or so per operation.   And probably you have a =
operation
	also to open each file.   And given that the filename entry data (name, =
and such) may
	not be close, it may not be a short quick seek, it may take longer.  =
Exactly
	how many seeks you have depends on exactly how the filesystem lays
	the data out on disk.

	So you have open, read32b, read620b, each taking 5.2ms or so, so a =
total
	of 15.6ms per file, times 10k files =3D 156 seconds, and that is in a =
perfect
	world.   You may also have a operation to update the file access time =
since
	you have read the file, and each of the seeks could require a read to =
figure
	out exactly where that block actually is on disk.  So there could be as
	many as 4 reads and a write going on on the far end.   And then on top
	of that you have the network latency of around a 1 ms or so to send
	the packets back and forth for each operation.   And my experience in
	the past has been that opens by themselves are pretty expensive, so
	there may be alot of operations going on in the background to make an
	open happen.  =20

> ttl=3D255 time=3D0.264 ms
> ....
> --- storage1.medusa.phys.uwm.edu ping statistics ---
> 26 packets transmitted, 26 received, 0% loss, time 25250ms
> rtt min/avg/max/mdev =3D 0.156/0.230/0.499/0.063 ms
>=20
> so 230 usec (average) x 30,000 =3D 7 seconds
>=20
> OK, so if all is well, then if I run the code locally on the NFS =
server
> itself (with disk cache buffers all dirty) it should take around 7
> seconds less time than if I run it on an NFS client.
>=20
> I'll check the numbers and report back.
>=20
>=20
	On the ping, you really need to ping for at least an hour or more, my
	experience is that if you are ping 1/second for an hour and you are
	losing 1 of 3600 pings (losing 1 ping per hour) it is very obvious to=20
	anything or anyone running that things are being affected, and this
	needs to be fixed.    A clean network will lose the pings at a rate
	of less than 1 of 3600.   And if you are losing 1 of 3600
	packets this will have ugly results on UDP nfs and even on
	other applications.

						Roger


> --__--__--
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
> End of NFS Digest


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
