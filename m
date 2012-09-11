Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:36426 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165Ab2IKTZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2012 15:25:24 -0400
Received: from sim by peace.netnation.com with local (Exim 4.80)
	(envelope-from <sim@netnation.com>)
	id 1TBW5L-0004be-Fr
	for linux-nfs@vger.kernel.org; Tue, 11 Sep 2012 12:25:23 -0700
Date: Tue, 11 Sep 2012 12:25:23 -0700
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: Re: [3.6-rc3] rdirplus broken? (EBUSY)
Message-ID: <20120911192523.GA11160@hostway.ca>
References: <20120827215510.GL24761@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120827215510.GL24761@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 27, 2012 at 02:55:10PM -0700, Simon Kirby wrote:

> Hello!
> 
> Something seems broiken in 3.6-rc[123] which was fine in 3.5 and earlier.
> This is a 3.4.1 knfsd server with ext3 and XFS-based NFS exports:
> 
> /	192.168.13.0/24(rw,no_root_squash,no_subtree_check,async)
> /pics	192.168.13.0/24(rw,no_root_squash,no_subtree_check,async)
> /raid	192.168.13.0/24(rw,no_root_squash,no_subtree_check,async)
> 
> and a 3.6-rc3 client with this in fstab:
> 
> flick:/		/flick		nfs	rw,vers=3
> flick:/raid	/flick/raid	nfs	rw,vers=3
> flick:/pics	/flick/pics	nfs	rw,vers=3
> 
> This seems to fail now as follows:
> 
> [sroot@oof:/]# mount flick
> [sroot@oof:/]# mount flick/raid
> [sroot@oof:/]# mount flick/pics
> [sroot@oof:/]# ls -l flick
> ls: cannot access flick/pics: Device or resource busy
> ls: cannot access flick/raid: Device or resource busy
> total 2180
> drwxr-xr-x  45 root root    4096 Jun 18 14:19 ./
> drwxr-xr-x  58 root root    4096 Jul  3 22:24 ../
> ...
> ??????????   ? ?    ?          ?            ? pics
> ??????????   ? ?    ?          ?            ? raid
> ...
> [sroot@oof:/]# cd flick/pics
> flick/pics: Device or resource busy.
> 
> These mount points are now stuck and cannot be unmounted until
> I reboot (umount -l fails with EBUSY).
> 
> If I mount with "nordirplus", I can't seem to get it to break. However,
> sometimes it will work regardless. I can bisect this if it would help..

This is still the case with 3.6-rc5. I hadn't noticed any problem since
mounting with nordirplus, and it broke immediately after removing the
option again. I will bisect.

Simon-
