Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751826AbdBPKWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 05:22:03 -0500
Subject: Re: [PATCH] Fix nfs-mountd dependency on rpcbind
To: Rafael David Tinoco <rafael.tinoco@canonical.com>,
        linux-nfs@vger.kernel.org
References: <20170207191650.19219-1-rafael.tinoco@canonical.com>
Cc: neilb@suse.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <be365f8a-ef61-9240-b28a-7f1659326d88@RedHat.com>
Date: Thu, 16 Feb 2017 05:22:03 -0500
MIME-Version: 1.0
In-Reply-To: <20170207191650.19219-1-rafael.tinoco@canonical.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2017 02:16 PM, Rafael David Tinoco wrote:
> Following commit 91da135f - it replaced "rpcbind.target" by "rpcbind.socket" in
> some unit files - "rpcbind.socket" should also be added to "nfs-mountd.service"
> as a dependency to avoid race conditions.
>
> Usually "rpcbind.socket" is either started as a "sockets.target" dependency, or
> as a dependency for "nfs-server.service", when unit files include it in
> "BindsTo" or "After". Unfortunately there is a possilibility to have
> "nfs-mountd.service" started when the rpcbind socket is not yet created:
>
> systemd[1]: Starting NFS Mount Daemon...
> systemd[1]: nfs-mountd.service: Control process exited, code=exited status=1
> systemd[1]: Failed to start NFS Mount Daemon.
> systemd[1]: nfs-mountd.service: Unit entered failed state.
> systemd[1]: nfs-mountd.service: Failed with result 'exit-code'.
>
> Nowadays "nfs-mountd.service" uses "BindTo" directive to "nfs-server.service".
> That, per se, doesn't guarantee ordering for NFS server to start rpcbind and for
> nfs-mountd to depend on it.
>
> https://bugs.launchpad.net/bugs/1590799
>
> Signed-off-by: Rafael David Tinoco <rafael.tinoco@canonical.com>
Committed

steved.
> ---
>  systemd/nfs-mountd.service | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> index 15e828b..b0a8bc0 100644
> --- a/systemd/nfs-mountd.service
> +++ b/systemd/nfs-mountd.service
> @@ -4,6 +4,7 @@ DefaultDependencies=no
>  Requires=proc-fs-nfsd.mount
>  After=proc-fs-nfsd.mount
>  After=network.target local-fs.target
> +After=rpcbind.socket
>  BindsTo=nfs-server.service
>  
>  [Service]

