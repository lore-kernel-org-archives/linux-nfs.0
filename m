Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753182AbaLIQkF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 11:40:05 -0500
Message-ID: <548725DF.9000202@RedHat.com>
Date: Tue, 09 Dec 2014 11:39:59 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?RGF2aWQgSMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/19] gssd improvements
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 12/09/2014 12:40 AM, David Härdeman wrote:
> The following series converts gssd to use libevent and inotify instead
> of a handrolled event loop and dnotify. Lots of cleanups in the process
> (e.g. removing a lot of arbitrary limitations and fixed size buffers).
> 
> All in all a nice reduction in code size (what can I say, I was bored).
I just have to asked... Does this patch set solve a problem? Fix a Bug?
I know you said you were bored :-) but what was your motivation?

The reason I ask is this patch set just scream out to me were "fixing 
something that is not broken". Plus rewrites like this eliminate years 
of testing and stability, so we can't take it lightly. gssd is now
an important part of all nfs client mounts... 

That said, I did read through the set and there is definitely some
good/needed cleanup as well some superfluous changes which is fine..
Its obvious you do have a clue and you spent some time on them.. 

So by no means I am against these patches. I guess I need a reason 
to apply them... ;-) What do they fix? Are these patches leading use 
down to a better place? Is there a noticeable performance gain?  

Finally, why the "change dnotify to inotify" a good thing? 

> 
> I've even managed to mount NFS shares with the patched server :)
Was that mount at least a secure mount? ;-)  Seriously was that all
the testing that done?

Again, thank you for your time!

steved.
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
