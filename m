From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: NFS related crash?
Date: Tue, 27 Jul 2004 13:40:46 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1090960846.3475.264.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-f33tREjtjjf2S9Xs2j8x"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpYkk-0002sN-2Y
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 13:40:50 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BpYkj-0002rN-NI
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 13:40:50 -0700
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


--=-f33tREjtjjf2S9Xs2j8x
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


We have an RHEL 3 NFS server (cpu AMD Opteron(tm) Processor 240), that
is apparently consistently crashing when I try to extract a large .zip
file (a solaris 8 .iso) from a Fedora Core 2 client with these mount
options:

type nfs (rw,nosuid,intr,hard,timeo=3D20,rsize=3D8192,wsize=3D8192

...and this was in nfsstat:

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
496158     244        11         233        0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
12     100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
=20
Server nfs v3:
null       getattr    setattr    lookup     access     readlink
29      0% 463983 93% 428     0% 4494    0% 2902    0% 4       0%
read       write      create     mkdir      symlink    mknod
4153    0% 16956   3% 508     0% 4       0% 8       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
969     0% 4       0% 173     0% 88      0% 8       0% 419     0%
fsstat     fsinfo     pathconf   commit
43      0% 4       0% 1       0% 944     0%
=20
Client rpc stats:
calls      retrans    authrefrsh
8343       20         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 4716   56% 0       0% 1523   18% 1247   14% 32      0%
read       write      create     mkdir      symlink    mknod
417     4% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 394     4%
fsstat     fsinfo     pathconf   commit
12      0% 2       0% 0       0% 0       0%



There was nothing useful in the logs after the crash.

We haven't yet investigated RHEL's network-based crashdump facility.=20
Would that be helpful?

The server hardware is pretty new, and we had to return it to the vendor
once, because it kept crashing while we copied our homedirs onto its
disk.

Does this sound more like a software problem or a hardware problem?=20
Anyone seen anything like this?  Anyone have any suggestions for
resolving the issue?

--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-f33tREjtjjf2S9Xs2j8x
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQBBBr3Oo0feVm00f/8RArsWAKCMQ51nSoUQI1MOjM/WPAg5n10wFACfchN9
9neTFXd5pVVWwzJm/gnI0b8=
=Lv/U
-----END PGP SIGNATURE-----

--=-f33tREjtjjf2S9Xs2j8x--



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
