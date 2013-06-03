Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56943 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758763Ab3FCXag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jun 2013 19:30:36 -0400
Date: Tue, 4 Jun 2013 09:30:25 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130604093025.5e467eeb@notabene.brown>
In-Reply-To: <C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
	<20130603122319.47f4e0dd@notabene.brown>
	<0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
	<20130603130101.4acfe706@notabene.brown>
	<C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/evdAvZ+6I/_3Wjn4++3j8Ko"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/evdAvZ+6I/_3Wjn4++3j8Ko
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 3 Jun 2013 00:32:54 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Jun 2, 2013, at 11:01 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> > On Sun, 2 Jun 2013 22:45:16 -0400 Chuck Lever <chuck.lever@oracle.com> =
wrote:
> >=20
> >>=20
> >> On Jun 2, 2013, at 10:23 PM, NeilBrown <neilb@suse.de> wrote:
> >>=20
> >>> On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.com=
> wrote:
> >>>=20
> >>>>=20
> >>>> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
> >>>>=20
> >>>>> As you probably know, since 3.7 (I think) Linux NFS has explicitly
> >>>>> asked for machine credentials for certain requests rather than aski=
ng
> >>>>> for root credentials as is previously did.
> >>>>> This causes a regression for people who don't have any machine
> >>>>> credentials configured and use "gssd -n".
> >>>>>=20
> >>>>> I gather this was discussed on the mailing list earlier this year b=
ut
> >>>>> not resolved.
> >>>>=20
> >>>> It's resolved in 3.10-rc.
> >>>>=20
> >>>> The kernel will attempt to use krb5i for lease management operations=
.  If that fails because there is no keytab available, it falls back to usi=
ng AUTH_SYS.
> >>>=20
> >>> And if the server refuses to accept AUTH_SYS?
> >>>=20
> >>> I guess this is commit 79d852bf5e7691dc7 ??
> >>=20
> >> That's one of the subsequent bug fixes.  The initial change is commit =
4edaa308.
> >>=20
> >>> It seems to say that the server should always accept AUTH_SYS ... is =
that right?
> >>=20
> >> If we ever find a server implementation that does not support either K=
erberos or AUTH_SYS, we can add another step to the negotiation.
> >>=20
> >> So far, despite RFC 3530 not requiring AUTH_SYS support on NFSv4 serve=
rs, I haven't found an implementation that does not support AUTH_SYS.  We h=
ave found one (FreeBSD) that does not support AUTH_NONE.  We do know that s=
ome servers allow administrators to control what security flavors are allow=
ed for lease management.
> >>=20
> >>> That commit isn't tagged for -stable.
> >>> So do we still need to make it work for 3.7,3.8,3.9 users?
> >>=20
> >> There are several commits that would need to be back-ported, starting =
with commit 4edaa308.  I am not certain they would apply cleanly to 3.[789]=
, but a backport should not be difficult.
> >>=20
> >> This change also requires that now gssd must be running on the client.=
  Otherwise without gssd a sec=3Dsys mount hangs for a bit waiting for the =
upcall to time out (since the client will attempt to use krb5i for lease ma=
nagement operations).  Trond and Bruce have been discussing a change to add=
ress that.
> >=20
> > Thanks for the explanation.  That all looks rather painful to back-port
> > though, especially as some of it isn't even written yet :-)
> > I think I'll stick with my "-N" option for openSUSE for now.
> >=20
> > Do you think that supporting -N (or similar) so that the admin can ask =
for
> > root credentials to be used for SETCLIENTID requests is reasonable? i.e=
. what
> > do you think of my patch going in to nfs-utils anyway?
>=20
> So, let me confirm my understanding of your proposed changes: a user logs=
 in as root, then kinit's with her own user principal.  That establishes a =
Kerberos credential for root to use, and "-N" makes gssd return this creden=
tial when the kernel requests "service=3D*".

Correct.

>=20
> Lease management is shared among all NFS users on a client.  In particula=
r, machine credentials give us two important features that cannot be matche=
d by user credentials:
>=20
>   o  Machine credentials never expire even when users log out.  On a
>      multi-user client, you don't want credential expiry or a user
>      logout to cause lease management to stop working for other users.=20

... while on a single-user client, this isn't really an issue.

And I can easily imagine a server admin not wanting to hand out credentials
that never expire, but still requiring strong credentials for lease
management.

>=20
>   o  Machine credentials are always the same no matter who is logged
>      in.  The client has to use the same credential every time for
>      lease management, or else servers return CLID_INUSE and prevent a
>      fresh lease from being established (at least until the existing
>      lease for that clientid expires on the server).

Again, not really an issue for a single-user client.  And single-user
machines are certainly a common use-case these days.

>=20
> Using root's credentials for lease management makes it likely one of thes=
e two bullets will end up in your foot.  Specifically for the use case wher=
e one user is always using the same client (say, a student's laptop), "-N" =
might work fine.  For other use cases, like a shared build machine that doe=
sn't have a keytab, "-N" would not work reliably.

Completely agree.  So -N should certainly not be the default.

>=20
> With 3.10, if we can't use a Kerberos host principal for lease management=
, we'll use a less secure equivalent.  The point of backing off the securit=
y flavor for lease management is that AUTH_SYS with UID 0, or even AUTH_NON=
E, are essentially machine credentials.  They don't expire, and the client =
will present a consistent credential for lease management, no matter what u=
ser logs in or leaves the machine.
>=20
> So, yes, machine credentials are a pain in the ass, and have been for yea=
rs.  I'm sorry this took 3 kernel releases to figure out, but I'm hoping th=
at the path we're on with these kernel changes is towards more transparent =
support for a wider array of use cases.  NFSv4.1 also offers some relief in=
 this area (see SP4_MACH_CRED, which I think we do not support quite yet).

All sounds very good, but doesn't seem to address the issue.

For the openSUSE user who raised this, he simply does not have a machine
credential. I don't know why, maybe the server admin doesn't want to hand
them out.  But this hasn't been a problem because "gssd -n" meant that a
machine credential would never be used.
But now,  with 3.[789], "gssd -n" still wants the machine credential that
doesn't exist.

It is possible that with 3.10, he might get away with doing lease management
with AUTH_SYS, but that seems unlikely.  Given that an integrity protecting
security flavour is now recommended for SETCLIENTID, his server admin
could easily make a case that AUTH_SYS won't be accepted.  In that case he
would still have a problem.

Given that "gssd -n" has meant "no machine credential needed" in the past, I
think it is important to preserve the possibility of running secure NFS with
no machine credential.  I don't see how your changes (valuable though they
are) achieve that.

So I think we either need to change "gssd -n" to mean "never use machine
credentials" or add something like "gssd -N", so the two different possible
uses of machine credentials can be separately controlled.

NeilBrown

--Sig_/evdAvZ+6I/_3Wjn4++3j8Ko
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa0nETnsnt1WYoG5AQJyuRAAwS7J+kXk0bjRC+uq5fYjmVyanWFfxBAU
zNggtVhCTxwF3bgUkTyaP/xhDsKZNrSqD2Cxd8dXQjwwI30prDYhgp5VxNjQcw83
FMzs4jeYokaRNJAbpEZ28j0rYh/W/ggAKVVK4h8mGdsT0SbNox0qrv/a65WsS3Zu
2hFtgfnLDmVbnUtnGJNf/FqlQsMVGddEsf5g38LsSj2bygcJ+kVS3FrPpicW20Y+
D4SuJtSfXHRzvFBKLAjDmWK1wi9B5btngeNBcIE1heCeJ/oPU25fgfzcQXVLdl/y
pmsYjP2BYtxxGvdEY+c89JqdxkJXTqsyNmxTNzyZmuMCLx1Ul/WX+dH5zOuq6cMC
iwjXYvcPLRioPgznwtGTE/PCBzMGerdm1eR/I5xVEA7z0Kw7XkhLuuSId0umt1wE
gGjY/1r3xZXvaJXK6pZoGcVE08SQsjseca0gNZT5DM03UtF+BIVdJ+8dnrOYqfyU
maTmwMx2OIQDAG4UZ3PVMK3phZysq8FSkwO8eFcNaT9c9VO9mGCHUADMLy7WiICi
UvvLyHLFhJuIawzSxhL/tFOVTfkkikye6SNIO5f2gMPTRiUllp1E9S2pj8ie33p2
R3M+2qiFED6nJTCAbEMZSiOscscih8z2wbf/e5N1aRdcBNxLJNU2HEMd2PHLPXp7
rTUiOe2zTVk=
=sXBM
-----END PGP SIGNATURE-----

--Sig_/evdAvZ+6I/_3Wjn4++3j8Ko--
