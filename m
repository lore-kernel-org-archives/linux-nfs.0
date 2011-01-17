Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36890 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab1AQRbP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jan 2011 12:31:15 -0500
Message-ID: <4D347CDF.2080600@panasas.com>
Date: Mon, 17 Jan 2011 19:31:11 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "Rees, James" <rees@umich.edu>
CC: NFS list <linux-nfs@vger.kernel.org>, Fred Isaman <iisaman@netapp.com>,
        Andy Adamson <andros@netapp.com>
Subject: pnfs block build errors in 2.6.38
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim, I get the following build errors in 2.6.38:

/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c: In function 'nfs4_blkdev_get':
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c:58: error: implicit declaration of function 'open_by_devnum'
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c:58: warning: assignment makes pointer from integer without a cast
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c: In function 'nfs4_blkdev_put':
/usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/blocklayout/blocklayoutdev.c:75: error: implicit declaration of function 'bd_release'

I pushed the tree to git://git.bhalevy.com/linux-pnfs.git

Mind taking a look at this?

Andy, Fred: you can synchronize with this tree at this point, after the rebase on top
of Bruce's latest changes it won't change much, so feel free to go for it :)

Thanks,

Benny
