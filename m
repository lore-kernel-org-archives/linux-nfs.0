Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40706 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753528AbaBCWfE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Feb 2014 17:35:04 -0500
Date: Tue, 4 Feb 2014 09:34:52 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140204093452.7b6d7c7d@notabene.brown>
In-Reply-To: <52F003A1.3060908@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/mu78NDHp.hAoPCXggS/Sk9j"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/mu78NDHp.hAoPCXggS/Sk9j
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 01/30/2014 01:24 AM, NeilBrown wrote:
> >=20
> >  So:
> >   1/ Do you agree that a collection of systemd unit files belongs in
> >      nfs-utils?
> I think having a single way to start NFS across all distors would be
> a very good thing...=20
>=20
> >   2/ Do you think it reasonable to expect most (systemd using) distros =
to
> >      use the one set?  I will certainly try to ensure openSUSE does if
> >      upstream accepts them.
> I think I'll already agreed to this as well...=20
>=20
> >   3/ Do you have any comments/question about those below?
> I took a little closer look at these and actual tried to=20
> get them to work in a Fedora environment. Here is what I found..
>=20
>=20
> > diff --git a/systemd/README b/systemd/README
> > new file mode 100644
> > index 000000000000..f0fb68825499
> > --- /dev/null
> > +++ b/systemd/README
> > @@ -0,0 +1,50 @@
> > +
> > +Notes about systemd unit files for nfs-utils.
> > +
> > +The unit files provided here should be sufficient for systemd
> > +to manage all daemons and related services provides by nfs-utils.
> > +
> > +They do *not* include any unit files for separate services such as
> > +rpc.rquotad (in the 'quota' package) or rpcbind.
> > +
> > +There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
> > +by a suitable 'preset' setting:
> > +
> > + nfs-server.target
> > +    If enabled, nfs service is started together with dependencies
> > +    such as mountd, statd, rpc.idmapd
> This changes the current API... Today to enable/start this service=20
> today one does:
>=20
>   systemctl enable nfs-server
>   systemctl start nfs-server
>=20
> which would change to:
>=20
>   systemctl enable nfs-server.target
>   systemctl start nfs-server

I think this would need to be "systemctl start nfs-server.target".

>=20
> with the same daemons being started.
> This changed will cause existing scripts to fail...=20
> I guess I don't see the point of having a .target file.=20

It's frustrating that "foo" is treated as "foo.service" rather than
"foo.target" but I guess we have to live with it.

According to the documentation a .service file "encodes
information about a process controlled and supervised by systemd."

nfs-server isn't "a process", it is a collection of processes.

A .target is "used for grouping units" so it makes sense to me to group all
the nfs-server units in an "nfs-server.target".

So the structure makes sense based on the documentation and apparent design
of systemd.  Unfortunately it leads to this clumsy API of having to give the
".target" suffix.

I guess it makes sense to merge nfs-server.service and nfs-server.target as,
after all, nfs-server.service doesn't describe a process controlled by
systemd anyway - it is a 'oneshot'....
I'll send a patch to do that.


>=20
> How is rpc.svcgssd enabled? Since the .service file does
> not have a [Install] section the systemctl enable rpc.svcgssd
> fails.

The "README" touches on this.  If you
   systemctl enable nfs-secure.target
then rpc.svcgssd will be run whenever nfs-server.target is started.
Also rpc.gssd will be run whenever nfs-server.target or nfs-client.target is
started.

>=20
> Also how does gss-proxy come to play in all this? Maybe we=20
> just use  gss-proxy by default and retire rpc.svcgssd.

I haven't really be following and so am only dimly aware of gss-proxy.
It's a replacement for rpc.svcgssd - right?
So we should get it to start in the same circumstances as rpc.svcgssd?

Is there some easy test - eg something existing in the filesystem - that we
could use to see if the kernel supports gss-proxy ?

Also, I've been wondering if we could avoid the need to explicitly enable
the gss stuff by gating it on the existence of /etc/krb5.keytab.
Do you think that would be reasonable?

>=20
> > +
> > + nfs-client.target
> > +    If enabled, daemons needs for an nfs client are enabled.
> > +    This does *not* include rpc.statd.  the rpc-statd.service unit
> > +    is started by /usr/sbin/start-statd which mount.nfs will run
> > +    if statd is needed.
> I am coming around to liking this one... but I think it should start
> statd and configure lockd. Why not just roll the current nfs-lock=20
> service under this umbrella? A simple systemctl restart nfs-client
> would configure and start all of the needed daemons.=20

I just feels like the wrong place to be setting sysctl values... But maybe.
And why start statd if it isn't needed.

>=20
> How would these daemons be restart and shutdown? Since this is a=20
> target, systemctl restart and system stop don't do anything.

This is something I haven't completely figured out yet.

Part of the solution might be the "PartOf" directive.
If each service claims to be "PartOf" the main one, then stopping or
restarting the main service will propagate to stopping and restarting the
individual services.
Unfortunately in nfs we have some shared services.  rpc.statd and rpc.gssd
are needed by both server and client.  That isn't a big problem for 'restar=
t',
but if you 'systemctl stop nfs-client' and find that the server isn't
properly working any more, that would be awkward
If could possibly work around that by setting "StopWhenUnneeded" for those
shared services.  Then e.g. rpc.statd would stop when both client and server
are stopped, but not if either one of them is stopped.
However I don't know how that interacts with restart.  I suspect that the
StopWhenUnneeded services are *not* stopped and restarted when the main
service is stopped.  So it would  be  hard to restart all nfs services on an
upgrade.

Further research seems needed here.


>=20
> > +
> > + nfs-secure.target
> > +    If enabled, then rpc.gssd will be run when either -client or
> > +    -server is started, and rpc.svcgssd will be run when -server
> > +    is started
> I like that fact that rpc.gssd is started by nfs-client but=20
> I don't like that API change. systemctl restart nfs-secure breaks=20

Why would you want to "restart nfs-secure".  I can understanding wanting to
restart individual processed, or the whole collection, but why that subset?

I'm fairly sure we can keep that API working if you really need it, but
maybe as a fedora-specific hack?
> =20
> > +
> > + nfs-blkmap.target
> > +    If enabled, then blkmapd will be run when nfs-client.target is
> > +    started.
> Unless someone steps up and says why this is needed or if it will=20
> ever be needed... I'm seriously thinking about dropping it from Fedora.
>=20
> I think overall its workable but I just don't see the advantage=20
> of using .targets over .service files...=20
>=20
> steved.

Thanks for your very thorough review.

NeilBrown

--Sig_/mu78NDHp.hAoPCXggS/Sk9j
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvAZjDnsnt1WYoG5AQLvXg//R/uyyfZRc3Zl4m7E1MQnD6X6qW5VOTSv
xYxdDoiyOf+54HVJAO+j1PKC3SW5Hu8Wg87SjBAVnHG2eUWBcwdvRyEgnKGjX1r3
79EhkHBsoyCh8enlgK132Jr84dcnu5iyi7IBSVnV1XuGAhTn5j4V/lesZkPxod+h
JwDDeHnCW03KwDS7QkV9yR1BVg6OK4CYT8s/5r93nw8ONMeQEXjd6X/zW4Lqqde1
jBRW0ClwqQ9OjxV6TflfLN2GaId2dK6Vtw9bmBcOd0+h9IPrtGlSJHUh7uLc0fh7
mjIBv/cHTIuLMx/pdflRxSlVgjpnu/wk8DKNiLPxawNET/Upow5NwOyNIVJt//H7
o+ayc0tZqNGXTtYHW/uvptJmuoAVMbn0z9aa2BoJ1zufr4GfmWCMJgu+uELSz589
xBWvmKjuksRb1hUdl0A1dN5il5ZNIMtf0RXbS+CfO7Sv9MAbalL+Kzr75UD8W7TZ
WmWffElQb/AGaag7guwdEQDSpDEAgUQybDT/5M7+sci33SXRsY0l6PZp/KT/TJqS
/T7nIxm+bywT9oiMksL5on3HgdEHF9bNVLtMv8KbUAIbjhNQ3A0W8uwo67aQPvRV
ld9K8hvlHQIIM0u2jWlGt3HcwpfFXzB/FGUzLDtdspOB0vtyJifEnwFFU6sPnp+O
xH9pezyic4o=
=dNyE
-----END PGP SIGNATURE-----

--Sig_/mu78NDHp.hAoPCXggS/Sk9j--
