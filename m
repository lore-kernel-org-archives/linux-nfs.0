Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6669 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab1AXDBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Jan 2011 22:01:06 -0500
Message-ID: <4D3CEB71.4070707@panasas.com>
Date: Sun, 23 Jan 2011 22:01:05 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 0/3] nfs-utils: blkmapd
References: <cover.1295627825.git.rees@umich.edu>
In-Reply-To: <cover.1295627825.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks. Merged at pnfs-nfs-utils-1-2-4-rc5

Benny

On 2011-01-21 11:53, Jim Rees wrote:
> This set of patches fixes various bugs in stripe size calculation turned up
> in testing.  I believe blkmapd will now handle any layout that is allowed by
> the spec and can be constructed by device-mapper.
> 
> If a striped device is not a multiple of both the number of constituent
> devices and the stripe width, blkmapd will truncate the device so that
> device-mapper can handle it.
> 
> Jim Rees (3):
>   change device offset to signed to match the spec
>   Fix calculation of stripe device and unit sizes
>   Various improvements to comments and syslog messages
> 
>  utils/blkmapd/device-discovery.c |    2 -
>  utils/blkmapd/device-discovery.h |    4 +-
>  utils/blkmapd/device-process.c   |   50 +++++++++++++++++++------------------
>  utils/blkmapd/dm-device.c        |   28 ++++++++++++++++-----
>  4 files changed, 49 insertions(+), 35 deletions(-)
> 
