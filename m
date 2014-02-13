Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbaBMTmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Feb 2014 14:42:19 -0500
Message-ID: <52FD2017.4050403@RedHat.com>
Date: Thu, 13 Feb 2014 14:42:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH nfs-utils/systemd] systemd: convert secure services to
 start without explicit configuration.
References: <20140205141836.5fc941a9@notabene.brown>
In-Reply-To: <20140205141836.5fc941a9@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/04/2014 10:18 PM, NeilBrown wrote:
> 
> 
> This patch removes nfs-secure.target.
> Instead, rpc.gssd and rpc.svcgssd start started if they appear to be needed.
> 
> For rpc.gssd, this means if the file /etc/krb5.keytab exists.
> As the only security mechanism supported is krb5, that file must exist
> for rpc.gssd to be useful.  Conversely, if it does exist, it seems very
> likely that krb5 is configured on the system an may be used for NFS.
> 
> For rpc.svcgssd, it also means checking if gss-proxy might be performing
> the equivalent task instead.  So we check if it is running, and if the kernel
> is able to talk to it.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed to the systemd branch of my git tree...

I would like to more testing before I move them on
to the master branch...

steved.

> 
> diff --git a/systemd/README b/systemd/README
> index 00d3e415092e..d697cefbe229 100644
> --- a/systemd/README
> +++ b/systemd/README
> @@ -24,11 +24,6 @@ by a suitable 'preset' setting:
>      is started by /usr/sbin/start-statd which mount.nfs will run
>      if statd is needed.
>  
> - nfs-secure.target
> -    If enabled, then rpc.gssd will be run when either -client or
> -    -server is started, and rpc.svcgssd will be run when -server
> -    is started
> -
>   nfs-blkmap.target
>      If enabled, then blkmapd will be run when nfs-client.target is
>      started.
> @@ -52,3 +47,15 @@ This should write /run/sysconfig/nfs-utils based on configuration
>  information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
>  It should write to a tmp file and rename to the target to
>  avoid parallel units seeing incomplete copies of the file.
> +
> +rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
> +is present.
> +If a site needs this file present but does not want the gss daemons
> +running, it should create
> +   /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
> +and
> +   /etc/systemd/system/rpc-svcgssd.service.d/01-disable.conf
> +
> +containing
> +   [Unit]
> +   ConditionNull=false
> diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
> deleted file mode 100644
> index 0127fdb07dbd..000000000000
> --- a/systemd/nfs-secure.target
> +++ /dev/null
> @@ -1,8 +0,0 @@
> -[Unit]
> -Description=Secure NFS client/server services
> -# If this target is enabled, then rpc.gssd and rpc.svcgssd will be started
> -# as required.  If it is not enabled they won't.
> -
> -[Install]
> -WantedBy=remote-fs.target
> -WantedBy=multi-user.target
> \ No newline at end of file
> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> index f0fef007d480..8778c3ef651b 100644
> --- a/systemd/rpc-gssd.service
> +++ b/systemd/rpc-gssd.service
> @@ -3,8 +3,7 @@ Description=RPC security service for NFS client and server
>  Requires=var-lib-nfs-rpc_pipefs.mount
>  After=var-lib-nfs-rpc_pipefs.mount
>  
> -Requisite=nfs-secure.target
> -After=nfs-secure.target
> +ConditionPathExists=/etc/krb5.keytab
>  
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index f024d40a8f41..036ec579bfc1 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -4,8 +4,10 @@ Requires=var-lib-nfs-rpc_pipefs.mount
>  After=var-lib-nfs-rpc_pipefs.mount
>  PartOf=nfs-server.service
>  
> -Requisite=nfs-secure.target
> -After=nfs-secure.target
> +After=gssproxy.service
> +ConditionPathExists=|!@localstatedir@/run/gssproxy.pid
> +ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
> +ConditionPathExists=/etc/krb5.keytab
>  
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
> 
