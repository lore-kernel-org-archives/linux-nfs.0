Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49826 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750916AbdLSQaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Dec 2017 11:30:24 -0500
Date: Tue, 19 Dec 2017 11:30:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Thiago Rafael Becker <thiago.becker@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of
 set_groups.
Message-ID: <20171219163023.GB19967@fieldses.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171130130457.11429-3-thiago.becker@gmail.com>
 <87mv2ztgix.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
 <87efoatfsb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87efoatfsb.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 05, 2017 at 07:11:00AM +1100, NeilBrown wrote:
> On Mon, Dec 04 2017, Thiago Rafael Becker wrote:
> 
> > On Mon, 4 Dec 2017, NeilBrown wrote:
> >
> >> I think you need to add groups_sort() in a few more places.
> >> Almost anywhere that calls groups_alloc() should be considered.
> >> net/sunrpc/svcauth_unix.c, net/sunrpc/auth_gss/svcauth_gss.c,
> >> fs/nfsd/auth.c definitely need it.
> >
> > So are any other functions that modify group_info. OK, I think I'll 
> > implement the type detection below as it helps detecting where these 
> > situations are located.
> >
> > This may take some time to make sane. I wonder if we shouldn't 
> > accept the first change suggested to fix the corruption detected in 
> > auth.unix.gid while I work on a new set of patches. 
> 
> As we don't seem to be pursuing this possibility is probably isn't very
> important, but I'd like to point out that the original fix isn't a true
> fix.
> It just sorts a shared group_info early.  This does not stop corruption.
> Every time a thread calls set_groups() on that group_info it will be
> sorted again.
> The sort algorithm used is the heap sort, and a heap sort always moves
> elements in the array around - it does not leave a sorted array
> untouched (unlike e.g. the quick sort which doesn't move anything in a
> sorted array).
> So it is still possible for two calls to groups_sort() to race.
> We *need* to move groups_sort() out of set_groups().

By the way,

	https://bugzilla.kernel.org/show_bug.cgi?id=197887

looks like it might be this bug.  They report it started to happen on
upgrade from a 4.10-ish kernel to a 4.13-ish kernel, which would include
the commit (b7b2562f725) that converted groups_sort to a function that
is no longer a no-op in the already-sorted case.

Looks like rpc.mountd just uses getgrouplist(), and I don't think that
guarantees any particular oder.  I wonder if it's the case that many
common configurations always pass down an already-sorted list.  In that
case this may show up as a 4.13 regression for some users.

--b.
