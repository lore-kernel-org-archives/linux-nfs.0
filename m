From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: Linux NFS rsize/wsize
Date: Thu, 19 Jun 2003 15:27:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <31B1521BD986E84E9D43651F8DF99BDC0134B41D@POEXMB1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman1.ppco.com ([138.32.33.10])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T60b-0005UP-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 13:27:49 -0700
To: "Dennis, Richard" <Richard.Dennis@lehman.com>, <nfs@lists.sourceforge.net>
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


MTU is separate from wsize/rsize, the network always breaks down
everything into MTU sized chunks, otherwise the packets won't
get there.

You probably have the data in cache on the read side so are not
seeing the actual packets coming from the solaris server, just the =
packets
verifing that the file has not changed.   I don't see any big packets on =
the=20
read side going anywhere, so it almost has to be in cache.  Notice
on the read side the biggest packet says "len 212", there are no
big packets of data, just overhead packets.


				Roger

> -----Original Message-----
> From:	Dennis, Richard [SMTP:Richard.Dennis@lehman.com]
> Sent:	Thursday, June 19, 2003 2:56 PM
> To:	nfs@lists.sourceforge.net
> Subject:	[NFS] Linux NFS rsize/wsize
>=20
> I've observed something in our Linux NFS environment that I don't
> understand, and I was hoping someone could help shed some light on =
this.
>=20
> From a Linux client, I have mounted a share from a Solaris 8 server.  =
It's
> mounted with the options: =
"rw,nosuid,hard,rsize=3D32768,wsize=3D32768,intr" on
> the Linux client, which defaults to UDP.
>=20
> I'm seeing that when I set the rsize and wsize to 32k, packets are =
read
> (coming from the Solaris server) in 32k packets, but when I write to =
this
> share, Linux frags the file according to my MTU.  Why would the =
Solaris
> server accept the rsize, but the linux client not accept the wsize?  =
(The
> Solaris server's MTU is also 1500.) =20
>=20
> Below are the beginnings of the tcpdumps as taken from the client.
>=20
> Thanks in advance. =20
> --Rick
>=20
> [root@client root]# tcpdump -s 1500 -vvv -r =
nfstest_32k_udp_read.out|more
>=20
> 16:01:31.260245 nfsclient.412459744 > nfsserver.nfs: 176 access fh
> 211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
> 16:01:31.260699 nfsclient.429236960 > nfsserver.nfs: 180 lookup fh
> 211,9000/1267050 "foo2" (DF) (ttl 64, id 0, len 208)
> 16:01:31.261119 nfsclient.446014176 > nfsserver.nfs: 176 access fh
> 211,9000/1253571 0001 (DF) (ttl 64, id 0, len 204)
> 16:01:31.261589 nfsclient.462791392 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000000000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.265868 nfsclient.479568608 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000008000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.265925 nfsclient.496345824 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000010000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.274669 nfsclient.513123040 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000018000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.274737 nfsclient.529900256 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000020000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.274784 nfsclient.546677472 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000028000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.283490 nfsclient.563454688 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000030000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.284079 nfsclient.580231904 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000038000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.284655 nfsclient.597009120 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000040000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.291038 nfsclient.613786336 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000048000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.291545 nfsclient.630563552 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000050000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.295064 nfsclient.647340768 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000058000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.297166 nfsclient.664117984 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000060000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.299847 nfsclient.680895200 > nfsserver.nfs: 184 read fh>=20
> 211,9000/1253571 32768 bytes @ 0x000068000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.302588 nfsclient.697672416 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000070000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.305327 nfsclient.714449632 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000078000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.308053 nfsclient.731226848 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000080000 (DF) (ttl 64, id 0, len =
212)
> 16:01:31.310805 nfsclient.748004064 > nfsserver.nfs: 184 read fh
> 211,9000/1253571 32768 bytes @ 0x000088000 (DF) (ttl 64, id 0, len =
212)
>=20
>=20
>=20
> [root@client root]# tcpdump -s 1500 -vvv -r =
nfstest_32k_udp_write.out|more
>=20
> 16:00:27.177895 nfsclient.3415450336 > nfsserver.nfs: 176 access fh
> 211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
> 16:00:27.178405 nfsclient.3432227552 > nfsserver.nfs: 176 access fh
> 211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
> 16:00:27.178827 nfsclient.3449004768 > nfsserver.nfs: 180 lookup fh
> 211,9000/1267050 "foo3" (DF) (ttl 64, id 0, len 208)
> 16:00:27.179221 nfsclient.3465781984 > nfsserver.nfs: 176 access fh
> 211,9000/1267050 001e (DF) (ttl 64, id 0, len 204)
> 16:00:27.179598 nfsclient.3482559200 > nfsserver.nfs: 212 create fh
> 211,9000/1267050 "foo3" (DF) (ttl 64, id 0, len 240)
> 16:00:27.182630 nfsclient.3499336416 > nfsserver.nfs: 176 access fh
> 211,9000/1266907 0000 (DF) (ttl 64, id 0, len 204)
> 16:00:27.185844 nfsclient.3516113632 > nfsserver.nfs: 1472 write fh
> 211,9000/1266907 32768 bytes @ 0x000000000 <unstable> (frag =
50541:1480@0+)
> (ttl 64, len 1500)
> 16:00:27.185864 nfsclient > nfsserver: (frag 50541:1480@1480+) (ttl =
64, len
> 1500)
> 16:00:27.185869 nfsclient > nfsserver: (frag 50541:1480@2960+) (ttl =
64, len
> 1500)
> 16:00:27.185875 nfsclient > nfsserver: (frag 50541:1480@4440+) (ttl =
64, len
> 1500)
> 16:00:27.185883 nfsclient > nfsserver: (frag 50541:1480@5920+) (ttl =
64, len
> 1500)
> 16:00:27.185891 nfsclient > nfsserver: (frag 50541:1480@7400+) (ttl =
64, len
> 1500)
> 16:00:27.185912 nfsclient > nfsserver: (frag 50541:1480@8880+) (ttl =
64, len
> 1500)
> 16:00:27.185918 nfsclient > nfsserver: (frag 50541:1480@10360+) (ttl =
64, len
> 1500)
> 16:00:27.185929 nfsclient > nfsserver: (frag 50541:1480@11840+) (ttl =
64, len
> 1500)
> 16:00:27.185934 nfsclient > nfsserver: (frag 50541:1480@13320+) (ttl =
64, len
> 1500)
> 16:00:27.185939 nfsclient > nfsserver: (frag 50541:1480@14800+) (ttl =
64, len
> 1500)
> 16:00:27.185945 nfsclient > nfsserver: (frag 50541:1480@16280+) (ttl =
64, len
> 1500)
> 16:00:27.185950 nfsclient > nfsserver: (frag 50541:1480@17760+) (ttl =
64, len
> 1500)
> 16:00:27.185956 nfsclient > nfsserver: (frag 50541:1480@19240+) (ttl =
64, len
> 1500)
> 16:00:27.185962 nfsclient > nfsserver: (frag 50541:1480@20720+) (ttl =
64, len
> 1500)
> 16:00:27.185968 nfsclient > nfsserver: (frag 50541:1480@22200+) (ttl =
64, len
> 1500)
> 16:00:27.185974 nfsclient > nfsserver: (frag 50541:1480@23680+) (ttl =
64, len
> 1500)
> 16:00:27.185980 nfsclient > nfsserver: (frag 50541:1480@25160+) (ttl =
64, len
> 1500)
> 16:00:27.185986 nfsclient > nfsserver: (frag 50541:1480@26640+) (ttl =
64, len
> 1500)
> 16:00:27.185992 nfsclient > nfsserver: (frag 50541:1480@28120+) (ttl =
64, len
> 1500)
> 16:00:27.185998 nfsclient > nfsserver: (frag 50541:1480@29600+) (ttl =
64, len
> 1500)
> 16:00:27.186006 nfsclient > nfsserver: (frag 50541:1480@31080+) (ttl =
64, len
> 1500)
> 16:00:27.186015 nfsclient > nfsserver: (frag 50541:408@32560) (ttl 64, =
len
> 428)
> 16:00:27.187272 nfsclient.3532890848 > nfsserver.nfs: 1472 write fh
> 211,9000/1266907 32768 bytes @ 0x000008000 <unstable> (frag =
50542:1480@0+)
> (ttl 64, len 1500)
> 16:00:27.187291 nfsclient > nfsserver: (frag 50542:1480@1480+) (ttl =
64, len
> 1500)
> 16:00:27.187296 nfsclient > nfsserver: (frag 50542:1480@2960+) (ttl =
64, len
> 1500)
> 16:00:27.187302 nfsclient > nfsserver: (frag 50542:1480@4440+) (ttl =
64, len>=20
> 1500)
> 16:00:27.187307 nfsclient > nfsserver: (frag 50542:1480@5920+) (ttl =
64, len
> 1500)
>=20
> =
-------------------------------------------------------------------------=
-----
> This message is intended only for the personal and confidential use of =
the
> designated recipient(s) named above.  If you are not the intended =
recipient of
> this message you are hereby notified that any review, dissemination,
> distribution or copying of this message is strictly prohibited.  This
> communication is for information purposes only and should not be =
regarded as
> an offer to sell or as a solicitation of an offer to buy any financial
> product, an official confirmation of any transaction, or as an =
official
> statement of Lehman Brothers.  Email transmission cannot be guaranteed =
to be
> secure or error-free.  Therefore, we do not represent that this =
information is
> complete or accurate and it should not be relied upon as such.  All
> information is subject to change without notice.
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting =
Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly =
Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
