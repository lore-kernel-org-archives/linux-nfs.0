From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: remounting with a different blocksize
Date: Wed, 17 Sep 2003 08:20:51 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D06CAA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ze7T-0005nS-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 08:21:27 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19ze7T-0004Yb-EH
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 08:21:27 -0700
To: "Amir Hermelin" <amir@montilio.com>
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
> I'm using RH Linux 2.4.20 on both machines.  When I first=20
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
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
