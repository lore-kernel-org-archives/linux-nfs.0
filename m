Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51159 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751057AbaA3SwH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jan 2014 13:52:07 -0500
Date: Thu, 30 Jan 2014 13:52:06 -0500
To: Weston Andros Adamson <dros@monkey.org>
Cc: NeilBrown <neilb@suse.de>, linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140130185206.GA12456@fieldses.org>
References: <20140130172451.7a354ce4@notabene.brown>
 <42E058FF-5672-4E07-8AFC-32C0933A01F8@monkey.org>
 <4D91FF8C-313D-4F02-858B-476ABEB46987@monkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4D91FF8C-313D-4F02-858B-476ABEB46987@monkey.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 12:56:49PM -0500, Weston Andros Adamson wrote:
> On Jan 30, 2014, at 10:04 AM, Weston Andros Adamson <dros@monkey.org> wrote:
> 
> > I think this is a great idea!  The nfs-utils package seems like the right place for this.
> > 
> > I don’t know enough about systemd to say that one set of scripts could definitely be shared across distributions, but it seems like any differences should be pretty minor.  If there are differences, perhaps we could use cpp or something to do a pass over the source files to make distro specific files?
> > 
> > -dros
> 
> I think we’ll need a preprocessor pass (or something similar) to handle the “—prefix=” config option and such...

If it's just a different path here or there, it might be simplest for a
distro just to apply a one-line patch?

Anyway, thumbs up to the idea of agreeing on a common set of unit files,
I'll try to take a look....

--b.

> 
> -dros
> 
> > 
> > On Jan 30, 2014, at 1:24 AM, NeilBrown <neilb@suse.de> wrote:
> > 
> >> 
> >> Hi all,
> >> 
> >> I would really like to see a common set of systemd unit files used for
> >> nfs-utils by every distribution (that actually uses systemd), and would like
> >> those unit files to be in the upstream nfs-utils package.
> >> 
> >> To that end I have put together the following collection of unit files which
> >> seem right to me, and appear to work as I think I want them to work.
> >> 
> >> I've looked at the unit files in Fedora and borrowed some ideas while
> >> discarding and changing others.  I won't try to list and justify all the
> >> changes here, but I'm perfectly willing (possibly even eager) to justify
> >> anything specific that anyone cares to ask about.
> >> 
> >> So:
> >> 1/ Do you agree that a collection of systemd unit files belongs in
> >>    nfs-utils?
> >> 2/ Do you think it reasonable to expect most (systemd using) distros to
> >>    use the one set?  I will certainly try to ensure openSUSE does if
> >>    upstream accepts them.
> >> 3/ Do you have any comments/question about those below?
> >> 
> >> 
> >> Thanks,
> >> NeilBrown
> >> 
> >> diff --git a/systemd/README b/systemd/README
> >> new file mode 100644
> >> index 000000000000..f0fb68825499
> >> --- /dev/null
> >> +++ b/systemd/README
> >> @@ -0,0 +1,50 @@
> >> +
> >> +Notes about systemd unit files for nfs-utils.
> >> +
> >> +The unit files provided here should be sufficient for systemd
> >> +to manage all daemons and related services provides by nfs-utils.
> >> +
> >> +They do *not* include any unit files for separate services such as
> >> +rpc.rquotad (in the 'quota' package) or rpcbind.
> >> +
> >> +There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
> >> +by a suitable 'preset' setting:
> >> +
> >> + nfs-server.target
> >> +    If enabled, nfs service is started together with dependencies
> >> +    such as mountd, statd, rpc.idmapd
> >> +
> >> + nfs-client.target
> >> +    If enabled, daemons needs for an nfs client are enabled.
> >> +    This does *not* include rpc.statd.  the rpc-statd.service unit
> >> +    is started by /usr/sbin/start-statd which mount.nfs will run
> >> +    if statd is needed.
> >> +
> >> + nfs-secure.target
> >> +    If enabled, then rpc.gssd will be run when either -client or
> >> +    -server is started, and rpc.svcgssd will be run when -server
> >> +    is started
> >> +
> >> + nfs-blkmap.target
> >> +    If enabled, then blkmapd will be run when nfs-client.target is
> >> +    started.
> >> +
> >> +
> >> +It is possible that we should have an nfs-statd.target which can
> >> +selectively enable statd being stared by -server and sm-notify
> >> +being started by -server or -client.  That way it could be disabled
> >> +completely on V4-only configurations.  Currently statd is always
> >> +started on the server and sm-notify is always run if server or
> >> +client is enabled.
> >> +
> >> +Stopping nfs-server will also stop rpc.mountd, and rpc.svcgssd.
> >> +It cannot stop rpc.statd or rpc.gssd as they may be in use by the
> >> +client and systemd cannot specify is two-pronged reverse dependency.
> >> +(i.e. stop this unit if none of these units are running)
> >> +
> >> +Distro specific commandline configuration can be provided by
> >> +installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
> >> +This should write /run/sysconfig/nfs-utils based on configuration
> >> +information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
> >> +It should write to a tmp file and rename to the target to
> >> +avoid parallel units seeing incomplete copies of the file.
> >> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> >> new file mode 100644
> >> index 000000000000..7319a88661cc
> >> --- /dev/null
> >> +++ b/systemd/nfs-blkmap.service
> >> @@ -0,0 +1,11 @@
> >> +[Unit]
> >> +Description=pNFS block layout mapping daemon
> >> +After=var-lib-nfs-rpc_pipefs.mount
> >> +Requires=var-lib-nfs-rpc_pipefs.mount
> >> +
> >> +Requisite=nfs-blkmap.target
> >> +After=nfs-blkmap.target
> >> +
> >> +[Service]
> >> +Type=forking
> >> +ExecStart=/usr/sbin/blkmapd
> >> diff --git a/systemd/nfs-blkmap.target b/systemd/nfs-blkmap.target
> >> new file mode 100644
> >> index 000000000000..fbcc111152ee
> >> --- /dev/null
> >> +++ b/systemd/nfs-blkmap.target
> >> @@ -0,0 +1,8 @@
> >> +[Unit]
> >> +Description= PNFS blkmaping enablement.
> >> +# If this target is enabled, then blkmapd will be started
> >> +# as required.  If it is not enabled it won't.
> >> +
> >> +[Install]
> >> +WantedBy=remote-fs.target
> >> +WantedBy=multi-user.target
> >> \ No newline at end of file
> >> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> >> new file mode 100644
> >> index 000000000000..fa591354abf3
> >> --- /dev/null
> >> +++ b/systemd/nfs-client.target
> >> @@ -0,0 +1,13 @@
> >> +[Unit]
> >> +Description=NFS client services
> >> +Before=remote-fs-pre.target
> >> +Wants=remote-fs-pre.target
> >> +
> >> +# Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
> >> +# start that on demand if needed.
> >> +Wants=rpc-gssd.service nfs-blkmap.service rpc-statd-notify.service
> >> +Before=rpc-gssd.service nfs-blkmap.service
> >> +
> >> +[Install]
> >> +WantedBy=multi-user.target
> >> +WantedBy=remote-fs.target
> >> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> >> new file mode 100644
> >> index 000000000000..6c2e1537f064
> >> --- /dev/null
> >> +++ b/systemd/nfs-idmapd.service
> >> @@ -0,0 +1,9 @@
> >> +[Unit]
> >> +Description=NFSv4 ID-name mapping service
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=forking
> >> +ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
> >> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> >> new file mode 100644
> >> index 000000000000..92e05ca309ee
> >> --- /dev/null
> >> +++ b/systemd/nfs-mountd.service
> >> @@ -0,0 +1,13 @@
> >> +[Unit]
> >> +Description=NFS Mount Daemon
> >> +Requires=proc-fs-nfsd.mount
> >> +After=proc-fs-nfsd.mount
> >> +After=network.target
> >> +PartOf=nfs-server.service
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=forking
> >> +ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
> >> diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
> >> new file mode 100644
> >> index 000000000000..0127fdb07dbd
> >> --- /dev/null
> >> +++ b/systemd/nfs-secure.target
> >> @@ -0,0 +1,8 @@
> >> +[Unit]
> >> +Description=Secure NFS client/server services
> >> +# If this target is enabled, then rpc.gssd and rpc.svcgssd will be started
> >> +# as required.  If it is not enabled they won't.
> >> +
> >> +[Install]
> >> +WantedBy=remote-fs.target
> >> +WantedBy=multi-user.target
> >> \ No newline at end of file
> >> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> >> new file mode 100644
> >> index 000000000000..9812866c66aa
> >> --- /dev/null
> >> +++ b/systemd/nfs-server.service
> >> @@ -0,0 +1,24 @@
> >> +[Unit]
> >> +Description=NFS server
> >> +DefaultDependencies=no
> >> +Requires= network.target proc-fs-nfsd.mount rpcbind.target
> >> +PartOf=nfs-server.target
> >> +
> >> +After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
> >> +After= nfs-idmapd.service rpc-statd.service
> >> +After= rpc-gssd.service rpc-svcgssd.service
> >> +Before= rpc-statd-notify.service
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=oneshot
> >> +RemainAfterExit=yes
> >> +ExecStartPre=/usr/sbin/exportfs -r
> >> +ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
> >> +ExecStop=/usr/sbin/rpc.nfsd 0
> >> +ExecStopPost=/usr/sbin/exportfs -au
> >> +ExecStopPost=/usr/sbin/exportfs -f
> >> +
> >> +ExecReload=/usr/sbin/exportfs -r
> >> diff --git a/systemd/nfs-server.target b/systemd/nfs-server.target
> >> new file mode 100644
> >> index 000000000000..a3e629f022a9
> >> --- /dev/null
> >> +++ b/systemd/nfs-server.target
> >> @@ -0,0 +1,8 @@
> >> +[Unit]
> >> +Description=NFS server services
> >> +Requires=nfs-server.service nfs-mountd.service
> >> +Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> >> +Wants=rpc-statd-notify.service
> >> +
> >> +[Install]
> >> +WantedBy=multi-user.target
> >> diff --git a/systemd/proc-fs-nfsd.mount b/systemd/proc-fs-nfsd.mount
> >> new file mode 100644
> >> index 000000000000..f44d52f3d67b
> >> --- /dev/null
> >> +++ b/systemd/proc-fs-nfsd.mount
> >> @@ -0,0 +1,8 @@
> >> +[Unit]
> >> +Description=NFSD configuration filesystem
> >> +DefaultDependencies=no
> >> +
> >> +[Mount]
> >> +What=nfsd
> >> +Where=/proc/fs/nfsd
> >> +Type=nfsd
> >> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> >> new file mode 100644
> >> index 000000000000..f0fef007d480
> >> --- /dev/null
> >> +++ b/systemd/rpc-gssd.service
> >> @@ -0,0 +1,14 @@
> >> +[Unit]
> >> +Description=RPC security service for NFS client and server
> >> +Requires=var-lib-nfs-rpc_pipefs.mount
> >> +After=var-lib-nfs-rpc_pipefs.mount
> >> +
> >> +Requisite=nfs-secure.target
> >> +After=nfs-secure.target
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=forking
> >> +ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
> >> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> >> new file mode 100644
> >> index 000000000000..9d972fc7753a
> >> --- /dev/null
> >> +++ b/systemd/rpc-statd-notify.service
> >> @@ -0,0 +1,17 @@
> >> +[Unit]
> >> +Description=Notify NFS peers of a restart
> >> +DefaultDependencies=no
> >> +Requires=network-online.target
> >> +After=network-online.target nss-lookup.target
> >> +
> >> +# if we run an nfs server, it needs to be running before we
> >> +# tell clients that it has restarted.
> >> +After=nfs-server.service
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=oneshot
> >> +RemainAfterExit=yes
> >> +ExecStart=-/usr/sbin/sm-notify -d $SMNOTIFYARGS
> >> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> >> new file mode 100644
> >> index 000000000000..04962e542fbc
> >> --- /dev/null
> >> +++ b/systemd/rpc-statd.service
> >> @@ -0,0 +1,12 @@
> >> +[Unit]
> >> +Description=NFS status monitor for NFSv2/3 locking.
> >> +DefaultDependencies=no
> >> +Requires=nss-lookup.target rpcbind.target
> >> +After=network.target nss-lookup.target rpcbind.target
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=forking
> >> +ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS
> >> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> >> new file mode 100644
> >> index 000000000000..f024d40a8f41
> >> --- /dev/null
> >> +++ b/systemd/rpc-svcgssd.service
> >> @@ -0,0 +1,15 @@
> >> +[Unit]
> >> +Description=RPC security service for NFS server
> >> +Requires=var-lib-nfs-rpc_pipefs.mount
> >> +After=var-lib-nfs-rpc_pipefs.mount
> >> +PartOf=nfs-server.service
> >> +
> >> +Requisite=nfs-secure.target
> >> +After=nfs-secure.target
> >> +
> >> +[Service]
> >> +EnvironmentFile=-/run/sysconfig/nfs-utils
> >> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> >> +
> >> +Type=forking
> >> +ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
> >> diff --git a/systemd/var-lib-nfs-rpc_pipefs.mount b/systemd/var-lib-nfs-rpc_pipefs.mount
> >> new file mode 100644
> >> index 000000000000..cd614cf49f00
> >> --- /dev/null
> >> +++ b/systemd/var-lib-nfs-rpc_pipefs.mount
> >> @@ -0,0 +1,8 @@
> >> +[Unit]
> >> +Description=RPC Pipe File System
> >> +DefaultDependencies=no
> >> +
> >> +[Mount]
> >> +What=sunrpc
> >> +Where=/var/lib/nfs/rpc_pipefs
> >> +Type=rpc_pipefs
> >> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> >> index 1b345a547932..cde3583238e3 100644
> >> --- a/utils/statd/start-statd
> >> +++ b/utils/statd/start-statd
> >> @@ -5,5 +5,8 @@
> >> # It should run statd with whatever flags are apropriate for this
> >> # site.
> >> PATH=/sbin:/usr/sbin
> >> -exec rpc.statd --no-notify
> >> -
> >> +if systemctl start statd.service
> >> +then :
> >> +else
> >> +    exec rpc.statd --no-notify
> >> +fi
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
