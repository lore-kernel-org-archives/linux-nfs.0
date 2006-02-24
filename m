From: Andrew Morton <akpm@osdl.org>
Subject: Re: Problems with mmap consistency
Date: Fri, 24 Feb 2006 15:39:31 -0800
Message-ID: <20060224153931.746cc19f.akpm@osdl.org>
References: <20060217105756.GE25707@suse.de>
	<1140189330.3612.3.camel@lade.trondhjem.org>
	<20060224040142.GW5866@g5.random>
	<17406.42109.177974.703541@cse.unsw.edu.au>
	<20060224160828.GB5866@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, trond.myklebust@fys.uio.no, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCmV5-000200-6B
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 15:37:27 -0800
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FCmV4-0005sA-UV
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 15:37:27 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20060224160828.GB5866@g5.random>
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

Andrea Arcangeli <andrea@suse.de> wrote:
>
> While reading the default releasepage callback I was also shoked by this:
> 
> 	spin_lock(&mapping->private_lock);
> 	ret = drop_buffers(page, &buffers_to_free);
> 	if (ret) {
> 		/*
> 		 * If the filesystem writes its buffers by hand (eg
> 		 * ext3)
> 		 * then we can have clean buffers against a dirty page.
> 		 * We
> 		 * clean the page here; otherwise later reattachment of
> 		 * buffers
> 		 * could encounter a non-uptodate page, which is
> 		 * unresolvable.
> 		 * This only applies in the rare case where
> 		 * try_to_free_buffers
> 		 * succeeds but the page is not freed.
> 		 */
> 		clear_page_dirty(page);
> 		^^^^^^^^^^^^^^^^
> 	}
> 
> I can't possibly see how the above is safe.

The protocol is: a clean page with dirty buffers is illegal.  A dirty page
with clean buffers is legal (filesystem cleaned the bh's independently).

This is enforced by:

- If an address_space uses buffer_heads, it must use
  a_ops.set_page_dirty=__set_page_dirty_buffers.  And
  __set_page_dirty_buffers() will dirty the buffer_heads when someone runs
  set_page_dirty().

- try_to_free_buffers() is hence allowed to assume that clean buffers
  means a fully written-back page, hence try_to_free_buffers() is allowed
  to clear the page's dirty bit.

  Arguably the fs should be doing this, but the core "knows" about
  filesystems which write the buffers directly.

  Synchronisation for the page-vs-buffer dirty state is via
  mapping->private_lock.  try_to_free_buffers() versus
  __set_page_dirty_buffers().


I _think_ it's all solid?  It's pretty old code now..

We used to have zillions of assertions in there to check that this was all
functioning correctly.  I took them out a year or two ago.

I guess we really should retain a check for clean page with dirty
buffers.  That's a memory leak and potentially a data loss.

> The above even collided with
> the previous was_dirty logic.

What's the "was_dirty logic"?

> What was the point of was_dirty logic
> (besides the fact we don't need to be destructive in the first place),
> when try_to_release_page can clear the dirty bit? I really can't see how
> the fact we managed to release the bh because they were not busy, has
> anything to do with the page being clean (like after a munmap). I think
> the above is a lonstanding fs corruption bug and the above
> clear_page_dirty should be nuked, but perhaps I'm overlooking
> something.... The above path is quite related to our code for the nfs
> matter since it's invoked here:
> 
> 	if (PagePrivate(page) && !try_to_release_page(page, 0))
> 		return 0;
> 
> 	write_lock_irq(&mapping->tree_lock);
> 	if (PageDirty(page)) {

try_to_free_buffers() doesn't check - it assume that there's a valid bh* at
page_private().  It will oops if called with a page which doesn't have
buffers, so NFS cannot get in here at all.



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
