From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client: 2.6.7 client much slower than 2.4.26
Date: Thu, 01 Jul 2004 17:43:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088718192.4349.91.camel@lade.trondhjem.org>
References: <200407012318.18934.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bg9Kt-0002ns-4l
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 14:43:15 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bg9Ks-0002in-PR
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 14:43:15 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407012318.18934.bernd-schubert@web.de>
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

P=E5 to , 01/07/2004 klokka 17:18, skreiv Bernd Schubert:

> benchmarks:
>=20
> copy a file to the server (2.6.7): ~ 3MB/s
> copy a file to the server (2.4.26): ~ 9MB/s
>=20
> copy a file from the server (2.6.7): ~ 3MB/s
> copy a file from the server (2.4.26): ~ 11MB/s

Looks like the wire speeds on read/write are the same. How does the
above compare to ttcp transfer speeds of a 300MB file?


> Here's the nfsstat output:

What's that for, 2.4.26 or 2.6.7? How does it compare?

> So I really thing this is a client problem. Well, the client is not the=20
> fastest of our systems (PII 450), but with 2.4.X it has the usual speed. =
Its=20
> also interesting top is showing that the rpciod is taking all cpu-time wh=
en=20
> copying a file to the server.

How much memory does this thing have? The main difference between 2.4.x
and 2.6.x is the fact that the 2.6.x caches a lot more data and for
longer (the VM is what decides when to flush the cache).
You might want to try twiddling around with the vm sysctl parameters to
see if that makes a difference.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
