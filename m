Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:52448 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754006AbdLNSMK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 13:12:10 -0500
Date: Thu, 14 Dec 2017 19:05:51 +0100
From: Lennart Poettering <lennart@poettering.net>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH] rpcbind.service: Not pulling the
 rpcbind.target
Message-ID: <20171214180551.GA15603@gardel-login>
References: <20171214170544.11793-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171214170544.11793-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Do, 14.12.17 12:05, Steve Dickson (steved@redhat.com) wrote:

> According to systemd.special(7) manpage:
> 
> rpcbind.target
>     The portmapper/rpcbind pulls in this target and
>     orders itself before it, to indicate its availability. systemd
>     automatically adds dependencies of type After= for this target
>     unit to all SysV init script service units with an LSB header
>     referring to the "$portmap" facility.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/rpcbind.service.in | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> index f8cfa9f..2b49c24 100644
> --- a/systemd/rpcbind.service.in
> +++ b/systemd/rpcbind.service.in
> @@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
>  
>  # Make sure we use the IP addresses listed for
>  # rpcbind.socket, no matter how this unit is started.
> -Wants=rpcbind.socket
> -After=rpcbind.socket
> +Wants=rpcbind.socket rpcbind.target
> +After=rpcbind.socket rpcbind.target

The last line should be:

After=rpcbind.socket
Before=rpcbind.target

Lennart

-- 
Lennart Poettering, Red Hat
