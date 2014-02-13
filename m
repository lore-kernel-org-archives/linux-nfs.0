Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbaBMTkh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Feb 2014 14:40:37 -0500
Message-ID: <52FD1FB2.9010402@RedHat.com>
Date: Thu, 13 Feb 2014 14:40:34 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] systemd units: merge nfs-server.service and
 nfs-server.target
References: <20140204120957.7bb0375a@notabene.brown>
In-Reply-To: <20140204120957.7bb0375a@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/03/2014 08:09 PM, NeilBrown wrote:
> 
> With systemd, a 'service' should run a single server while a 'target'
> can be used to group services.
> As nfs service is really a group of services a 'target' makes more sense.
> However that means that we need commands like
>    systemctl start nfs-server.target
> rather than the more simple
>    systemctl start nfs-server
> 
> As the target/service separate doesn't bring any gain except a minor aesthetic,
> and does bring a practical inconvenience, this patch merges nfs-server.target
> into nfs-server.service.
> 
> Reported-by: Steve Dickson <SteveD@redhat.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed to systemd branch of my git tree...

steved.

> 
> diff --git a/systemd/README b/systemd/README
> index f0fb68825499..00d3e415092e 100644
> --- a/systemd/README
> +++ b/systemd/README
> @@ -10,9 +10,13 @@ rpc.rquotad (in the 'quota' package) or rpcbind.
>  There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
>  by a suitable 'preset' setting:
>  
> - nfs-server.target
> + nfs-server.service
>      If enabled, nfs service is started together with dependencies
>      such as mountd, statd, rpc.idmapd
> +    This is a "service" file rather than a "target" (which is the
> +    normal grouping construct) so that
> +        systemctl start nfs-server
> +    can work (if no type is given, ".service" is assumed).
>  
>   nfs-client.target
>      If enabled, daemons needs for an nfs client are enabled.
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 9812866c66aa..6ba2fc0f346e 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,8 +1,10 @@
>  [Unit]
> -Description=NFS server
> +Description=NFS server and services
>  DefaultDependencies=no
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
> -PartOf=nfs-server.target
> +Requires= nfs-mountd.service
> +Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> +Wants=rpc-statd-notify.service
>  
>  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
> @@ -22,3 +24,6 @@ ExecStopPost=/usr/sbin/exportfs -au
>  ExecStopPost=/usr/sbin/exportfs -f
>  
>  ExecReload=/usr/sbin/exportfs -r
> +
> +[Install]
> +WantedBy=multi-user.target
> diff --git a/systemd/nfs-server.target b/systemd/nfs-server.target
> deleted file mode 100644
> index a3e629f022a9..000000000000
> --- a/systemd/nfs-server.target
> +++ /dev/null
> @@ -1,8 +0,0 @@
> -[Unit]
> -Description=NFS server services
> -Requires=nfs-server.service nfs-mountd.service
> -Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> -Wants=rpc-statd-notify.service
> -
> -[Install]
> -WantedBy=multi-user.target
> 
