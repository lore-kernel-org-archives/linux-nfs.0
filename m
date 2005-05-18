From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Extremely high load on NFS clients wen the NFS server is
	down...
Date: Wed, 18 May 2005 11:52:13 -0700
Message-ID: <1116442333.25985.57.camel@seki.nac.uci.edu>
References: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-K9l/4ZICfV+EcEacjuA8"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYTeX-0008MY-Qo
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 11:52:21 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYTeV-0004ni-7r
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 11:52:21 -0700
To: Henrik Schmiediche <henrik@stat.tamu.edu>
In-Reply-To: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
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


--=-K9l/4ZICfV+EcEacjuA8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2005-05-18 at 09:28 -0500, Henrik Schmiediche wrote:
>     Hello,
> I have two Redhat AS3 servers. One of them (among other things) serves NF=
S
> file systems to my other systems including to the other server. When my N=
FS
> file server goes down or is restarted the load on the other AS3 server
> increases to the point it is completely useless (it goes to 50+ in a minu=
te
> or two). I never observed this behavior when I was serving NFS file syste=
ms
> using a Solaris system.
>=20
> Has anyone observed this phenomenon?  Any solution to it?
>=20
> Sincerely,
>=20
>    - Henrik

I've seen this a number of times.  In fact, I just sorted out such a
situation again over the weekend - but running jack the ripper to get a
list of accounts with bad passwords, and digging up one that had a local
shell, rather than a shell on NFS.

Far from a fix, but this program can help a lot when the load on a
system gets so high, and the NFS timeouts are so bad, that you cannot
ssh in or get any other form of interactive shell:

http://dcs.nac.uci.edu/~strombrg/fallback-reboot/

In fact, it can often even allow you reboot a system when the system's
hard disks have gone temporarily useless.

(Yes, it's a shameless plug of my own program :)


--=-K9l/4ZICfV+EcEacjuA8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCi47do0feVm00f/8RAuiiAJoDjB4B54L6KLtipb61MS2MZSQDgACeNHI+
Z+AaTg1oLbv963wocs6HGqM=
=E06i
-----END PGP SIGNATURE-----

--=-K9l/4ZICfV+EcEacjuA8--



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
