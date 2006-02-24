From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Problems with mmap consistency
Date: Fri, 24 Feb 2006 17:08:28 +0100
Message-ID: <20060224160828.GB5866@g5.random>
References: <20060217105756.GE25707@suse.de> <1140189330.3612.3.camel@lade.trondhjem.org> <20060224040142.GW5866@g5.random> <17406.42109.177974.703541@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCfUw-0001jJ-CJ
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 08:08:50 -0800
Received: from 217-133-42-200.b2b.tiscali.it ([217.133.42.200] helo=g5.random)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCfUs-0005br-6P
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 08:08:50 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17406.42109.177974.703541@cse.unsw.edu.au>
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

on fri, feb 24, 2006 at 05:15:25pm +1100, neil brown wrote:
> what is *needed* is that we invalidate any part of a page that isn't
> dirty.  dirty parts need to be left for write-back, but the non-dirty

I agree, this is exactly what my patch does. never destry the dirty
info.

> i'm not sure exactly what you mean by 'non destructive'.

Non destructive means you can call it anytime on anything and you're
always safe. that basically means not destroying dirty bits (everything
else can always be discarded in a loss-less way, only discarding dirty
bits is a destructive operation).

> do you mean that pages are not removed but are just marked 'invalid',
> or do you mean that if a page is dirty it doesn't get removed.

Clean pages are still freed hard (from pagecache to freelist), only
pages dirty are left in the cache i.e. the non-destructive behaviour
(while previously they would have been destroyed too, i.e. the
destructive behaviour).

> the later, by itself, is dangerous i think.  as a page can be partly
> dirty and partly not (for 'write' requests, nfs knows which parts are
> dirty.  for mmap, it has to assume that it is all dirty), the part that
> is not dirty really needs to be invalidated somehow.

That's why we have to call fdatasyncandwait before
invalidate_inode_pages2. that's what is taking care to flush them before
invalidating them. furthermore the lowlevel nfs caches are being taken
care of by the above check in try_to_release_page.

Note also that the dirty bit must be set on the pagecache too, when a
page is dirty and needs writeback. It's not enough to set the lowlevel
caches dirty or pdflush will never see them and periodically flush them.
The writeback layer of the pagecache has no clue on the lowlevel caches
of the pageprivate pages, so the dirty bits must be set in the pagecache
too when writeback data exists in the lowlevel and writepage has to be
called.

The highlevel only makes sure to call writepage on pages with dirty bit
(so then the lowlevel caches can be flushed) and then
try_to_release_page is guaranteed to be called before discarding a page
(just in case the page is busy when we try to free it: should never
happen with nfs unless the dirty bit is set too).

> a ->readpage already calls nfs_wb_page before starting a read, so if
> we define an invalidate_page callback (see patch below from trond,
> modified by me) which calls clearpageuptodate appropriately, we might
> get the desired result.  however i'm not entirely sure what the code should
> look like as i don't know exactly when a page is marked dirty and when
> marked clean as it flows through nfs....

I see what your patch does. It's quite equivalent to mine except I
solved the problem in a more VM generic way then a nfs lowlevel way.

Note also that I'm not convinced that try_to_release_page is really a
do_writeback call. Basically the way you workaround the problem without
changing the VM function is to flush the dirty lowlevel cache
inside try_to_release_page. But I suspect try_to_release_page should be
more a "try_to_release" then a "writepage_and_try_to_release". As long
as the dirty bit is always set, it's the VM that takes care of not
freeing the page and calling writepage on it again, you don't have to do
that before the page is destroyed to avoid corruption.

Still implementing the releaspage callback is a good idea, but I think
it would be enough to bugcheck against any data being dirty inside it
with PageDirty not set. As long as PageDirty is set, you don't have to
do anything in releasepage callback.

Overall I think my patch is obviously backwards compatible, and I would
like to see your patch modified with only bugchecks inside releasepage
and invalidate page (or whatever else action needed to free clean
buffers).

While reading the default releasepage callback I was also shoked by this:

	spin_lock(&mapping->private_lock);
	ret = drop_buffers(page, &buffers_to_free);
	if (ret) {
		/*
		 * If the filesystem writes its buffers by hand (eg
		 * ext3)
		 * then we can have clean buffers against a dirty page.
		 * We
		 * clean the page here; otherwise later reattachment of
		 * buffers
		 * could encounter a non-uptodate page, which is
		 * unresolvable.
		 * This only applies in the rare case where
		 * try_to_free_buffers
		 * succeeds but the page is not freed.
		 */
		clear_page_dirty(page);
		^^^^^^^^^^^^^^^^
	}

I can't possibly see how the above is safe. The above even collided with
the previous was_dirty logic. What was the point of was_dirty logic
(besides the fact we don't need to be destructive in the first place),
when try_to_release_page can clear the dirty bit? I really can't see how
the fact we managed to release the bh because they were not busy, has
anything to do with the page being clean (like after a munmap). I think
the above is a lonstanding fs corruption bug and the above
clear_page_dirty should be nuked, but perhaps I'm overlooking
something.... The above path is quite related to our code for the nfs
matter since it's invoked here:

	if (PagePrivate(page) && !try_to_release_page(page, 0))
		return 0;

	write_lock_irq(&mapping->tree_lock);
	if (PageDirty(page)) {

If the above bogus clear_page_dirty clears the dirty bitflag, what's the
point of checking PageDirty after returning from try_to_release_page?


I'm CC'ing Andrew since this stuff goes way beyond nfs and he knows this
better ;)

Here the relevant links including patches for Andrew:

http://sourceforge.net/mailarchive/message.php?msg_id=14906347
http://sourceforge.net/mailarchive/message.php?msg_id=14906867

PS. I'm offlist so please keep me in CC, thanks.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
