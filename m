Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756383Ab2CLUft (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 16:35:49 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2CKZnQR013974
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2012 16:35:49 -0400
Message-ID: <4F5E5E21.6040309@RedHat.com>
Date: Mon, 12 Mar 2012 16:35:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Kill SPKM3 auth method
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/09/2012 02:49 PM, Simo Sorce wrote:
> This authentication method is obsolete and it is time it dies for good.
> 
> Sorry for spamming again, the first time I forgot to singoff the commits.
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
Committed...

steved.
