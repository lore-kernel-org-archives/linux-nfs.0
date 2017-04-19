Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764182AbdDSOTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 10:19:40 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0B4DF75743
        for <linux-nfs@vger.kernel.org>; Wed, 19 Apr 2017 14:19:40 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-168.rdu2.redhat.com [10.10.120.168])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BDCF67F6A1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Apr 2017 14:19:39 +0000 (UTC)
Subject: Re: [PATCH] systemd: NFS server services should use network-online
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170410112341.10700-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e2b02d7b-3b92-4990-5715-42ca35d70625@RedHat.com>
Date: Wed, 19 Apr 2017 10:19:39 -0400
MIME-Version: 1.0
In-Reply-To: <20170410112341.10700-1-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 04/10/2017 07:23 AM, Steve Dickson wrote:
> There has been an number startup problems where parts of
> the NFS server fails to start due to DNS and other
> parts of the network not be up.
> 
> Reading the systemd.special it seems network.target is
> a passive unit which does not wait for the entire
> network to come up and network-online.target is an
> active unit which does wait.
> 
> So this adds Wants=network-online.target to all of
> the NFS server services
I'm getting some push back on this patch because people
are saying Requires= should be used not Wants= even 
though the man page ways wants... 

The theory is Wants "not strong enough". 

Any opinion on this? Here is the bz 
   https://bugzilla.redhat.com/show_bug.cgi?id=1419351

steved.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-mountd.service       | 2 +-
>  systemd/nfs-server.service       | 4 ++--
>  systemd/rpc-statd-notify.service | 2 +-
>  systemd/rpc-statd.service        | 3 ++-
>  4 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> index b0a8bc0..fec0399 100644
> --- a/systemd/nfs-mountd.service
> +++ b/systemd/nfs-mountd.service
> @@ -2,8 +2,8 @@
>  Description=NFS Mount Daemon
>  DefaultDependencies=no
>  Requires=proc-fs-nfsd.mount
> +Wants=network-online.target
>  After=proc-fs-nfsd.mount
> -After=network.target local-fs.target
>  After=rpcbind.socket
>  BindsTo=nfs-server.service
>  
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 7cf4ae0..e6b8f58 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -3,11 +3,11 @@ Description=NFS server and services
>  DefaultDependencies=no
>  Requires= network.target proc-fs-nfsd.mount
>  Requires= nfs-mountd.service
> -Wants=rpcbind.socket
> +Wants=rpcbind.socket network-online.target
>  Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
>  
> -After= local-fs.target network-online.target
> +After= local-fs.target
>  After= proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
>  Before= rpc-statd-notify.service
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index 7bfc9b1..f54d4c5 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -1,7 +1,7 @@
>  [Unit]
>  Description=Notify NFS peers of a restart
>  DefaultDependencies=no
> -Requires=network.target
> +Wants=network-online.target
>  After=local-fs.target network.target nss-lookup.target
>  
>  # if we run an nfs server, it needs to be running before we
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index 60d600f..8cef022 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -3,7 +3,8 @@ Description=NFS status monitor for NFSv2/3 locking.
>  DefaultDependencies=no
>  Conflicts=umount.target
>  Requires=nss-lookup.target rpcbind.socket
> -After=network.target nss-lookup.target rpcbind.socket
> +Wants=network-online.target
> +After=nss-lookup.target rpcbind.socket
>  
>  PartOf=nfs-utils.service
>  
> 
