Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118AbaA3UGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jan 2014 15:06:37 -0500
Message-ID: <52EAB0CA.2090204@RedHat.com>
Date: Thu, 30 Jan 2014 15:06:34 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown>
In-Reply-To: <20140130172451.7a354ce4@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/30/2014 01:24 AM, NeilBrown wrote:
> 
> Hi all,
> 
>  I would really like to see a common set of systemd unit files used for
>  nfs-utils by every distribution (that actually uses systemd), and would like
>  those unit files to be in the upstream nfs-utils package.
> 
>  To that end I have put together the following collection of unit files which
>  seem right to me, and appear to work as I think I want them to work.
> 
>  I've looked at the unit files in Fedora and borrowed some ideas while
>  discarding and changing others.  I won't try to list and justify all the
>  changes here, but I'm perfectly willing (possibly even eager) to justify
>  anything specific that anyone cares to ask about.
> 
>  So:
>   1/ Do you agree that a collection of systemd unit files belongs in
>      nfs-utils?
I would think so... 
>   2/ Do you think it reasonable to expect most (systemd using) distros to
>      use the one set?  I will certainly try to ensure openSUSE does if
>      upstream accepts them.
>   3/ Do you have any comments/question about those below?
> 
> 
> Thanks,
> NeilBrown
> 
> diff --git a/systemd/README b/systemd/README
> new file mode 100644
> index 000000000000..f0fb68825499
> --- /dev/null
> +++ b/systemd/README
> @@ -0,0 +1,50 @@
> +
> +Notes about systemd unit files for nfs-utils.
> +
> +The unit files provided here should be sufficient for systemd
> +to manage all daemons and related services provides by nfs-utils.
> +
> +They do *not* include any unit files for separate services such as
> +rpc.rquotad (in the 'quota' package) or rpcbind.
> +
> +There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
> +by a suitable 'preset' setting:
> +
> + nfs-server.target
> +    If enabled, nfs service is started together with dependencies
> +    such as mountd, statd, rpc.idmapd
> +
> + nfs-client.target
> +    If enabled, daemons needs for an nfs client are enabled.
> +    This does *not* include rpc.statd.  the rpc-statd.service unit
> +    is started by /usr/sbin/start-statd which mount.nfs will run
> +    if statd is needed.
> +
> + nfs-secure.target
> +    If enabled, then rpc.gssd will be run when either -client or
> +    -server is started, and rpc.svcgssd will be run when -server
> +    is started
> +
> + nfs-blkmap.target
> +    If enabled, then blkmapd will be run when nfs-client.target is
> +    started.
Do we really need all of these targets? Could we cut it down to
two. nfs.target and nfs-secure.target?

> +
> +
> +It is possible that we should have an nfs-statd.target which can
> +selectively enable statd being stared by -server and sm-notify
> +being started by -server or -client.  That way it could be disabled
> +completely on V4-only configurations.  Currently statd is always
> +started on the server and sm-notify is always run if server or
> +client is enabled.
> +
> +Stopping nfs-server will also stop rpc.mountd, and rpc.svcgssd.
> +It cannot stop rpc.statd or rpc.gssd as they may be in use by the
> +client and systemd cannot specify is two-pronged reverse dependency.
> +(i.e. stop this unit if none of these units are running)
> +
> +Distro specific commandline configuration can be provided by
> +installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
> +This should write /run/sysconfig/nfs-utils based on configuration
> +information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
> +It should write to a tmp file and rename to the target to
> +avoid parallel units seeing incomplete copies of the file.

> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> new file mode 100644
> index 000000000000..7319a88661cc
> --- /dev/null
> +++ b/systemd/nfs-blkmap.service
> @@ -0,0 +1,11 @@
> +[Unit]
> +Description=pNFS block layout mapping daemon
> +After=var-lib-nfs-rpc_pipefs.mount
> +Requires=var-lib-nfs-rpc_pipefs.mount
> +
> +Requisite=nfs-blkmap.target
> +After=nfs-blkmap.target
> +
> +[Service]
> +Type=forking
> +ExecStart=/usr/sbin/blkmapd
Is this even supported anymore? Maybe we can just drop it???


> diff --git a/systemd/nfs-blkmap.target b/systemd/nfs-blkmap.target
> new file mode 100644
> index 000000000000..fbcc111152ee
> --- /dev/null
> +++ b/systemd/nfs-blkmap.target
> @@ -0,0 +1,8 @@
> +[Unit]
> +Description= PNFS blkmaping enablement.
> +# If this target is enabled, then blkmapd will be started
> +# as required.  If it is not enabled it won't.
> +
> +[Install]
> +WantedBy=remote-fs.target
> +WantedBy=multi-user.target
> \ No newline at end of file

Again, why is a client target needed? Now that idmappings are
stored in the key ring what needs to be started on the client?

> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> new file mode 100644
> index 000000000000..fa591354abf3
> --- /dev/null
> +++ b/systemd/nfs-client.target
> @@ -0,0 +1,13 @@
> +[Unit]
> +Description=NFS client services
> +Before=remote-fs-pre.target
> +Wants=remote-fs-pre.target
> +
> +# Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
> +# start that on demand if needed.
> +Wants=rpc-gssd.service nfs-blkmap.service rpc-statd-notify.service
> +Before=rpc-gssd.service nfs-blkmap.service
> +
> +[Install]
> +WantedBy=multi-user.target
> +WantedBy=remote-fs.target


> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> new file mode 100644
> index 000000000000..6c2e1537f064
> --- /dev/null
> +++ b/systemd/nfs-idmapd.service
> @@ -0,0 +1,9 @@
> +[Unit]
> +Description=NFSv4 ID-name mapping service
Fedora has in the [Unit]:
BindTo=nfs-server.service
After=nfs-server.service
I guess I thought they were needed at the time..

> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> +
> +Type=forking
> +ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS


> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> new file mode 100644
> index 000000000000..92e05ca309ee
> --- /dev/null
> +++ b/systemd/nfs-mountd.service
> @@ -0,0 +1,13 @@
> +[Unit]
> +Description=NFS Mount Daemon
> +Requires=proc-fs-nfsd.mount
> +After=proc-fs-nfsd.mount
> +After=network.target
> +PartOf=nfs-server.service
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
How does this script know who is calling it and what it
has to do? 

> +
> +Type=forking
> +ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS


> diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
> new file mode 100644
> index 000000000000..0127fdb07dbd
> --- /dev/null
> +++ b/systemd/nfs-secure.target
> @@ -0,0 +1,8 @@
> +[Unit]
> +Description=Secure NFS client/server services
> +# If this target is enabled, then rpc.gssd and rpc.svcgssd will be started
> +# as required.  If it is not enabled they won't.
So the "Requisite=nfs-secure.target" in rpc-gssd.service cause the 
daemon to started?

> +
> +[Install]
> +WantedBy=remote-fs.target
> +WantedBy=multi-user.target
> \ No newline at end of file


> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> new file mode 100644
> index 000000000000..9812866c66aa
> --- /dev/null
> +++ b/systemd/nfs-server.service
> @@ -0,0 +1,24 @@
> +[Unit]
> +Description=NFS server
> +DefaultDependencies=no
> +Requires= network.target proc-fs-nfsd.mount rpcbind.target
> +PartOf=nfs-server.target
> +
> +After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
> +After= nfs-idmapd.service rpc-statd.service
> +After= rpc-gssd.service rpc-svcgssd.service
> +Before= rpc-statd-notify.service
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> +
> +Type=oneshot
> +RemainAfterExit=yes
> +ExecStartPre=/usr/sbin/exportfs -r
> +ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
Having ExecStartPre and ExecStartPost scripts gives
us a place to do some pre and post server configuration.

Granted it has not been needed in a while but I'm thinking
it could come in handing... 

> +ExecStop=/usr/sbin/rpc.nfsd 0
> +ExecStopPost=/usr/sbin/exportfs -au
> +ExecStopPost=/usr/sbin/exportfs -f
> +
> +ExecReload=/usr/sbin/exportfs -r


> diff --git a/systemd/nfs-server.target b/systemd/nfs-server.target
> new file mode 100644
> index 000000000000..a3e629f022a9
> --- /dev/null
> +++ b/systemd/nfs-server.target
> @@ -0,0 +1,8 @@
> +[Unit]
> +Description=NFS server services
> +Requires=nfs-server.service nfs-mountd.service
> +Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> +Wants=rpc-statd-notify.service
> +
> +[Install]
> +WantedBy=multi-user.target


> diff --git a/systemd/proc-fs-nfsd.mount b/systemd/proc-fs-nfsd.mount
> new file mode 100644
> index 000000000000..f44d52f3d67b
> --- /dev/null
> +++ b/systemd/proc-fs-nfsd.mount
> @@ -0,0 +1,8 @@
> +[Unit]
> +Description=NFSD configuration filesystem
> +DefaultDependencies=no
> +
> +[Mount]
> +What=nfsd
> +Where=/proc/fs/nfsd
> +Type=nfsd


> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> new file mode 100644
> index 000000000000..f0fef007d480
> --- /dev/null
> +++ b/systemd/rpc-gssd.service
> @@ -0,0 +1,14 @@
> +[Unit]
> +Description=RPC security service for NFS client and server
> +Requires=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount
> +
> +Requisite=nfs-secure.target
> +After=nfs-secure.target
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> +
> +Type=forking
> +ExecStart=/usr/sbin/rpc.gssd $GSSDARGS


> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> new file mode 100644
> index 000000000000..9d972fc7753a
> --- /dev/null
> +++ b/systemd/rpc-statd-notify.service
> @@ -0,0 +1,17 @@
> +[Unit]
> +Description=Notify NFS peers of a restart
> +DefaultDependencies=no
> +Requires=network-online.target
> +After=network-online.target nss-lookup.target
> +
> +# if we run an nfs server, it needs to be running before we
> +# tell clients that it has restarted.
> +After=nfs-server.service
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=/usr/lib/systemd/scritps/nfs-utils_env.sh
> +
> +Type=oneshot
> +RemainAfterExit=yes
> +ExecStart=-/usr/sbin/sm-notify -d $SMNOTIFYARGS


> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> new file mode 100644
> index 000000000000..04962e542fbc
> --- /dev/null
> +++ b/systemd/rpc-statd.service
> @@ -0,0 +1,12 @@
> +[Unit]
> +Description=NFS status monitor for NFSv2/3 locking.
> +DefaultDependencies=no
> +Requires=nss-lookup.target rpcbind.target
> +After=network.target nss-lookup.target rpcbind.target
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> +
> +Type=forking
> +ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS


> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> new file mode 100644
> index 000000000000..f024d40a8f41
> --- /dev/null
> +++ b/systemd/rpc-svcgssd.service
> @@ -0,0 +1,15 @@
> +[Unit]
> +Description=RPC security service for NFS server
> +Requires=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount
> +PartOf=nfs-server.service
> +
> +Requisite=nfs-secure.target
> +After=nfs-secure.target
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> +
> +Type=forking
> +ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS


> diff --git a/systemd/var-lib-nfs-rpc_pipefs.mount b/systemd/var-lib-nfs-rpc_pipefs.mount
> new file mode 100644
> index 000000000000..cd614cf49f00
> --- /dev/null
> +++ b/systemd/var-lib-nfs-rpc_pipefs.mount
> @@ -0,0 +1,8 @@
> +[Unit]
> +Description=RPC Pipe File System
> +DefaultDependencies=no
> +
> +[Mount]
> +What=sunrpc
> +Where=/var/lib/nfs/rpc_pipefs
> +Type=rpc_pipefs


> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> index 1b345a547932..cde3583238e3 100644
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -5,5 +5,8 @@
>  # It should run statd with whatever flags are apropriate for this
>  # site.
>  PATH=/sbin:/usr/sbin
> -exec rpc.statd --no-notify
> -
> +if systemctl start statd.service
> +then :
> +else
> +    exec rpc.statd --no-notify
> +fi
> 

How does lockd get started and configured?

Overall it looks reasonable... But this is a change
of ABI... so it will be painful... :-(

steved.
