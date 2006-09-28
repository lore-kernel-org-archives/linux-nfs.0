From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 009 of 11] knfsd: Allow max size of NFSd payload
 to be configured.
Date: Thu, 28 Sep 2006 18:09:33 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0609281752290.32574@blonde.wat.veritas.com>
References: <20060824162917.3600.patches@notabene> <1060824063716.5020@suse.de>
	<20060925212457.GK32762@fieldses.org>
	<17691.19982.162616.572205@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSzOa-0005gH-BO
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 10:10:00 -0700
Received: from excu-mxob-2.symantec.com ([198.6.49.23])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSzOZ-0000Rv-T9
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 10:10:01 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17691.19982.162616.572205@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 28 Sep 2006, Neil Brown wrote:
> But are the pages that totalram is measure in, normal pages, of
> page_cache pages?  And is there a difference?

There's never yet been a difference, outside of some patches by bcrl.
But totalram_pages comes "before" any idea of page cache, so it's in
normal pages.

> Should we use PAGE_CACHE_SHIFT, or PAGE_SHIFT?

PAGE_SHIFT.

> And why do we have both if they are numerically identical?

Very irritating: the time I've wasted on "correcting" code for the
"difference" between them!  Yet there's still plenty wrong and I've
largely given up on it.

Probably never will be a difference: but the idea was that the page
cache might use >0-order pages (unclear what happens to swap cache).

I wish they'd waited for a working implementation before introducing
the distinction; but never quite felt like deleting all trace of it.

> 
> I'll submit a patch which uses
>         12 - PAGE_SHIFT
> in a little while.

I haven't seen your context; but "12 - PAGE_SHIFT" sounds like a
bad idea on all those architectures with PAGE_SHIFT 13 or more;
you'll be on much safer ground working with "PAGE_SHIFT - 12".

Hugh

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
