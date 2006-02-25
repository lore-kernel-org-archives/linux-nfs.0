From: Andrew Morton <akpm@osdl.org>
Subject: Re: Problems with mmap consistency
Date: Fri, 24 Feb 2006 17:17:52 -0800
Message-ID: <20060224171752.546dbe0d.akpm@osdl.org>
References: <20060217105756.GE25707@suse.de>
	<1140189330.3612.3.camel@lade.trondhjem.org>
	<20060224040142.GW5866@g5.random>
	<17406.42109.177974.703541@cse.unsw.edu.au>
	<20060224160828.GB5866@g5.random>
	<20060224153931.746cc19f.akpm@osdl.org>
	<20060225003343.GA6592@g5.random>
	<1140829162.3615.117.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: andrea@suse.de, neilb@suse.de, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCo2I-0003hy-EV
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 17:15:50 -0800
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FCo2H-0006VW-4S
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 17:15:50 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140829162.3615.117.camel@lade.trondhjem.org>
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

Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Sat, 2006-02-25 at 01:33 +0100, Andrea Arcangeli wrote:
> 
> > I got positive confirmation that my patch that makes
> > invalidate_inode_pages2 non-destructive fixed the problem. At the top of
> > this thread you can find the testcase used to reproduce the race posted
> > by Olaf. I'm unsure if Neil's patch is needed, but it certainly could
> > co-exist. I feel his patch should not execute a writepage inside
> > try_to_release_page, it's not needed anymore with my fix in place.
> 
> Yes it still is needed. The page doesn't need to have the dirty bit set
> in order to actually need writing out (sort of the equivalent of having
> buffers in the blocks case).

eh?  I don't know what's being talked about here, but that doesn't sound
right.  Taking the block-backed protocol as an example, if a page isn't
dirty it shouldn't be written out.  What _is_ legal is a page which is
dirty but doesn't need writing out.  You've gone and invented the converse,
illegal case here.

> My patch just ensures that try_to_release_page() actually flushes those
> buffers and waits for completion.

<what patch?>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
