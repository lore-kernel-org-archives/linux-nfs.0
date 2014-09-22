Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33673 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135AbaIVTk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 15:40:57 -0400
Date: Mon, 22 Sep 2014 15:40:57 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140922194057.GE26763@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
 <1411413608-16462-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1411413608-16462-2-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 22, 2014 at 03:20:07PM -0400, Steve Dickson wrote:
> Added the gssproxy.service to both the Wants= and
> Atfers= lines, before the rpc-svcgssd.service. There
> are  ConditionPathExists= lines in the rpc-svcgssd.service
> unit which will stop the rpc.svcgssd daemon from
> starting when the gssproxy daemon is already running.

That should read "when the kernel supports gssproxy", not "when the
gssproxy daemon is already running."

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-server.service | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 2fa7387..c740fa2 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -2,12 +2,13 @@
>  Description=NFS server and services
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
> -Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
> +Wants=rpc-statd.service nfs-idmapd.service 
> +Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
>  Wants=rpc-statd-notify.service
>  
>  After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
> -After= rpc-gssd.service rpc-svcgssd.service
> +After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
>  Before= rpc-statd-notify.service
>  
>  Wants=nfs-config.service
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
