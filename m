Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbaI3PFO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2014 11:05:14 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8UF5E12014311
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 11:05:14 -0400
Message-ID: <542AC6AA.1090702@RedHat.com>
Date: Tue, 30 Sep 2014 11:05:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Move the wants only to the auth unit.
References: <1412014923-26587-1-git-send-email-simo@redhat.com> <1412014923-26587-2-git-send-email-simo@redhat.com>
In-Reply-To: <1412014923-26587-2-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/29/2014 02:22 PM, Simo Sorce wrote:
> This way either gssproxy or rpc.svcgssd are started only if the auth module is
> requested, and it finds a keytab.
> If the wants are in the main nfs-client or nfs-server unit files then the
> two deamons are started unconditionally and would require conditions which we
> can test once and for all in a single unit file instead.
> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
> ---
>  systemd/auth-rpcgss-module.service | 3 ++-
>  systemd/nfs-client.target          | 4 ++--
>  systemd/nfs-server.service         | 1 -
>  3 files changed, 4 insertions(+), 4 deletions(-)
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
By moving these into this unit,it destroys client/server
sync starts commit 12a95eda talks about... 

Maybe we could put an After=nfs-server.service in nfs-client.target
to bring back that synchronization... because in the end
we really really want the server to start first especially
when gssproxy is involved and both units are enabled.

Also, this will cause gssproxy to be started on every boot
regardless whether Kerberos is installed and configured
(which not the case with rpc.svcgssd)... 

I can hear the complaints already... Why is NFS starting 
up this daemon that will never have anything to do, in
the case when Kerberos is not installed/configure
which could be the majority of the cases...

I would really really, really like to avoid this.

steved. 

  
> +Wants=gssproxy.service rpc-svcgssd.service rpc-gssd.service
>  ConditionPathExists=/etc/krb5.keytab
>  
>  [Service]
> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> index 474f5e9ad74b70d265a7b2099556c2b9220bcdd0..f3d884a241543e41fdd91bcb0a055654b4b2c275 100644
> --- a/systemd/nfs-client.target
> +++ b/systemd/nfs-client.target
> @@ -5,9 +5,9 @@ Wants=remote-fs-pre.target
>  
>  # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
>  # start that on demand if needed.
> -Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
> +Wants=auth-rpcgss-module.service
>  Wants=nfs-blkmap.service rpc-statd-notify.service
> -Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
> +Before=nfs-blkmap.service
>  
>  [Install]
>  WantedBy=multi-user.target
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 1048c5cbbf68328a8ac8c88b67e477061cf487c7..a5039062ad95ca0c73c8a6c33d053a845d596185 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -3,7 +3,6 @@ Description=NFS server and services
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
>  Wants=rpc-statd.service nfs-idmapd.service auth-rpcgss-module.service
> -Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
>  Wants=rpc-statd-notify.service
>  
>  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
> 
