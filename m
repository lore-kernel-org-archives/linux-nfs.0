From: Garrick Staples <garrick@usc.edu>
Subject: stat'ing >4TB NFS filesystems
Date: Thu, 15 Jul 2004 12:21:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040715192125.GZ22659@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vRacM696f6w3EQmW"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BlBo7-0007qs-Um
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 12:22:15 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BlBo7-0001xe-M9
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 12:22:15 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i6FJLPSX022384
	for <nfs@lists.sourceforge.net>; Thu, 15 Jul 2004 12:21:25 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i6FJLPuA022382
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 12:21:25 -0700
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


--vRacM696f6w3EQmW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,
   I have some RHE3 machines (2.4.21) here that can't properly stat a 5GB f=
ilesystem,
but some RH7.2 machines with (vanilla 2.4.26) can stat it fine.  I searched=
 for
the lkml looking for NFS patches since 2.4.21 but couldn't find anything.
Can anyone here point me to the right patch?


On RHE3 (rcf-104 is about 5.3TB):
df -k...
rcf-fs2:/export/home/rcf-104
                     1075438752 -9223372036280871432 1595639072 101%
/auto/rcf-104
hpc-fs3:/export/home/hpc-20
                     4342331984 1270896448 3071435536  30% /auto/hpc-20

$ stat -f /auto/rcf-104
  File: "/auto/rcf-104"
    ID: 0        Namelen: 255     Type: nfs
Blocks: Total: 2150877504 Free: 3295674688 Available: 3188266576 Size: 512
Inodes: Total: 6246144    Free: 6233949  =20
(note: the "Size" is wrong too, it should be 32768)

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--vRacM696f6w3EQmW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA9tk10SBUxJbm9HMRAozqAKC6nTgOtlxh3KjoJ+2+MmDmdE6FEgCdHlsn
TxT0MWgn+vJ2CafwhSOrYlw=
=B1JV
-----END PGP SIGNATURE-----

--vRacM696f6w3EQmW--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
