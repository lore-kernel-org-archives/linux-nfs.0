Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34542 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750907AbdAaOjY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jan 2017 09:39:24 -0500
Date: Tue, 31 Jan 2017 09:38:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSDv4: use export cache flushtime for changeid on
 V4ROOT objects.
Message-ID: <20170131143855.GA5727@fieldses.org>
References: <87mve9rs0z.fsf@notabene.neil.brown.name>
 <20170130153517.GC24786@fieldses.org>
 <8737g0rxm2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8737g0rxm2.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 31, 2017 at 09:28:37AM +1100, NeilBrown wrote:
> On Mon, Jan 30 2017, J. Bruce Fields wrote:
> 
> > On Mon, Jan 30, 2017 at 05:17:00PM +1100, NeilBrown wrote:
> >> 
> >> If you change the set of filesystems that are exported, then
> >> the contents of various directories in the NFSv4 pseudo-root
> >> is likely to change.  However the change-id of those
> >> directories is currently tied to the underlying directory,
> >> so the clinet may not see the changes in a timely fashion.
> >
> > Oh, good catch.
> >
> >> This patch changes the change-id number to be derived from the
> >> "flush_time" of the export cache.  Whenever any changes are
> >> made to the set of exported filesystems, this flush_time is
> >> updated.  The result is that clients see changes to the set
> >> of exported filesystems much more quickly, often immediately.
> >
> > And, a clever solution, as usual....
> >
> > I wonder if it's completely right yet, though.  Off the top of my head:
> > can't the client see the new flush time before it sees the new contents?
> > If so, a client that caches both during that window could cache the old
> > contents indefinitely.
> 
> uhm....
> Yes, it could see the new flush time before it sees the new contents.
> When it sees that new flush time (i.e. new change attribute), it will
> invalidate its cached contents and ask for the contents again.

The problem comes if it's still possible for the client to read (and
cache) the old contents at this point, in which case the client's cache
will incorrectly associate old contents with new change attribute.

> It will then definitely get new contents.

So the problem with changing change attribute before contents is:

	- client retrieves old contents and new attribute, caches.
	- client revalidates cache at an arbitrarily later time, sees
	  it's still the new attribute, continues caching old contents.

So usually I believe you want the two changes--contents and change
attribute--to be atomic or, if that's not possible, for them to be
changed in that order.

I haven't thought through how that applies to this case, but I think it
should be possible if in-progress rpc's hold references to objects in
the flushed cache?

--b.
