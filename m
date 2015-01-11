Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:51098 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbbAKSj2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 13:39:28 -0500
Date: Sun, 11 Jan 2015 13:39:24 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 12/12] fs: remove default_backing_dev_info
Message-ID: <20150111183924.GQ25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-13-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-13-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 06:45:33PM +0100, Christoph Hellwig wrote:
> Now that default_backing_dev_info is not used for writeback purposes we can
> git rid of it easily:
> 
>  - instead of using it's name for tracing unregistered bdi we just use
>    "unknown"
>  - btrfs and ceph can just assign the default read ahead window themselves
>    like several other filesystems already do.
>  - we can assign noop_backing_dev_info as the default one in alloc_super.
>    All filesystems already either assigned their own or
>    noop_backing_dev_info.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
