Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49604 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900AbaCXABH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Mar 2014 20:01:07 -0400
Date: Mon, 24 Mar 2014 11:00:59 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/6] systemd units: create nfs-config.service as single
 location to process config.
Message-ID: <20140324110059.0ed78f5e@notabene.brown>
In-Reply-To: <532DFFAB.7020707@RedHat.com>
References: <20140220065345.7320.49992.stgit@notabene.brown>
	<20140220065530.7320.61569.stgit@notabene.brown>
	<532DFFAB.7020707@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZFK3TJWHjEOuu9m2x4GJd2w"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZFK3TJWHjEOuu9m2x4GJd2w
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 22 Mar 2014 17:24:59 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> Hello,
>=20
> I finally got around to playing with these....
> Here is what I found.
>=20
> On 02/20/2014 01:55 AM, Neil Brown wrote:
> > Instead of processing the config information into command lines every
> > time it might be needed, do it once in a separate service that other
> > services can Want.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  systemd/README                   |    3 +--
> >  systemd/nfs-config.service       |    7 +++++++
> >  systemd/nfs-idmapd.service       |    5 +++--
> >  systemd/nfs-mountd.service       |    5 +++--
> >  systemd/nfs-server.service       |    4 +++-
> >  systemd/rpc-gssd.service         |    4 +++-
> >  systemd/rpc-statd-notify.service |    5 +++--
> >  systemd/rpc-statd.service        |    5 +++--
> >  systemd/rpc-svcgssd.service      |    5 +++--
> >  9 files changed, 29 insertions(+), 14 deletions(-)
> >  create mode 100644 systemd/nfs-config.service
> >=20
> > diff --git a/systemd/README b/systemd/README
> > index 8359530098f4..a2a5f0634726 100644
> > --- a/systemd/README
> > +++ b/systemd/README
> > @@ -56,8 +56,7 @@ Distro specific commandline configuration can be prov=
ided by
> >  installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
> >  This should write /run/sysconfig/nfs-utils based on configuration
> >  information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
> > -It should write to a tmp file and rename to the target to
> > -avoid parallel units seeing incomplete copies of the file.
> > +It is run once by nfs-config.service.
> > =20
> >  rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
> >  is present.
> > diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
> > new file mode 100644
> > index 000000000000..4cf2ecc76e4a
> > --- /dev/null
> > +++ b/systemd/nfs-config.service
> > @@ -0,0 +1,7 @@
> > +[Unit]
> > +Description=3DPreprocess NFS configuration
> > +
> > +[Service]
> > +type=3Doneshot
> This is a typo... It should be Type=3Doneshot

Groan.  Thanks.


>=20
> > +RemainAfterExit=3Dyes
> > +ExecStart=3D/usr/lib/systemd/scripts/nfs-utils_env.sh
> Can this be moved from /usr/lib/systemd/scripts to /usr/lib/systemd/system
> since the scripts directory does not exit and I don't think we
> want to be creating directories under /usr/lib/systemd/

Interesting question.
I don't think it really belongs in /usr/lib/systemd/system, though as it has
a ".sh" extension systemd isn't going to confuse it for a unit file.
However systemd developers seem to have the attitude to just "do it right,
even if that means doing something new", and I think a scripts directory is
"right", even though it is currently "new".

Though it isn't that new - a google for
   "/usr/lib/systemd/scripts"
(in quotes) claim 44000 hits, and those that I looked at are genuine (though
probably not all really unique).

If we agree that having shell scripts is appropriate we should probably rai=
se
the preferred location on the systemd-devel mailing list.


>=20
> Finally, Its a bit confusing on how to get the new /run/sysconfig/nfs-uti=
ls
> created. systemctl start nfs-config does not do it but=20
> systemctl restart nfs-config.=20
>=20
> Doesn't this also mean every time /etc/sysconfig/nfs is edited
> a systemctl restart nfs-config has to be done to update the=20
> new /run/sysconfig/nfs-utils and then restart the server=20
> they are reconfigured? Or am I missing something?

Fair comment.... Maybe we should use a 'path' unit to run the config-parser
every time /etc/sysconfig/nfs changes.
I'll see if I can make that work.

Thanks,
NeilBrown





>=20
> If I'm not it seems a bit overly complicated and its not=20
> appeared to be documented anywhere...=20
>=20
> steved.
>=20
> > diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> > index 7d0dd84d8a44..11895e234438 100644
> > --- a/systemd/nfs-idmapd.service
> > +++ b/systemd/nfs-idmapd.service
> > @@ -3,9 +3,10 @@ Description=3DNFSv4 ID-name mapping service
> > =20
> >  PartOf=3Dnfs-utils.service
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > -
> >  Type=3Dforking
> >  ExecStart=3D/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
> > diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> > index 90746a854b40..7ccc0f72012d 100644
> > --- a/systemd/nfs-mountd.service
> > +++ b/systemd/nfs-mountd.service
> > @@ -6,9 +6,10 @@ After=3Dnetwork.target
> >  PartOf=3Dnfs-server.service
> >  PartOf=3Dnfs-utils.service
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > -
> >  Type=3Dforking
> >  ExecStart=3D/usr/sbin/rpc.mountd $RPCMOUNTDARGS
> > diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> > index 5779fd39ed34..2fa7387e1cb9 100644
> > --- a/systemd/nfs-server.service
> > +++ b/systemd/nfs-server.service
> > @@ -10,9 +10,11 @@ After=3D nfs-idmapd.service rpc-statd.service
> >  After=3D rpc-gssd.service rpc-svcgssd.service
> >  Before=3D rpc-statd-notify.service
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > =20
> >  Type=3Doneshot
> >  RemainAfterExit=3Dyes
> > diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> > index 375792804247..d4a381904de4 100644
> > --- a/systemd/rpc-gssd.service
> > +++ b/systemd/rpc-gssd.service
> > @@ -9,9 +9,11 @@ ConditionPathExists=3D/etc/krb5.keytab
> > =20
> >  PartOf=3Dnfs-utils.service
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > =20
> >  Type=3Dforking
> >  ExecStart=3D/usr/sbin/rpc.gssd $GSSDARGS
> > diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notif=
y.service
> > index 7742ac8c5d9a..6b13b323e758 100644
> > --- a/systemd/rpc-statd-notify.service
> > +++ b/systemd/rpc-statd-notify.service
> > @@ -9,10 +9,11 @@ After=3Dnfs-server.service
> > =20
> >  PartOf=3Dnfs-utils.service
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D/usr/lib/systemd/scritps/nfs-utils_env.sh
> > -
> >  Type=3Doneshot
> >  RemainAfterExit=3Dyes
> >  ExecStart=3D-/usr/sbin/sm-notify -d $SMNOTIFYARGS
> > diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> > index 3f6cda16accd..c5795fd68f96 100644
> > --- a/systemd/rpc-statd.service
> > +++ b/systemd/rpc-statd.service
> > @@ -7,9 +7,10 @@ After=3Dnetwork.target nss-lookup.target rpcbind.target
> > =20
> >  PartOf=3Dnfs-utils.service
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > -
> >  Type=3Dforking
> >  ExecStart=3D/usr/sbin/rpc.statd --no-notify $STATDARGS
> > diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> > index 6bd45884d991..32b786ec5c7d 100644
> > --- a/systemd/rpc-svcgssd.service
> > +++ b/systemd/rpc-svcgssd.service
> > @@ -10,9 +10,10 @@ ConditionPathExists=3D|!@localstatedir@/run/gssproxy=
.pid
> >  ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy
> >  ConditionPathExists=3D/etc/krb5.keytab
> > =20
> > +Wants=3Dnfs-config.service
> > +After=3Dnfs-config.service
> > +
> >  [Service]
> >  EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > -ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > -
> >  Type=3Dforking
> >  ExecStart=3D/usr/sbin/rpc.svcgssd $SVCGSSDARGS
> >=20
> >=20


--Sig_/ZFK3TJWHjEOuu9m2x4GJd2w
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUy91uznsnt1WYoG5AQIVLA/7BofzWgY6d+clzLFu4s9OB4t03VShT4VF
IK66gfE3gr8UhQg1npMEd/UfF6P3KKtYzjVnwtwuUHMur3dMbxMBfazDw9ath/we
TrE+pg7k+QGh8KsZpYpAHUUDWZUOOlxXB8lOeb1cZWAeH4oq94tP7mC2LaKXi8II
mFBJs2CBfeESeFc8kkWvKNYYKc/2NsUMREK0ANQLIpgvD6lvwH5DUcUtLKIMTCdy
7iOxlqQn4arrGn/j8fOyf4ys3twrdfNTnEsDdrpPApN6TrAvOU+JZVWwj4I6weBX
a17yIrjUF+ODyGhWIvFDSVl6AFmqWiuhd/g8RiKdP3nbPiSWUeGk1JUaCv1Gvez6
3t1xqQJ5sv6jvIago95D7gA/fSkOed7FScF8lHhWoS/dLGb8VjNvqIxKU7HchT0j
Hzly/7tdCy7E1QNIjC+V/url/sqhIfJkC8Fi7NrjVfNShj/EzZLPs/VJHGGHT8o1
in9zdZAsS8iNOaZisSGpYyfmBUN3yihuMoBx28aqjXfSEFRZD153vVGcKdWe5sNW
QZMjba17STguO8UBkRZvRowCps7YVCMH/Zpdvpu4aGtBLwOeieYZ6SqJ8RKik+L6
BX2wpidAWnhF0MkqDroplKfcE+5gFlzwcvUMc6hmmvSc7saDC13WAnzsQz9fltm1
9KNbMmJe5s0=
=VeCi
-----END PGP SIGNATURE-----

--Sig_/ZFK3TJWHjEOuu9m2x4GJd2w--
