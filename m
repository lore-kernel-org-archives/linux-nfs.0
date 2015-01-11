Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34380 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbAKSd6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 13:33:58 -0500
Date: Sun, 11 Jan 2015 13:33:54 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
 default_backing_dev_info
Message-ID: <20150111183354.GP25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-12-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-12-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 06:45:32PM +0100, Christoph Hellwig wrote:
> If we have dirty inodes we need to call the filesystem for it, even if the
> device has been removed and the filesystem will error out early.  The
> current code does that by reassining all dirty inodes to the default
> backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> that the bdi must always outlive the super block.

It's also shifting writeback shutdown to destroy time from
unregistration time.  This is part of fixing the bdi lifetime issue,
right?  It hink It'd be worthwhile to mention that in the commit
message.

Other than that,

 Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
