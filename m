From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Mon, 8 Mar 2010 13:21:48 -0500
Message-ID: <20100308182148.GB1675@fieldses.org>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu> <1267992481-13332-2-git-send-email-bfields@citi.umich.edu> <1267992481-13332-3-git-send-email-bfields@citi.umich.edu> <20100308082516.260e5f70@notabene.brown> <20100307215826.GA14104@fieldses.org> <20100308101014.14e635b2@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60788 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754627Ab0CHSU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 13:20:28 -0500
In-Reply-To: <20100308101014.14e635b2-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 08, 2010 at 10:10:14AM +1100, Neil Brown wrote:
> On Sun, 7 Mar 2010 16:58:26 -0500
> "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > Don't we have this problem already, then?  The export cache really is
> > just a cache, and we should be prepared for a given entry to be purged
> > at any time.
> > 
> 
> Yes, it is a cache, but things don't get pushed out when it is 'full', so you
> can expect items to stay out their expiry time.

At least for some caches we may want some sort of pruning when they get
to full.

If we do that, then we may want to vary the behavior from cache to
cache, hence keeping the export cache protected from this deadlock.
Though I'd rather avoid that kind of special case if we could.

> So if you add something
> with  an expiry 30 minutes in the future, you can usually expect it to still
> be there in 30 seconds.
> 
> If someone ran "exportfs -f"

or "exportfs -r"?

> at exactly the wrong time you might be able to deadlock mountd (I'd
> have to double-check to be sure), but that is very different from
> mountd acting in a way which leads directly to a deadlock.

Yeah, agreed.  It's still a bug--people are supposed to be able to do
that without deadlock--but, sure, it may be unbelievably hard to hit.

So, I need to look harder at this, thanks for the review.  (May take a
few days, though, so if someone else wants to volunteer, feel free.)

I wonder how best to eliminate the deadlock:

	- Allow fh downcall to return -EAGAIN, let mountd change that to
	  a JUKEBOX or dropped rpc?
	- Require mountd run two processes, with one dedicated to
	  upcalls?
	- Separate mountd entirely into an upcall-handling daemon and an
	  rpc daemon?

Occasionally we seem to hear from a security-conscious administrator
who's running v4-only and is irritated that they have to firewall off
mountd instead of just being able to kill it entirely.  The latter might
reassure them, I suppose.

--b.
