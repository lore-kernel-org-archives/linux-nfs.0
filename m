From: "Amir Hermelin" <amir@montilio.com>
Subject: RE: remounting with a different blocksize
Date: Thu, 18 Sep 2003 09:19:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00d101c37db5$324ebf40$1301a8c0@CARTMAN>
References: <482A3FA0050D21419C269D13989C6113D06CAA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="windows-1255"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zs9A-00046d-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 23:20:08 -0700
Received: from enigma.barak.net.il ([212.150.48.99])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zs99-00083t-9S
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 23:20:07 -0700
To: "'Lever, Charles'" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113D06CAA@lavender-fe.eng.netapp.com>
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

I'm really only running a small and specific number of tests, one READ =
at a
time, files ranging from 8K to 256MB.  Is there any place I can read =
about
the reasons why my client (Linux 2.4) isn't using the blocksize I need?

Thanks,
Amir.



-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Lever, Charles
Sent: =E3 17 =F1=F4=E8=EE=E1=F8 2003 17:21
To: Amir Hermelin
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] remounting with a different blocksize


hi amir-

using "rsize=3D8192" means the client *can* use 8KB reads,
it doesn't mean that it *always* will.  there are a variety
of reasons the client might choose 4KB reads even though
it could send larger ones.

can you describe your workload?

> -----Original Message-----
> From: Amir Hermelin [mailto:amir@montilio.com]
> Sent: Wednesday, September 17, 2003 2:45 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] remounting with a different blocksize
>=20
>=20
> Hi,
> I'm using RH Linux 2.4.20 on both machines.  When I first
> mount one of the
> machines with a 4k read/write blocksize, the READ requests=20
> are 4K bytes.
> However, when I umount and then mount again with read/write=20
> blocksize of 8K,
> the READ requests are still 4K bytes.
>=20
> Any ideas on how I can properly change the blocksizes?
>=20
> Thanks,
> Amir.
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf _______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
