Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56929 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932527AbaLJUfN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 15:35:13 -0500
Date: Wed, 10 Dec 2014 15:35:11 -0500
To: David =?utf-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141210203511.GF20235@fieldses.org>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2014 at 06:40:40AM +0100, David Härdeman wrote:
> The following series converts gssd to use libevent and inotify instead
> of a handrolled event loop and dnotify. Lots of cleanups in the process
> (e.g. removing a lot of arbitrary limitations and fixed size buffers).
> 
> All in all a nice reduction in code size (what can I say, I was bored).

This code has been crying out for help for a while, thanks for taking a
look!

On dnotify/inotify: if I remember correctly, this was written before
inotify existed.  So you're probably breaking compatibility with older
kernels, which we normally try not to do.

According to inotify(7):

	Inotify  was merged into the 2.6.13 Linux kernel.  The required
	library interfaces were  added  to  glibc  in  version  2.4.
	(IN_DONT_FOLLOW, IN_MASK_ADD, and IN_ONLYDIR were added in
	version 2.5.)

So that's almost 10 years.  In RHEL terms I think RHEL4 would be the
latest without inotify support.

OK, maybe that's long enough.

If there's an easy way to provide a fallback to dnotify, that would be
nice, otherwise would you mind just adding a note about this somewhere?
(Maybe the gssd man page should say something like "this version of gssd
depends on inotify, introduced in kernel version 2.6.13...".)

--b.

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
