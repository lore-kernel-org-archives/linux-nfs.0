Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbaJBT13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Oct 2014 15:27:29 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s92JRTpB028437
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Oct 2014 15:27:29 -0400
Message-ID: <542DA720.5020002@RedHat.com>
Date: Thu, 02 Oct 2014 15:27:28 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Centralize dependencies on the auth unit.
References: <542AC20B.9040509@redhat.com> <1412091888-32220-1-git-send-email-simo@redhat.com>
In-Reply-To: <1412091888-32220-1-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/30/2014 11:44 AM, Simo Sorce wrote:
> With this patch either gssproxy or rpc.svcgssd are started only if the
> auth module is requested, and it finds a keytab.
> If the wants are in the main nfs-client or nfs-server unit files then
> the two deamons are started unconditionally and would require
> conditions which we can test once and for all in a single unit file
> instead.
> 
> Change also Before and After statments accordingly to properly
> serialize loading modules and starting daemons in 3 steps
> 1. load kernel GSS auth module
> 2. start GSS handling daemons
> 3. start NFS client/server daemons
> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
I begrudgingly commit this because when gssproxy is install
the NFS client will *always* start it, which is
a bug in gssproxy... IMHO... If a daemon is not needed
it shouldn't start up... similar to how the gss daemons work.

steved.



> ---
>  systemd/auth-rpcgss-module.service | 3 ++-
>  systemd/nfs-client.target          | 7 +++++--
>  systemd/nfs-server.service         | 8 +++++---
>  3 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-module.service
> index 3fc2f4ac924f7e9d6e24969bb9a21d88a5c144fc..0355e13e009528632e97373332db9fa3acdfd1a9 100644
> --- a/systemd/auth-rpcgss-module.service
> +++ b/systemd/auth-rpcgss-module.service
> @@ -6,7 +6,8 @@
>  # unit will fail.  But that's OK.)
>  [Unit]
>  Description=Kernel Module supporting RPCSEC_GSS
> -Before=gssproxy.service rpc-svcgssd.service
> +Before=gssproxy.service rpc-svcgssd.service rpc-gssd.service
> +Wants=gssproxy.service rpc-svcgssd.service rpc-gssd.service
>  ConditionPathExists=/etc/krb5.keytab
>  
>  [Service]
> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> index 87a1ce8cec8f39c810c9c67325161de3e6a1db47..9b792a363e14c88ecaf8e45b7a3deadb97b3acac 100644
> --- a/systemd/nfs-client.target
> +++ b/systemd/nfs-client.target
> @@ -5,9 +5,12 @@ Wants=remote-fs-pre.target
>  
>  # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
>  # start that on demand if needed.
> -Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
>  Wants=nfs-blkmap.service rpc-statd-notify.service
> -After=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
> +After=nfs-blkmap.service
> +
> +# GSS services dependencies and ordering
> +Wants=auth-rpcgss-module.service
> +After=rpc-gssd.service rpc-svcgssd.service gssproxy.service
>  
>  [Install]
>  WantedBy=multi-user.target
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 1048c5cbbf68328a8ac8c88b67e477061cf487c7..8010aadc487005cf7f1d1774fb237457a06a5d51 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -2,15 +2,17 @@
>  Description=NFS server and services
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
> -Wants=rpc-statd.service nfs-idmapd.service auth-rpcgss-module.service
> -Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
> +Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
>  
>  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
> -After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
>  Before= rpc-statd-notify.service
>  
> +# GSS services dependencies and ordering
> +Wants=auth-rpcgss-module.service
> +After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
> +
>  Wants=nfs-config.service
>  After=nfs-config.service
>  
> 
