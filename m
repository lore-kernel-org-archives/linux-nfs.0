From: Pascal =?iso-8859-1?q?Hav=E9?= <have@ann.jussieu.fr>
Subject: NFS client cannot read many data blocks
Date: Thu, 26 Feb 2004 16:39:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402261639.59669.have@ann.jussieu.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwNgH-0005MF-9d
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 07:44:09 -0800
Received: from shiva.jussieu.fr ([134.157.0.129])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwNQU-0000Ou-UX
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 07:27:51 -0800
Received: from emeu.ann.jussieu.fr (emeu.ann.jussieu.fr [134.157.2.1])
          by shiva.jussieu.fr (8.12.10/jtpda-5.4) with ESMTP id i1QFg4G3030710
          for <nfs@lists.sourceforge.net>; Thu, 26 Feb 2004 16:42:04 +0100 (CET)
Received: from patera.ann.jussieu.fr (patera.ann.jussieu.fr [134.157.2.51])
          by emeu.ann.jussieu.fr (8.11.6/jtpda-5.3.1) with ESMTP id i1QFg4c10450
          for <nfs@lists.sourceforge.net>; Thu, 26 Feb 2004 16:42:04 +0100
To: nfs@lists.sourceforge.net
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1


Hello,=20
Since I have change disk on server, I have a strange problem with some NFS=
=20
clients (config has been simply copied).

=46irst, I will describe my environment.
I have a NFS server which exports a /home partition (XFS) to ~20 clients.
The NFS server (P4 Xeon) runs a nfs-kernel-server 1.0.6-1 (Debian) with=20
RPCNFSDCOUNT=3D24. This kernel version is 2.6.3 with following options :
CONFIG_NFS_FS=3Dy
CONFIG_NFS_V3=3Dy
CONFIG_NFSD=3Dy
CONFIG_NFSD_V3=3Dy
CONFIG_LOCKD=3Dy
CONFIG_LOCKD_V4=3Dy
CONFIG_EXPORTFS=3Dy
CONFIG_SUNRPC=3Dy


There are 2 kinds of client.=20
A: 8 clients (P4 Xeon) with a 2.4.20 kernel
B: 12 clients (P3) with a 2.4.25 kernel
All of them have following kernel options
CONFIG_NFS_FS=3Dy
CONFIG_NFS_V3=3Dy
CONFIG_SUNRPC=3Dy
CONFIG_LOCKD=3Dy
CONFIG_LOCKD_V4=3Dy

Everything works on clients A, but on clients B=20
it is very strange. I can obtain stats of directories and sub-directories=20
(with 'ls -l', find, ...), read/write is OK for small files (few blocks=20
of 4096 octets) but for larger files, it seems to freeze connection.

If I use=20
echo 1 > /proc/sys/sunrpc/nfs_debug on clients and
echo 1 > /proc/sys/sunrpc/nfsd_debug on server

when I copy a small file 'b' (5 blocks) to local /tmp, I have=20
(/var/log/syslog)
=2D ---------%<---------------------------------------
=46eb 26 16:09:19 client kernel: NFS: refresh_inode(b/237372685 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:20 client kernel: NFS: refresh_inode(b/235142450 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:20 client kernel: NFS: dentry_delete(test/b, 0)
=46eb 26 16:09:22 client kernel: NFS: refresh_inode(b/237372685 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:25 client kernel: NFS: refresh_inode(b/235142450 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:32 client kernel: NFS: refresh_inode(b/235142450 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:32 client kernel: nfs: read(test/b, 4096@0)
=46eb 26 16:09:32 client kernel: nfs: read(test/b, 4096@4096)
=46eb 26 16:09:32 client kernel: nfs: read(test/b, 4096@8192)
=46eb 26 16:09:32 client kernel: nfs: read(test/b, 4096@12288)
=46eb 26 16:09:32 client kernel: nfs: read(test/b, 4096@16384)
=46eb 26 16:09:32 client kernel: nfs: read(test/b, 4096@20480)
=46eb 26 16:09:32 client kernel: nfs: flush(b/235142450)
=46eb 26 16:09:32 client kernel: NFS: dentry_delete(test/b, 0)
=46eb 26 16:09:32 client kernel: NFS: refresh_inode(b/237372685 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:32 client kernel: NFS: refresh_inode(b/235142450 ct=3D1=20
info=3D0x6)
=46eb 26 16:09:32 client kernel: NFS: dentry_delete(test/b, 0)
=2D --------------------->%-------------------------------------

And when copying a larger file 'c' (20 blocks) to local /tmp:
=2D ---------%<---------------------------------------
=46eb 26 16:16:34 client kernel: NFS: refresh_inode(7/237372685 ct=3D1=20
info=3D0x6)
=46eb 26 16:16:35 client kernel: NFS: refresh_inode(7/235142451 ct=3D1=20
info=3D0x6)
=46eb 26 16:16:35 client kernel: NFS: dentry_delete(test/c, 0)
=46eb 26 16:16:35 client kernel: NFS: refresh_inode(7/237372685 ct=3D1=20
info=3D0x6)
=46eb 26 16:16:35 client kernel: NFS: refresh_inode(7/235142451 ct=3D1=20
info=3D0x6)
=46eb 26 16:16:35 client kernel: NFS: refresh_inode(7/235142451 ct=3D1=20
info=3D0x6)
=46eb 26 16:16:35 client kernel: nfs: read(test/c, 4096@0)
=46eb 26 16:16:35 client kernel: NFS: refresh_inode(7/235142451 ct=3D1=20
info=3D0x6)
=46eb 26 16:16:35 client kernel: nfs: read(test/c, 4096@4096)
=46eb 26 16:16:35 client kernel: nfs: read(test/c, 4096@8192)
=46eb 26 16:16:35 client kernel: nfs: read(test/c, 4096@12288)
=46eb 26 16:16:35 client kernel: nfs: read(test/c, 4096@16384)
=46eb 26 16:16:52 client kernel: nfs: server hydre not responding, still=20
trying
=2D --------------------->%-------------------------------------
It seems that the problem always appears when it read(..., 4096@16384)

Then everything is frozen on this NFS mount point (read/write/stats)

Do you have an idea about what may be wrong (maybe in my configuration?)=20
since I have changed the server? (server and client configs are the=20
same).

Best regards,
=2D --=20
| Pascal Hav=E9
| Laboratoire Jacques-Louis Lions
| Universit=E9 Pierre et Marie Curie
| Boite courrier 187, 75252  Paris cedex 05 FRANCE
| (express mail) 175 rue du Chevaleret, 75013 Paris
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAPhNOmhLInsKdD4IRAjv7AJ90mmG6Yv9glGNww24KMgf/FFBzFACgw0Sb
OTw8DwA81qH18gpD8v6h97U=3D
=3D4jcI
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
