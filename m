From: Daniel Phillips <phillips@phunq.net>
Subject: Re: A unresponsive file system can hang all I/O in the system
	on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 17:46:43 -0700
Message-ID: <200709281746.44499.phillips@phunq.net>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbQTz-0004vx-Ck
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 17:46:59 -0700
Received: from phunq.net ([64.81.85.152] helo=moonbase.phunq.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IbQU4-000122-8s
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 17:47:04 -0700
In-Reply-To: <20070927235034.ae7bd73d.akpm@linux-foundation.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday 27 September 2007 23:50, Andrew Morton wrote:
> Actually we perhaps could address this at the VFS level in another
> way. Processes which are writing to the dead NFS server will
> eventually block in balance_dirty_pages() once they've exceeded the
> memory limits and will remain blocked until the server wakes up -
> that's the behaviour we want.

It is not necessary to restrict total dirty pages at all.  Instead it is 
necessary to restrict total writeout in flight.  This is evident from 
the fact that making progress is the one and only reason our kernel 
exists, and writeout is how we make progress clearing memory.  In other 
words, if we guarantee the progress of writeout, we will live happily 
ever after and not have to sell the farm.

The current situation has an eerily similar feeling to the VM 
instability in early 2.4, which was never solved until we convinced 
ourselves that the only way to deal with Moore's law as applied to 
number of memory pages was to implement positive control of swapout in 
the form of reverse mapping[1].  This time round, we need to add 
positive control of writeout in the form of rate limiting.

I _think_ Peter is with me on this, and not only that, but between the 
too of us we already have patches for most of the subsystems that need 
it, and we have both been busy testing (different subsets of) these 
patches to destruction for the better part of a year.

Anyway, to fix the immediate bug before the one true dirty_limit removal 
patch lands (promise) I think you are on the right track by noticing 
that balance_dirty_pages has to become aware of how congested the 
involved block device is, since blocking a writeout process on an 
underused block device is clearly a bad idea.  Note how much this idea 
looks like rate limiting.

[1] We lost the scent for a number of reasons, not least because the 
experimental implementation of reverse mapping at the time was buggy 
for reasons entirely unrelated to the reverse mapping itself.

Regards,

Daniel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
