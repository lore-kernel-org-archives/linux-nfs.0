Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:34396 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755719AbdLOOwG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Dec 2017 09:52:06 -0500
Date: Fri, 15 Dec 2017 15:52:04 +0100
From: Lennart Poettering <lennart@poettering.net>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH][V2] rpcbind.service: Not pulling the
 rpcbind.target
Message-ID: <20171215145203.GA16686@gardel-login>
References: <20171215130047.8944-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171215130047.8944-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fr, 15.12.17 08:00, Steve Dickson (steved@redhat.com) wrote:

> According to systemd.special(7) manpage:
> 
> rpcbind.target
>     The portmapper/rpcbind pulls in this target and orders itself
>     before it, to indicate its availability. systemd automatically
>     adds dependencies of type After= for this target unit to
>     all SysV init script service units with an LSB header
>     referring to the "$portmap" facility.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1431574
> ---
>  systemd/rpcbind.service.in | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> index f8cfa9f..9dbc82c 100644
> --- a/systemd/rpcbind.service.in
> +++ b/systemd/rpcbind.service.in
> @@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
>  
>  # Make sure we use the IP addresses listed for
>  # rpcbind.socket, no matter how this unit is started.
> -Wants=rpcbind.socket
> -After=rpcbind.socket
> +Requires=rpcbind.socket
> +Before=rpcbind.target

You should still pull in rpcbind.target as the man page
says. i.e. "Wants=rpcbind.target" really should be there.

Lennart

-- 
Lennart Poettering, Red Hat
