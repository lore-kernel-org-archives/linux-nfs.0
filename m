Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52938 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982AbaIWCIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 22:08:14 -0400
Date: Tue, 23 Sep 2014 12:08:04 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923120804.51dbcc2e@notabene.brown>
In-Reply-To: <20140923015549.GB32712@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922152603.75005941@willson.usersys.redhat.com>
	<54207BCD.70101@RedHat.com>
	<20140922204401.GI26763@fieldses.org>
	<5420911D.6080506@RedHat.com>
	<20140922223423.GA29932@fieldses.org>
	<5420B78D.6040704@RedHat.com>
	<20140922202655.5e308e58@willson.usersys.redhat.com>
	<20140923015549.GB32712@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/e86V8TWfp9aNpuGJnDdd3Ml"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/e86V8TWfp9aNpuGJnDdd3Ml
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Sep 2014 21:55:49 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Sep 22, 2014 at 08:26:55PM -0400, Simo Sorce wrote:
> > On Mon, 22 Sep 2014 19:58:05 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> >=20
> > >=20
> > >=20
> > > On 09/22/2014 06:34 PM, J. Bruce Fields wrote:
> > > > On Mon, Sep 22, 2014 at 05:14:05PM -0400, Steve Dickson wrote:
> > > >>
> > > >>
> > > >> On 09/22/2014 04:44 PM, J. Bruce Fields wrote:
> > > >>> On Mon, Sep 22, 2014 at 03:43:09PM -0400, Steve Dickson wrote:
> > > >>>>
> > > >>>>
> > > >>>> On 09/22/2014 03:26 PM, Simo Sorce wrote:
> > > >>>>> On Mon, 22 Sep 2014 15:20:07 -0400
> > > >>>>> Steve Dickson <steved@redhat.com> wrote:
> > > >>>>>
> > > >>>>>> Added the gssproxy.service to both the Wants=3D and
> > > >>>>>> Atfers=3D lines, before the rpc-svcgssd.service. There
> > > >>>>>> are  ConditionPathExists=3D lines in the rpc-svcgssd.service
> > > >>>>>> unit which will stop the rpc.svcgssd daemon from
> > > >>>>>> starting when the gssproxy daemon is already running.
> > > >>>>>>
> > > >>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
> > > >>>>>> ---
> > > >>>>>>  systemd/nfs-server.service | 5 +++--
> > > >>>>>>  1 file changed, 3 insertions(+), 2 deletions(-)
> > > >>>>>>
> > > >>>>>> diff --git a/systemd/nfs-server.service
> > > >>>>>> b/systemd/nfs-server.service index 2fa7387..c740fa2 100644
> > > >>>>>> --- a/systemd/nfs-server.service
> > > >>>>>> +++ b/systemd/nfs-server.service
> > > >>>>>> @@ -2,12 +2,13 @@
> > > >>>>>>  Description=3DNFS server and services
> > > >>>>>>  Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
> > > >>>>>>  Requires=3D nfs-mountd.service
> > > >>>>>> -Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service
> > > >>>>>> rpc-svcgssd.service +Wants=3Drpc-statd.service
> > > >>>>>> nfs-idmapd.service +Wants=3Drpc-gssd.service =20
> > > >>>>>>  Wants=3Drpc-statd-notify.service
> > > >>>>>> =20
> > > >>>>>>  After=3D network.target proc-fs-nfsd.mount rpcbind.target
> > > >>>>>> nfs-mountd.service After=3D nfs-idmapd.service rpc-statd.servi=
ce
> > > >>>>>> -After=3D rpc-gssd.service rpc-svcgssd.service
> > > >>>>>> +After=3D rpc-gssd.service gssproxy.service rpc-svcgssd.service
> > > >>>>>>  Before=3D rpc-statd-notify.service
> > > >>>>>> =20
> > > >>>>>>  Wants=3Dnfs-config.service
> > > >>>>>
> > > >>>>> I think you really need to insure that the modules are loaded
> > > >>>>> before any of the server services are started, perhaps adding a
> > > >>>>> unit file that exec's modprobe and has "Before:
> > > >>>>> gssproxy.service rpc-svcgssd.service" in it ?
> > > >>>> I really don't think its needed... From my testing it appears=20
> > > >>>> gssproxy is always being started and rpc.svcgssd is not...=20
> > > >>>
> > > >>> Huh.  Well rpc-svcgssd.service has var-lib-nfs-rpc_pipefs.mount
> > > >>> as both "Requires=3D" and "After=3D", so rpc-svcgssd.service will
> > > >>> never run without first running var-lib-nfs-rpc_pipefs.mount,
> > > >>> which will load sunrpc.  But I don't see where auth_rpcgss is
> > > >>> getting loaded.  And I don't see what ensures anything happening
> > > >>> before gssproxy runs.
> > > >> It happens during the mount on the client and when the server
> > > >> is started.=20
> > > >>
> > > >>>
> > > >>> We want to make sure your testing's not just getting lucky on the
> > > >>> startup order.
> > > >> The reason it working is because rpc.gssd is being started on the
> > > >> server these days for callbacks and the After=3D line in
> > > >> rpc-svcgssd.service is being executed before the
> > > >> ConditionPathExists which cause rpc.svcgssd not to start.
> > > >=20
> > > > nfs-utils$ grep After systemd/rpc-svcgssd.service=20
> > > > After=3Dvar-lib-nfs-rpc_pipefs.mount
> > > > After=3Dgssproxy.service
> > > > After=3Dnfs-config.service
> > > >=20
> > > > There doesn't seem to be an After=3D line referring to rpc.gssd.
> > > No, why should there be? There is After=3D line referring to rpc.gssd
> > > in nfs-server.service
> > >=20
> > > grep After systemd/nfs-server.service=20
> > > After=3D network.target proc-fs-nfsd.mount rpcbind.target
> > > nfs-mountd.service After=3D nfs-idmapd.service rpc-statd.service
> > > After=3D rpc-gssd.service rpc-svcgssd.service
> > > After=3Dnfs-config.service
> > >=20
> > > So when the server starts,rpc.gssd will start and rpc.svcgssd will
> > > start if gssproxy is not enable and there is a key tab.=20
> >=20
> > They can start in parallel, there is nothing in that line that makes
> > one start before the other.
> >=20
> > If you are relying on this you are relying on luck.
> >=20
> > > >> So when gssproxy.service does it's "Before=3Dnfs-secure.service
> > > >> nfs-secure-server.service" line everything is loaded before
> > > >> gssproxy start...=20
> > > >=20
> > > > That line only makes gss-proxy start before those other things.
> > > Right, which will load the sunrpc modules.
> >=20
> > No, starting before those service in itself achieves nothing.\
> > I think what may cause the module to load maybe the fact
> > gssproxy.service includes:
> > Requires=3Dproc-fs-nfsd.mount
>=20
> I'd expect that to only load the nfsd module.
>=20
> Hm, I think nfsd actually has a dependency on auth_rpcgss.  I wonder if
> that's correct.  Maybe that's what's doing it.
>=20
> > But to be honest this was a hack to deal with broken nfs service files,
> > gss-proxy should not require nfsd, the dependency should be the other
> > way around, as gss-proxy can run on machines where there is no nfs
> > service whatsoever, as it stand this is a bug in gssproxy.service and
> > I'd like to fix it.
>=20
> So, something like this?  (Untested, no idea if I'm doing this right.)
>=20
> --b.
>=20
> diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-mod=
ule.service
> new file mode 100644
> index 000000000000..252545b458fd
> --- /dev/null
> +++ b/systemd/auth-rpcgss-module.service
> @@ -0,0 +1,15 @@
> +# We want to start gss-proxy on kernels that support it and rpc.svcgssd
> +# on those that don't.  Those services check for support by checking
> +# for existence of the path /proc/net/rpc/use-gss-proxy.  Before they
> +# can perform that check, they need this module loaded.  (Unless
> +# rpcsec_gss is built directly into the kernel, in which case this unit
> +# will fail.  But that's OK.)
> +[Unit]
> +Description=3DKernel Module supporting RPCSEC_GSS
> +Before=3Dgssproxy.service rpc-svcgssd.service
> +
> +[Service]
> +ExecStart=3D/sbin/modprobe -q auth_rpcgss

I think you need
   Type=3Doneshot

else systemd won't wait for the modprobe to complete before running the oth=
er
services.

> +
> +[Install]
> +WantedBy=3Dgssproxy.service rpc-svcgssd.service

I don't think you want an install section.  That means the service has to be
explicitly enabled, which is a pain.
I think nfs-server.service should Want=3D this.
I also think=20

  ConditionPathExists=3D/etc/krb5.keytab

would be appropriate.

Thanks,
NeilBrown

--Sig_/e86V8TWfp9aNpuGJnDdd3Ml
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCDWBDnsnt1WYoG5AQKmXxAAwRyhg3EONfqM31Ubbe5fBHc1cify1YBx
73/MFYUrTav72DsyXfXa8atxcpxVrrbmUWJmhxCuDKHhq3ELov+wSw6nLrH5p3sI
WRJE6+3ixNGDCorL+osB818ZLOKg6EdTZbirNeD+ObRskkcG5VI4hlACH4meL/UQ
S9g4Ng1Hd7iU2KN52BNTuzAB6i0l5WP3yn9Jd9LrJiOAHuSZkjxGDeUgzfi+NERn
45IDvgyQoY+m4kYBJ+vRbZuSSX7yG90646LJpZQJVlW8U5a5b3EMM7o0nlswWA5E
B0Cdjx/qdTPcGEJXaiHp4DJN/yx0Kpu092/AVBlkjs1JkiSu/H5+XqevboxnXCjx
kczEjXsl3ml1Mz/ZosWaG7L3GI7FepvGgR6KcQgSHdj5OW3wXF2Mjzrm/YruLA6C
ofNlrG9ECpioFK3bqpVUlo+V6f/UfNNnQW0lVtPFy/iFVdGA0XToFwWX4nPIKO8I
/cTsYhDrqGvLx7LHGl0XaYxAheOBUYW0zUoNcmnoHud0F862/M2vE05WrSn/pSia
uvN6u3UDvT3LSkh5i7I/znFF1XQDY08EVPSyS++aYs0CrbiPcgBO/6gcuWwwJoYa
3B1+l5kUEX+ev9/Hof01om2IU7CyddPhKxMgtH/xoBWOP/Njc7cyF8o045LLX8Cf
EOU2FFcURkc=
=4I3R
-----END PGP SIGNATURE-----

--Sig_/e86V8TWfp9aNpuGJnDdd3Ml--
