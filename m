Return-Path: linux-nfs-owner@vger.kernel.org
Received: from kawka.in.waw.pl ([178.63.212.103]:32891 "EHLO kawka.in.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756160AbbCCSe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 13:34:26 -0500
Date: Tue, 3 Mar 2015 18:58:04 +0100
From: Zbigniew =?utf-8?Q?J=C4=99drzejewski-Szmek?= <zbyszek@in.waw.pl>
To: Martin Pitt <martin.pitt@ubuntu.com>
Cc: linux-nfs@vger.kernel.org, systemd-devel@lists.freedesktop.org
Subject: Re: [systemd-devel] [PATCH 1/2] systemd: Order NFS server before
 client
Message-ID: <20150303175804.GI3058@in.waw.pl>
References: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com>
 <1425403690-23847-2-git-send-email-martin.pitt@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1425403690-23847-2-git-send-email-martin.pitt@ubuntu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2015 at 06:28:09PM +0100, Martin Pitt wrote:
> This makes mounting NFS shares from localhost work reliably, as you need to
> start the server before attempting (client) mounts, and conversely on shutdown
> need to unmount all shares before stopping the server to avoid hangs.
> ---
>  systemd/nfs-server.service | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 8010aad..b35e193 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -13,6 +13,9 @@ Before= rpc-statd-notify.service
>  Wants=auth-rpcgss-module.service
>  After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
>  
> +# start/stop server before/after client
> +Before=remote-fs-pre.target
> +
>  Wants=nfs-config.service
>  After=nfs-config.service

Looks reasonable.

Zbyszek
