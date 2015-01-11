Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:37907 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbbAKRYa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 12:24:30 -0500
Date: Sun, 11 Jan 2015 12:24:26 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 03/12] fs: introduce f_op->mmap_capabilities for nommu
 mmap support
Message-ID: <20150111172426.GJ25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-4-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-4-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 06:45:24PM +0100, Christoph Hellwig wrote:
> Since "BDI: Provide backing device capability information [try #3]" the
> backing_dev_info structure also provides flags for the kind of mmap
> operation available in a nommu environment, which is entirely unrelated
> to it's original purpose.
> 
> Introduce a new nommu-only file operation to provide this information to
> the nommu mmap code instead.  Splitting this from the backing_dev_info
> structure allows to remove lots of backing_dev_info instance that aren't
> otherwise needed, and entirely gets rid of the concept of providing a
> backing_dev_info for a character device.  It also removes the need for
> the mtd_inodefs filesystem.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

FWIW,

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
