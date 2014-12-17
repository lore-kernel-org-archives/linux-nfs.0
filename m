Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:52762 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaLQWDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2014 17:03:20 -0500
Date: Wed, 17 Dec 2014 22:03:13 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: Omar Sandoval <osandov@osandov.com>, Jan Kara <jack@suse.cz>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217220313.GK22149@ZenIV.linux.org.uk>
References: <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
 <20141217082020.GH22149@ZenIV.linux.org.uk>
 <20141217082437.GA9301@infradead.org>
 <20141217145832.GA3497@mew>
 <20141217185256.GA5657@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141217185256.GA5657@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2014 at 10:52:56AM -0800, Christoph Hellwig wrote:
> On Wed, Dec 17, 2014 at 06:58:32AM -0800, Omar Sandoval wrote:
> > See my previous message. If we use O_DIRECT on the original open, then
> > filesystems that implement bmap but not direct_IO will no longer work.
> > These are the ones that I found in my tree:
> 
> In the long run I don't think they are worth keeping.  But to keep you
> out of that discussion you can just try an open without O_DIRECT if the
> open with the flag failed.

Umm...  That's one possibility, of course (and if swapon(2) is on someone's
hotpath, I really would like to see what the hell they are doing - it has
to be interesting in a sick way).

Said that, there's an interesting problem with O_DIRECT.  It's irrelevant
in this case, but it *can* be changed halfway through e.g write(2) and
AFAICS we have at least some suspicious codepaths.  Look at
ext4_file_write_iter(), for example.  We check O_DIRECT, then grab some
locks, then proceed to look at the results of that check, do some work...
and call __generic_file_write_iter(), which checks O_DIRECT again.  If
it has been cleared (or, probably worse, set) it looks like we'll get
an interesting bunch of holes.

Should we just labda-expand that call of __generic_file_write_iter() and
replace its 
        if (unlikely(file->f_flags & O_DIRECT)) {
with
	if (odirect)
to be guaranteed that it'll match the things we'd done before the call?

I'm looking through the callchains right now in search of similar places
right now, will follow up when I'm done...

BTW, speaking of read/write vs. swap - what's the story with e.g. AFS
write() checking IS_SWAPFILE() and failing with -EBUSY?  Note that
	* it's done before acquiring i_mutex, so it isn't race-free
	* it's dubious from the POSIX POV - EBUSY isn't in the error
list for write(2).
	* other filesystems generally don't have anything of that sort.
NFS does, but local ones do not...
Besides, do we even allow swapfiles on AFS?
