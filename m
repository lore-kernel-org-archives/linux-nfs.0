From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: client: 2.6.7 client much slower than 2.4.26
Date: Fri, 2 Jul 2004 00:32:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407020032.28335.bernd-schubert@web.de>
References: <200407012318.18934.bernd-schubert@web.de> <1088718192.4349.91.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BgA6i-0003HJ-Vw
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 15:32:40 -0700
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BgA6h-0007bQ-Qq
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 15:32:40 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088718192.4349.91.camel@lade.trondhjem.org>
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

On Thursday 01 July 2004 23:43, you wrote:
> P=E5 to , 01/07/2004 klokka 17:18, skreiv Bernd Schubert:
> > benchmarks:
> >
> > copy a file to the server (2.6.7): ~ 3MB/s
> > copy a file to the server (2.4.26): ~ 9MB/s
> >
> > copy a file from the server (2.6.7): ~ 3MB/s
> > copy a file from the server (2.4.26): ~ 11MB/s
>
> Looks like the wire speeds on read/write are the same. How does the
> above compare to ttcp transfer speeds of a 300MB file?

Thanks, I didn't know about this tool and I think you are right, it seems t=
hat=20
the general network speed is much slower with 2.6.7:

2.4.26:
bernd@euklid bernd>nttcp -T taylor
     Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-=
C/s
l  8388608    0.70    0.06     95.2480   1118.4811    2048   2906.74   3413=
3.3
1  8388608    0.71    0.03     94.1283   2485.7897    5793   8125.38  21457=
9.4

2.6.7:
bernd@euklid bernd>nttcp -T taylor
     Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-=
C/s
l  8388608    2.67    2.64     25.1472     25.4046    2048    767.43     77=
5.3
1  8388608    2.67    0.03     25.1442   2237.3350    6145   2302.40  20486=
7.5

Its already too late, so I will do the 300MB test tomorrow, but I think the=
=20
numbers from the default 8MB test are already convincing.


> How much memory does this thing have? The main difference between 2.4.x

Somehow this system didn't like to have more than 2x128MB, when we added=20
another DIMM, the system crashed pretty often, though memtest86 showed no=20
problems.=20

> and 2.6.x is the fact that the 2.6.x caches a lot more data and for
> longer (the VM is what decides when to flush the cache).
> You might want to try twiddling around with the vm sysctl parameters to
> see if that makes a difference.
>

I will try to play with this over the weekend.


Thanks again a lot for your help!


Cheers,
	Bernd


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
