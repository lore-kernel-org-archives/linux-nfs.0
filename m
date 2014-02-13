Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45926 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbaBMVxH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Feb 2014 16:53:07 -0500
Date: Fri, 14 Feb 2014 08:52:55 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH nfs-utils/systemd] systemd: convert secure services to
 start without explicit configuration.
Message-ID: <20140214085255.47f84b8b@notabene.brown>
In-Reply-To: <52FD2017.4050403@RedHat.com>
References: <20140205141836.5fc941a9@notabene.brown>
	<52FD2017.4050403@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/p85Yy2y_Uo0z4v6VMS0G_8X"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/p85Yy2y_Uo0z4v6VMS0G_8X
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 13 Feb 2014 14:42:15 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 02/04/2014 10:18 PM, NeilBrown wrote:
> >=20
> >=20
> > This patch removes nfs-secure.target.
> > Instead, rpc.gssd and rpc.svcgssd start started if they appear to be ne=
eded.
> >=20
> > For rpc.gssd, this means if the file /etc/krb5.keytab exists.
> > As the only security mechanism supported is krb5, that file must exist
> > for rpc.gssd to be useful.  Conversely, if it does exist, it seems very
> > likely that krb5 is configured on the system an may be used for NFS.
> >=20
> > For rpc.svcgssd, it also means checking if gss-proxy might be performing
> > the equivalent task instead.  So we check if it is running, and if the =
kernel
> > is able to talk to it.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> Committed to the systemd branch of my git tree...
>=20
> I would like to more testing before I move them on
> to the master branch...

Thanks Steve.  And I totally agree with more testing, and also more
development, tidying up, documentation, and integration with "make install".
This is still a WIP and doesn't belong on master yet.

I'll be sending more patches over the coming weeks.

Thanks,
NeilBrown

--Sig_/p85Yy2y_Uo0z4v6VMS0G_8X
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUv0+tznsnt1WYoG5AQKxhg/9GAIaI2kn9Mb9gK4oFShoiAUKPmqCPaTE
XerQT286JovY7J1k9AaJXs0phuhi/Xs8zZR1qav27aV5H7dhqdb2IdSp8m5NINV6
4AhgVcuwZqMYr30K1o4WoANPFo4aTOlTQI302ad2bIsdZnLyHoP/qZB4ZTQ7eaxl
o86MVifTI++UAgbhnVOSW553rYMeq2iRH+hQMMwzzJamdGKaFAKaIkkmvA3ujSFz
50qoDePEcbj0dMUwgU+WpHPrnXibgCm/9fmUv4mBIHjLSwO5d984LJ4cpwhSBrq8
8PX5xCsFCdz9LTeGzY/Yz4fibe9ZSt8iHLxblFWbY5sW85KtMxSpv4UpfzeXt01f
o40L1gUvcMkjXGWONaOneXMmU06toaGs7Qz1h9zlEhK+Yiv+KbalcdyMKdXP/V8F
bWLm1bB/Lbg0oNMjmllTM8Q5Gs5SNTyGQHkJ6HdaQ0ygra0Fc/+sampALzsaa07o
83Rpsu8zQr/wbPaNDa+GcE35bvvECQjYjVZSmnRoZrg6IjUIL9a9wbbisJ2K9ijn
i6Q9QLNGCRoqbd9kxHtmAOkCOQSj9qES6zLxfe62KhJKwhfuxv1AL0tHQcKEynue
b2hAZsceGX34QQ83PZeIcorwHcgM+oS4vArScr76ASRc0eby9TgQPS8TJpb8sh9C
sbuv0hBRGqc=
=M/RZ
-----END PGP SIGNATURE-----

--Sig_/p85Yy2y_Uo0z4v6VMS0G_8X--
