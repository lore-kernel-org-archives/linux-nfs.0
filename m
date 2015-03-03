Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kawka.in.waw.pl ([178.63.212.103]:32880 "EHLO kawka.in.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754819AbbCCSIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 13:08:11 -0500
Date: Tue, 3 Mar 2015 19:08:09 +0100
From: Zbigniew =?utf-8?Q?J=C4=99drzejewski-Szmek?= <zbyszek@in.waw.pl>
To: Martin Pitt <martin.pitt@ubuntu.com>
Cc: linux-nfs@vger.kernel.org, systemd-devel@lists.freedesktop.org
Subject: Re: [systemd-devel] [PATCH 2/2] systemd: Relax dependencies of
 services
Message-ID: <20150303180809.GJ3058@in.waw.pl>
References: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com>
 <1425403690-23847-3-git-send-email-martin.pitt@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1425403690-23847-3-git-send-email-martin.pitt@ubuntu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2015 at 06:28:10PM +0100, Martin Pitt wrote:
> Stop depending on basic.target in the daemons which still do; i. e. add
> DefaultDependencies=no. This makes it possible to run NFS during early boot,
> and helps if you e. g. have /var on NFS. We don't require much else than
> local-fs.
Are you sure that all of those nfs daemons do not require
sockets.target and other stuff provided by basic.target to be ready?

Zbyszek

> ---
>  systemd/auth-rpcgss-module.service | 1 +
>  systemd/nfs-config.service         | 2 ++
>  systemd/nfs-idmapd.service         | 3 ++-
>  systemd/nfs-mountd.service         | 3 ++-
>  systemd/nfs-server.service         | 2 ++
>  systemd/rpc-statd-notify.service   | 3 ++-
>  systemd/rpc-svcgssd.service        | 3 ++-
>  7 files changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-module.service
> index 0355e13..5241f7b 100644
> --- a/systemd/auth-rpcgss-module.service
> +++ b/systemd/auth-rpcgss-module.service
> @@ -6,6 +6,7 @@
>  # unit will fail.  But that's OK.)
>  [Unit]
>  Description=Kernel Module supporting RPCSEC_GSS
> +DefaultDependencies=no
>  Before=gssproxy.service rpc-svcgssd.service rpc-gssd.service
>  Wants=gssproxy.service rpc-svcgssd.service rpc-gssd.service
>  ConditionPathExists=/etc/krb5.keytab
> diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
> index 64010e6..7f65305 100644
> --- a/systemd/nfs-config.service
> +++ b/systemd/nfs-config.service
> @@ -1,5 +1,7 @@
>  [Unit]
>  Description=Preprocess NFS configuration
> +After=local-fs.target
> +DefaultDependencies=no
>  
>  [Service]
>  Type=oneshot
> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> index e84f8c8..df3dd9d 100644
> --- a/systemd/nfs-idmapd.service
> +++ b/systemd/nfs-idmapd.service
> @@ -1,7 +1,8 @@
>  [Unit]
>  Description=NFSv4 ID-name mapping service
> +DefaultDependencies=no
>  Requires=var-lib-nfs-rpc_pipefs.mount
> -After=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount local-fs.target
>  
>  BindsTo=nfs-server.service
>  
> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> index d908afe..8a39f3e 100644
> --- a/systemd/nfs-mountd.service
> +++ b/systemd/nfs-mountd.service
> @@ -1,8 +1,9 @@
>  [Unit]
>  Description=NFS Mount Daemon
> +DefaultDependencies=no
>  Requires=proc-fs-nfsd.mount
>  After=proc-fs-nfsd.mount
> -After=network.target
> +After=network.target local-fs.target
>  BindsTo=nfs-server.service
>  
>  Wants=nfs-config.service
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index b35e193..db801cb 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,10 +1,12 @@
>  [Unit]
>  Description=NFS server and services
> +DefaultDependencies=no
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
>  Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
>  
> +After= local-fs.target
>  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
>  Before= rpc-statd-notify.service
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index a655445..a7e2f8e 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -1,7 +1,8 @@
>  [Unit]
>  Description=Notify NFS peers of a restart
> +DefaultDependencies=no
>  Requires=network-online.target
> -After=network.target nss-lookup.target
> +After=local-fs.target network.target nss-lookup.target
>  
>  # if we run an nfs server, it needs to be running before we
>  # tell clients that it has restarted.
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index f7424b0..41177b6 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -1,7 +1,8 @@
>  [Unit]
>  Description=RPC security service for NFS server
> +DefaultDependencies=no
>  Requires=var-lib-nfs-rpc_pipefs.mount
> -After=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount local-fs.target
>  PartOf=nfs-server.service
>  PartOf=nfs-utils.service
>  
> -- 
> 2.1.4
> 
> _______________________________________________
> systemd-devel mailing list
> systemd-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/systemd-devel
