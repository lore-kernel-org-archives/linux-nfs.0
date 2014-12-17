Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:50138 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbaLQIUa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2014 03:20:30 -0500
Date: Wed, 17 Dec 2014 08:20:21 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: Omar Sandoval <osandov@osandov.com>, Jan Kara <jack@suse.cz>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217082020.GH22149@ZenIV.linux.org.uk>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141217080610.GA20335@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2014 at 12:06:10AM -0800, Christoph Hellwig wrote:

> > This seems to be more or less equivalent to doing a fcntl(F_SETFL) to
> > add the O_DIRECT flag to swap_file (which is a struct file *). Swapoff
> > calls filp_close on swap_file, so I don't see why it's necessary to
> > clear the flag.
> 
> filp_lose doesn't nessecarily destroy the file structure, there might be
> other reference to it, e.g. from dup() or descriptor passing.

Where the hell would those other references come from?  We open the damn
thing in sys_swapon(), never put it into descriptor tables, etc. and
the only reason why we use filp_close() instead of fput() is that we
would miss ->flush() otherwise.

Said that, why not simply *open* it with O_DIRECT to start with and be done
with that?  It's not as if those guys came preopened by caller - swapon(2)
gets a pathname and does opening itself.
