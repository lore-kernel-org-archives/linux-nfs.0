From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Problems with mmap consistency
Date: Tue, 28 Feb 2006 02:04:46 +0100
Message-ID: <20060228010446.GI5410@g5.random>
References: <17406.42109.177974.703541@cse.unsw.edu.au> <20060224160828.GB5866@g5.random> <20060224153931.746cc19f.akpm@osdl.org> <20060225003343.GA6592@g5.random> <1140829162.3615.117.camel@lade.trondhjem.org> <20060224171752.546dbe0d.akpm@osdl.org> <20060225045940.GB6592@g5.random> <1140879301.3615.137.camel@lade.trondhjem.org> <20060225172737.GB5410@g5.random> <1140892927.7877.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, neilb@suse.de, okir@suse.de,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FDtIR-0007se-Cp
	for nfs@lists.sourceforge.net; Mon, 27 Feb 2006 17:04:59 -0800
Received: from 217-133-42-200.b2b.tiscali.it ([217.133.42.200] helo=g5.random)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FDtIP-0007td-Lg
	for nfs@lists.sourceforge.net; Mon, 27 Feb 2006 17:04:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140892927.7877.24.camel@lade.trondhjem.org>
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

On Sat, Feb 25, 2006 at 01:42:07PM -0500, Trond Myklebust wrote:
> The only case where we allow ourselves to rely on writepage() is for
> mmapped files, where the whole concept of "user context" is all pretty
> blurry anyway.

Ok. I trust you on the nfs lowlevel part and I think Neil's comment on
this is interesting.

However I want to clarify a few things on those two patches. While you
currently don't relay on the dirty bitflag when it's clear, you
definitely relay on the dirty bitflag when it's set (because your
.set_page_dirty callback is set to __set_page_dirty_nobuffers).


I mean, you don't relay on the dirty bitflag after writepage has been
called and the page is clean, but like every other kernel fs (including
ext2) you relay on it _before_ writepage is invoked. The race my patch
wants to address is a race where a page becomes from dirty to clean,
without writepage being invoked and without the lowlevel fs ever
noticing that the page has been marked dirty.

If you had a lowlevel implementation of .set_page_dirty, you had a
slight chance to fix the race locally to the fs, but you didn't use it,
not even Neil's patch modified set_page_dirty.

So no matter how you change the code inside linux/fs/*, unless you hack
more around .set_page_dirty there's no chance for you to fix the
fs-corruption source that my patch fixed in the VM (in linux/mm/*).

So again those two patches are completely orthogonal, both are needed
and they should be considered separately: they fixes two completely
different bugs. The fact both bugs can lead to a similar kind of fs
corruption now seems just a pure coincidence.

The fact my fix fixed the testcase fully, seems to mean that the
lowlevel race has a much smaller window to trigger and the highlevel
race in the VM was the biggest offender (at least for the testcase that
Olaf posted here, dunno about other workloads).

Thanks.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
