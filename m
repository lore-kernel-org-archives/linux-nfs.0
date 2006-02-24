From: Olaf Kirch <okir@suse.de>
Subject: Re: Problems with mmap consistency
Date: Fri, 24 Feb 2006 08:12:27 +0100
Message-ID: <20060224071227.GA24087@suse.de>
References: <20060217105756.GE25707@suse.de> <1140189330.3612.3.camel@lade.trondhjem.org> <20060224040142.GW5866@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCX7x-0003T7-J8
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 23:12:33 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCX7w-0006IC-2u
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 23:12:33 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20060224040142.GW5866@g5.random>
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

On Fri, Feb 24, 2006 at 05:01:42AM +0100, Andrea Arcangeli wrote:
> > We need to add a VM helper that will invalidate the page cache and flush
> > dirty pages atomically (such a thing does not yet exist).
> 
> Such thing will hardly exist if page faults can mark pages dirty at any
> time mostly lockless. Things may change for the better if we start
> taking the page lock in do_no_page but I doubt we'll serialize
> atomically against the whole disk-bound fdatawriteandwait.

One thing I've been thinking about, which would be rather heavy-handed
though, would be to have an rwsem in the mapping; do_no_page would take
a readlock, while nfs would take the write lock when invalidating.
Bu that's really ugly because we'd add this lock for NFS only.

> I think it's enough to make invalidate_inode_pages2 non destructive.

That would be worth trying. I'll give your patch a try.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
