Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:28161 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754524AbaDPGSg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 02:18:36 -0400
Date: Wed, 16 Apr 2014 16:18:20 +1000
From: Dave Chinner <david@fromorbit.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 19/19] XFS: set PF_FSTRANS while ilock is held in
 xfs_free_eofblocks
Message-ID: <20140416061819.GF15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.7488.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140416040337.10604.7488.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> memory allocates can happen while the xfs ilock is held in
> xfs_free_eofblocks, particularly
> 
>   [<ffffffff813e6667>] kmem_zone_alloc+0x67/0xc0
>   [<ffffffff813e5945>] xfs_trans_add_item+0x25/0x50
>   [<ffffffff8143d64c>] xfs_trans_ijoin+0x2c/0x60
>   [<ffffffff8142275e>] xfs_itruncate_extents+0xbe/0x400
>   [<ffffffff813c72f4>] xfs_free_eofblocks+0x1c4/0x240
> 
> So set PF_FSTRANS to avoid this causing a deadlock.

Another "You broke KM_NOFS" moment. You win a Kit Kat. ;)

xfs_trans_add_item():

	lidp = kmem_zone_zalloc(xfs_log_item_desc_zone, KM_SLEEP | KM_NOFS);

KM_NOFS needs to work, otherwise XFS is just a huge steaming pile of
memory reclaim deadlocks regardless of whether you are using
loopback NFS or not.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
