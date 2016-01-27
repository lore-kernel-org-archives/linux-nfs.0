Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:31919 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750826AbcA0AJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 19:09:24 -0500
Date: Wed, 27 Jan 2016 11:04:04 +1100
From: Dave Chinner <david@fromorbit.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Remote access to pmem on storage targets
Message-ID: <20160127000404.GN6033@dastard>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
 <20160126082533.GR24938@quack.suse.cz>
 <F0E2108B-891C-4570-B486-7DC7C4FB59C4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F0E2108B-891C-4570-B486-7DC7C4FB59C4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 26, 2016 at 10:58:44AM -0500, Chuck Lever wrote:
> It is not going to be like the well-worn paradigm that
> involves a page cache on the storage target backed by
> slow I/O operations. The protocol layers on storage
> targets need a way to discover memory addresses of
> persistent memory that will be used as source/sink
> buffers for RDMA operations.
> 
> And making data durable after a write is going to need
> some thought. So I believe some new plumbing will be
> necessary.

Haven't we already solve this for the pNFS file driver that XFS
implements? i.e. these export operations:

        int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
        int (*map_blocks)(struct inode *inode, loff_t offset,
                          u64 len, struct iomap *iomap,
                          bool write, u32 *device_generation);
        int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
                             int nr_iomaps, struct iattr *iattr);

so mapping/allocation of file offset to sector mappings, which can
then trivially be used to grab the memory address through the bdev
->direct_access method, yes?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
