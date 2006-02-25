From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Problems with mmap consistency
Date: Sat, 25 Feb 2006 01:33:43 +0100
Message-ID: <20060225003343.GA6592@g5.random>
References: <20060217105756.GE25707@suse.de> <1140189330.3612.3.camel@lade.trondhjem.org> <20060224040142.GW5866@g5.random> <17406.42109.177974.703541@cse.unsw.edu.au> <20060224160828.GB5866@g5.random> <20060224153931.746cc19f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, trond.myklebust@fys.uio.no, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCnNs-0007aM-Hy
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 16:34:04 -0800
Received: from 217-133-42-200.b2b.tiscali.it ([217.133.42.200] helo=g5.random)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCnNq-0007gp-1S
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 16:34:04 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060224153931.746cc19f.akpm@osdl.org>
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

On Fri, Feb 24, 2006 at 03:39:31PM -0800, Andrew Morton wrote:
>   a_ops.set_page_dirty=__set_page_dirty_buffers.  And
>   __set_page_dirty_buffers() will dirty the buffer_heads when someone runs

Ok this is what I temporarily forgot. set_page_dirty doesn't only tags
the tree etc.. it also calls into the lowlevel through
a_ops.set_page_dirty.

> I _think_ it's all solid?  It's pretty old code now..

yep sorry.

> > The above even collided with
> > the previous was_dirty logic.
> 
> What's the "was_dirty logic"?

this:

-                       was_dirty = test_clear_page_dirty(page);
-                       if (!invalidate_complete_page(mapping, page)) {
-                               if (was_dirty)
-                                       set_page_dirty(page);
+
+                       if (!invalidate_complete_page(mapping, page))
                                ret = -EIO;
-                       }


but everything is ok, there was no collision since it is right calling
clear_page_dirty.

> > (besides the fact we don't need to be destructive in the first place),
> > when try_to_release_page can clear the dirty bit? I really can't see how
> > the fact we managed to release the bh because they were not busy, has
> > anything to do with the page being clean (like after a munmap). I think
> > the above is a lonstanding fs corruption bug and the above
> > clear_page_dirty should be nuked, but perhaps I'm overlooking
> > something.... The above path is quite related to our code for the nfs
> > matter since it's invoked here:
> > 
> > 	if (PagePrivate(page) && !try_to_release_page(page, 0))
> > 		return 0;
> > 
> > 	write_lock_irq(&mapping->tree_lock);
> > 	if (PageDirty(page)) {
> 
> try_to_free_buffers() doesn't check - it assume that there's a valid bh* at
> page_private().  It will oops if called with a page which doesn't have
> buffers, so NFS cannot get in here at all.

Yes, I meant our code in the sense on the stuff my patch modified.

I got positive confirmation that my patch that makes
invalidate_inode_pages2 non-destructive fixed the problem. At the top of
this thread you can find the testcase used to reproduce the race posted
by Olaf. I'm unsure if Neil's patch is needed, but it certainly could
co-exist. I feel his patch should not execute a writepage inside
try_to_release_page, it's not needed anymore with my fix in place.

Thanks for the enlightenment!


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
