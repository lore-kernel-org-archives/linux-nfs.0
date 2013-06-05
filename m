Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60229 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862Ab3FEXnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 19:43:53 -0400
Date: Thu, 6 Jun 2013 09:43:36 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130606094336.4faf099d@notabene.brown>
In-Reply-To: <1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
	<20130603122319.47f4e0dd@notabene.brown>
	<0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
	<20130603130101.4acfe706@notabene.brown>
	<C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com>
	<20130604093025.5e467eeb@notabene.brown>
	<9F47F7D4-9D96-424E-BAD9-21AE1C06A877@oracle.com>
	<2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com>
	<20130605112635.188f628e@notabene.brown>
	<1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/x+8=w/GvHV.=N/6JGwGbS/H"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/x+8=w/GvHV.=N/6JGwGbS/H
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Jun 2013 11:37:12 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

> Again, I ask: what is being protected?  Why would an administrator make t=
his requirement?  I would like to clearly understand this particular attack=
 so we can design a smart solution that does what administrators want.

I honestly have no idea.  But if there is nothing to be protected, why would
someone recommend (even if they don't require) integrity protection?

If I was setting up a server and was concerned about security I would be
choosing options that required signed messages where-ever possible, even if=
 I
couldn't see the exact scenario by which a non-signed message could cause a
problem.

Certainly in an AUTH_SYS environment (trusted network transport), AUTH_SYS =
or
AUTH_NONE should be enough for SETCLIENTID.  But you want an AUTH_GSS
environment, why not aim to make everything use AUTH_GSS?

>=20
> > For 3.6 (and earlier?) a client could work with this by running "kinit"=
 as
> > both themselves and root, and running "gssd -n".  Then whenever they ac=
cess
> > files, or whenever root accesses files on their behalf, the access uses=
 their
> > credential and works.  The only access that tried to use the machine
> > credential (which doesn't exist) would be performed in the context of an
> > access by the user (an open) and would fall back on the user's credenti=
al.
> >=20
> > In 3.[789] the mount doesn't work because it requires a SETCLIENTID whi=
ch
> > tries to use the machine credential and has no user to fall back on.
> > It falls back on AUTH_NONE (is that right?) which the server doesn't ac=
cept.
>=20
> The 3.7+ fallback logic works just like 3.6 and earlier.  The difference =
is that now the SETCLIENTID occurs as the first operation on the first moun=
t.  At that early stage, there are no user credentials available because no=
-one has attempted to create any open or lock state, which is what is mined=
 on the client for a user credential.
>=20
> > In 3.10 the same happens but now it falls back on AUTH_SYS and the serv=
er
> > still doesn't accept it (because Dave said integrity protection is impo=
rtant).
>=20
> No one has proposed a server change, so AUTH_SYS should be a reasonable c=
hoice.  Servers do not have to enforce the use of integrity-protecting secu=
rity flavors for lease management unless the administrators recognize a pal=
pable threat.  I'm trying to identify what kind of threats that might be, b=
ecause so far we have been talking in hypotheticals.

If it is only hypothetical, why is it even recommended?  I must be missing
something.
If we expect the server will always accept AUTH_SYS, why ever bother sending
anything else?
If we expect the server might not accept AUTH_SYS, we should do our best to
send the appropriate authentication.



> > Your desire to make it "just work" without monkeying around with flags =
to gssd
> > is certainly good.  However there is a key difference between a multi-u=
ser
> > client and a single-user client.  For the multi-user client there must =
be a
> > separate "root" identity, whether in the form of a machine credential o=
r a
> > credential for uid=3D0.  For the single-user client there is only one i=
dentity.
> > So somewhere that distinction needs to be configured.
>=20
> I believe we will be fundamentally better off if we use the same mechanis=
m in both cases.  The implementation is less complex and easier for us to t=
est and maintain.  The promise of a broad "no configuration" solution also =
has its appeal.

Certainly agree it would be better.  Not convinced it is actually possible.
Not an important issue for me at the moment though.

I've provided a patched kernel to customer.  Hopefully will hear back soon.

Thanks
NeilBrown

--Sig_/x+8=w/GvHV.=N/6JGwGbS/H
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa/NKDnsnt1WYoG5AQKFIBAAgsj9IIOkVFiAdN59VRaFk3pNZdKa52US
16G3wWhlrY2Afp8kKJut8QsvQT+uHF3UnuTKR7QNjBRQa6WHNeSUfRYVeFH9m47T
pu+RH+ZeB/8dXN5kO+sPCGJTx45Z2Y45eg/dHBPN4XU10WqNCt27L7hJgsYh0uQB
uHuLWuOdLkK9UCajydTyYqv43d2qPNW/4PI/UqtGAYVQl1/wEt2MNwhVQ6TZO52P
hvfbidJm7XF5DEaaOnxOWqrrgVF/YMp6HLFE4M/hQcfncgncFqJs/9spfQN1skZD
yoyhsK2AUENwrwlExSaqDUZPvXt0EADs9jOZzZJUf3CuCt3Oc5/d9qHePCWEopw2
CMCP036G3IzEchDNKXtkfyNl8DEf3JEBnbYcF3VjPVp517FEuTe8Sqgi+zfmdZ66
HkRvCnqw0lkcJ0wzTvyzivL+4EpQBqZjlj6qm9nWIF4Ir+fNcPTnEIDebZHhdjB4
BYlqPtoAl06wNpPqLfx7fO59l3Rjl1TU9oZPicwG52pevwYBq39gl8tTAsQmr1vR
ohsfBP3+K9mzM8RDRtYHTEVb7iUJXhBaiMqeCuySU1G9QhWkEju4bhc0KRhAu6sB
jk5Vd7bGnQE/ElXWXKTp/6lksGE+4Y0tmcxN9y31fkQ8SA+b3q7Xk62RnEzsvgKN
mZEDb+TFc1M=
=bmMl
-----END PGP SIGNATURE-----

--Sig_/x+8=w/GvHV.=N/6JGwGbS/H--
