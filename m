Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39203 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759137Ab2CIULm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 15:11:42 -0500
Date: Fri, 9 Mar 2012 15:11:41 -0500
To: Simo Sorce <simo@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Kill SPKM3 auth method
Message-ID: <20120309201141.GA20153@fieldses.org>
References: <1331321672-2111-1-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1331321672-2111-1-git-send-email-simo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 09, 2012 at 02:34:25PM -0500, Simo Sorce wrote:
> This authentication method is obsolete and it is time it dies for good.

Yes, the kernel no longer supports it, it was never really used, and
it's now deprecated.

It might have some historical value, but someone that needs to go look
at that code can find it in the git history.

So, ACK from me.--b.

> 
> Simo Sorce (7):
>   Kill SPKM3: Remove spkm3 references from svcgssd
>   Kill SPKM3: Remove spkm3 support from gssd
>   Kill SPKM3: remove spkm3 from common gssd code
>   Kill SPKM3: Remove spkm3 support from nfs.mount
>   Kill SPKM3: Remove spkm3 support from exports
>   Kill SPKM3: Stop checking for spkm3.h in configure
>   Kill SPKM3: Remove mentions of SPKM3 from README
> 
>  README                          |    4 +-
>  configure.ac                    |    3 -
>  support/include/pseudoflavors.h |    3 -
>  support/nfs/exports.c           |    3 -
>  utils/gssd/Makefile.am          |    1 -
>  utils/gssd/context.c            |    4 -
>  utils/gssd/context.h            |    2 -
>  utils/gssd/context_spkm3.c      |  184 ---------------------------------------
>  utils/gssd/gss_oids.c           |    3 -
>  utils/gssd/gss_oids.h           |    1 -
>  utils/gssd/gssd.h               |    5 +-
>  utils/gssd/gssd_main_loop.c     |   11 ---
>  utils/gssd/gssd_proc.c          |  106 +----------------------
>  utils/gssd/svcgssd_mech2file.c  |    1 -
>  utils/gssd/svcgssd_proc.c       |    8 +--
>  utils/mount/nfs.man             |    7 +-
>  utils/mount/nfs_mount.h         |    3 -
>  utils/mount/nfsmount.c          |    6 --
>  18 files changed, 10 insertions(+), 345 deletions(-)
>  delete mode 100644 utils/gssd/context_spkm3.c
> 
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
