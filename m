Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:55425 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbbAKRFu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 12:05:50 -0500
Date: Sun, 11 Jan 2015 12:05:46 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 02/12] fs: kill BDI_CAP_SWAP_BACKED
Message-ID: <20150111170546.GI25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-3-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 06:45:23PM +0100, Christoph Hellwig wrote:
> This bdi flag isn't too useful - we can determine that a vma is backed by
> either swap or shmem trivially in the caller.
> 
> This also allows removing the backing_dev_info instaces for swap and shmem
> in favor of noop_backing_dev_info.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
