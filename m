Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58087 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117Ab3FEB0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 21:26:49 -0400
Date: Wed, 5 Jun 2013 11:26:35 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130605112635.188f628e@notabene.brown>
In-Reply-To: <2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
	<20130603122319.47f4e0dd@notabene.brown>
	<0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
	<20130603130101.4acfe706@notabene.brown>
	<C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com>
	<20130604093025.5e467eeb@notabene.brown>
	<9F47F7D4-9D96-424E-BAD9-21AE1C06A877@oracle.com>
	<2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/W+JJ=WHp+euOGXgmlDYrYS9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/W+JJ=WHp+euOGXgmlDYrYS9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 4 Jun 2013 15:16:01 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Jun 3, 2013, at 9:13 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
> >=20
> > On Jun 3, 2013, at 7:30 PM, NeilBrown <neilb@suse.de> wrote:
> >=20
> >> On Mon, 3 Jun 2013 00:32:54 -0400 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >>=20
> >>>=20
> >>> On Jun 2, 2013, at 11:01 PM, NeilBrown <neilb@suse.de> wrote:
> >>>=20
> >>>> On Sun, 2 Jun 2013 22:45:16 -0400 Chuck Lever <chuck.lever@oracle.co=
m> wrote:
> >>>>=20
> >>>>>=20
> >>>>> On Jun 2, 2013, at 10:23 PM, NeilBrown <neilb@suse.de> wrote:
> >>>>>=20
> >>>>>> On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.=
com> wrote:
> >>>>>>=20
> >>>>>>>=20
> >>>>>>> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
> >>>>>>>=20
> >>>>>>>> As you probably know, since 3.7 (I think) Linux NFS has explicit=
ly
> >>>>>>>> asked for machine credentials for certain requests rather than a=
sking
> >>>>>>>> for root credentials as is previously did.
> >>>>>>>> This causes a regression for people who don't have any machine
> >>>>>>>> credentials configured and use "gssd -n".
> >>>>>>>>=20
> >>>>>>>> I gather this was discussed on the mailing list earlier this yea=
r but
> >>>>>>>> not resolved.
> >>>>>>>=20
> >>>>>>> It's resolved in 3.10-rc.
> >>>>>>>=20
> >>>>>>> The kernel will attempt to use krb5i for lease management operati=
ons.  If that fails because there is no keytab available, it falls back to =
using AUTH_SYS.
> >>>>>>=20
> >>>>>> And if the server refuses to accept AUTH_SYS?
> >>>>>>=20
> >>>>>> I guess this is commit 79d852bf5e7691dc7 ??
> >>>>>=20
> >>>>> That's one of the subsequent bug fixes.  The initial change is comm=
it 4edaa308.
> >>>>>=20
> >>>>>> It seems to say that the server should always accept AUTH_SYS ... =
is that right?
> >>>>>=20
> >>>>> If we ever find a server implementation that does not support eithe=
r Kerberos or AUTH_SYS, we can add another step to the negotiation.
> >>>>>=20
> >>>>> So far, despite RFC 3530 not requiring AUTH_SYS support on NFSv4 se=
rvers, I haven't found an implementation that does not support AUTH_SYS.  W=
e have found one (FreeBSD) that does not support AUTH_NONE.  We do know tha=
t some servers allow administrators to control what security flavors are al=
lowed for lease management.
> >>>>>=20
> >>>>>> That commit isn't tagged for -stable.
> >>>>>> So do we still need to make it work for 3.7,3.8,3.9 users?
> >>>>>=20
> >>>>> There are several commits that would need to be back-ported, starti=
ng with commit 4edaa308.  I am not certain they would apply cleanly to 3.[7=
89], but a backport should not be difficult.
> >>>>>=20
> >>>>> This change also requires that now gssd must be running on the clie=
nt.  Otherwise without gssd a sec=3Dsys mount hangs for a bit waiting for t=
he upcall to time out (since the client will attempt to use krb5i for lease=
 management operations).  Trond and Bruce have been discussing a change to =
address that.
> >>>>=20
> >>>> Thanks for the explanation.  That all looks rather painful to back-p=
ort
> >>>> though, especially as some of it isn't even written yet :-)
> >>>> I think I'll stick with my "-N" option for openSUSE for now.
> >>>>=20
> >>>> Do you think that supporting -N (or similar) so that the admin can a=
sk for
> >>>> root credentials to be used for SETCLIENTID requests is reasonable? =
i.e. what
> >>>> do you think of my patch going in to nfs-utils anyway?
> >>>=20
> >>> So, let me confirm my understanding of your proposed changes: a user =
logs in as root, then kinit's with her own user principal.  That establishe=
s a Kerberos credential for root to use, and "-N" makes gssd return this cr=
edential when the kernel requests "service=3D*".
> >>=20
> >> Correct.
> >>=20
> >>>=20
> >>> Lease management is shared among all NFS users on a client.  In parti=
cular, machine credentials give us two important features that cannot be ma=
tched by user credentials:
> >>>=20
> >>> o  Machine credentials never expire even when users log out.  On a
> >>>    multi-user client, you don't want credential expiry or a user
> >>>    logout to cause lease management to stop working for other users.=
=20
> >>=20
> >> ... while on a single-user client, this isn't really an issue.
> >>=20
> >> And I can easily imagine a server admin not wanting to hand out creden=
tials
> >> that never expire, but still requiring strong credentials for lease
> >> management.
> >=20
> > Why, exactly, would strong credentials be required for lease management=
, but an admin would choose not to hand out keytabs?
> >=20
> >>=20
> >>>=20
> >>> o  Machine credentials are always the same no matter who is logged
> >>>    in.  The client has to use the same credential every time for
> >>>    lease management, or else servers return CLID_INUSE and prevent a
> >>>    fresh lease from being established (at least until the existing
> >>>    lease for that clientid expires on the server).
> >>=20
> >> Again, not really an issue for a single-user client.  And single-user
> >> machines are certainly a common use-case these days.
> >>=20
> >>>=20
> >>> Using root's credentials for lease management makes it likely one of =
these two bullets will end up in your foot.  Specifically for the use case =
where one user is always using the same client (say, a student's laptop), "=
-N" might work fine.  For other use cases, like a shared build machine that=
 doesn't have a keytab, "-N" would not work reliably.
> >>=20
> >> Completely agree.  So -N should certainly not be the default.
> >>=20
> >>>=20
> >>> With 3.10, if we can't use a Kerberos host principal for lease manage=
ment, we'll use a less secure equivalent.  The point of backing off the sec=
urity flavor for lease management is that AUTH_SYS with UID 0, or even AUTH=
_NONE, are essentially machine credentials.  They don't expire, and the cli=
ent will present a consistent credential for lease management, no matter wh=
at user logs in or leaves the machine.
> >>>=20
> >>> So, yes, machine credentials are a pain in the ass, and have been for=
 years.  I'm sorry this took 3 kernel releases to figure out, but I'm hopin=
g that the path we're on with these kernel changes is towards more transpar=
ent support for a wider array of use cases.  NFSv4.1 also offers some relie=
f in this area (see SP4_MACH_CRED, which I think we do not support quite ye=
t).
> >>=20
> >> All sounds very good, but doesn't seem to address the issue.
> >=20
> >> For the openSUSE user who raised this, he simply does not have a machi=
ne
> >> credential. I don't know why, maybe the server admin doesn't want to h=
and
> >> them out.
> >=20
> > Handing out keytabs for every NFS client that wants to use Kerberized N=
FS is onerous for some administrators.
> >=20
> >> But this hasn't been a problem because "gssd -n" meant that a
> >> machine credential would never be used.
> >=20
> > No, it meant that root's user credential was used instead of a service =
credential for lease  management.  As I explained above, that solution has =
some compromises for some important use cases.
>=20
> Correction:
>=20
> rpc.gssd(8) on Fedora 18 says:
>=20
> > With the -n option, "machine credentials" will not be used for accesses=
 by UID 0.
>=20
>=20
> In other words, normally root doesn't have a Kerberos ticket.  The kernel=
 uses the machine's credentials for UID 0.  "-n" means only that root has t=
o kinit.
>=20
>=20
> >> But now,  with 3.[789], "gssd -n" still wants the machine credential t=
hat
> >> doesn't exist.
> >=20
> > The change that introduced the requirement for a machine credential is =
commit 68c97153 "SUNRPC: Clean up the RPCSEC_GSS service ticket requests", =
Tue Jan 3 13:22:46 2012, which was merged long before 3.7.
> >=20
> > The Uniform Client String changes in 3.7 merely made the machine creden=
tial requirement more obtrusive.  The new broken "-n" behavior is an uninte=
nded side effect.
>=20
> I was wondering what exactly about 3.7's UCS changes exposed the requirem=
ent for a machine credential, so I built a 3.6 kernel and tried it.
>=20
> The key difference between 3.6 and 3.7 is that 3.6 performs the SETCLIENT=
ID much later, after a user has logged in and kinit'd, and is actually doin=
g an OPEN.
>=20
> 3.6 requests a machine credential, but if that fails, it asks for the OPE=
N user's credential for SETCLIENTID.  The retried upcall request is for "se=
rvice=3D<null> UID=3Dnnnn".
>=20
> If root kinit's for the mount, but the user does not kinit before accessi=
ng the mount, the SETCLIENTID still fails!  Root's ticket and "gssd -n" has=
 nothing to do with SETCLIENTID's security flavor, as far as I can tell.
>=20
> With 3.7, the SETCLIENTID is done right at mount time.  There is no user =
with credentials trying to do an OPEN, so the only credential the kernel tr=
ies is the machine's credential.  Perhaps the kernel could retry the upcall=
 with "server=3D<null> UID=3D0".
>=20
> >> It is possible that with 3.10, he might get away with doing lease mana=
gement
> >> with AUTH_SYS, but that seems unlikely.  Given that an integrity prote=
cting
> >> security flavour is now recommended for SETCLIENTID, his server admin
> >> could easily make a case that AUTH_SYS won't be accepted.  In that cas=
e he
> >> would still have a problem.
> >=20
> > His problem then would be with his server admin, not with us.
> >=20
> > If a server admin wants to protect his server by denying the use of AUT=
H_SYS for lease management, he has every right to do that.  But he must als=
o therefore understand the position that puts his users in.
> >=20
> >> Given that "gssd -n" has meant "no machine credential needed" in the p=
ast,
> >=20
> > It never meant that.  It meant "use root's credential as the machine cr=
edential".  I think we should be clear about exactly what "-n" is.
>=20
> Right, I should heed my own words.
>=20
> > I also believe "-n" (or "-N") is a workaround.  Logging in as root and =
authenticating is a pain for users, who have already logged in once.
>=20
> This is still true, however.
>=20
> >> I think it is important to preserve the possibility of running secure =
NFS with
> >> no machine credential.  I don't see how your changes (valuable though =
they are)
> >> achieve that.
> >=20
> > Please explain how allowing lease management to occur using AUTH_SYS is=
 somehow a major new exposure.  A mixture of sec=3Dsys and sec=3Dkrb5 mount=
s today means there's a good chance that a sec=3Dsys mount might occur firs=
t, and thus lease management uses AUTH_SYS anyway.
> >=20
> > Can you share your attack model?  Why do you believe that using AUTH_SY=
S for lease management on sec=3Dkrb5 mounts will be unacceptable to users? =
 I suspect that most will not notice or care.
>=20
> I'm still interested in knowing if we have a palpable hole in the current=
 solution in 3.10.
>=20
> >> So I think we either need to change "gssd -n" to mean "never use machi=
ne
> >> credentials" or add something like "gssd -N", so the two different pos=
sible
> >> uses of machine credentials can be separately controlled.
> >=20
> > I'm not convinced that "-N" is the right way to fix this.  Another knob=
 to turn means more testing for us, more documentation to write and maintai=
n, and so on.  It doesn't get us any farther forward.  The difference betwe=
en "-n" (which no longer works) and "-N" is subtle and confusing.  Explaini=
ng when to use "-N" versus "-n" is not a job I would like to do, and I'm no=
t interested in taking the support calls either.  :-p
>=20
> Let me restate this without all the cleverness.
>=20
> Trond's recommendation was to tell gssd exactly where to find the machine=
 credential if it's not in a keytab: basically an option that says "look in=
 this file for that user credential".  That was our first try, but it was c=
lumsy.
>=20
> You want "gssd -N" to mean specifically "use root's ticket as the machine=
 credential."  Then "-n -N" would mean "force root to kinit, and use root's=
 ticket as the machine credential."  (Perhaps "-N" doesn't make sense unles=
s "-n" is also specified...?)
>=20
> But that's still not the same as 3.6's behavior.  And, it would still be =
a regression, as I understand it, because a user space change would be need=
ed after a kernel upgrade.  For that reason, for 3.[789] we probably want t=
o find a kernel-only solution.
>=20
> Command line options on gssd are really poor from a usability standpoint.=
  IMO in the long run we want "mount sec=3Dkrb5 without a client keytab" ju=
st to work.  No monkeying with gssd.
>=20

Hi Chuck,
 thanks for you explanations and investigations - they certainly help.

Let me try to present my perspective.

The "problem" situation is where the server admin does not want to hand out
machine credentials (keytabs).
As you say:
   "Handing out keytabs for every NFS client that wants to use Kerberized N=
FS
    is onerous for some administrators"

If I want to use my personal machine to access only my files over NFS then,
from the server admin's perspective, a kerberos login should be enough.  And
until recently it has been.

This server admin might have read Dave Noveck's recommendations that you
quote in commit 4edaa308888b:

    Dave Noveck's migration issues draft recommends the use of an
    integrity-protecting security flavor for the SETCLIENTID operation.

and decided to disable AUTH_SYS for SETCLIENTID.

For 3.6 (and earlier?) a client could work with this by running "kinit" as
both themselves and root, and running "gssd -n".  Then whenever they access
files, or whenever root accesses files on their behalf, the access uses the=
ir
credential and works.  The only access that tried to use the machine
credential (which doesn't exist) would be performed in the context of an
access by the user (an open) and would fall back on the user's credential.

In 3.[789] the mount doesn't work because it requires a SETCLIENTID which
tries to use the machine credential and has no user to fall back on.
It falls back on AUTH_NONE (is that right?) which the server doesn't accept.

In 3.10 the same happens but now it falls back on AUTH_SYS and the server
still doesn't accept it (because Dave said integrity protection is importan=
t).

The only way I can see out of this is for the SETCLIENTID request at mount
time to be able to use root's credential.

I don't much care whether:
  a- the kernel requests
          mech=3Dkrb5 uid=3D0 enctypes=3D18,17,16,23,3,1,2
     if
          mech=3Dkrb5 uid=3D0 service=3D* enctypes=3D18,17,16,23,3,1,2
     fails, or
  b- gssd tried the credential for 'uid=3D0' when a lookup for the machine
     credential fails, or
  c- "gssd -N" means "use uid=3D0 credential when kernel requests a machine
     credential" or
  d- "gssd -n" adds the above to its current meaning.

'c' is what I implemented as it has least impact on people who don't care.
I think you suggested 'a' above.  I'm certainly happy with that, but I'd
rather not try to implement it myself.
I don't particularly need a "kernel-only solution" as I can update nfs-utils
in openSUSE just as easily as the kernel, but it is a good idea in principle
and I'd be happy to get it tested if someone else implements it :-)


Your desire to make it "just work" without monkeying around with flags to g=
ssd
is certainly good.  However there is a key difference between a multi-user
client and a single-user client.  For the multi-user client there must be a
separate "root" identity, whether in the form of a machine credential or a
credential for uid=3D0.  For the single-user client there is only one ident=
ity.
So somewhere that distinction needs to be configured.
One way is requiring a 'kinit' as root and running "gssd -n", but that is
indeed clumsy.
The only other approach I can think if is a mount option: 'root-uid=3DNN'
This would mean that any access that would require a "uid=3D0" credential
lookup instead uses a "uid=3DNN" credential lookup.  That would mean that t=
he
single user would not need to "kinit" as root.  They just "kinit" as
themselves and mount the filesystem with the right option and everything
"just works".

Thanks,
NeilBrown

--Sig_/W+JJ=WHp+euOGXgmlDYrYS9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa6Tyznsnt1WYoG5AQL/jxAAjxsjJbBLg0biCHq6ZvMF7scTX82/+n1k
8m4BytJoQ6VoRMSPxJxCTwOC573QER/R/WZDNBflScTFyUHkgQTMbrntuTpTeX00
10PUJmBnwkTCC8LGBBIwsy9tVDhkFaMVR36WhAO5VdehlTaKKUIRtJFl/yDxSOwe
5YF1XlcJtP4wJKf6QjU7Ouzi2IdiYPYpAlGC2z0MXse4WEVxc2ku9pp99WgRUFP6
IcMhXFAHK0FQumglGNLN1WCtn3cDCn/MAyFogpTEycVpm8sGl2Zvf9lI9oL0BvSm
sbKk3SXHY63dRuRPlWt5TTZAsIVFszgi3dzDHnfbJs0agHiDDn+3P7bkEGOaxVAc
iq/8kF9qDrIdVtwxAHgZckO25AOF5aWSOUvQVE3qBumfYphRVi7Hx2C4YeotbNb1
K5iDGfU4LfmLr98Vw0Ugs6yRvMJTd8bJMud8+A2wIBSqn/s8P6Pwt8hPPGJII9rq
Zy4vm5ZyZ8tKvIHnxkIdSHvhSOODpk4JISAmTPtejG7wWdIqK1H27olJsPaNox9c
tWa2oZd9JRemBya89FE6ykxu0MEBW4SH3p5OmuU/45gvq+4T4VV9y4DCiKyCMXG0
vila0JOMuxyohZho2m2PKMuaGLW7qGPZo6BKh5c6ZiSRQ3LFaPyhRGL1TKkXNPJ4
j6/ATAPT/58=
=H8SD
-----END PGP SIGNATURE-----

--Sig_/W+JJ=WHp+euOGXgmlDYrYS9--
