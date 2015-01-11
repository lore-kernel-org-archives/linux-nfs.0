Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:54313 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbbAKRlI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 12:41:08 -0500
Date: Sun, 11 Jan 2015 12:41:03 -0500
From: Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH 06/12] nilfs2: set up s_bdi like the generic mount_bdev
 code
Message-ID: <20150111174103.GM25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-7-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420739133-27514-7-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 06:45:27PM +0100, Christoph Hellwig wrote:
> mapping->backing_dev_info will go away, so don't rely on it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
