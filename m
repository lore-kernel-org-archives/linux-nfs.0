Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58490 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbaHXPyy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 11:54:54 -0400
Date: Sun, 24 Aug 2014 08:54:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        bfields@fieldses.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] locks: plumb an "aux" pointer into the setlease
 routines
Message-ID: <20140824155454.GE15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-7-git-send-email-jlayton@primarydata.com>
 <20140824013305.GB21609@infradead.org>
 <20140824060801.5402880c@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140824060801.5402880c@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 24, 2014 at 06:08:01AM -0400, Jeff Layton wrote:
> > Can you just return -EEXIST if reusing an existing one and make it a
> > normal private pointer a we use elsewhere?
> > 
> 
> That sounds a little confusing...
> 
> We have two pointers we pass down to generic_setlease: the file_lock
> itself and with this patch, the "aux" pointer. We can end up using
> either, neither or both during a call to generic_setlease.
> 
> A simple error code can't properly indicate which of the two pointers
> got used. It might be clearer to turn the file_lock into a normal
> pointer and return -EEXIST if we reused it, but leave aux as a double
> pointer.

There is no way we could use a new file_lock but an existing
fasync_struct, as there won't be one on the newly allocated file_lock
structure, but otherwise you're right.

Just rename it to priv then and make me a little less grumpy ;-)

