Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41908 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935Ab3GPErE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jul 2013 00:47:04 -0400
Date: Tue, 16 Jul 2013 14:46:51 +1000
From: NeilBrown <neilb@suse.de>
To: Ben Greear <greearb@candelatech.com>
Cc: Dean <seattleplus@gmail.com>, "J.Bruce Fields" <bfields@citi.umich.edu>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130716144651.3d93940d@notabene.brown>
In-Reply-To: <51E48670.9070901@candelatech.com>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<51DD9AD5.1030508@gmail.com>
	<51DD9C5A.3000505@candelatech.com>
	<20130715143527.4eca7283@notabene.brown>
	<51E48670.9070901@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/2nYGp4wP/C7uPCCGFpO9ax3"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2nYGp4wP/C7uPCCGFpO9ax3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 15 Jul 2013 16:32:00 -0700 Ben Greear <greearb@candelatech.com> wro=
te:

> On 07/14/2013 09:35 PM, NeilBrown wrote:
> > On Wed, 10 Jul 2013 10:39:38 -0700 Ben Greear <greearb@candelatech.com>=
 wrote:
> >
> >> On 07/10/2013 10:33 AM, Dean wrote:
> >>>   > This could significantly limit the amount of parallelism that can=
 be achieved for a single TCP connection (and given that the
> >>>   > Linux client strongly prefers a single connection now, this could=
 become more of an issue).
> >>>
> >>> I understand the simplicity in using a single tcp connection, but per=
formance-wise it is definitely not the way to go on WAN links. When even a =
miniscule amount
> >>> of packet loss is added to the link (<0.001% packet loss), the tcp bu=
ffer collapses and performance drops significantly (especially on 10GigE WA=
N links).  I
> >>> think new TCP algorithms could help the problem somewhat, but nothing=
 available today makes much of a difference vs. cubic.
> >>>
> >>> Using multiple tcp connections allows better saturation of the link, =
since when packet loss occurs on a stream, the other streams can fill the v=
oid.  Today, the
> >>> only solution is to scale up the number of physical clients, which ha=
s high coordination overhead, or use a wan accelerator such as Bitspeed or =
Riverbed (which
> >>> comes with its own issues such as extra hardware, cost, etc).
> >>
> >> I have a set of patches that allows one to do multiple unique mounts t=
o the same server from a single
> >> client, but the patches are for the client side, so it would not help
> >> non-Linux clients.  And, the patches were rejected for upstream as not=
 being
> >> useful.  But, if you are interested in such, please let me know and I =
can point
> >> you to them...
> >
> > Yes please!
>=20
>=20
> I haven't ported these forward to 3.10 yet, but you can find my 3.9 tree
> here:
>=20
> http://dmz2.candelatech.com/git/gitweb.cgi?p=3Dlinux-3.9.dev.y/.git;a=3Ds=
ummary
>=20
> There's a bunch of other patches, but the nfs related ones are all in a r=
ow
> and the patches are rebased, so you can probably pull them out w/out
> too much difficulty.  The patches introduce a bug where it fails to compi=
le
> w/out NFS 4.1 defined..I haven't bothered to fix it yet but it's probably
> simple..or just compile with NFS 4.1 as I do.
>=20
> Older trees found here, but we don't bother back-porting many patches,
> so I'd use the latest if you can.
>=20
> http://dmz2.candelatech.com/git/gitweb.cgi
>=20
> And, you'll need a patched mount.nfs:
>=20
> https://github.com/greearb/nfs-utils-ct
>=20
> I hope to get started on porting these to 3.10 later this week..  If
> there is any interest in this patch series or something like it going
> upstream (there wasn't in the past, I've no good reason to think that
> has changed), let me know and I will clean them up and post them to
> the mailing list again...
>=20
> If you search for greearb@candelatech.com and 'bind to local' you
> can find previous threads in the mailing list archives...

Thanks.
You are supporting multiple independent mounts by using different client-si=
de
IP addresses.  That has clear benefits for controlling routing, but also
admin costs if you don't care about routing.  The latter case applies to me.

So I'll bookmark this, but it isn't what I need just now.

Thanks,
NeilBrown


--Sig_/2nYGp4wP/C7uPCCGFpO9ax3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUeTQOznsnt1WYoG5AQImUQ/+Iz0Hd5y3yugRiC14Ss17QJCyLzl4ZmgX
DRtKOIO36HFoeff0Q9UEalb2+8RGY/3fOX46xNSaOTsAiHk72OuZGQg3CLc7akPt
oCP5qcaf/oAbyrTYnJvQm9yk5oWLKE2iHOLUHJ+Cc6p033mnl9gVIIpevfEwBi8t
XN04QhICZYOlkSqY42wYplLWzC60k/UQNnWM8Ncklq3c/9gDuLzovBWwe19XZI9y
iY7A+WM8COibirivBEifDIxr7PmRR9x56OMTjp1O3FROibtDPzKsc+cS/vs+IxhE
r3zHjPUR/8lKyfk+Xp1oRpq3jzcVT7Rmg4yUvDl1ZJ7hufkegNFtS5Azd/FAoOGw
MB06jlzpalqolG8bQKJj4TX/VDNsJOcJoP0jNgoyVA9+aca/Vv5AgBMq5YKq2kcJ
bIHM/SN6W/4mVQ/dmLLmLmQgt3AroijG60NTDm8/BGClgEYrzn/o1VaLG+ocXZrr
ZfaUFnSjPf2hqx2Jb3Ist0V0gAY7ZqXKHz+tr0VmrVaCw6rpCNb1M3MGsPWN2u1M
9yDab0A+CqIOXCq8kqQ6nRAlbRxYKNnA+OGekhGzJDtl/51vbNRIxgUarTHm/3Db
68UcCeapEhaDSsJ/kFdTmAfb+NlVt1h5ReW1d0JCYy0ArxE+69BhFrOsGNBZhidD
lvblB7Cq/jc=
=7uBV
-----END PGP SIGNATURE-----

--Sig_/2nYGp4wP/C7uPCCGFpO9ax3--
