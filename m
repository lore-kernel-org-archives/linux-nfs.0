From: "Patrice Seyed" <apseyed@bu.edu>
Subject: RE: ReasmFails increases / NFS performance on Linux Cluster
Date: Mon, 16 Aug 2004 17:05:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <005f01c483d4$b6fa9f40$6701a8c0@psyche1>
References: <Pine.LNX.4.58.0408160851520.24272@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwoiB-0005hY-NZ
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 14:08:11 -0700
Received: from acsn03.bu.edu ([128.197.159.63])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bwogh-0007io-Ga
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 14:08:11 -0700
To: "'Joshua Baker-LePain'" <jlb17@duke.edu>, <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.58.0408160851520.24272@chaos.egr.duke.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Joshua,

Hmmm...

I had read somewhere that when you have nfs daemons over 100 it can =
cause
throttled and hence slowdowns on the server. I did test with 128 daemons
today and at one point it appears things grinded to a complete halt ( I
couldn't get a login session through ssh at all). Still I had increased =
the
size of the dd writes from 4MB to 8MB, coming from each 134 node to the =
nfs
server simultaneously. With this change my nfsd looks like this:

th 128 1018239 4.510 8.650 6.110 7.290 2.280 4.040 6.360 6.460 20.590
1467.200=20

In the tldp howto it indicates that the last 10 numbers of the th line =
is
the number of seconds the thread usage was at that percentage of maximum
allowable, and if you have large numbers in the top three deciles, =
increase
# of nfsd.=20

I was unaware of the interpretation of the second number, thanks.

Patrice

-----Original Message-----
From: Joshua Baker-LePain [mailto:jlb17@duke.edu]=20
Sent: Monday, August 16, 2004 8:54 AM
To: nfs@lists.sourceforge.net; Patrice Seyed
Subject: Re: [NFS] ReasmFails increases / NFS performance on Linux =
Cluster

>=20
> Message: 1
> From: "Patrice Seyed" <apseyed@bu.edu>
> To: <nfs@lists.sourceforge.net>
> Cc: "'Patrice Seyed'" <apseyed@bu.edu>
> Subject: RE: [NFS] ReasmFails increases / NFS performance on Linux =
Cluster
> Date: Sun, 15 Aug 2004 17:52:13 -0400
>=20
> Like I said I'm now running 64 nfs daemons, and the th line looks like =
=3D
> this
> now:
>=20
> th 64 2380739 168.120 128.860 68.350 261.730 184.990 121.680 145.930 =
=3D
> 122.090
> 178.390 1749.090

You don't have enough threads.  That 2nd number (after the number of=20
threads) should be as close to zero as possible -- that's the number of=20
times all threads have been busy when a request came in.  IIRC, you have =

plenty of memory on the server -- crank up the number of threads and you =

should see some difference.

--=20
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
