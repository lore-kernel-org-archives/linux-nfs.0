Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49267 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754870AbaBEVLK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Feb 2014 16:11:10 -0500
Date: Wed, 5 Feb 2014 16:11:07 -0500
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140205211107.GA14457@fieldses.org>
References: <20140130172451.7a354ce4@notabene.brown>
 <52F003A1.3060908@RedHat.com>
 <20140204093452.7b6d7c7d@notabene.brown>
 <52F130E2.6090308@RedHat.com>
 <20140205164351.7a766eff@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140205164351.7a766eff@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 05, 2014 at 04:43:51PM +1100, NeilBrown wrote:
> On Tue, 04 Feb 2014 13:26:42 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> > > 
> > >>
> > >> How would these daemons be restart and shutdown? Since this is a 
> > >> target, systemctl restart and system stop don't do anything.
> > > 
> > > This is something I haven't completely figured out yet.
> > > 
> > > Part of the solution might be the "PartOf" directive.
> > > If each service claims to be "PartOf" the main one, then stopping or
> > > restarting the main service will propagate to stopping and restarting the
> > > individual services.
> > > Unfortunately in nfs we have some shared services.  rpc.statd and rpc.gssd
> > > are needed by both server and client.  That isn't a big problem for 'restart',
> > > but if you 'systemctl stop nfs-client' and find that the server isn't
> > > properly working any more, that would be awkward
> > > If could possibly work around that by setting "StopWhenUnneeded" for those
> > > shared services.  Then e.g. rpc.statd would stop when both client and server
> > > are stopped, but not if either one of them is stopped.
> > > However I don't know how that interacts with restart.  I suspect that the
> > > StopWhenUnneeded services are *not* stopped and restarted when the main
> > > service is stopped.  So it would  be  hard to restart all nfs services on an
> > > upgrade.
> > > 
> > > Further research seems needed here.
> > Fine... I'll try to digest what you are saying here, but
> > would it make it easier if everything was in a service file?
> 
> So I did a bit more research and thinking, and I present the two patches
> below for consideration.  If you agree and would prefer them in separate
> emails I can certainly do that.
> 
> The first ensures that we can easily restart all daemons during software
> update.  It creates a new 'nfs-utils.service' which exists only to allow that
> restart.
> 
> The second ensures startup and shutdown work properly (though I haven't
> tested much).
> Do we need to shutdown nfs-server or nfs-client easily at any time other than
> system shutdown?

I think it's hard to as I don't think there's a way for the NSM protocol
to treat the nfs client and server as different things that could go up
and down independently.  But I could be wrong, I rarely think about
statd!  In a v4-only setup that wouldn't be a problem any more.

On the server side there are a few parameters (v4 lease time?) that can
only be changed with a restart but maybe that's not terribly important.

HA people may restart the server on failover to get a new grace period.
They probably use their own scripts for that but it would be better to
get them using standard systemd configuration to the extent possible.

Anyway those are existing problems that it's not necessarily up to you
to fix.

--b.

> 
> Thanks,
> 
> NeilBrown
> 
> From 0d880d8faf4db7189c11fc13854da82074c260ac Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Wed, 5 Feb 2014 16:28:47 +1100
> Subject: [PATCH] systemd: add nfs-utils.service which can be used to restart
>  everything.
> 
> With this patch,
>    systemctl restart nfs-utils
> will restart any nfs-utils daemons that are currently running, whether
> there were started via nfs-server.service, nfs-client.target, or
> directly by systemctl.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/systemd/README b/systemd/README
> index d697cefbe229..8359530098f4 100644
> --- a/systemd/README
> +++ b/systemd/README
> @@ -28,6 +28,17 @@ by a suitable 'preset' setting:
>      If enabled, then blkmapd will be run when nfs-client.target is
>      started.
>  
> +Another special unit is "nfs-utils.service".  This doesn't really do
> +anything, but exists so that other units may declare themselves as
> +"PartOf" nfs-utils.service.
> +The effect of this is that
> +     systemctl restart nfs-utils
> +will restart all nfs-utils daemons as maybe be required during
> +software update.  It isn't possible to make
> +     systemctl try-restart nfs-server nfs-client.target
> +do this as some daemon are included in both, and rpc.statd would
> +not be restarted if nfs-server were not active (as nfs-client doesn't
> +Want it - it is started by mount.nfs running start-statd).
>  
>  It is possible that we should have an nfs-statd.target which can
>  selectively enable statd being stared by -server and sm-notify
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index 7319a88661cc..80033f2fbcf4 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -6,6 +6,8 @@ Requires=var-lib-nfs-rpc_pipefs.mount
>  Requisite=nfs-blkmap.target
>  After=nfs-blkmap.target
>  
> +PartOf=nfs-utils.service
> +
>  [Service]
>  Type=forking
>  ExecStart=/usr/sbin/blkmapd
> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> index 6c2e1537f064..7d0dd84d8a44 100644
> --- a/systemd/nfs-idmapd.service
> +++ b/systemd/nfs-idmapd.service
> @@ -1,6 +1,8 @@
>  [Unit]
>  Description=NFSv4 ID-name mapping service
>  
> +PartOf=nfs-utils.service
> +
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
>  ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> index 92e05ca309ee..90746a854b40 100644
> --- a/systemd/nfs-mountd.service
> +++ b/systemd/nfs-mountd.service
> @@ -4,6 +4,7 @@ Requires=proc-fs-nfsd.mount
>  After=proc-fs-nfsd.mount
>  After=network.target
>  PartOf=nfs-server.service
> +PartOf=nfs-utils.service
>  
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
> diff --git a/systemd/nfs-utils.service b/systemd/nfs-utils.service
> new file mode 100644
> index 000000000000..54b6314d8d52
> --- /dev/null
> +++ b/systemd/nfs-utils.service
> @@ -0,0 +1,17 @@
> +[Unit]
> +Description=NFS server and client services
> +# This service should never be stopped, only restarted.
> +# When it is re-started, all other services which declare
> +# themselves to be "PartOf" this service will also be
> +# restarted. Thus
> +#   systemctl restart nfs-utils
> +# will restart all daemons which are part of nfs-utils
> +# and which are running.  This is useful after a software
> +# update.
> +
> +# This is a "service" rather than "target" so that we
> +# don't need to say "systemctl restart nfs-utils.target".
> +[Service]
> +Type=oneshot
> +RemainAfterExit=yes
> +ExecStart=/bin/true
> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> index 8778c3ef651b..3982985762ea 100644
> --- a/systemd/rpc-gssd.service
> +++ b/systemd/rpc-gssd.service
> @@ -5,6 +5,8 @@ After=var-lib-nfs-rpc_pipefs.mount
>  
>  ConditionPathExists=/etc/krb5.keytab
>  
> +PartOf=nfs-utils.service
> +
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
>  ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index 9d972fc7753a..532354d64fa0 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -8,6 +8,8 @@ After=network-online.target nss-lookup.target
>  # tell clients that it has restarted.
>  After=nfs-server.service
>  
> +PartOf=nfs-utils.service
> +
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
>  ExecStartPre=/usr/lib/systemd/scritps/nfs-utils_env.sh
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index 04962e542fbc..88d2527cae9d 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -4,6 +4,8 @@ DefaultDependencies=no
>  Requires=nss-lookup.target rpcbind.target
>  After=network.target nss-lookup.target rpcbind.target
>  
> +PartOf=nfs-utils.service
> +
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
>  ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index 036ec579bfc1..6bd45884d991 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -3,6 +3,7 @@ Description=RPC security service for NFS server
>  Requires=var-lib-nfs-rpc_pipefs.mount
>  After=var-lib-nfs-rpc_pipefs.mount
>  PartOf=nfs-server.service
> +PartOf=nfs-utils.service
>  
>  After=gssproxy.service
>  ConditionPathExists=|!@localstatedir@/run/gssproxy.pid
> 
> 
> 
> 
> 
> 
> 
> From 30b27a718632e9d24c479921b116d2c3958a3fc2 Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Wed, 5 Feb 2014 16:36:21 +1100
> Subject: [PATCH] systemd: tidy up DefaultDependencies
> 
> DefaultDependencies should be "yes" (the default) for things
> needed only be the NFS server, as that is a service that doesn't
> need to start early.
> 
> DefaultDependencies should be "no" for things needed to mount an
> NFS filesystem, and filesystems are mounted before basic.target.
> To ensure these services are shut down in a timely fashion, they
> must Conflict with systemd.umount so they are shutdown when everything
> is unmounted.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index 80033f2fbcf4..4b74e9f61454 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -1,5 +1,7 @@
>  [Unit]
>  Description=pNFS block layout mapping daemon
> +DefaultDependencies=no
> +Conflicts=umount.target
>  After=var-lib-nfs-rpc_pipefs.mount
>  Requires=var-lib-nfs-rpc_pipefs.mount
>  
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 6ba2fc0f346e..5779fd39ed34 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,6 +1,5 @@
>  [Unit]
>  Description=NFS server and services
> -DefaultDependencies=no
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
>  Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> diff --git a/systemd/proc-fs-nfsd.mount b/systemd/proc-fs-nfsd.mount
> index f44d52f3d67b..931a5ceeb055 100644
> --- a/systemd/proc-fs-nfsd.mount
> +++ b/systemd/proc-fs-nfsd.mount
> @@ -1,6 +1,5 @@
>  [Unit]
>  Description=NFSD configuration filesystem
> -DefaultDependencies=no
>  
>  [Mount]
>  What=nfsd
> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> index 3982985762ea..375792804247 100644
> --- a/systemd/rpc-gssd.service
> +++ b/systemd/rpc-gssd.service
> @@ -1,5 +1,7 @@
>  [Unit]
>  Description=RPC security service for NFS client and server
> +DefaultDependencies=no
> +Conflicts=umount.target
>  Requires=var-lib-nfs-rpc_pipefs.mount
>  After=var-lib-nfs-rpc_pipefs.mount
>  
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index 532354d64fa0..7742ac8c5d9a 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -1,6 +1,5 @@
>  [Unit]
>  Description=Notify NFS peers of a restart
> -DefaultDependencies=no
>  Requires=network-online.target
>  After=network-online.target nss-lookup.target
>  
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index 88d2527cae9d..3f6cda16accd 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -1,6 +1,7 @@
>  [Unit]
>  Description=NFS status monitor for NFSv2/3 locking.
>  DefaultDependencies=no
> +Conflicts=umount.target
>  Requires=nss-lookup.target rpcbind.target
>  After=network.target nss-lookup.target rpcbind.target
>  
> diff --git a/systemd/var-lib-nfs-rpc_pipefs.mount b/systemd/var-lib-nfs-rpc_pipefs.mount
> index cd614cf49f00..33c5db65aa38 100644
> --- a/systemd/var-lib-nfs-rpc_pipefs.mount
> +++ b/systemd/var-lib-nfs-rpc_pipefs.mount
> @@ -1,6 +1,7 @@
>  [Unit]
>  Description=RPC Pipe File System
>  DefaultDependencies=no
> +Conflicts=umount.target
>  
>  [Mount]
>  What=sunrpc


