From: Neil Brown <neilb@suse.de>
Subject: Re: Problems with mmap consistency
Date: Mon, 27 Feb 2006 09:33:42 +1100
Message-ID: <17410.11462.303435.46479@cse.unsw.edu.au>
References: <20060217105756.GE25707@suse.de>
	<1140189330.3612.3.camel@lade.trondhjem.org>
	<20060224040142.GW5866@g5.random>
	<17406.42109.177974.703541@cse.unsw.edu.au>
	<20060224160828.GB5866@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FDUTI-0005Aq-MR
	for nfs@lists.sourceforge.net; Sun, 26 Feb 2006 14:34:32 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FDUTI-0007rf-6m
	for nfs@lists.sourceforge.net; Sun, 26 Feb 2006 14:34:32 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: message from Andrea Arcangeli on Friday February 24
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday February 24, andrea@suse.de wrote:
> on fri, feb 24, 2006 at 05:15:25pm +1100, neil brown wrote:
> > i'm not sure exactly what you mean by 'non destructive'.
> 
> Non destructive means you can call it anytime on anything and you're
> always safe. that basically means not destroying dirty bits (everything
> else can always be discarded in a loss-less way, only discarding dirty
> bits is a destructive operation).

Ok, thanks...

> > the later, by itself, is dangerous i think.  as a page can be partly
> > dirty and partly not (for 'write' requests, nfs knows which parts are
> > dirty.  for mmap, it has to assume that it is all dirty), the part that
> > is not dirty really needs to be invalidated somehow.
> 
> That's why we have to call fdatasyncandwait before
> invalidate_inode_pages2. that's what is taking care to flush them before
> invalidating them. furthermore the lowlevel nfs caches are being taken
> care of by the above check in try_to_release_page.

But I don't think this is enough.  You see, nfs really wants
invalidate_inode_pages2 to actually invalidate all pages.

Suppose I take a read lock (With fcntl) on the second half of a page.
nfs will flush out any pending writes, and flag the inode as having an
invalid page cache.  A little later (I'm not 100% sure when, but
before a read completes), nfs_revalidate_mapping will be called which
will again flush out any pending writes (with nfs_sync_mapping) and
then call invalidate_inode_pages2.

Now suppose that in that little gap between nfs_sync_mapping finishing
and invalidate_inode_page2 starting, some other process writes to the
first half of the page and marks the page dirty.
Now the page doesn't get invalidated by invalidate_inode_page2 and a
subsequent read on the locked region could get old data.

This is why I think that nfs's ->releasepage (or similar) needs to
flag the page as not being uptodate if it fails to disconnect it from
the pagecache.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
