From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS Performance issues
Date: Wed, 11 May 2005 10:25:09 -0700
Message-ID: <1115832309.1498.33.camel@seki.nac.uci.edu>
References: <BEA6E6AA.11AD0%jblock@mrsc.ucsf.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XGdoEjRDhIPuyNVlEj0P"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVuxN-0005Kl-00
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 10:25:13 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DVuxM-0004Jg-Cp
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 10:25:12 -0700
To: Jeff Block <jblock@mrsc.ucsf.edu>
In-Reply-To: <BEA6E6AA.11AD0%jblock@mrsc.ucsf.edu>
Sender: nfs-admin@lists.sourceforge.net
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


--=-XGdoEjRDhIPuyNVlEj0P
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


You might try upgrading to RHEL 4, or other linux with a 2.6.x kernel.

If you're on a gigabit network, you might try turning on jumbo frames.

NFS is known to have a lot of "back and forth", relative to other
protocols.  For bulk transfers, you're far better off with something
like ftp, ssh, rsync - even on a system with pretty good NFS
performance...  NFS is there for convenience, more than large data
transfers,IMO.

You might try firing up a sniffer against the NFS traffic, comparing
linux->linux, linux->solaris, solaris->linux, solaris->solaris.  If one
pairing has a lot more retries than others, then you know to look for a
network problem.

You might try UDP if you're using TCP now, or TCP if you're using UDP
now.  Theoretically, TCP should be better for long-haul transfers (lots
of router hops), and UDP should be better for local transfers through a
small (or even nil) number of routers.  But we may be surprised.  :)

If you're getting lots of retries, a smaller blocksize may actually
speed things up.  (But check for network problems first)

You might try benchmarking the same data -locally-, without any network
involved, to see to what extent your RAID situation is contributing to
the slowdown you're seeing.

FUSE might be an interesting thing to try...  To ditch NFS.  :)  I've
never installed a FUSE-based filesystem though, let alone benchmarked
one though.

Some vendor or other, is expected to be releasing some sort of NFS proxy
(which I believe probably functions a bit like "NX", of NoMachine fame -
IE, includes protocol-specific smarts to cache suitable chunks of data
on either side of the transmissions, and uses a hash table indexed by
cryptographic hashes to see if something similar was already transferred
recently, in which case the data can be simply pulled from a cache),
which should reduce the "back and forthing" of NFS significantly, and
hence give much better NFS performance.  Unfortunately, the guy who
mentioned this was under an NDA, so I don't know the name of the
vendor.  :(

HTH.

On Tue, 2005-05-10 at 22:31 -0700, Jeff Block wrote:
> We seem to be having some major performance problems on our redhat
> enterprise linux 3 boxes.  Some of our machines have RAIDs attached, some
> have internal SCSI drives, and some have internal IDE drives.   The one
> thing all the boxes have in common is that there solaris counterparts are
> putting them to shame in the nfs performance battle.
>=20
> Here's some of the info and what we've already tried.
> /etc/exports is simple:
> /export/data    @all-hosts(rw,sync)
>=20
> The automounter is used so the default mount options are used, looks like
> this:
> server:/export/data /data/mountpoint nfs
> rw,v3,rsize=3D8192,wsize=3D8192,hard,udp,lock,addr=3Dserver 0 0
>=20
> We can't change the rsize and wsize on these mounts because the precompil=
ed
> redhat kernel for vers3 maxes out at 8K.  We could of course compile our =
own
> kernel, but doing this for more than a handful of machines can be a big
> headache. =20
>=20
> We've tried moving the journaling from RAID devices onto another internal
> disk.  This helped a little, but not much.
>=20
> We have tried async, and that certainly does speed things up, but we are
> definitely not comfortable with using async.
>=20
> The big problem that we are having seems to do with copying a bunch of da=
ta
> from one machine to another.
>=20
> We have 683MB of test data that we were playing with that represents the
> file sizes that our users play with.  There are several small files in th=
is
> set so there is a lot of writes and commits.  Our users generally work wi=
th
> data sets in the multiple gigabyte range.
>      =20
> Test data - 683 MB=20
> NFS Testing:
> Client | Server | Storage | NFS cp Time | SCP Time
> Solaris | Solaris | RAID | 1:32 | 1:59
> Linux A | Solaris | RAID | 0:42 | 2:51
> Linux A | Linux B | RAID5 /Journal to SCSI | 3:17 | 2:05
> Linux A | Linux B | RAID5 /Journal to RAID | 5:07 | 1:45
> Linux A | Linux B | SCSI | 3:17 | 1:52
> Linux A | Linux B | IDE | 1:36 | 2:27
>       =20
> Other Tests     =20
>       =20
> Internal Tests:   =20
> Host/Storage | Host/Storage | cp Time
> Linux B Int. SCSI | Linux B Ext. RAID5 | 0:37
> Sol Int. SCSI | Sol Ext. RAID5 | 0:35
>       =20
> Network:     =20
> Host A | Host B | Throughput
> linux A | linux B | 893 Mbit/sec
>=20
> Probably hard to read, but the bottom line is this:
> Copying the 683MB from a linux host to a solaris RAID took 42 seconds.
> Copying the same data from a linux host to a linux RAID took 5:07 or 3:17
> depending on where the journal is stored.  My SCP times from Linux to Lin=
ux
> RAID are much quicker than my nfs copies which seems pretty backwards to =
me.
>=20
> Thanks in advance for the help on this.
>=20
> Jeff Block
> Programmer / Analyst
> Radiology Research Computing
> University of California, San Francisco
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by Oracle Space Sweepstakes
> Want to be the first software developer in space?
> Enter now for the Oracle Space Sweepstakes!
> http://ads.osdn.com/?ad_id=3D7393&alloc_id=3D16281&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=-XGdoEjRDhIPuyNVlEj0P
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCgj/1o0feVm00f/8RAgAuAJ9m9g3p8LnSncWH+tuCh6GYO0Q1CgCfeEBf
7MY3WQi/N2TAZEmqIT2FIio=
=Uu/q
-----END PGP SIGNATURE-----

--=-XGdoEjRDhIPuyNVlEj0P--



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
