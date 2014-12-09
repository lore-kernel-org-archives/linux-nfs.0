Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:40207 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbaLINJ0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 08:09:26 -0500
Received: by mail-qg0-f41.google.com with SMTP id j5so341817qga.28
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 05:09:25 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 9 Dec 2014 08:09:23 -0500
To: David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141209080923.2708eb4f@tlielax.poochiereds.net>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 09 Dec 2014 06:40:40 +0100
David Härdeman <david@hardeman.nu> wrote:

> The following series converts gssd to use libevent and inotify instead
> of a handrolled event loop and dnotify. Lots of cleanups in the process
> (e.g. removing a lot of arbitrary limitations and fixed size buffers).
> 
> All in all a nice reduction in code size (what can I say, I was bored).
> 
> I've even managed to mount NFS shares with the patched server :)
> 
> ---
> 
> David Härdeman (19):
>       nfs-utils: cleanup daemonization code
>       nfs-utils: gssd - merge gssd_main_loop.c and gssd.c
>       nfs-utils: gssd - simplify some option handling
>       nfs-utils: gssd - remove arbitrary GSSD_MAX_CCACHE_SEARCH limitation
>       nfs-utils: gssd - simplify topdirs path
>       nfs-utils: gssd - move over pipfs scanning code
>       nfs-utils: gssd - simplify client dir scanning code
>       nfs-utils: gssd - use libevent
>       nfs-utils: gssd - remove "close me" code
>       nfs-utils: gssd - make the client lists per-topdir
>       nfs-utils: gssd - keep the rpc_pipefs dir open
>       nfs-utils: gssd - use more relative paths
>       nfs-utils: gssd - simplify topdir scanning
>       nfs-utils: gssd - simplify client scanning
>       nfs-utils: gssd - cleanup read_service_info
>       nfs-utils: gssd - change dnotify to inotify
>       nfs-utils: gssd - further shorten some pathnames
>       nfs-utils: gssd - improve inotify
>       nfs-utils: gssd - simplify handle_gssd_upcall
> 
> 
>  support/include/nfslib.h    |    5 
>  support/nfs/mydaemon.c      |   92 +++--
>  utils/gssd/Makefile.am      |   24 +
>  utils/gssd/gss_util.h       |    2 
>  utils/gssd/gssd.c           |  785 +++++++++++++++++++++++++++++++++++++++++--
>  utils/gssd/gssd.h           |   46 +--
>  utils/gssd/gssd_main_loop.c |  263 --------------
>  utils/gssd/gssd_proc.c      |  654 ++----------------------------------
>  utils/gssd/svcgssd.c        |    8 
>  utils/idmapd/idmapd.c       |    6 
>  utils/statd/statd.c         |   66 +---
>  11 files changed, 878 insertions(+), 1073 deletions(-)
>  delete mode 100644 utils/gssd/gssd_main_loop.c
> 
> --
> David Härdeman
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks like a nice cleanup at first glance, but I haven't gone over it
in detail.

One thing that _would_ be nice while you're in here though would be to
help parallelize more of process_krb5_upcall. Currently it forks before
changing its identity and then the parent waits on that to exit which
keeps everything serialized.

I did it that way so that we didn't need change how we close the fds
afterward. Now that you're already doing some surgery there, that might
be easier to do and may help performance.

-- 
Jeff Layton <jlayton@primarydata.com>
