Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35802 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbcGUIJN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 04:09:13 -0400
Date: Thu, 21 Jul 2016 10:09:10 +0200
From: Christoph Hellwig <hch@lst.de>
To: Artem Savkov <asavkov@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@lst.de
Subject: Re: [PATCH v2] Fix NULL pointer dereference in bl_free_device().
Message-ID: <20160721080910.GA20363@lst.de>
References: <f195fe6f-8e2c-b200-2b00-9cd84f29bfc5@Netapp.com> <1468942744-10646-1-git-send-email-asavkov@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1468942744-10646-1-git-send-email-asavkov@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 19, 2016 at 05:39:04PM +0200, Artem Savkov wrote:
> When bl_parse_deviceid() fails in bl_alloc_deviceid_node() on
> blkdev_get_by_*() step we get an pnfs_block_dev struct that is
> uninitialized except for bdev field which is set to whatever error
> blkdev_get_by_*() returns.  bl_free_device() then tries to call
> blkdev_put() if bdev is not 0 resulting in a wrong pointer dereference.
> 
> Fixing this by making sure bdev is not an error code in bl_free_device().
> 
> Signed-off-by: Artem Savkov <asavkov@redhat.com>

I guess this is fine to be defensive, but we should probably just ensure
->bdev is NULLed on failure.
