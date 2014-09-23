Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52800 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477AbaIWCBZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 22:01:25 -0400
Date: Tue, 23 Sep 2014 12:01:12 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923120112.6b3c0d6f@notabene.brown>
In-Reply-To: <20140922223423.GA29932@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922152603.75005941@willson.usersys.redhat.com>
	<54207BCD.70101@RedHat.com>
	<20140922204401.GI26763@fieldses.org>
	<5420911D.6080506@RedHat.com>
	<20140922223423.GA29932@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/r5K+l1mx0lti7IYy5JkdO/1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/r5K+l1mx0lti7IYy5JkdO/1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Sep 2014 18:34:23 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Sep 22, 2014 at 05:14:05PM -0400, Steve Dickson wrote:
> >=20
> >=20
> > On 09/22/2014 04:44 PM, J. Bruce Fields wrote:
> > > On Mon, Sep 22, 2014 at 03:43:09PM -0400, Steve Dickson wrote:
> > >>
> > >>
> > >> On 09/22/2014 03:26 PM, Simo Sorce wrote:
> > >>> On Mon, 22 Sep 2014 15:20:07 -0400
> > >>> Steve Dickson <steved@redhat.com> wrote:
> > >>>
> > >>>> Added the gssproxy.service to both the Wants=3D and
> > >>>> Atfers=3D lines, before the rpc-svcgssd.service. There
> > >>>> are  ConditionPathExists=3D lines in the rpc-svcgssd.service
> > >>>> unit which will stop the rpc.svcgssd daemon from
> > >>>> starting when the gssproxy daemon is already running.
> > >>>>
> > >>>> Signed-off-by: Steve Dickson <steved@redhat.com>
> > >>>> ---
> > >>>>  systemd/nfs-server.service | 5 +++--
> > >>>>  1 file changed, 3 insertions(+), 2 deletions(-)
> > >>>>
> > >>>> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.servi=
ce
> > >>>> index 2fa7387..c740fa2 100644
> > >>>> --- a/systemd/nfs-server.service
> > >>>> +++ b/systemd/nfs-server.service
> > >>>> @@ -2,12 +2,13 @@
> > >>>>  Description=3DNFS server and services
> > >>>>  Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
> > >>>>  Requires=3D nfs-mountd.service
> > >>>> -Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service
> > >>>> rpc-svcgssd.service +Wants=3Drpc-statd.service nfs-idmapd.service=
=20
> > >>>> +Wants=3Drpc-gssd.service =20
> > >>>>  Wants=3Drpc-statd-notify.service
> > >>>> =20
> > >>>>  After=3D network.target proc-fs-nfsd.mount rpcbind.target
> > >>>> nfs-mountd.service After=3D nfs-idmapd.service rpc-statd.service
> > >>>> -After=3D rpc-gssd.service rpc-svcgssd.service
> > >>>> +After=3D rpc-gssd.service gssproxy.service rpc-svcgssd.service
> > >>>>  Before=3D rpc-statd-notify.service
> > >>>> =20
> > >>>>  Wants=3Dnfs-config.service
> > >>>
> > >>> I think you really need to insure that the modules are loaded before
> > >>> any of the server services are started, perhaps adding a unit file =
that
> > >>> exec's modprobe and has "Before: gssproxy.service rpc-svcgssd.servi=
ce"
> > >>> in it ?
> > >> I really don't think its needed... From my testing it appears=20
> > >> gssproxy is always being started and rpc.svcgssd is not...=20
> > >=20
> > > Huh.  Well rpc-svcgssd.service has var-lib-nfs-rpc_pipefs.mount as bo=
th
> > > "Requires=3D" and "After=3D", so rpc-svcgssd.service will never run
> > > without first running var-lib-nfs-rpc_pipefs.mount, which will load
> > > sunrpc.  But I don't see where auth_rpcgss is getting loaded.  And I
> > > don't see what ensures anything happening before gssproxy runs.
> > It happens during the mount on the client and when the server
> > is started.=20
> >=20
> > >=20
> > > We want to make sure your testing's not just getting lucky on the
> > > startup order.
> > The reason it working is because rpc.gssd is being started on the serve=
r=20
> > these days for callbacks and the After=3D line in rpc-svcgssd.service i=
s being=20
> > executed before the ConditionPathExists which cause rpc.svcgssd not to =
start.
>=20
> nfs-utils$ grep After systemd/rpc-svcgssd.service=20
> After=3Dvar-lib-nfs-rpc_pipefs.mount
> After=3Dgssproxy.service
> After=3Dnfs-config.service
>=20
> There doesn't seem to be an After=3D line referring to rpc.gssd.
>=20
> > So when gssproxy.service does it's "Before=3Dnfs-secure.service nfs-sec=
ure-server.service"
> > line everything is loaded before gssproxy start...=20
>=20
> That line only makes gss-proxy start before those other things.
>=20
> > I'm think gssproxy.service just needs to the put the Wants and After=3D
> > var-lib-nfs-rpc_pipefs.mount lines, instead of that Before line..=20
>=20
> That would make sure sunrpc's loaded, but not auth_rpcgss.
>=20
> > >> Plus, from my understanding...  loading module from a service=20
> > >> file is a big no no! People were having problems with
> > >> way back when...=20
> > >=20
> > > Any pointers?  Google's not finding me anything.
> > Search the the Fedora bz's when systemd first came out...=20
>=20
> All I can find is:
>=20
> 	https://bugzilla.redhat.com/show_bug.cgi?id=3D699040#c16
>=20
> 	Btw afaik modules should be loaded via autoloading based on bus
> 	information, or via /etc/modules-load.d/*.conf. and unloading a
> 	module from the kernel should not be done except for debugging
> 	purposes so loading all these modules is it really necessary?
>=20
> Which I agree with--modules should normally load on demand when we need
> them, and we should have an explanation for exceptions.
>=20
> But here we have a pretty reasonable explanation (we need to know
> on startup whether a certain module has a certain feature, and we have
> to modprobe to do that).  I don't see any blanket prohibition against
> loading modules.
>=20
> OK, and in 702707 there's a request for support of the monolithic kernel
> case, but that's easy, we just allow the modprobe to fail in that case.
>=20

I certainly think it is absolutely fine for the service files for the gss
daemons to modprobe auth_rpcgss.  It would be really nice if the loading of
the module would automatically trigger the starting of the daemons, or would
signal the daemons to start talking to the module.  But that is probably
unnecessary complexity.

I would probably have a separate service file which did the modprobe.
It would declare itself to be Before=3D all of the gss daemons,
and it would be conditional on /etc/krb5.conf existing.
nfs-server would Want it, so it would be started when needed at just the
right time...

NeilBrown

--Sig_/r5K+l1mx0lti7IYy5JkdO/1
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCDUaTnsnt1WYoG5AQLa2hAAkbDJeDR3on4YX9F7ELyg3EM8gmFo4mMP
ruuepRKiH2D9u+96n6ZTspkZBKpdEt0pBUCGqeMX2ZSgjRtJCI/Y0csbeEIFRZNu
clZu/meHdhkbkerycW7xC5QsDsudSnFkehE2N192qLzMd2uOjRK6BxABDQGG+qXu
CKgURaH0SNdVkDhqGnh6sj2mRMsCBGMB1nZZRXBZbFXL08aSloskuOQt7TJ5Gtyx
qqH1YMyQPTrBzboxIhR4mFqBoH6MZxc/jRfYSAqXD0gloMHdrKjR3YtWw3TZlSxf
E4z8fVqfAtKswV5zj0IEzTF3ri1BbR6aqVkZ+dTbYstrSLzHJc2oHKD5uh3sBBYI
QQPYSEd+BqA7qk8jVL1/nfwf/hxGdx5wUtdz2NRpff/QqECNF4wM8IxOkavTRVmD
HdRoXId8ZwCiRm+214KEACmZ0B9y3D1ypacC/SmNA9Je2hyhaigaWPe4YB4A3UqB
GxY9I1eCS88B/BvJpkhxV+TGRtTx5hidHbqF1SOEMDTztM9RMW+nX5WI6loCSHn6
ZE7EUCb6695lNXieK3inqKE0qHAH4nY94GPiVsfsQ+XuaCFOHjtG5Wr7h+HMWjsH
0hX+XrPMMEvUF1czP5/IxuO50R0fzCeMtt19zdclU29LZ7Naknx59XZKp9HjpMDp
BprdS2FegGc=
=vwK0
-----END PGP SIGNATURE-----

--Sig_/r5K+l1mx0lti7IYy5JkdO/1--
