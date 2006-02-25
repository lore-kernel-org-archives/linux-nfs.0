From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with mmap consistency
Date: Fri, 24 Feb 2006 19:59:22 -0500
Message-ID: <1140829162.3615.117.camel@lade.trondhjem.org>
References: <20060217105756.GE25707@suse.de>
	 <1140189330.3612.3.camel@lade.trondhjem.org>
	 <20060224040142.GW5866@g5.random>
	 <17406.42109.177974.703541@cse.unsw.edu.au>
	 <20060224160828.GB5866@g5.random> <20060224153931.746cc19f.akpm@osdl.org>
	 <20060225003343.GA6592@g5.random>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@osdl.org>, neilb@suse.de, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCnmi-0001hq-Tc
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 16:59:44 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCnmh-0000Ys-JZ
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 16:59:45 -0800
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20060225003343.GA6592@g5.random>
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

On Sat, 2006-02-25 at 01:33 +0100, Andrea Arcangeli wrote:

> I got positive confirmation that my patch that makes
> invalidate_inode_pages2 non-destructive fixed the problem. At the top of
> this thread you can find the testcase used to reproduce the race posted
> by Olaf. I'm unsure if Neil's patch is needed, but it certainly could
> co-exist. I feel his patch should not execute a writepage inside
> try_to_release_page, it's not needed anymore with my fix in place.

Yes it still is needed. The page doesn't need to have the dirty bit set
in order to actually need writing out (sort of the equivalent of having
buffers in the blocks case).
My patch just ensures that try_to_release_page() actually flushes those
buffers and waits for completion.

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
