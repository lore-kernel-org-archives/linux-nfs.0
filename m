Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36616 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbaLQIYn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2014 03:24:43 -0500
Date: Wed, 17 Dec 2014 00:24:37 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Omar Sandoval <osandov@osandov.com>, Jan Kara <jack@suse.cz>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217082437.GA9301@infradead.org>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
 <20141217082020.GH22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141217082020.GH22149@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2014 at 08:20:21AM +0000, Al Viro wrote:
> Where the hell would those other references come from?  We open the damn
> thing in sys_swapon(), never put it into descriptor tables, etc. and
> the only reason why we use filp_close() instead of fput() is that we
> would miss ->flush() otherwise.
> 
> Said that, why not simply *open* it with O_DIRECT to start with and be done
> with that?  It's not as if those guys came preopened by caller - swapon(2)
> gets a pathname and does opening itself.

Oops, should have dug deeper into the code.  For some reason I assumed
the fd is passed in from userspace.

The suggestion from Al is much better, given that we never do normal
I/O on the swapfile, just the bmap + direct bio submission which I hope
could go away in favor of the direct I/O variant in the long run.
