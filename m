From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with mmap consistency
Date: Sat, 25 Feb 2006 09:55:01 -0500
Message-ID: <1140879301.3615.137.camel@lade.trondhjem.org>
References: <20060217105756.GE25707@suse.de>
	 <1140189330.3612.3.camel@lade.trondhjem.org>
	 <20060224040142.GW5866@g5.random>
	 <17406.42109.177974.703541@cse.unsw.edu.au>
	 <20060224160828.GB5866@g5.random> <20060224153931.746cc19f.akpm@osdl.org>
	 <20060225003343.GA6592@g5.random>
	 <1140829162.3615.117.camel@lade.trondhjem.org>
	 <20060224171752.546dbe0d.akpm@osdl.org>  <20060225045940.GB6592@g5.random>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@osdl.org>, neilb@suse.de, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FD0pP-00008S-B6
	for nfs@lists.sourceforge.net; Sat, 25 Feb 2006 06:55:23 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FD0pN-0004Yt-5H
	for nfs@lists.sourceforge.net; Sat, 25 Feb 2006 06:55:23 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20060225045940.GB6592@g5.random>
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

On Sat, 2006-02-25 at 05:59 +0100, Andrea Arcangeli wrote:
> > eh?  I don't know what's being talked about here, but that doesn't sound
> > right.  Taking the block-backed protocol as an example, if a page isn't
> > dirty it shouldn't be written out.  What _is_ legal is a page which is
> > dirty but doesn't need writing out.  You've gone and invented the converse,
> > illegal case here.
> 
> Agreed, this is what I was trying to say too in the previous emails in
> answer to Neil (and it was confirmed by your last email too). It doesn't
> sound sane that a page has dirty-lowlevel data but PG_dirty is not set.
> try_to_release_page isn't ->writepage and if PG_dirty isn't set it would
> be hiding those pages to pdflush (pdflush wouldn't see the dirty bit and
> it wouldn't writeback periodically).

If we don't clear PG_dirty in writepage(), then the VM gets all huffy.
However, we do not want to start actual writeback until we've got enough
pages to make it worth our while. For that reason, we track the dirty
pages in the NFS layer, and start writeout when writepages() is done.

How does this differ from a page that has buffers but is "clean"?

Cheers
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
