From: Bernd Schubert <bernd-schubert@web.de>
Subject: client: 2.6.7 client much slower than 2.4.26
Date: Thu, 1 Jul 2004 23:18:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407012318.18934.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_a+H5ACB/RGgQj5D";
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bg8wx-0007c0-17
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 14:18:31 -0700
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bg8ww-0006ve-CM
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 14:18:30 -0700
Received: from [80.140.1.156] (helo=bathl.lan.fli4l)
	by smtp06.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.101 #38)
	id 1Bg8wm-0008BS-00
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 23:18:20 +0200
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


--Boundary-02=_a+H5ACB/RGgQj5D
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I'm currently testing 2.6.7 on one of our clients and the nfs transfer is m=
uch=20
slower than when the same system is running 2.4.X

Well, the usual suggestion probably would be to run nfs over tcp now, but t=
cp=20
is already enabled (from /proc/mounts):

taylor:/worka /mnt/test nfs=20
rw,v3,rsize=3D32768,wsize=3D32768,hard,tcp,lock,addr=3Dtaylor 0 0

benchmarks:

copy a file to the server (2.6.7): ~ 3MB/s
copy a file to the server (2.4.26): ~ 9MB/s

copy a file from the server (2.6.7): ~ 3MB/s
copy a file from the server (2.4.26): ~ 11MB/s

The filesize was 300MB.


Here's the nfsstat output:

euklid:~# nfsstat
Client rpc stats:
calls      retrans    authrefrsh
385466     0          0
Client nfs v2:
null       getattr    setattr    root       lookup     readlink
0       0% 27475  66% 231     0% 0       0% 3963    9% 161     0%
read       wrcache    write      create     remove     rename
8303   20% 0       0% 560     1% 171     0% 198     0% 42      0%
link       symlink    mkdir      rmdir      readdir    fsstat
45      0% 0       0% 3       0% 3       0% 129     0% 2       0%

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 56851  16% 1047    0% 17711   5% 36670  10% 936     0%
read       write      create     mkdir      symlink    mknod
73640  21% 149802 43% 629     0% 86      0% 1       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
701     0% 105     0% 279     0% 36      0% 464     0% 1557    0%
fsstat     fsinfo     pathconf   commit
260     0% 18      0% 0       0% 3387    0%


I already tried to reduce rsize and wsize up to 1024, but this didn't chang=
e=20
anything.

This happens to two different servers, one server is running 2.6.7 and has=
=20
Gigabit connection to the switch. The other server is running 2.4.25 and on=
ly=20
has a 100MBit connection. All of our clients have 100MBit connections.

So I really thing this is a client problem. Well, the client is not the=20
fastest of our systems (PII 450), but with 2.4.X it has the usual speed. It=
s=20
also interesting top is showing that the rpciod is taking all cpu-time when=
=20
copying a file to the server.

Any ideas whats going on?

Thanks,
	Bernd

--Boundary-02=_a+H5ACB/RGgQj5D
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA5H+aC8BUnAF+ydYRAik5AJ9VU8s2+5a4hM0Di5cNVLhjLm5YWQCeM042
78zKqd1Rge2EBPRbfGmLV98=
=pxVw
-----END PGP SIGNATURE-----

--Boundary-02=_a+H5ACB/RGgQj5D--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
