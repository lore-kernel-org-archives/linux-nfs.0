Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49231 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbaBSG54 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Feb 2014 01:57:56 -0500
Date: Wed, 19 Feb 2014 17:57:46 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] nfs-utils: systemd units bug fixes and comments.
Message-ID: <20140219175746.0481f690@notabene.brown>
In-Reply-To: <1392713329-17979-1-git-send-email-steved@redhat.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/fbxk.UpzlanAa=x1NGNJY1Q"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fbxk.UpzlanAa=x1NGNJY1Q
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Feb 2014 03:48:47 -0500 Steve Dickson <steved@redhat.com> wrote:

> Bug Fixes:
>=20
> The /proc/net/rpc/use-gss-proxy file can not be used
> as a start up trigger for rpc.svcsgssd since it always
> exists, with or without gss-proxy installed.
>=20
> Adding the Wants=3D to the nfs server unit cause a systemd ordering=20
> cycle which caused reboots to take forever.
>=20
> Comment One:
>=20
> Even though nfs-client does conditionally start the rpc.gssd=20
> service when /etc/krb5.keytab exists (which good), but that's=20
> all it does. Meaning 'systemctl status' does not show that rpc.gssd=20
> is running and 'systemctl restart' does not restart rpc.gssd=20
> and 'systemctl stop' does not stop the daemon.

Well it doesn't *only* start rpc.gssd, it also starts e.g. sm-notify.  But
maybe you meant that.  It only starts things, it doesn't stop them.
This how systemd works.  Certainly there is no way I can see for=20
   systemctl status foo
to report on anything but a single service: foo.  It might be nice if it
could report on a collection of services, but that doesn't seem to be
supported.

We could arrange that when you 'stop' nfs-client it would also stop rpc-gssd
(unless the server was running and wanted it) by setting
   StopWhenUnneeded=3Dyes

That isn't the default in systemd so I'm cautious of setting it without a
good reason.  However I don't object if it turns out that it works.

Restart is a bit tricky - again because both the client and the server want
some services.
You can enable Restart propagation by using PartOf=3D.  However that also
enables Stop propagation and we don't want that.  i.e. we don't want=20
   systemctl stop nfs-client
to unilaterally stop rpc.gssd - in particular not if nfs-server is running.


In short: I think that the inter-relationships in nfs-utils are too complex=
 to
allow the simplicity that you are seeking.  Or systemd isn't sophisticated
enough to represent them.


>=20
> It just seems odd to me that we will be using one target unit=20
> to enable a daemon then another service unit (rpc-gssd) to=20
> control it.=20
>=20
> I thinking we should  have one service unit, when enabled, control=20
> both the rpc.gssd and the rpc.svcgssd daemons. The start up trigger=20
> for both daemons will be the existence of /etc/krb5.keytab and=20
> rpc.svcgssd will only be started if the nfs server is=20
> enabled (if that is possible).

I originally thought that would not practical as the requirements for server
and client are different.  However I now see (thanks Bruce) that both the
client and the server need both rpc.gssd and rpc.svcgssd.  So we can have an
  nfs-secure
(or similar) which Wants both rpc-gssd and rpc-svcgssd.  Then both server a=
nd
client Want it.

However I don't think it should be "enabled".  It should automatically start
whenever nfs-server or nfs-client is started, providing the relevant files
exist.
(It can be 'masked' if someone has installed krb5 but really doesn't want t=
he
gss daemons running).

So you would still use a different service to enable it than to restart it.

Also "systemctl status nfs-secure" would not be able to show you the status
of both daemons.

>=20
> Comment Two:
>=20
> How about renaming the nfs-utils unit to nfs-services since a=20
> 'systemctl restart' of the unit start all the server and client=20
> daemons (even when the server is not enabled, which is probably a bug).
>=20

I don't object to a renaming.  The name "nfs-utils" was simply the first
thing I thought of.

  systemctl restart nfs-utils

should *not* start any service that is not already started.  I think I test=
ed
that.  However if I'm wrong we could argue that "try-restart" should be used
if you don't want to start services that aren't already running.... though
I'm not sure that would work.  Must test....

 systemctl stop nfs-utils

should stop services.  It uses "PartOf" which is supposed to apply to
'restart' and 'stop' equally.


> Since a 'systemctl restart nfs-utils' starts all the daemons shouldn't
> 'systemctl stop nfs-utils' bring them all down as well?

Doesn't it?

>=20
> Another oddity, going a 'systemctl restart nfs-utils' causes v3=20
> mounts to go stale... Meaning going a ls on a v3 mount point=20
> after the restart errors out with ESTALE... Not sure why...=20
>=20

That is weird and certainly needs looking in to.  I could be due to

   ExecStopPost=3D/usr/sbin/exportfs -au

I wonder if we really need that.

I hope to get some time tomorrow to experiment with all this and I will
definitely look into this issue (unless you explain it first :-)


> Comment Three:
>=20
> I'm not seeing how the nfs-utils_env.sh file, called by each unit,=20
> is all that useful. The main reason is you can not tell which=20
> unit its being called from so how do know what should be done?=20
> I guess I'm just missing the concept on how and what it should=20
> be used for.

I've got a patch which changes this so it is only called once in a separate
service.  However the principle remains unchanged.

The purpose of the script is to read /etc/sysconfig/nfs (or similar) and
write out /run/sysconfig/nfs-utils containing *all* the environment variabl=
es
used in *any* nfs-utils unit file.  It allows a translation from what is
expected in the sysconfig file to what the daemons expect as their argument=
s.

I see this as a transitional thing.  Ultimately the various daemons should =
be
able to inspect their environment, and expect exactly the things that might
be in the config file. So systemd just reads /etc/sysconfig/nfs and then ru=
ns
the daemons.  But that goal is a little ways off yet.

One thing we have in our sysconfig file is "NFS3_SERVER_SUPPORT".  If that =
is
set to "no", then as well as constructing appropriate arguments for rpc.mou=
ntd
and rpc.nfs we don't run rpc.statd (unless a v3 filesystem is mounted).
Handling the first part with nfs-utils_env.sh is trivial.  Handling the
second bit is something I haven't figured out yet.

Thanks for your comments.

NeilBrown


>=20
> Steve Dickson (2):
>   rpc-svcgssd.service: removed a the start up triggers
>   systemd: Removed the "ordering cycle" from nfs-server.service
>=20
>  systemd/nfs-server.service  | 2 --
>  systemd/rpc-svcgssd.service | 1 -
>  2 files changed, 3 deletions(-)
>=20


--Sig_/fbxk.UpzlanAa=x1NGNJY1Q
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwRV6jnsnt1WYoG5AQKJ9w//fOq1NBfowYweOefRbZcJ78cRZpWGyrxJ
LwsJdCLENSqwB4vbYP43DUGf0KyrH56wkDCZpTD8iNQOtrShUPIqHnLbzSKWpxHH
493FeqI7zdOJDYyzrmU8ppvG+D0WaP5VhYCXrINGI7VRNrpnEbci1XKYjdF5gc2H
OWlo3f5zhMcbMLaLXUltg6zihZURRY0/onuIa6Ws1DLFpkga7f8QQ666Kes0y62U
wrwWwhyM3j78t6gDJDC0oIyrdbd94Y8KMPHs7JDycpKZf5tL9nn502Rcs4LesuRq
hcAaTrNccsWd6VZ36irA88XkTT2NIW4uNcwN8GQ6VbQa5xsMGPlFsFbmc9g40YwN
YcxcFVnyXYAtgfd91jslD4nK/f+lq9oBLr/kIYk5SJZzuMp40Lb3n1ilD7B32/fR
c6KWLaru/H+nxf1caICqVHewhV17+0zE3lOI07my6/kj8prpahkQGARcKvZyYla7
EiPPqN1meWooan0SApnEw33DThjKV7m8SEubxiBB5dDJ2xdOHW9XovU21lOZDsds
EOZ69M0S/wUNCK0B//hYXVbZcCCOiT2aUMfqDsKcdeGCl4QIaF8p9167XXKJVPxg
EhF26RrjhWlX+n8DgxhDF94U3JQ70laPzpNmPGQ12vFafx3dsRQ5gRrL7z4FE15q
s8QEveaB2S4=
=LgIH
-----END PGP SIGNATURE-----

--Sig_/fbxk.UpzlanAa=x1NGNJY1Q--
