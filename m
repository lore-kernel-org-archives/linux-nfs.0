From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/6] nfs-utils: Cumulative patches for blkmapd
Date: Wed, 03 Nov 2010 09:08:21 +0200
Message-ID: <4CD10A65.1050601@panasas.com>
References: <cover.1288726186.git.rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
	Steve Dickson <steved@redhat.com>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:42708 "HELO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753125Ab0KCHIZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 03:08:25 -0400
In-Reply-To: <cover.1288726186.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All merged and pushed to git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git
at tag pnfs-utils-1-2-4-rc1

Thanks!

Benny

On 2010-11-02 22:08, Jim Rees wrote:
> Cumulative patches for blkmapd.
> 
> Jim Rees (6):
>   blkmapd: get rid of config file and instead examine all block devices
>   blkmapd: don't rescan periodically
>   blkmapd: don't use atomicio() where it's not needed
>   ignore passive devices before checking serial numbers
>   add "-d" option to just do discovery then exit
>   Various bug fixes and cleanups.
> 
>  utils/blkmapd/Makefile.am        |    3 -
>  utils/blkmapd/atomicio.c         |   54 --------
>  utils/blkmapd/cfg.c              |  248 --------------------------------------
>  utils/blkmapd/cfg.h              |   47 -------
>  utils/blkmapd/device-discovery.c |  216 +++++++++++++++------------------
>  utils/blkmapd/device-discovery.h |    5 +-
>  utils/blkmapd/device-inq.c       |   43 +++----
>  utils/blkmapd/device-process.c   |   30 ++---
>  utils/blkmapd/dm-device.c        |    1 +
>  9 files changed, 129 insertions(+), 518 deletions(-)
>  delete mode 100644 utils/blkmapd/atomicio.c
>  delete mode 100644 utils/blkmapd/cfg.c
>  delete mode 100644 utils/blkmapd/cfg.h
> 
