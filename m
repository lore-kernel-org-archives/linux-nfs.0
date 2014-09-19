Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932186AbaISTvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 15:51:13 -0400
Message-ID: <541C892D.7020401@RedHat.com>
Date: Fri, 19 Sep 2014 15:51:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-server: Replace rpc.svcgssd with gssproxy in
 systemd script
References: <1411146621-18797-1-git-send-email-steved@redhat.com> <1411146621-18797-2-git-send-email-steved@redhat.com>
In-Reply-To: <1411146621-18797-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil,

On 09/19/2014 01:10 PM, Steve Dickson wrote:
> Have the nfs-server depend/start on the gssproxy daemon
> instead of rpc.svcgssd to manage GSSAPI credentials
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-server.service | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 2fa7387..3b04f84 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -2,12 +2,12 @@
>  Description=NFS server and services
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
> -Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> +Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service gssproxy.service
>  Wants=rpc-statd-notify.service
>  
>  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
> -After= rpc-gssd.service rpc-svcgssd.service
> +After= rpc-gssd.service gssproxy.service
Is there a better way to do this, to be more backwards compatible? 

Maybe figure out that gssproxy is installed so would start that daemon
if not fall back to rpc.svcgssd? 

Unfortunately systemd is still somewhat of a mystery to me.... :-( 

steved.
>  Before= rpc-statd-notify.service
>  
>  Wants=nfs-config.service
> 
