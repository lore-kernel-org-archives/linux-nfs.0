From: Juergen Sauer <jojo@automatix.de>
Subject: XFS NFS Fileserver, kernel: nfs: server server not responding, still trying
Date: Fri, 7 Nov 2003 17:36:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311071736.09000.jojo@automatix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AI9sH-0002G7-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Nov 2003 08:54:17 -0800
Received: from 237.230.131.213.rev.inetbone.net ([213.131.230.237] helo=mail.automatix.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AI9sH-0004MS-4E
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 08:54:17 -0800
Received: from uucp by mail.automatix.de with local-bsmtp (Exim 3.35 #1)
	id 1AI9sG-0004q0-00
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 17:54:16 +0100
Received: from pc2.s.automatix.de ([192.168.11.12] ident=jojo)
	by s.automatix.de with esmtp (Exim 3.36 #1)
	id 1AI9an-00072A-00
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 17:36:13 +0100
To: nfs@lists.sourceforge.net
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi List !

Since upgrading to Kernel 2.4.22-xfs (direct from SGI-CVS) I get this
problems, during bigger file NFS-copying (local XFS ->=20
remote NFS-based filesserver (also completely in XFS).

Nov 7 17:20:02 pc2 kernel: nfs: server server not responding, still trying
Nov  7 17:20:02 pc2 kernel: nfs: server server not responding, still trying
Nov  7 17:20:02 pc2 kernel: nfs: server server OK

This is my Test-Setup:
server: 64GB XFS-fs on ICP-Vortex (Hardware Raid5) SCSI controller

I tried everything, mentioned on the NFS FAQ Page to avoid this problems.
http://nfs.sourceforge.net/nfs-howto/performance.html#TIMEOUT

jojo@pc2:jojo $ ssh root@localhost
Linux pc2 2.4.22-xfs #2 Don Okt 23 17:01:40 CEST 2003 i686 unknown
root@pc2:root# nfsstat
[...]
Client rpc stats:
calls      retrans    authrefrsh
1483912    21137      0
[...]

root@pc2:root# echo 262144 > /proc/sys/net/core/rmem_default
root@pc2:root# echo 262144 > /proc/sys/net/core/rmem_max
root@pc2:root# mount /home  -o remount,timeo=3D14,retrans=3D6
Copy Try -> Same Problem

root@pc2:root# mount /home  -o remount,timeo=3D30,retrans=3D12
root@pc2:root# mount /home  -o remount,timeo=3D30,retrans=3D12,rsize=3D3276=
8,wsize=3D32768

root@pc2:jojo# nfsstat
=2E..
Client rpc stats:
calls      retrans    authrefrsh
1752966    23343      0
=2E..

root@pc2:jojo# mount /home  -o remount,timeo=3D30,retrans=3D12,rsize=3D3276=
8,wsize=3D32768,nfsvers=3D3
root@pc2:jojo# mount
server:/home on /home type nfs (rw,lock,timeo=3D30,retrans=3D12,rsize=3D327=
68,wsize=3D32768,nfsvers=3D3,addr=3D192.168.11.1)
Copy Try -> Same Problem

This Kernel 2.4.22-xfs is in case of NFS performance the worst since 2.4.7 =
and reiserfs or the userspace
nfs daemon.

How can we stop the problem ?
Any ideas ?

TIA !

mfG
	J=FCrgen
	automatiX Linux  Support Crew
=2D --=20
J=FCrgen Sauer - AutomatiX GmbH, +49-4209-4699, jojo@automatix.de **
** Das Linux Systemhaus - Service - Support - Server - L=F6sungen **
** http://www.automatix.de                    ICQ: #344389676   **
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/q8n4W7UKI9EqarERAvA7AKC2Jy4x5aYF1/VbuDqh8gYxDqhvCQCfczpg
xbNgxw8+W9OJJ+7R6NKveAQ=3D
=3D9uNz
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
