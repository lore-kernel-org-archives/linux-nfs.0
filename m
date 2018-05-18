Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:60286 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbeERRD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 May 2018 13:03:28 -0400
Date: Fri, 18 May 2018 19:08:12 +0200
From: Christoph Hellwig <hch@lst.de>
To: Mel Gorman <mgorman@suse.de>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org
Subject: do we still need ->is_dirty_writeback
Message-ID: <20180518170812.GA5190@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Mel,

you added the is_dirty_writeback callback a couple years ago mostly
to work around the crazy ext3 writeback code, which is long gone now.
We still use buffer_check_dirty_writeback on the block device, but
without that ext3 case we really should not need it anymore.

That leaves NFS, where I don't understand why it doesn't simply
use PageWrite?
