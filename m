From: Cajus Pollmeier <c.pollmeier@gmx.net>
Subject: NFS problems, UMON, missing directories, wrong permissions
Date: Tue, 6 May 2003 10:41:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305061042.02405.c.pollmeier@gmx.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dns-2.dinet.de ([212.8.6.1] helo=mail-2.dinet.de)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Cy1W-00027d-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 01:42:06 -0700
Received: from ots-2 (carbon.gonicus.de [212.8.6.6])
	by mail-2.dinet.de (Postfix) with ESMTP id 598572CC009
	for <nfs@lists.sourceforge.net>; Tue,  6 May 2003 10:42:02 +0200 (CEST)
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

[Please cc me, I'm currently not subscribed]

Hi!

Sorry to bother you with this kind of stuff, but I currently have no idea w=
hat's going on here.

The facts:

* Fileserver
  Debian Woody,  Kernel 2.4.19 SMP using knfs and Debian nfs-utils,
  export is on partitions with xfs/ext3

  /etc/exports contains something like this:
  /export/home            10.1.0.0/255.255.0.0(rw,no_root_squash)

* Terminal Server(s)
  Debian Woody,  Kernel 2.4.19 SMP using knfs and Debian nfs-utils=20
  (seem to be 1.0)

  fstab tells to mount with these options:
  fileserver:/export/home /home nfs exec,nodev,nosuid,timeo=3D10,rw,hard,re=
trans=3D20,rsize=3D8192,wsize=3D8192 1 1

One terminal server keeps about 15 users, all accessing there home via nfs,=
 shared files via group
permissions inclusive.


The problem(s) (they are massive at all :-/)

* Randomly missing directories / shredded permissions
  Either users don't see shared directories contents or have no permissions=
 to access them. In
  fact they have, "id" shows up with the correct group membership and "ls -=
la" shows the directory
  group writable. After logging out and in again, everything's fine.

* Periodical error messages in system log
  Client:
  May  6 07:12:59 terminalserver kernel: lockd: nlm_lookup_host(0a010002, p=
=3D17, v=3D4)
  May  6 07:12:59 terminalserver kernel: lockd: host garbage collection
  May  6 07:12:59 terminalserver kernel: lockd: nlmsvc_mark_resources
  May  6 07:12:59 terminalserver kernel: lockd: delete host 10.1.0.2
  May  6 07:12:59 terminalserver kernel: lockd: nsm_unmonitor(10.1.0.2)
  May  6 07:12:59 terminalserver kernel: nsm: xdr_encode_mon(0a010002, -124=
9509120, 67108864, 268435456)
  May  6 07:12:59 terminalserver rpc.statd[1932]: Received erroneous SM_UNM=
ON request from terminalserver for 10.1.0.2
  May  6 07:12:59 terminalserver kernel: lockd: creating host entry
  May  6 07:12:59 terminalserver kernel: lockd: nlm_bind_host(0a010002)
  May  6 07:12:59 terminalserver kernel: lockd: nsm_monitor(10.1.0.2)
  May  6 07:12:59 terminalserver kernel: nsm: xdr_encode_mon(0a010002, -124=
9509120, 67108864, 268435456)
  May  6 07:12:59 terminalserver kernel: nsm: xdr_decode_stat_res status 0 =
state 79
  May  6 07:12:59 terminalserver kernel: lockd: nlm_bind_host(0a010002)
  May  6 07:12:59 terminalserver kernel: lockd: release host 10.1.0.2
  May  6 07:12:59 terminalserver kernel: lockd: get host 10.1.0.2
  May  6 07:12:59 terminalserver kernel: lockd: nlm_lookup_host(0a010002, p=
=3D17, v=3D4)
  May  6 07:12:59 terminalserver kernel: lockd: get host 10.1.0.2
  May  6 07:12:59 terminalserver kernel: lockd: nlm_bind_host(0a010002)
  May  6 07:12:59 terminalserver kernel: lockd: release host 10.1.0.2
  May  6 07:12:59 terminalserver kernel: lockd: release host 10.1.0.2
  May  6 07:13:00 terminalserver kernel: lockd: nlm_lookup_host(0a010002, p=
=3D17, v=3D4)
  May  6 07:13:00 terminalserver kernel: lockd: get host 10.1.0.2
  May  6 07:13:00 terminalserver kernel: lockd: nlm_bind_host(0a010002)
  ....

  Server:
  May  6 07:12:59 fileserver kernel: lockd: request from 0a010005
  May  6 07:12:59 fileserver kernel: lockd: nlm_lookup_host(0a010005, p=3D1=
7, v=3D4)
  May  6 07:12:59 fileserver kernel: lockd: creating host entry
  May  6 07:12:59 fileserver kernel: lockd: nsm_monitor(10.1.0.5)
  May  6 07:12:59 fileserver kernel: nsm: xdr_encode_mon(0a010005, -1249509=
120, 67108864, 268435456)
  May  6 07:12:59 fileserver kernel: nsm: xdr_decode_stat_res status 0 stat=
e 91121
  May  6 07:12:59 fileserver kernel: lockd: nlm_file_lookup(02000001 110008=
00 00020001 00324063 53324ecb 00324060)
  May  6 07:12:59 fileserver kernel: lockd: creating file for (02000001 110=
00800 00020001 00324063 53324ecb 00324060)
  May  6 07:12:59 fileserver kernel: lockd: found file e6c1e280 (count 0)
  May  6 07:12:59 fileserver kernel: lockd: nlmsvc_lock(0811/3293283, ty=3D=
0, pi=3D18885, 0-9223372036854775807, bl=3D1)
  May  6 07:12:59 fileserver kernel: lockd: nlmsvc_lookup_block f=3De6c1e28=
0 pd=3D18885 0-9223372036854775807 ty=3D0
  May  6 07:12:59 fileserver kernel: lockd: posix_lock_file returned 0
  May  6 07:12:59 fileserver kernel: lockd: release host 10.1.0.5
  May  6 07:12:59 fileserver kernel: lockd: nlm_release_file(e6c1e280, ct =
=3D 1)
  May  6 07:12:59 fileserver kernel: nlmsvc_retry_blocked(00000000, when=3D=
0)
  May  6 07:12:59 fileserver kernel: nlmsvc_retry_blocked(00000000, when=3D=
0)
  May  6 07:12:59 fileserver kernel: lockd: request from 0a010005
  May  6 07:12:59 fileserver kernel: lockd: nlm_lookup_host(0a010005, p=3D1=
7, v=3D4)
  May  6 07:12:59 fileserver kernel: lockd: get host 10.1.0.5
  May  6 07:12:59 fileserver kernel: lockd: nlm_file_lookup(02000001 110008=
00 00020001 00324063 53324ecb 00324060)
  May  6 07:12:59 fileserver kernel: lockd: found file e6c1e280 (count 0)
  May  6 07:12:59 fileserver kernel: lockd: nlmsvc_unlock(0811/3293283, pi=
=3D18885, 0-9223372036854775807)
  May  6 07:12:59 fileserver kernel: lockd: nlmsvc_cancel(0811/3293283, pi=
=3D18885, 0-9223372036854775807)
  May  6 07:12:59 fileserver kernel: lockd: nlmsvc_lookup_block f=3De6c1e28=
0 pd=3D18885 0-9223372036854775807 ty=3D2
  May  6 07:12:59 fileserver kernel: lockd: release host 10.1.0.5
  May  6 07:12:59 fileserver kernel: lockd: nlm_release_file(e6c1e280, ct =
=3D 1)
  May  6 07:12:59 fileserver kernel: lockd: closing file 08:11/3293283
  May  6 07:12:59 fileserver kernel: nlmsvc_retry_blocked(00000000, when=3D=
0)
  May  6 07:12:59 fileserver kernel: nlmsvc_retry_blocked(00000000, when=3D=
0)
  May  6 07:13:00 fileserver kernel: lockd: request from 0a010005
  May  6 07:13:00 fileserver kernel: lockd: nlm_lookup_host(0a010005, p=3D1=
7, v=3D4)
  May  6 07:13:00 fileserver kernel: lockd: get host 10.1.0.5

* state in /var/lib/nfs/sm
Server:
drwxr-xr-x    2 root     root         4096 May  6 07:30 .
drwxr-xr-x    4 root     root         4096 May  5 11:36 ..
=2D -rw-------    1 root     root            0 Apr 16 07:13 10.1.0.5   (whi=
ch is the terminalserver)

Client:
drwxr-xr-x    2 root     root         4096 16. Apr 07:13 .
drwxr-xr-x    4 root     root         4096 15. Apr 18:38 ..
=2D -rw-------    1 root     root            0 16. Apr 07:13 10.1.0.2  (whi=
ch is the fileserver)

This is no permission problem, since rpc.statd is running as root and there=
fore is able to
write here.


The solution:

Is missing. I'm willing to debug this even deeper, but my knowledge of nfs =
is limited. Are there any obvious
parameters I can tune? I've read many messages about failing UMON requests,=
 but there never was a solution.

Any help is greatly appreciated,
=2D -Cajus Pollmeier

=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t3VUtyibJ/7Y+CYRAvGNAKDRQF92MX47J98bjM2CT+KXm1HS9ACg1HJl
PdnHq2/pXlELNwEnk/0T3r4=3D
=3DnXpH
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
