Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34058 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752755AbcK1Umq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Nov 2016 15:42:46 -0500
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Fix path for rpcbind in
 rpcbind.service.
To: NeilBrown <neilb@suse.com>
References: <87shqga40h.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <21b59ce6-7657-14fa-949a-1cf9f82b6814@RedHat.com>
Date: Mon, 28 Nov 2016 15:42:45 -0500
MIME-Version: 1.0
In-Reply-To: <87shqga40h.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/24/2016 05:48 PM, NeilBrown wrote:
> 
> Due to a miscommunication,
>  Commit: 0cc39c519278 ("Provide systemd unit files for rpcbind")
> used sbindir as the location of rpcbind to put in the systemd unit
> file instead of bindir, which is where rpcbind gets installed.
> 
> So change those few instances of sbindir to bindir so that the unit
> file will have the correct path.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... 

steved.

> ---
>  configure.ac               | 6 +++---
>  systemd/rpcbind.service.in | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index acc69149c862..f34f669dc7da 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -61,9 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
>  
>  AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
>  
> -# make sbindir available for substitution in config file
> +# make bindir available for substitution in config file
>  # 2 "evals" needed to expand variable names
> -AC_SUBST([_sbindir])
> -AC_CONFIG_COMMANDS_PRE([eval eval _sbindir=$sbindir])
> +AC_SUBST([_bindir])
> +AC_CONFIG_COMMANDS_PRE([eval eval _bindir=$bindir])
>  
>  AC_OUTPUT([Makefile systemd/rpcbind.service])
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> index c173b838bd42..e7e86da0c268 100644
> --- a/systemd/rpcbind.service.in
> +++ b/systemd/rpcbind.service.in
> @@ -11,7 +11,7 @@ After=rpcbind.socket
>  [Service]
>  Type=notify
>  # distro can provide a drop-in adding EnvironmentFile=-/??? if needed.
> -ExecStart=@_sbindir@/rpcbind $RPCBIND_OPTIONS -w -f
> +ExecStart=@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
>  
>  [Install]
>  WantedBy=multi-user.target
> 
> 
> 
> ------------------------------------------------------------------------------
> 
> 
> 
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
> 
