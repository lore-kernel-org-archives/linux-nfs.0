From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/4] nfs-utils: rework device scanning in blkmapd
Date: Mon, 11 Oct 2010 11:05:56 -0400
Message-ID: <4CB327D4.8050807@panasas.com>
References: <cover.1286552019.git.rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
	sfaibish <sfaibish@emc.com>,
	peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:41692 "HELO
	exprod5og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754501Ab0JKPF6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Oct 2010 11:05:58 -0400
In-Reply-To: <cover.1286552019.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged, thanks!

Benny

On 2010-10-08 12:06, Jim Rees wrote:
> This series reworks the way device scanning is done in blkmapd as a result
> of test results and discussions at the Fall 2010 Bakeathon.
> 
> We get rid of the config file and instead examine all block devices as
> listed in /sys/block and /proc/partitions (this is the way fdisk does it).
> Since we're looking for pnfs signatures, it usually doesn't hurt to examine
> a device that isn't part of a layout, and in general it's hard to tell ahead
> of time which devices should be considered, so I think having a config file
> does more harm than good.
> 
> We get rid of periodic (once a minute) device rescanning, and instead rescan
> only when the kernel asks for a layout.  This will suffice for the common
> case, and works with all current known server implementations.  A later
> patch will re-introduce rescanning during the life of a layout, but will be
> triggered by configuration change notifications from udev, rather than by
> expiration of an arbitrary time interval.
> 
> We get rid of the test for active/passive devices.  This test really only
> works for EMC servers, and isn't even needed because the passive devices
> will be skipped over during signature detection.  Just remove the detection
> code.
> 
> Jim Rees (4):
>   blkmapd: get rid of config file and instead examine all block devices
>   blkmapd: don't rescan periodically
>   blkmapd: don't use atomicio() where it's not needed
>   blkmapd: don't try to distinguish between active/passive devices
> 
>  utils/blkmapd/Makefile.am        |    2 -
>  utils/blkmapd/cfg.c              |  248 --------------------------------------
>  utils/blkmapd/cfg.h              |   47 -------
>  utils/blkmapd/device-discovery.c |  141 ++++++++--------------
>  utils/blkmapd/device-discovery.h |    3 -
>  utils/blkmapd/device-inq.c       |   40 ++-----
>  utils/blkmapd/device-process.c   |    2 +-
>  7 files changed, 60 insertions(+), 423 deletions(-)
>  delete mode 100644 utils/blkmapd/cfg.c
>  delete mode 100644 utils/blkmapd/cfg.h
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
