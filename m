Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34929 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754960Ab1JCPiY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Oct 2011 11:38:24 -0400
Date: Mon, 3 Oct 2011 11:38:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
Message-ID: <20111003153821.GC5524@pad.fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
 <1316438143-1057-4-git-send-email-bfields@redhat.com>
 <4E89CA1C.4050107@tonian.com>
 <20111003145749.GB5524@pad.fieldses.org>
 <4E89D114.1020109@tonian.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E89D114.1020109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 03, 2011 at 05:13:24PM +0200, Benny Halevy wrote:
> On 2011-10-03 16:57, J. Bruce Fields wrote:
> > On Mon, Oct 03, 2011 at 04:43:40PM +0200, Benny Halevy wrote:
> >> Bruce, it seems with this patch, doing si_opaque.so_id = current_stateid
> >> makes all stateid's unique, regardless of their type.
> >> Is find_stateid_by_type still needed?
> >>
> >> And if the opaque part of the stateid isn't unique,
> >> shouldn't find_stateid_by_type go over the hash bucket by itself
> >> to look for other stateid's sharing the same opaque but having
> >> the type it is looking for?
> > 
> > Stateid's have actually always been unique--they'd have to be, since
> > e.g. READ doesn't come with any indication of which type of stateid
> > you're being given.  All find_stateid_by_type() does is fail when it
> > doesn't find something of the right type.
> > 
> 
> So I'm still confused.  That's what I thought.
> So in what cases find_stateid that find_stateid_by_type calls
> will find a stateid structure with a non-matching sc_type?

Suppose, for example, the server gets a DELEGRETURN, looks up the
provided stateid, and finds an open stateid.

At this point either the client is buggy, or else something very
unlikely has happened.  (E.g. a stateid was retired and then reused).

So find_stateid_by_type() returns NULL which the caller will likely
translate to something like BAD_STATEID.

Other cases: open_confirm and close require an open stateid, ulock or
lock with the !new_lock_owner case requires a lock stateid, etc.

--b.
