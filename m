From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs-utils: Various bug fixes and cleanups to blkmapd
Date: Wed, 03 Nov 2010 17:02:06 +0200
Message-ID: <4CD1796E.2020006@panasas.com>
References: <20101029153637.GA31961@merit.edu> <4CCFB107.1090600@panasas.com> <20101102140522.GA23409@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Eric Anderle <eanderle@umich.edu>,
	peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:42629 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755563Ab0KCPDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 11:03:10 -0400
In-Reply-To: <20101102140522.GA23409-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-02 16:05, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   There are conflicts merging this patch as bldev_read_ap_state
>   is already defined (in "Add complex block layout discovery and mapping daemon")
>   I'm not sure how, but we seem out of sync, maybe I didn't get an earlier patch
>   of yours.
> 
> My patches are all in your pnfs-nfs-utils-1-2-3-2010-10-08 but are missing
> after that.  I will re-send.

Sorry about that.  Thanks for tracking this down and resending!

Benny

> 
> % git shortlog --author=rees@umich pnfs-nfs-utils-1-2-3-2010-10-08
> Jim Rees (5):
>       Add complex block layout discovery and mapping daemon
>       blkmapd: get rid of config file and instead examine all block devices
>       blkmapd: don't rescan periodically
>       blkmapd: don't use atomicio() where it's not needed
>       blkmapd: don't try to distinguish between active/passive devices
> 
> % git shortlog --author=rees@umich origin/master
> Jim Rees (1):
>       Add complex block layout discovery and mapping daemon
