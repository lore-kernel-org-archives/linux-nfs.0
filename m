Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52023 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbaIYBpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 21:45:01 -0400
Date: Thu, 25 Sep 2014 11:44:52 +1000
From: NeilBrown <neilb@suse.de>
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS auto-reconnect tuning.
Message-ID: <20140925114452.121776c0@notabene.brown>
In-Reply-To: <5422E5CB.6000402@mpstor.com>
References: <5422E5CB.6000402@mpstor.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/r=y0vxC3GoPwkIrotpE41Mc"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/r=y0vxC3GoPwkIrotpE41Mc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 24 Sep 2014 16:39:55 +0100 Benjamin ESTRABAUD <be@mpstor.com> wrote:

> Hi!
>=20
> I've got a scenario where I'm connected to a NFS share on a client, have=
=20
> a file descriptor open as read only (could also be write) on a file from=
=20
> that share, and I'm suddenly changing the IP address of that client.
>=20
> Obviously, the NFS share will hang, so if I now try to read the file=20
> descriptor I've got open (here in Python), the "read" call will also hang.
>=20
> However, the driver seems to attempt to do something (maybe=20
> save/determine whether the existing connection can be saved) and then,=20
> after about 20 minutes the driver transparently reconnects to the NFS=20
> share (which is what I wanted anyways) and the "read" call instantiated=20
> earlier simply finishes (I don't even have to re-open the file again or=20
> even call "read" again).
>=20
> The dmesg prints I get are as follow:
>=20
> [ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <--=20
> changed IP address and started reading the file.
> [ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was=20
> reconnected, the "read" call completes successfully.

The difference between these timestamps is 27 seconds, which is a lot less
than the "20 minutes" that you quote.  That seems odd.

If you adjust
   /proc/sys/net/ipv4/tcp_retries2

you can reduce the current timeout.
See Documentation/networking/ip-sysctl.txt for details on the setting.

https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt

It claims the default gives an effective timeout of 924 seconds or about 15
minutes.

I just tried and the timeout was 1047 seconds. This is probably the next
retry after 924 seconds.

If I reduce tcp_retries2 to '3' (well below the recommended minimum) I get
a timeout of 5 seconds.
You can possibly find a suitable number that isn't too small...

Alternately you could use NFSv4.  It will close the connection on a timeout.
In the default config I measure a 78 second timeout, which is probably more
acceptable.  This number would respond to the timeo mount option.
If I set that to 100, I get a 28 second timeout.

The same effect could be provided for NFSv3 by setting:

           __set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);

somewhere appropriate.  I wonder why that isn't being done for v3 already...
Probably some subtle protocol difference.

NeilBrown

=20
> I would like to know if there was any way to tune this behaviour,=20
> telling the NFS driver to reconnect if a share is unavailable after say=20
> 10 seconds.
>=20
> I tried the following options without any success:
>=20
> retry=3D0; hard/soft; timeo=3D3; retrans=3D1; bg/fg
>=20
> I am running on a custom distro (homemade embedded distro, not based on=20
> anything in particular) running stock kernel 3.10.18 compiled for i686.
>=20
> Would anyone know what I could do to force NFS into reconnecting a=20
> seemingly "dead" session sooner?
>=20
> Thanks in advance for your help.
>=20
> Regards,
>=20
> Ben - MPSTOR.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/r=y0vxC3GoPwkIrotpE41Mc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCNzlDnsnt1WYoG5AQLdnw//epKKakCosICqkG0q7bRP25xELwYyQ6rx
lJMOuTD0cei/7TaIXS4Zw3/djdPdhJqypZfgiZ7zyN9e2DlEZQYTfgXnr5JkhcLp
+MmBrvnJ6euseNJA1DNqzbu4USdCDRJFTuACImLzDkhIMrfKdEqd3g4TApl6MNUn
rsOZimCuRq+sPiFLIW55lYEW4wW3fwhvI01pnG6H3ukSJJe3+0P3cFtBtyKAt1hr
G+YLj14RljnUfWlGHcfCRCSDcZxEGQstLkjdY9EppPZ3KzaYiOZ6LYoWnOkyAJSX
0FOAgevjnwBlZKgFSbpIg6W6ZYUj/9cNX+kVT0bBIWkCw/R9MSDO8bn0bzeVELxD
dHqQmHxw/wsEpoNtssF0ITH5Czuos4OvM8b0rpTHCKNQRfVmhEgr6xu/LA7/2V+R
HP41KfzV/Kratgro9RnOOH1li2eE6pTFYfD2CCNUiG617YGSCHy//sNwz3VpkK73
2J0G9nesLsQVFOAK+YN/CE0PoB7qiP/7en6OCXMbrkokX+L18g4y7xi/a94GljvX
IMazFvqSfyXpa30h4XmfEYfoLGWVHNWukU8/ZDWZRn5TbvYGQQxA3a/TwlFv7HRL
/96FHTJ40GwQBbSoZMXzpmq4r02RHx2vpaPje9C18dZmIdfg9KlAQLSJNy3uw05K
fxCqPMTwoQA=
=L0dj
-----END PGP SIGNATURE-----

--Sig_/r=y0vxC3GoPwkIrotpE41Mc--
