Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([143.182.124.21]:62513 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab1KTB56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Nov 2011 20:57:58 -0500
Date: Sun, 20 Nov 2011 09:57:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Feng Tang <feng.tang@intel.com>
Subject: Re: [PATCH] nfs: writeback pages wait queue
Message-ID: <20111120015755.GA7161@localhost>
References: <20111119125253.GA5483@localhost>
 <20111119134412.GA5853@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111119134412.GA5853@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jim,

On Sat, Nov 19, 2011 at 09:44:12PM +0800, Jim Rees wrote:
> Wu Fengguang wrote:
> 
>   The generic writeback routines are departing from congestion_wait()
>   in preference of get_request_wait(), aka. waiting on the block queues.
>   
>   Introduce the missing writeback wait queue for NFS, otherwise its
>   writeback pages will grow greedily, exhausting all PG_dirty pages.
>   
>   Tests show that it can effectively reduce stalls in the disk-network
>   pipeline, improve performance and reduce delays.
> 
> This is great stuff.  Did you do any tests on long delay paths?  I did some
> work on this a few years ago and made some progress but not enough.

Good question! I didn't test fat pipelines, which sure asks for reasonably high
nfs_congestion_kb to work well.

However we have good chances.

The nfs_congestion_kb is computed at module loading time in
nfs_init_writepagecache():

        /*
         * NFS congestion size, scale with available memory.
         *
         *  64MB:    8192k
         * 128MB:   11585k
         * 256MB:   16384k
         * 512MB:   23170k
         *   1GB:   32768k
         *   2GB:   46340k
         *   4GB:   65536k
         *   8GB:   92681k
         *  16GB:  131072k
         *
         * This allows larger machines to have larger/more transfers.
         * Limit the default to 256M
         */

For a typical mem=4GB client, nfs_congestion_kb=64MB, which is enough
to fill a 100ms*100MB/s=10MB network pipeline.

There may be more demanding ones, however that's rare case and its
user should be fully aware of the specialness and the need to do some
hand tuning, for example:

        echo $(300<<10) > /proc/sys/fs/nfs/nfs_congestion_kb

Thanks,
Fengguang
