Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42154 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbaBEDzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 22:55:25 -0500
Date: Wed, 5 Feb 2014 14:55:14 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140205145514.2c44b575@notabene.brown>
In-Reply-To: <52F130E2.6090308@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<20140204093452.7b6d7c7d@notabene.brown>
	<52F130E2.6090308@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/oPGoemddZ95zrG85j=VAou7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/oPGoemddZ95zrG85j=VAou7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 04 Feb 2014 13:26:42 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 02/03/2014 05:34 PM, NeilBrown wrote:
> > On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com> wr=
ote:

> >=20
> > So the structure makes sense based on the documentation and apparent de=
sign
> > of systemd.  Unfortunately it leads to this clumsy API of having to giv=
e the
> > ".target" suffix.
> In the beginning the .service suffix was not appended either. I actually
> opened a bug asking for the .service to be appended, which got
> soundly closed as NOTABUG! But I guess enough people bitched about
> so one day that "feature" just appeared. ;-)

Oh dear.  That is a sad story.  Good to know though.


> >=20
> >=20
> >>
> >> How is rpc.svcgssd enabled? Since the .service file does
> >> not have a [Install] section the systemctl enable rpc.svcgssd
> >> fails.
> >=20
> > The "README" touches on this.  If you
> >    systemctl enable nfs-secure.target
> > then rpc.svcgssd will be run whenever nfs-server.target is started.
> I was thinking nfs-server would only start rpc.svcgssd when its
> enabled... not every time...=20

I don't follow what you are saying ... not that it really matters as we both
seem to be agreed to take a different approach with the gss daemons.

In my original plan:
 if nfs-secure is enabled, then whenever nfs-server is started, it makes su=
re
 that rpc.svcgssd is running.
 if nfs-secure is not enabled, then rpc.svcgssd will refuse to start.


>=20
> > Also rpc.gssd will be run whenever nfs-server.target or nfs-client.targ=
et is
> > started.
> Why is rpc.gssd started when the nfs server is started? Possibly for secu=
re=20
> loopback mounts??

Call-backs from NFSv4.0 server, as has been mentioned elsewhere.

>=20
> >=20
> >>
> >> How would these daemons be restart and shutdown? Since this is a=20
> >> target, systemctl restart and system stop don't do anything.
> >=20
> > This is something I haven't completely figured out yet.
> >=20
> > Part of the solution might be the "PartOf" directive.
> > If each service claims to be "PartOf" the main one, then stopping or
> > restarting the main service will propagate to stopping and restarting t=
he
> > individual services.
> > Unfortunately in nfs we have some shared services.  rpc.statd and rpc.g=
ssd
> > are needed by both server and client.  That isn't a big problem for 're=
start',
> > but if you 'systemctl stop nfs-client' and find that the server isn't
> > properly working any more, that would be awkward
> > If could possibly work around that by setting "StopWhenUnneeded" for th=
ose
> > shared services.  Then e.g. rpc.statd would stop when both client and s=
erver
> > are stopped, but not if either one of them is stopped.
> > However I don't know how that interacts with restart.  I suspect that t=
he
> > StopWhenUnneeded services are *not* stopped and restarted when the main
> > service is stopped.  So it would  be  hard to restart all nfs services =
on an
> > upgrade.
> >=20
> > Further research seems needed here.
> Fine... I'll try to digest what you are saying here, but
> would it make it easier if everything was in a service file?

No, the only way the .target files are more awkward is that you have to type
".target".

In fact a .target can be turned into an .service by adding:

[Service]
Type=3Doneshot
RemainAfterExit=3Dyes
ExecStart=3D/bin/true

at the end.  You might even get away with less than that.
Given this and that ".target" is extra typing, there seems little reason to
use .target unit files.

>=20
> >=20
> >=20
> >>
> >>> +
> >>> + nfs-secure.target
> >>> +    If enabled, then rpc.gssd will be run when either -client or
> >>> +    -server is started, and rpc.svcgssd will be run when -server
> >>> +    is started
> >> I like that fact that rpc.gssd is started by nfs-client but=20
> >> I don't like that API change. systemctl restart nfs-secure breaks=20
> >=20
> > Why would you want to "restart nfs-secure".  I can understanding wantin=
g to
> > restart individual processed, or the whole collection, but why that sub=
set?
> Well in Fedora nfs-secure is one process ;-)=20

Oh yes, "nfs-secure" means "run rpc.gssd".
If you wanted to preserve that I think you could create a drop-in file
for rpc-gssd.service containing
   [Install]
   Alias=3Dnfs-secure.service
though that would require "systemctl enable rpc-gssd" so maybe it isn't the
best approach.


>=20
> >=20
> > I'm fairly sure we can keep that API working if you really need it, but
> > maybe as a fedora-specific hack?
> Yup! At the time I didn't know how to handle the security daemons
> that why there is a nfs-secure service and an nfs-server-secure
> service.=20
>=20
> The path we are head is much better...=20

Glad you think so :-)

NeilBrown

--Sig_/oPGoemddZ95zrG85j=VAou7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvG2Ijnsnt1WYoG5AQL1Sg//UlT+8o7c4udLomonxay9dtoYFhC/C75r
rtKE8BLbjLArf0ALWvu8n+uuIYvbFDEbhkP68JmzPC17C1FLe0fRKlugAMB16ReW
Z1AoWYuQtjGPscRGoy9swu0+u7sdZx8KNjjqmvWsnFUKjF4GBLYh6lVAQbutd8Xz
vRKAlksTsWqbhqhQgNQ/rxI8ylzRM12hKbQkGV5By0cC0CF2PYwDG3u7OdsGzCLG
czcpXDSB50ev2fXulyEZ38Zy/sPryRqBmFk3smD1/l33wo2oT1G2oqYJC++hbKKx
R34DEARAaMkKLADxOrp5IFBeh0M0G2ov3Bi44SewUFsBSnZ42A1nrUe1uvnRRO61
LtTVzR/YJPfbgGB6lHwQxd7kefKUcX/wv09Mi/JSoAcx9EnK1Mb0OHPp1Lfvj1AF
DkhUm1PXR5ARkItBSgAbOZfuo38oCwCn0G7QuHCpbvqAvYEXePBuAUrLG8mNSVlf
Og5PtqWzDFNbx+S/RB+ClCdUeoyWKeHP8fRXMpLwW3BzMtjS+ehKMwa6+ZXNvLyV
gP4UK2JNUGwTrPWlWJkeSz89aOULjRLd4LmhOmi5ejZeQwYCW5Czy9wR3j0KMFJ5
p82Ape85TFcsbCbzrHQLie/D1nuCKvbbR0yHumCyK4K+VLkkog3PfiL7MqkUFFoH
Zg1BekKatAw=
=vr9G
-----END PGP SIGNATURE-----

--Sig_/oPGoemddZ95zrG85j=VAou7--
