Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57596 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbaA3WPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jan 2014 17:15:05 -0500
Date: Fri, 31 Jan 2014 09:14:55 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140131091455.550e59a8@notabene.brown>
In-Reply-To: <52EAB0CA.2090204@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52EAB0CA.2090204@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/0XNlqiR/24z=JaSfW17HuVV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/0XNlqiR/24z=JaSfW17HuVV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 30 Jan 2014 15:06:34 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 01/30/2014 01:24 AM, NeilBrown wrote:
> >=20
> > Hi all,
> >=20
> >  I would really like to see a common set of systemd unit files used for
> >  nfs-utils by every distribution (that actually uses systemd), and woul=
d like
> >  those unit files to be in the upstream nfs-utils package.
> >=20
> >  To that end I have put together the following collection of unit files=
 which
> >  seem right to me, and appear to work as I think I want them to work.
> >=20
> >  I've looked at the unit files in Fedora and borrowed some ideas while
> >  discarding and changing others.  I won't try to list and justify all t=
he
> >  changes here, but I'm perfectly willing (possibly even eager) to justi=
fy
> >  anything specific that anyone cares to ask about.
> >=20
> >  So:
> >   1/ Do you agree that a collection of systemd unit files belongs in
> >      nfs-utils?
> I would think so...=20
> >   2/ Do you think it reasonable to expect most (systemd using) distros =
to
> >      use the one set?  I will certainly try to ensure openSUSE does if
> >      upstream accepts them.
> >   3/ Do you have any comments/question about those below?
> >=20
> >=20
> > Thanks,
> > NeilBrown
> >=20
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
> > +
> > + nfs-client.target
> > +    If enabled, daemons needs for an nfs client are enabled.
> > +    This does *not* include rpc.statd.  the rpc-statd.service unit
> > +    is started by /usr/sbin/start-statd which mount.nfs will run
> > +    if statd is needed.
> > +
> > + nfs-secure.target
> > +    If enabled, then rpc.gssd will be run when either -client or
> > +    -server is started, and rpc.svcgssd will be run when -server
> > +    is started
> > +
> > + nfs-blkmap.target
> > +    If enabled, then blkmapd will be run when nfs-client.target is
> > +    started.
> Do we really need all of these targets? Could we cut it down to
> two. nfs.target and nfs-secure.target?
>=20

Excellent question.
My thought was to err on the side of providing too many rather than too few.
If a distro wants to remove a particular choice it can use the "presets"
feature off systemd to make sure that target is always enabled.

But I think you might be questioning specific targets rather than the gener=
al
number of targets - I respond to that below.


> > +
> > +
> > +It is possible that we should have an nfs-statd.target which can
> > +selectively enable statd being stared by -server and sm-notify
> > +being started by -server or -client.  That way it could be disabled
> > +completely on V4-only configurations.  Currently statd is always
> > +started on the server and sm-notify is always run if server or
> > +client is enabled.
> > +
> > +Stopping nfs-server will also stop rpc.mountd, and rpc.svcgssd.
> > +It cannot stop rpc.statd or rpc.gssd as they may be in use by the
> > +client and systemd cannot specify is two-pronged reverse dependency.
> > +(i.e. stop this unit if none of these units are running)
> > +
> > +Distro specific commandline configuration can be provided by
> > +installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
> > +This should write /run/sysconfig/nfs-utils based on configuration
> > +information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
> > +It should write to a tmp file and rename to the target to
> > +avoid parallel units seeing incomplete copies of the file.
>=20
> > diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> > new file mode 100644
> > index 000000000000..7319a88661cc
> > --- /dev/null
> > +++ b/systemd/nfs-blkmap.service
> > @@ -0,0 +1,11 @@
> > +[Unit]
> > +Description=3DpNFS block layout mapping daemon
> > +After=3Dvar-lib-nfs-rpc_pipefs.mount
> > +Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> > +
> > +Requisite=3Dnfs-blkmap.target
> > +After=3Dnfs-blkmap.target
> > +
> > +[Service]
> > +Type=3Dforking
> > +ExecStart=3D/usr/sbin/blkmapd
> Is this even supported anymore? Maybe we can just drop it???

No idea.  I found it as I was looking around and assumed it should be start=
ed.
If it is no longer supported, how does NFS now find the block devices for
direct pnfs access?


>=20
>=20
> > diff --git a/systemd/nfs-blkmap.target b/systemd/nfs-blkmap.target
> > new file mode 100644
> > index 000000000000..fbcc111152ee
> > --- /dev/null
> > +++ b/systemd/nfs-blkmap.target
> > @@ -0,0 +1,8 @@
> > +[Unit]
> > +Description=3D PNFS blkmaping enablement.
> > +# If this target is enabled, then blkmapd will be started
> > +# as required.  If it is not enabled it won't.
> > +
> > +[Install]
> > +WantedBy=3Dremote-fs.target
> > +WantedBy=3Dmulti-user.target
> > \ No newline at end of file
>=20
> Again, why is a client target needed? Now that idmappings are
> stored in the key ring what needs to be started on the client?

rpc.gssd?

Also sm-notify needs to be run on a machine this is used as an NFS client.
This should happen even if no NFS filesystems are mounted at boot.
An 'nfs-client' target seems the natural place to put that requirement.

>=20
> > diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> > new file mode 100644
> > index 000000000000..fa591354abf3
> > --- /dev/null
> > +++ b/systemd/nfs-client.target
> > @@ -0,0 +1,13 @@
> > +[Unit]
> > +Description=3DNFS client services
> > +Before=3Dremote-fs-pre.target
> > +Wants=3Dremote-fs-pre.target
> > +
> > +# Note: we don't "Wants=3Drpc-statd.service" as "mount.nfs" will arran=
ge to
> > +# start that on demand if needed.
> > +Wants=3Drpc-gssd.service nfs-blkmap.service rpc-statd-notify.service
> > +Before=3Drpc-gssd.service nfs-blkmap.service
> > +
> > +[Install]
> > +WantedBy=3Dmulti-user.target
> > +WantedBy=3Dremote-fs.target
>=20
>=20
> > diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> > new file mode 100644
> > index 000000000000..6c2e1537f064
> > --- /dev/null
> > +++ b/systemd/nfs-idmapd.service
> > @@ -0,0 +1,9 @@
> > +[Unit]
> > +Description=3DNFSv4 ID-name mapping service
> Fedora has in the [Unit]:
> BindTo=3Dnfs-server.service
> After=3Dnfs-server.service
> I guess I thought they were needed at the time..

Yes, I saw that.  So I looked into it.
Apart from being a typo ("BindsTo" with an 's' is correct),
BindsTo has an extra effect if the target unit - nfs-server.service in this
case - disappears unexpectedly.  e.g. if the process dies.
However nfs-server.service doesn't have a process which can die.  Rather it
starts some kernel threads.  I'm pretty sure systemd won't be able to link
those threads with nfs-server.service.
So nfs-server.service can never "die", so "BindsTo" add nothing useful.

"After" just seems wrong.  The moment nfsd is started a request could come =
in
which could require an idmap lookup, so nfs-idmapd should already be there.

>=20
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > +
> > +Type=3Dforking
> > +ExecStart=3D/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
>=20
>=20
> > diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> > new file mode 100644
> > index 000000000000..92e05ca309ee
> > --- /dev/null
> > +++ b/systemd/nfs-mountd.service
> > @@ -0,0 +1,13 @@
> > +[Unit]
> > +Description=3DNFS Mount Daemon
> > +Requires=3Dproc-fs-nfsd.mount
> > +After=3Dproc-fs-nfsd.mount
> > +After=3Dnetwork.target
> > +PartOf=3Dnfs-server.service
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> How does this script know who is calling it and what it
> has to do?=20

Its task is to read some config file like /etc/sysconfig/nfs and determine
what the command line arguments for each nfs program should be and write out
 FOO_ARGS=3D
lines to /run/sysconfig/nfs-utils for each FOO which is an nfs program.
I have since thought this would work better as a separate unit which creates
the nfs-utils env file once, and have all the other units have Wants/After
dependencies.


>=20
> > +
> > +Type=3Dforking
> > +ExecStart=3D/usr/sbin/rpc.mountd $RPCMOUNTDARGS
>=20
>=20
> > diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
> > new file mode 100644
> > index 000000000000..0127fdb07dbd
> > --- /dev/null
> > +++ b/systemd/nfs-secure.target
> > @@ -0,0 +1,8 @@
> > +[Unit]
> > +Description=3DSecure NFS client/server services
> > +# If this target is enabled, then rpc.gssd and rpc.svcgssd will be sta=
rted
> > +# as required.  If it is not enabled they won't.
> So the "Requisite=3Dnfs-secure.target" in rpc-gssd.service cause the=20
> daemon to started?

This is a bit subtle.
The "Requisite=3Dnfs-secure.target" in rpc-gssd.service means that service =
is
only allowed to start if this unit (nfs-secure.target) is already started.
So if nfs-secure.target is enabled, then rpc-gssd.service will start when
anything Wants it.  If nfs-secure.target is not enabled, then
rpc-gssd.service will not start, even if something Wants it.

So enabling nfs-secure.target doesn't start anything, just allows a couple =
of
things to start if they are Wanted.


>=20
> > +
> > +[Install]
> > +WantedBy=3Dremote-fs.target
> > +WantedBy=3Dmulti-user.target
> > \ No newline at end of file
>=20
>=20
> > diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> > new file mode 100644
> > index 000000000000..9812866c66aa
> > --- /dev/null
> > +++ b/systemd/nfs-server.service
> > @@ -0,0 +1,24 @@
> > +[Unit]
> > +Description=3DNFS server
> > +DefaultDependencies=3Dno
> > +Requires=3D network.target proc-fs-nfsd.mount rpcbind.target
> > +PartOf=3Dnfs-server.target
> > +
> > +After=3D network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.s=
ervice
> > +After=3D nfs-idmapd.service rpc-statd.service
> > +After=3D rpc-gssd.service rpc-svcgssd.service
> > +Before=3D rpc-statd-notify.service
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > +
> > +Type=3Doneshot
> > +RemainAfterExit=3Dyes
> > +ExecStartPre=3D/usr/sbin/exportfs -r
> > +ExecStart=3D/usr/sbin/rpc.nfsd $RPCNFSDARGS
> Having ExecStartPre and ExecStartPost scripts gives
> us a place to do some pre and post server configuration.
>=20
> Granted it has not been needed in a while but I'm thinking
> it could come in handing...=20

systemd supports so-called "dropins".  If a distro wants to add an
ExecStartPre for some distro-specific reason they can put it in

 /etc/systemd/system/nfs-server.service.d/04-Fedora-hacks.conf

and it will be understood by systemd to be part of this service.
Of course if they were not distro-specific reasons we would include them in
the upstream package :-)

I note that the Fedora nfs-server.service has a preconfig
 echo "$NFSD_V4_GRACE" > /proc/fs/nfsd/nfsv4gracetime

and a postconfig
        /sbin/modprobe svcrdma
        echo "rdma $RDMA_PORT" > /proc/fs/nfsd/portlist

These seem reasonably general, though I'm wondering why the RDMA port is set
in postconfig rather than preconfig.
Do you know why that is?

>=20
> > +ExecStop=3D/usr/sbin/rpc.nfsd 0
> > +ExecStopPost=3D/usr/sbin/exportfs -au
> > +ExecStopPost=3D/usr/sbin/exportfs -f
> > +
> > +ExecReload=3D/usr/sbin/exportfs -r
>=20
>=20
> > diff --git a/systemd/nfs-server.target b/systemd/nfs-server.target
> > new file mode 100644
> > index 000000000000..a3e629f022a9
> > --- /dev/null
> > +++ b/systemd/nfs-server.target
> > @@ -0,0 +1,8 @@
> > +[Unit]
> > +Description=3DNFS server services
> > +Requires=3Dnfs-server.service nfs-mountd.service
> > +Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcg=
ssd.service
> > +Wants=3Drpc-statd-notify.service
> > +
> > +[Install]
> > +WantedBy=3Dmulti-user.target
>=20
>=20
> > diff --git a/systemd/proc-fs-nfsd.mount b/systemd/proc-fs-nfsd.mount
> > new file mode 100644
> > index 000000000000..f44d52f3d67b
> > --- /dev/null
> > +++ b/systemd/proc-fs-nfsd.mount
> > @@ -0,0 +1,8 @@
> > +[Unit]
> > +Description=3DNFSD configuration filesystem
> > +DefaultDependencies=3Dno
> > +
> > +[Mount]
> > +What=3Dnfsd
> > +Where=3D/proc/fs/nfsd
> > +Type=3Dnfsd
>=20
>=20
> > diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> > new file mode 100644
> > index 000000000000..f0fef007d480
> > --- /dev/null
> > +++ b/systemd/rpc-gssd.service
> > @@ -0,0 +1,14 @@
> > +[Unit]
> > +Description=3DRPC security service for NFS client and server
> > +Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> > +After=3Dvar-lib-nfs-rpc_pipefs.mount
> > +
> > +Requisite=3Dnfs-secure.target
> > +After=3Dnfs-secure.target
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > +
> > +Type=3Dforking
> > +ExecStart=3D/usr/sbin/rpc.gssd $GSSDARGS
>=20
>=20
> > diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notif=
y.service
> > new file mode 100644
> > index 000000000000..9d972fc7753a
> > --- /dev/null
> > +++ b/systemd/rpc-statd-notify.service
> > @@ -0,0 +1,17 @@
> > +[Unit]
> > +Description=3DNotify NFS peers of a restart
> > +DefaultDependencies=3Dno
> > +Requires=3Dnetwork-online.target
> > +After=3Dnetwork-online.target nss-lookup.target
> > +
> > +# if we run an nfs server, it needs to be running before we
> > +# tell clients that it has restarted.
> > +After=3Dnfs-server.service
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D/usr/lib/systemd/scritps/nfs-utils_env.sh
> > +
> > +Type=3Doneshot
> > +RemainAfterExit=3Dyes
> > +ExecStart=3D-/usr/sbin/sm-notify -d $SMNOTIFYARGS
>=20
>=20
> > diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> > new file mode 100644
> > index 000000000000..04962e542fbc
> > --- /dev/null
> > +++ b/systemd/rpc-statd.service
> > @@ -0,0 +1,12 @@
> > +[Unit]
> > +Description=3DNFS status monitor for NFSv2/3 locking.
> > +DefaultDependencies=3Dno
> > +Requires=3Dnss-lookup.target rpcbind.target
> > +After=3Dnetwork.target nss-lookup.target rpcbind.target
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > +
> > +Type=3Dforking
> > +ExecStart=3D/usr/sbin/rpc.statd --no-notify $STATDARGS
>=20
>=20
> > diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> > new file mode 100644
> > index 000000000000..f024d40a8f41
> > --- /dev/null
> > +++ b/systemd/rpc-svcgssd.service
> > @@ -0,0 +1,15 @@
> > +[Unit]
> > +Description=3DRPC security service for NFS server
> > +Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> > +After=3Dvar-lib-nfs-rpc_pipefs.mount
> > +PartOf=3Dnfs-server.service
> > +
> > +Requisite=3Dnfs-secure.target
> > +After=3Dnfs-secure.target
> > +
> > +[Service]
> > +EnvironmentFile=3D-/run/sysconfig/nfs-utils
> > +ExecStartPre=3D-/usr/lib/systemd/scritps/nfs-utils_env.sh
> > +
> > +Type=3Dforking
> > +ExecStart=3D/usr/sbin/rpc.svcgssd $SVCGSSDARGS
>=20
>=20
> > diff --git a/systemd/var-lib-nfs-rpc_pipefs.mount b/systemd/var-lib-nfs=
-rpc_pipefs.mount
> > new file mode 100644
> > index 000000000000..cd614cf49f00
> > --- /dev/null
> > +++ b/systemd/var-lib-nfs-rpc_pipefs.mount
> > @@ -0,0 +1,8 @@
> > +[Unit]
> > +Description=3DRPC Pipe File System
> > +DefaultDependencies=3Dno
> > +
> > +[Mount]
> > +What=3Dsunrpc
> > +Where=3D/var/lib/nfs/rpc_pipefs
> > +Type=3Drpc_pipefs
>=20
>=20
> > diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> > index 1b345a547932..cde3583238e3 100644
> > --- a/utils/statd/start-statd
> > +++ b/utils/statd/start-statd
> > @@ -5,5 +5,8 @@
> >  # It should run statd with whatever flags are apropriate for this
> >  # site.
> >  PATH=3D/sbin:/usr/sbin
> > -exec rpc.statd --no-notify
> > -
> > +if systemctl start statd.service
> > +then :
> > +else
> > +    exec rpc.statd --no-notify
> > +fi
> >=20
>=20
> How does lockd get started and configured?

Lockd is automatically started by the kernel (nfs and nfsd) when needed.
I noticed that Fedora had some scripts to optionally set the port numbers
that lockd would use.  I left that out because I hoped we could find a bett=
er
way.

If lockd is compiled in to the kernel, then I think fs.nfs.nlm_XXXport shou=
ld
be set via /etc/sysctl.conf.
If it is a module, then the module parameters should be configured via
an /etc/modprobe.d/lockd.conf file.
I wish this was unified somehow (should modprobe call sysctl??) but it isn'=
t.

I appreciate that in neither case is it easy to get values out of a
'sysconfig' file in to the right place.

I cannot really think of a better solution than an 'nfs-lock' service which
sets these values,  so I'll probably add it.
>=20
> Overall it looks reasonable... But this is a change
> of ABI... so it will be painful... :-(

What exactly is changing that will be painful?  I would certainly like to
arrange the unit files to minimise your pain as much as possible, as long as
it doesn't compromise effectiveness.

Thanks for your review!

NeilBrown

--Sig_/0XNlqiR/24z=JaSfW17HuVV
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUurO3znsnt1WYoG5AQKXpQ/6Anp00fx/0QtDeP9B/9fPrA9PwsUxS8pl
4Of7C4zUsYjt5Ib59sl8KWKRBr9d/f/qYqX7BdzfzSc7vtp5K6JZ1F8HA1K0nV1O
69uYlbV4PhygV5fh0x9J2Wl+ztcNA9TaaFfqOZ7G46OZhx+Dk6f/F8C3PjA0clZP
MHQelOcnzbjSrd5q+tSsPiT8h1PtXIo4BBKqyuDWHkxkwRJNURBwqbpzqrgWQlPK
VKOqsjuqVIcTM+Pi0W1na/VnB7KFZWVKELF9/OACMRXTfB31ui1IbLlygGz0CHpM
YsERCF8/S2z33oCfEZ3wd2az6TsInxuP7UMDIWlDnzJVqeWPmKr9lztddeBks7Q+
gDGHMpk9thbSA4KzllS2IfKoxwY65UWDfGR24vQh+c8bW9dbC9J5nXGGF4pYnPz1
Rja2bvxauRjoJOZqEeLBe8ezgkPbJaZYybRPPaMHWeAHpaYiLTIQOCV7MNBWdXuR
VlONyRe2/tzMR0qSpoBMnPSJyRRQgllypCWqU+qS5+FC4PRoEDPl7+q6tP7o5g+x
UcRhv1SV2rVXis3qlEwjPa1JCCjvrgkpYmd+1TlEswMGtTCipfdtIHUBK6qWbc6o
IZihXNjfB5kVeFo4GW+MlEhG9brEQ7XUqx8/CApJihYGN7bQ39P8pydfIogevX7T
Cdsb6kR2pWc=
=ASlU
-----END PGP SIGNATURE-----

--Sig_/0XNlqiR/24z=JaSfW17HuVV--
