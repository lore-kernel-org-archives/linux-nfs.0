Return-Path: SteveD@redhat.com
Message-ID: <54EF762F.3030801@RedHat.com>
Date: Thu, 26 Feb 2015 14:38:23 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Fix rpc.gssd and rpc.svcgssd args variable
 names
References: <88e82aeaea947c3aa47f57dc5c02c5bdbe901961.1423671114.git.bcodding@redhat.com>
In-Reply-To: <88e82aeaea947c3aa47f57dc5c02c5bdbe901961.1423671114.git.bcodding@redhat.com>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>



On 02/11/2015 11:17 AM, Benjamin Coddington wrote:
> This fixes mis-matched variable names from fedora's /etc/sysconfig/nfs.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  systemd/rpc-gssd.service    |    2 +-
>  systemd/rpc-svcgssd.service |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> index d4a3819..6e1af86 100644
> --- a/systemd/rpc-gssd.service
> +++ b/systemd/rpc-gssd.service
> @@ -16,4 +16,4 @@ After=nfs-config.service
>  EnvironmentFile=-/run/sysconfig/nfs-utils
>  
>  Type=forking
> -ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
> +ExecStart=/usr/sbin/rpc.gssd $RPCGSSDARGS
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index f7424b0..0aeaed9 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -16,4 +16,4 @@ After=nfs-config.service
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
>  Type=forking
> -ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
> +ExecStart=/usr/sbin/rpc.svcgssd $RPCSVCGSSDARGS
> 
This is distro specific... So I'm going to leave as is... 

steved.
