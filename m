From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with mmap consistency
Date: Sat, 25 Feb 2006 13:42:07 -0500
Message-ID: <1140892927.7877.24.camel@lade.trondhjem.org>
References: <1140189330.3612.3.camel@lade.trondhjem.org>
	 <20060224040142.GW5866@g5.random>
	 <17406.42109.177974.703541@cse.unsw.edu.au>
	 <20060224160828.GB5866@g5.random> <20060224153931.746cc19f.akpm@osdl.org>
	 <20060225003343.GA6592@g5.random>
	 <1140829162.3615.117.camel@lade.trondhjem.org>
	 <20060224171752.546dbe0d.akpm@osdl.org> <20060225045940.GB6592@g5.random>
	 <1140879301.3615.137.camel@lade.trondhjem.org>
	 <20060225172737.GB5410@g5.random>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@osdl.org>, neilb@suse.de, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FD4ND-0005rV-1j
	for nfs@lists.sourceforge.net; Sat, 25 Feb 2006 10:42:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FD4NA-0002EM-1n
	for nfs@lists.sourceforge.net; Sat, 25 Feb 2006 10:42:31 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20060225172737.GB5410@g5.random>
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

On Sat, 2006-02-25 at 18:27 +0100, Andrea Arcangeli wrote:
> On Sat, Feb 25, 2006 at 09:55:01AM -0500, Trond Myklebust wrote:
> > If we don't clear PG_dirty in writepage(), then the VM gets all huffy.
> > However, we do not want to start actual writeback until we've got enough
> > pages to make it worth our while. For that reason, we track the dirty
> > pages in the NFS layer, and start writeout when writepages() is done.
> 
> Isn't ->writepages API enough to coalesce writes together? Why do you
> assume you will get more data to write by waiting more time? pagecache
> layer already waits long enough before calling ->writepages.
> 
> I'm unsure if you really gain anything. If you weren't using
> ->writepages already then your local hack would look more worthwhile to
> me.

We don't wait beyond writepages(). However writepages doesn't protect
you against concurrent truncate calls: the vm seems to assume that the
page lock will. Since our flush mechanism  cannot lock the pages (we
need to be able to call it in contexts like "read" where the page is
already locked) we have a potential race.

> > How does this differ from a page that has buffers but is "clean"?
> 
> That those clean buffers can be discarded without data loss?
> 
> Andrew stated the invariant: "a clean page with dirty buffers is
> illegal.".
> 
> Now with this last flush on try_to_release_page perhaps you can get away
> with it, but your problem was going way beyond the VM race.
> 
> My fix fixed the VM race only (note that the same race would happen on
> ext2 too if you called randomly invalidate_inode_pages2 on any inode,
> which btw, surprise is what the new ioctl FIPUNCHMEM does... So let's
> say my fix is for FIPUNCHMEM and nfs on VM side.
> 
> Your patch fixes an entirely different matter, that is, it tries to
> close the holes that you opened by breaking the invariant that a page
> can be dirty still but with PG_dirty not set.
> 
> So again, those two patches are orthogonal. In the current state of
> things both looks to me, though I would like to understand if you really
> get a benefit from the local nfs hack around the pagecache invariants.

In 99% of cases we cannot, and will not use the page cache dirtying
mechanisms since those mechanisms discard all trace of the user context
in which the page was dirtied. In consequence, writepage() simply does
not allow us to track all the context data that we need in order to be
able to safely write out data (i.e. user credentials, file state
context, ...).

The only case where we allow ourselves to rely on writepage() is for
mmapped files, where the whole concept of "user context" is all pretty
blurry anyway.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
