Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60071 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247AbaI2Scr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 14:32:47 -0400
Date: Mon, 29 Sep 2014 14:32:46 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-client.target: Removed a ordering cycle with
 nfs-server.service
Message-ID: <20140929183245.GI30691@fieldses.org>
References: <1412004817-14432-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412004817-14432-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 29, 2014 at 11:33:37AM -0400, Steve Dickson wrote:
> On a VM that boots very fast and with out kerberos
> enabled a systemd ordering cycle happens between
> nfs-client and nfs-server units when both were
> enabled.
> 
> Having nfs-client start the gssd daemons in the
> same matter as the nfs-server does ('After=') seemed
> to eliminated the ordering cycle.

ACK.--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-client.target | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> index 474f5e9..87a1ce8 100644
> --- a/systemd/nfs-client.target
> +++ b/systemd/nfs-client.target
> @@ -7,7 +7,7 @@ Wants=remote-fs-pre.target
>  # start that on demand if needed.
>  Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
>  Wants=nfs-blkmap.service rpc-statd-notify.service
> -Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
> +After=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
>  
>  [Install]
>  WantedBy=multi-user.target
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
