From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: 2.4.19 NFSALL performance oddity
Date: Mon, 7 Oct 2002 16:27:40 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B91653BCAE@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yfPj-0002Sl-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 14:27:43 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


Update on the issue:

And given that I am using MS outlook, who knows
what this actual message will look like.

Original Test:
> 2.2.19 -> 2.4.19 no patches -> 6.5MB/second
> 2.4.19nfsall -> 2.4.19 no patches ->  2.00 MB/second
> 2.2.19 -> 2.4.19 nfsall patch -> 3.98MB/second
> 2.4.19nfsall -> 2.4.19 nfsall patch -> 2.32 MB/second
>=20
	All 2.4.19 kernels have at least 4GB himem enabled.
	The 2.4.19 kernels with nfsall have 64GB himem enabled.

	New tests:

	The write is a sequential write of a 2GB file,=20
	the read is a sequentail read of a 2GB file, the=20
	machines memory is just under 2GB, and it appears that
	the file is just large enough on the read test to make=20
	sure little or none of  the file is ever read straight=20
	from the cache.

	From the results, it looks like something in nfsall
	slows down both the client and the server.   The=20
	picture all of this data paints is rather unclear to me.
	If anyone sees any other test that would be possibly
	useful, suggest them.

	64GB/4GB/none does not appear to make a=20
	difference, for either the client or the server.   =20
	I did get some wide variations
	in some limited testing by adjusting the rmem/wmem
	and the number of nfsds, generally always slowing=20
	things down by a large amount, none of the numbers=20
	below are any of the especially slow cases.

	Tests with nohimem on NFSALL 2.4.19 server (32K blocks):
		nfsd=3D8, mem=3D65536, nohimem
			Client nohimem
				write: 2.312MB
				read: 8.938MB
			Client himem (64GB)
				write: 2.312MB
				read: 8.938MB=09

		nfsd=3D8, mem=3D262144, nohimem
			Client nohimem:=20
				write:  2.250MB
				read:   8.875MB
			Client himem (64GB)
				write: 2.312MB=20
				read:  8.812MB
	=09
	Tests with 4GB himem on nfsall 2.4.19 server (32k blocks)
			Client nohimem:
				write: 2.312MB
				read: 8.932MB
			Client 2.2.19:
				write: 4.50MB
				read:  8.812MB

	Tests with himem on NFSALL 2.4.19 server (8k blocks, different machine =
that 32k blocksize))
		nfsd=3D8, mem=3D65536, himem
			Client nohimem:
				write:	1.875MB
				read:	8.688MB
			Client himem (64GB)
				write:	1.875MB
				read:	8.625MB

	Tests with 4GB himem server, 2.4.19 server nohimem (8k blocks, =
different machine than other servers)
		nfsd=3D8, mem=3D65536
			Client nohimem, 2.4.19 nfsall
				write: 2.00 MB
				read:  2.00 MB
			Client 2.2.19:
				write:  6.5MB
				read:  10.0MB
			Client 2.4.19 no nfs patches, 64GB himem:
				write: not yet done
				read:

	Test with 2.2.19 server - these results seem to be unclear on their =
meaning:
			Client 2.4.19 64GB himem, nfsall:
				write: 3.875MB
				read:  4.875MB=09
			Client 2.2.19:
				write: 4.00 MB
				read: 8.188MB

> 				Roger


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
