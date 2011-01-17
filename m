Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10565 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417Ab1AQR5v convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jan 2011 12:57:51 -0500
Subject: Re: pnfs block build errors in 2.6.38
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4D347CDF.2080600@panasas.com>
Date: Mon, 17 Jan 2011 12:57:34 -0500
Cc: James Rees <rees@umich.edu>, NFS list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Message-Id: <091DDD0F-1819-45B3-9925-33AF6B318E51@netapp.com>
References: <4D347CDF.2080600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 17, 2011, at 12:31 PM, Benny Halevy wrote:

> Jim, I get the following build errors in 2.6.38:
> 
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c: In function 'nfs4_blkdev_get':
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c:58: error: implicit declaration of function 'open_by_devnum'
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c:58: warning: assignment makes pointer from integer without a cast
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c: In function 'nfs4_blkdev_put':
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c:75: error: implicit declaration of function 'bd_release'
> 
> I pushed the tree to git://git.bhalevy.com/linux-pnfs.git
> 
> Mind taking a look at this?
> 
> Andy, Fred: you can synchronize with this tree at this point, after the rebase on top
> of Bruce's latest changes it won't change much, so feel free to go for it :)
> 
> Thanks,
> 
> Benny

Cool.  Thanks Benny.  Just one note, the pnfs-submit branch should probably point to 56782b15 "pnfs-submit: wave4: fix bug dealing with commit split between DS and MDS" or at least somewhere close to that (before any LAYOUTCOMMIT code).

Fred


