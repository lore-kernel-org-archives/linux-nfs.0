Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52624 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754020AbaIWBYB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 21:24:01 -0400
Date: Tue, 23 Sep 2014 11:23:52 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-server: Replace rpc.svcgssd with gssproxy in
 systemd script
Message-ID: <20140923112352.28917775@notabene.brown>
In-Reply-To: <541C892D.7020401@RedHat.com>
References: <1411146621-18797-1-git-send-email-steved@redhat.com>
	<1411146621-18797-2-git-send-email-steved@redhat.com>
	<541C892D.7020401@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/aZVGfFCNkWm.x2c3axOilNH"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aZVGfFCNkWm.x2c3axOilNH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 19 Sep 2014 15:51:09 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> Neil,
>=20
> On 09/19/2014 01:10 PM, Steve Dickson wrote:
> > Have the nfs-server depend/start on the gssproxy daemon
> > instead of rpc.svcgssd to manage GSSAPI credentials
> >=20
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > ---
> >  systemd/nfs-server.service | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> > index 2fa7387..3b04f84 100644
> > --- a/systemd/nfs-server.service
> > +++ b/systemd/nfs-server.service
> > @@ -2,12 +2,12 @@
> >  Description=3DNFS server and services
> >  Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
> >  Requires=3D nfs-mountd.service
> > -Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcg=
ssd.service
> > +Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service gssproxy=
.service
> >  Wants=3Drpc-statd-notify.service
> > =20
> >  After=3D network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.s=
ervice
> >  After=3D nfs-idmapd.service rpc-statd.service
> > -After=3D rpc-gssd.service rpc-svcgssd.service
> > +After=3D rpc-gssd.service gssproxy.service
> Is there a better way to do this, to be more backwards compatible?=20
>=20
> Maybe figure out that gssproxy is installed so would start that daemon
> if not fall back to rpc.svcgssd?=20
>=20
> Unfortunately systemd is still somewhat of a mystery to me.... :-(=20
>=20
> steved.
> >  Before=3D rpc-statd-notify.service
> > =20
> >  Wants=3Dnfs-config.service
> >=20

Hi Steve,
 as gssproxy is part of a separate package, I don't think it is appropriate
 for and nfs-utils service file to 'want' it.  I don't know that there are
 any "rules" about this so I make it up as I go along, but that seems right
 to me.

 Instead, the .service file which the gssproxy package installs
 should/could/might declare

    WantedBy=3Dnfs-server.service

 so if that is enabled, the linkage gets created.

 Either way, my idea is that starting nfs-server should try to start both
 svcgssd and gssproxy.
 rpc-svcgssd.service already declares itself as being *after* gssproxy so if
 both are available, gssproxy will be run first.
 If gssproxy starts and finds the kernel supports it, then it will be runni=
ng
 when rpc-svcgssd.service starts up and the Conditions in there will cause =
it
 to not start the actual daemon.

 So the nfs-utils .service files should not need changing.  All that should
 be needed for gssproxy to be used is:
 - gssproxy needs to be installed (of course)
 - gssproxy.service needs to declare "WantedBy=3Dnfs-server.service" in the
   [Install] section
 - 'systemctl enable gssproxy' needs to have been run somehow.  There are
   various ways to get this to happen at install time.


 However I haven't really tested this much.  I know I said I would do some
 testing of these unit files and I really do want to, but it just hasn't
 happened yet because ... you know, "life".=20

 I had a look at the gssproxy.service file and it already has
 'WantedBy=3Dmulti-user.target' the same as nfs-server.service.
 So if they are both enabled, they should both be started at the same time,
 and if should all *just*work*.

 I assume it doesn't *just*work* at present.  What is actually happening?  =
Do
 you have gssproxy.service 'enabled'??

Thanks,
NeilBrown

--Sig_/aZVGfFCNkWm.x2c3axOilNH
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCDLqDnsnt1WYoG5AQKAbw//c5Vh+o84x8J9IqEslfMctqxHSadLvoGy
fBzcGASbIIzfLLUctpLuWpHbCTgJIByACjNXTQj8ApsJ0fNaD2jrgMbjoanyowbW
l3rBrXindKakzp+Pr2+DdiqkRF/VbjL2+ByVKoZj9qwofBetrvTWlaxMosQTtz0E
d+H7hKYjitQFM1YyOjbx632pp6if55/BgnxLzqIToC4cx9U79PYsm88SHsUN6vq3
wlm5+AVz6VZ1LicyZ/LTnhqQI+vpOvqlX+2374wQOOgHlaTPZs0kP3NfRkhjCsVr
fO0Yf636Us27IpL1TiTWPz6AKFGW46lXdzQNxOyPn5gz0Y7WJzR+YWZWhgX7CpfO
boKCerVG1vsDGz0Orgnnn4M3T7ZMTDoz5cMQ5KoqAA4Rs6ud0W/hly1NmFYWsiq5
m1tOC1f8Ybq6zs7w/Z6PRg9dasld/DfUS+Se4xQ6cCWLygJLvvyX4LBrGsU18tb+
zLWd7hzZSNfLsomxWiodaX6oEQojPlY8Ar6LxXffuDnCXnjaLBzpSHAChSR9Govs
gg/1tT5miSSZp3AzfDJwIfSdUYJ9aFub1Hn9if6Dd3Z+3+E1EukauUSWBY0kVoD7
J15S4owiGQXH7vv2HRHhzgZ3YEzOWILLh2gkm1iVN5taAbIzeuvFXstogsUHqBCW
86oqZOqIfcE=
=1hWj
-----END PGP SIGNATURE-----

--Sig_/aZVGfFCNkWm.x2c3axOilNH--
