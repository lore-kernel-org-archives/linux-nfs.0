From: Neil Brown <neilb@suse.de>
Subject: Re: Problems with mmap consistency
Date: Mon, 27 Feb 2006 11:26:21 +1100
Message-ID: <17410.18221.435882.829625@cse.unsw.edu.au>
References: <1140189330.3612.3.camel@lade.trondhjem.org>
	<20060224040142.GW5866@g5.random>
	<17406.42109.177974.703541@cse.unsw.edu.au>
	<20060224160828.GB5866@g5.random>
	<20060224153931.746cc19f.akpm@osdl.org>
	<20060225003343.GA6592@g5.random>
	<1140829162.3615.117.camel@lade.trondhjem.org>
	<20060224171752.546dbe0d.akpm@osdl.org>
	<20060225045940.GB6592@g5.random>
	<1140879301.3615.137.camel@lade.trondhjem.org>
	<20060225172737.GB5410@g5.random>
	<1140892927.7877.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>,
	okir@suse.de, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FDWEO-00008V-Um
	for nfs@lists.sourceforge.net; Sun, 26 Feb 2006 16:27:16 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FDWEO-0006ob-4n
	for nfs@lists.sourceforge.net; Sun, 26 Feb 2006 16:27:16 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Saturday February 25
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

On Saturday February 25, trond.myklebust@fys.uio.no wrote:
> On Sat, 2006-02-25 at 18:27 +0100, Andrea Arcangeli wrote:
> > On Sat, Feb 25, 2006 at 09:55:01AM -0500, Trond Myklebust wrote:
> > > If we don't clear PG_dirty in writepage(), then the VM gets all huffy.
> > > However, we do not want to start actual writeback until we've got enough
> > > pages to make it worth our while. For that reason, we track the dirty
> > > pages in the NFS layer, and start writeout when writepages() is done.
> > 
> > Isn't ->writepages API enough to coalesce writes together? Why do you
> > assume you will get more data to write by waiting more time? pagecache
> > layer already waits long enough before calling ->writepages.
> > 
> > I'm unsure if you really gain anything. If you weren't using
> > ->writepages already then your local hack would look more worthwhile to
> > me.
> 
> We don't wait beyond writepages(). However writepages doesn't protect
> you against concurrent truncate calls: the vm seems to assume that the
> page lock will. Since our flush mechanism  cannot lock the pages (we
> need to be able to call it in contexts like "read" where the page is
> already locked) we have a potential race.

Forgive me if I am way off-base here, but I've just been reading the
vm code and discovered AOP_TRUNCATED_PAGE.

->readpage is allowed to unlock the page and return
AOP_TRUNCATED_PAGE.
In this case the vm will retry the read, including looking up the page
cage and relocking it.

So presumably if nfs_readpage find that it needs to flush it could
unlock the page, do the flush, and return AOP_TRUNCATED_PAGE.  This
would allow the flush mechanism to lock the page.

Any sense in that?

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
