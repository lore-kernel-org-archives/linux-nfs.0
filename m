From: Bernd Schubert <bernd-schubert@web.de>
Subject: [2.4.26] nfs client oops
Date: Sun, 18 Jul 2004 15:56:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407181556.56791.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-03=_oGo+A3NiEp7LAzN";
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


--Boundary-03=_oGo+A3NiEp7LAzN
Content-Type: multipart/mixed;
  boundary="Boundary-01=_iGo+Aaq7++AsRlR"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

--Boundary-01=_iGo+Aaq7++AsRlR
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: body text
Content-Disposition: inline

Hello,

we just got a nfs oops on one of our clients.
Here's the action that caused this oops:

1.) There was a link: $HOME: wa -> /worka

2.) A directory was moved with 'mv wa/dir /home'

2.) While the mv command was running, another command 'mv wa worka' was=20
entered on another shell, which caused the kernel oops.

Both the oops and the decoded oops are attached.

Cheers,
	Bernd


=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

--Boundary-01=_iGo+Aaq7++AsRlR
Content-Type: text/plain;
  charset="us-ascii";
  name="oops.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="oops.txt"

Unable to handle kernel paging request at virtual address 62c23370
 printing eip:
c018ed87
*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    1010:[<c018ed87>]    Tainted: PF
EFLAGS: 00210213
eax: 00000013   ebx: 652d6d63   ecx: 00000000   edx: 00000000
esi: 62c23370   edi: f518ff14   ebp: f518fee4   esp: f518fdb4
ds: 1018   es: 1018   ss: 1018
Process ls (pid: 1928, stackpage=3Df518f000)
Stack: f6a1db60 00000000 f518fdc8 f6a2c5c0 c01861e6 00000006 ffffff0a c018e=
d0d=20
       00001010 00000002 000041ed 00000079 00000001 000081a4 00000001 00000=
834=20
       000003e8 00000249 00000000 00001000 00000000 00000000 00002b02 00000=
000=20
Call Trace:    [<c01861e6>] [<c018ed0d>] [<c01824e9>] [<c0182060>] [<c01364=
af>]
  [<c0183b07>] [<c0183a19>] [<c0183738>] [<c0182346>] [<c018ecf0>] [<c014ec=
9c>]
  [<c0153293>] [<c0153920>] [<c0153a5a>] [<c0153920>] [<c0109f83>]

Code: 8b 06 89 4d 08 0f c8 89 45 0c 89 c3 8b 46 04 09 da 83 c6 08=20


--Boundary-01=_iGo+Aaq7++AsRlR
Content-Type: text/plain;
  charset="us-ascii";
  name="oops.decoded"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="oops.decoded"

ksymoops 2.4.9 on i686 2.4.26-tc2.  Options used
     -v /usr/src/System.maps/vmlinux__2.4.26-tc2 (specified)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.26-tc2/ (default)
     -m /usr/src/System.maps/System.map__2.4.26-tc2 (specified)

Unable to handle kernel paging request at virtual address 62c23370
c018ed87
*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    1010:[<c018ed87>]    Tainted: PF
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00210213
eax: 00000013   ebx: 652d6d63   ecx: 00000000   edx: 00000000
esi: 62c23370   edi: f518ff14   ebp: f518fee4   esp: f518fdb4
ds: 1018   es: 1018   ss: 1018
Process ls (pid: 1928, stackpage=3Df518f000)
Stack: f6a1db60 00000000 f518fdc8 f6a2c5c0 c01861e6 00000006 ffffff0a c018e=
d0d=20
       00001010 00000002 000041ed 00000079 00000001 000081a4 00000001 00000=
834=20
       000003e8 00000249 00000000 00001000 00000000 00000000 00002b02 00000=
000=20
Call Trace:    [<c01861e6>] [<c018ed0d>] [<c01824e9>] [<c0182060>] [<c01364=
af>]
  [<c0183b07>] [<c0183a19>] [<c0183738>] [<c0182346>] [<c018ecf0>] [<c014ec=
9c>]
  [<c0153293>] [<c0153920>] [<c0153a5a>] [<c0153920>] [<c0109f83>]
Code: 8b 06 89 4d 08 0f c8 89 45 0c 89 c3 8b 46 04 09 da 83 c6 08=20


>>EIP; c018ed87 <nfs3_decode_dirent+97/170>   <=3D=3D=3D=3D=3D

>>edi; f518ff14 <_end+34d52668/384ba7b4>
>>ebp; f518fee4 <_end+34d52638/384ba7b4>
>>esp; f518fdb4 <_end+34d52508/384ba7b4>

Trace; c01861e6 <__nfs_revalidate_inode+146/270>
Trace; c018ed0d <nfs3_decode_dirent+1d/170>
Trace; c01824e9 <nfs_lookup_revalidate+119/390>
Trace; c0182060 <nfs_readdir_filler+0/110>
Trace; c01364af <__read_cache_page+3f/b0>
Trace; c0183b07 <find_dirent+27/bb>
Trace; c0183a19 <find_dirent_page+99/160>
Trace; c0183738 <readdir_search_pagecache+18/70>
Trace; c0182346 <nfs_readdir+96/110>
Trace; c018ecf0 <nfs3_decode_dirent+0/170>
Trace; c014ec9c <link_path_walk+56c/6a0>
Trace; c0153293 <vfs_readdir+93/e0>
Trace; c0153920 <filldir64+0/f0>
Trace; c0153a5a <sys_getdents64+4a/a0>
Trace; c0153920 <filldir64+0/f0>
Trace; c0109f83 <system_call+33/40>

Code;  c018ed87 <nfs3_decode_dirent+97/170>
00000000 <_EIP>:
Code;  c018ed87 <nfs3_decode_dirent+97/170>   <=3D=3D=3D=3D=3D
   0:   8b 06                     mov    (%esi),%eax   <=3D=3D=3D=3D=3D
Code;  c018ed89 <nfs3_decode_dirent+99/170>
   2:   89 4d 08                  mov    %ecx,0x8(%ebp)
Code;  c018ed8c <nfs3_decode_dirent+9c/170>
   5:   0f c8                     bswap  %eax
Code;  c018ed8e <nfs3_decode_dirent+9e/170>
   7:   89 45 0c                  mov    %eax,0xc(%ebp)
Code;  c018ed91 <nfs3_decode_dirent+a1/170>
   a:   89 c3                     mov    %eax,%ebx
Code;  c018ed93 <nfs3_decode_dirent+a3/170>
   c:   8b 46 04                  mov    0x4(%esi),%eax
Code;  c018ed96 <nfs3_decode_dirent+a6/170>
   f:   09 da                     or     %ebx,%edx
Code;  c018ed98 <nfs3_decode_dirent+a8/170>
  11:   83 c6 08                  add    $0x8,%esi


--Boundary-01=_iGo+Aaq7++AsRlR--

--Boundary-03=_oGo+A3NiEp7LAzN
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA+oGoC8BUnAF+ydYRAs0bAKCam2IbpNKDwyiGEIhrdJqLbUlEQACeKApp
c7JlCFvExsYWuOItPoOcyi8=
=NQvr
-----END PGP SIGNATURE-----

--Boundary-03=_oGo+A3NiEp7LAzN--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
