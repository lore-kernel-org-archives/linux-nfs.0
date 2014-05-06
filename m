Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754524AbaEFVFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 17:05:25 -0400
Message-ID: <53694E7D.6060706@redhat.com>
Date: Tue, 06 May 2014 17:05:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, Jan Kara <jack@suse.cz>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
References: <20140423022441.4725.89693.stgit@notabene.brown> <20140423024058.4725.38098.stgit@notabene.brown>
In-Reply-To: <20140423024058.4725.38098.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/22/2014 10:40 PM, NeilBrown wrote:
> PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> and live-locks while writing to the page cache in a loop-back
> NFS mount situation.
> 
> It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> situation.
> We now know when a request came from the local-host so it could be a
> loop-back mount.  We already know when we are handling write requests,
> and when we are doing anything else.
> 
> So combine those two to allow nfsd to still be throttled (like any
> other process) in every situation except when it is known to be
> problematic.

The FUSE code has something similar, but on the "client"
side.

See BDI_CAP_STRICTLIMIT in mm/writeback.c

Would it make sense to use that flag on loopback-mounted
NFS filesystems?

-- 
All rights reversed
