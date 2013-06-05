Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60547 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862Ab3FEXx6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 19:53:58 -0400
Date: Thu, 6 Jun 2013 09:53:41 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130606095341.1c7fc850@notabene.brown>
In-Reply-To: <675A79B3-FA0F-4014-85DA-67CE90E933B2@oracle.com>
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
	<675A79B3-FA0F-4014-85DA-67CE90E933B2@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/6uX=txOVS_JXWbycpLZIzEZ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/6uX=txOVS_JXWbycpLZIzEZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Jun 2013 13:14:00 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Jun 5, 2013, at 11:37 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
> >=20
> > On Jun 4, 2013, at 9:26 PM, NeilBrown <neilb@suse.de> wrote:
> >>=20
> >> Hi Chuck,
> >> thanks for you explanations and investigations - they certainly help.
> >>=20
> >> Let me try to present my perspective.
> >>=20
> >> The "problem" situation is where the server admin does not want to han=
d out
> >> machine credentials (keytabs).
> >> As you say:
> >>  "Handing out keytabs for every NFS client that wants to use Kerberize=
d NFS
> >>   is onerous for some administrators"
> >=20
> > We agree that there are environments where no host or nfs service princ=
ipal is available for clients, and we agree that type of environment should=
 be supported with Linux's NFSv4 client.
> >=20
> > Where we differ is what compromises we will accept in that type of envi=
ronment.
> >=20
> >> If I want to use my personal machine to access only my files over NFS =
then,
> >> from the server admin's perspective, a kerberos login should be enough=
.  And
> >> until recently it has been.
> >=20
> > I agree that not supporting this is a bug (regression) and should be fi=
xed.
> >=20
> >> This server admin might have read Dave Noveck's recommendations that y=
ou
> >> quote in commit 4edaa308888b:
> >>=20
> >>   Dave Noveck's migration issues draft recommends the use of an
> >>   integrity-protecting security flavor for the SETCLIENTID operation.
> >=20
> > That's a recommendation, not a requirement.  This means the standards a=
uthors (me, being one of the authors on Dave's migration draft) recognize t=
here are legitimate use cases where using an integrity-protecting security =
flavor is not feasible.
> >=20
> > Either the client or the server can enforce the use of an integrity-pro=
tecting flavor, but it is also possible that neither do.  (AUTH_NONE and AU=
TH_SYS-only environments being one important example).
> >=20
> >> and decided to disable AUTH_SYS for SETCLIENTID.
> >=20
> > Again, I ask: what is being protected?  Why would an administrator make=
 this requirement?  I would like to clearly understand this particular atta=
ck so we can design a smart solution that does what administrators want.
> >=20
> >> For 3.6 (and earlier?) a client could work with this by running "kinit=
" as
> >> both themselves and root, and running "gssd -n".  Then whenever they a=
ccess
> >> files, or whenever root accesses files on their behalf, the access use=
s their
> >> credential and works.  The only access that tried to use the machine
> >> credential (which doesn't exist) would be performed in the context of =
an
> >> access by the user (an open) and would fall back on the user's credent=
ial.
> >>=20
> >> In 3.[789] the mount doesn't work because it requires a SETCLIENTID wh=
ich
> >> tries to use the machine credential and has no user to fall back on.
> >> It falls back on AUTH_NONE (is that right?) which the server doesn't a=
ccept.
> >=20
> > The 3.7+ fallback logic works just like 3.6 and earlier.  The differenc=
e is that now the SETCLIENTID occurs as the first operation on the first mo=
unt.  At that early stage, there are no user credentials available because =
no-one has attempted to create any open or lock state, which is what is min=
ed on the client for a user credential.
> >=20
> >> In 3.10 the same happens but now it falls back on AUTH_SYS and the ser=
ver
> >> still doesn't accept it (because Dave said integrity protection is imp=
ortant).
> >=20
> > No one has proposed a server change, so AUTH_SYS should be a reasonable=
 choice.  Servers do not have to enforce the use of integrity-protecting se=
curity flavors for lease management unless the administrators recognize a p=
alpable threat.  I'm trying to identify what kind of threats that might be,=
 because so far we have been talking in hypotheticals.
> >=20
> >> The only way I can see out of this is for the SETCLIENTID request at m=
ount
> >> time to be able to use root's credential.
> >=20
> > That's what the patch I posted does.  If the kernel requests "service=
=3D*" and gssd returns -EACCES, the kernel will look for a user credential.=
  If there are no user credentials to try, it will try "service=3D<null> UI=
D=3D0".  If that doesn't work, 3.[789] fail.
> >=20
> > I haven't worked out how 3.10+ will behave.  I suspect it could try usi=
ng the UID=3D0 principal to establish a client ID using krb5i, and if _that=
_ fails, then slip back to AUTH_SYS.
> >=20
> >> I don't much care whether:
> >> a- the kernel requests
> >>         mech=3Dkrb5 uid=3D0 enctypes=3D18,17,16,23,3,1,2
> >>    if
> >>         mech=3Dkrb5 uid=3D0 service=3D* enctypes=3D18,17,16,23,3,1,2
> >>    fails, or
> >> b- gssd tried the credential for 'uid=3D0' when a lookup for the machi=
ne
> >>    credential fails, or
> >> c- "gssd -N" means "use uid=3D0 credential when kernel requests a mach=
ine
> >>    credential" or
> >> d- "gssd -n" adds the above to its current meaning.
> >>=20
> >> 'c' is what I implemented as it has least impact on people who don't c=
are.
> >> I think you suggested 'a' above.  I'm certainly happy with that, but I=
'd
> >> rather not try to implement it myself.
> >> I don't particularly need a "kernel-only solution" as I can update nfs=
-utils
> >> in openSUSE just as easily as the kernel,
> >=20
> > Understood, distributors are lucky in that regard ;-) .  The requiremen=
t for a kernel-only solution is for upstream.  Upgrading from 3.6 to 3.7 sh=
ould not require a user space adjustment like a new command line option or =
a new version of gssd.
>=20
> In terms of providing fixes for this issue:
>=20
>   o  3.7.y and 3.8.y are now EOL.  I think I should at least post patches=
 here for these kernels so a fix is available for distributions that contin=
ue to rely on these kernel versions
>=20
>   o  3.9.y is still maintained.  The 3.7 fix I posted yesterday will need=
 to be ported, but I'm guessing that it will work for 3.9 without a lot of =
alteration
>=20
>   o  A fix for 3.10-rc will need some adjustment, since there is a signif=
icant change in that kernel to use krb5i when possible for lease management=
 operations.  Or, should we consider not applying this fix to upstream?  Wo=
uld Greg take a fix for 3.9.y that hasn't gone into the upstream kernels?
>=20
> Thoughts?

I don't think Greg is keen on patches that aren't mainline, but he is a
reasonable man and will listen to a rational argument.
However I think you would need a clear idea of what *is* going to be in 3.10
before offering an alternate version of it for 3.9.
If all known servers really do accept SETCLIENTID with AUTH_SYS in all cases
then I guess you don't need anything new for mainline.
If it is then easier to make 3.9 fall back to
     "mech=3Dkrb5 uid=3D0 service=3D<null>"
than to have it fall back to AUTH_SYS, then it seems justifiable that the
"backport" to 3.9 does just that.

i.e argument to Greg is:
     3.9 fails if a machine credential is not available.  3.10 will now fall
     back to using AUTH_SYS.  In 3.9 it is easier to fall back on using the
     uid=3D0 credential and as we have always required that either the mach=
ine
     credential or the uid=3D0 credential exist (for gss mounts), do that is
     safe.

NeilBrown

--Sig_/6uX=txOVS_JXWbycpLZIzEZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa/PhTnsnt1WYoG5AQKV8Q//W3aP5MNBuL+nDM8TVVSNjObTWwACqHFB
yf+7Ae0bE4dzgcUqIxMg7cj8mVzWWFEoQGtrILDeVioI+Mu2IJE+k7y28cRbu1ix
+bnPNxFz1xWFdhFBnlj+AWO7hbNV0d9E7dnCl0ZdvWTTSldSvYtFca3EWHpjZqpa
1FyZhNYoteKmdkiWmXlPqYodTD4a9TxnZClRR6WwsjUOuJ9P4+/IqA7VCSwkxmMC
qXctftSeaRJ/9F2V2vOfD6Xapa7NXsIdFlMxJpSIDUDAFttgO8+5ZNfV2oTXXC2d
nMX0F0cKEeZnKq8VJQpd17lPY2YOsC+StO1jwufWHQk9pkilazF/9mDdWgKQvYk3
LXqOoU4RPNmrejiJKU04OZM80y8I2hcBcqgN1T8HJH6j1JYmDfSGza5v1TCKG5VS
oKT3BVNL55zNOLV4vu3qoQbRQRCl/4xqL99hAajJkStTpe11+MLBFlG28LaIvKQ0
1DVkJDb3zJsRHkeDDu4bKTcEO7SOY7UGGOwhKdb1WrxnL0ffrHg2dgxRCFV2mBDv
Isb6QyC6ZHuOKVJOx0MueBxshBlmmaImk+PJ9xOC7A4eF+B8H3OCY7yPmdC4zpTz
G0ExJ8fSVNjAOI0oXrrY8SOc+5PyIYHIv4prE3J2BYqrXcE3kTDIxUwDaJQKeG2Q
Ge9SKSHrNJw=
=htdJ
-----END PGP SIGNATURE-----

--Sig_/6uX=txOVS_JXWbycpLZIzEZ--
