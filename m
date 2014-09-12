Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:65281 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaILQ3D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Sep 2014 12:29:03 -0400
Received: by mail-vc0-f169.google.com with SMTP id ij19so953993vcb.0
        for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2014 09:29:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140912120737.385fdf6c@tlielax.poochiereds.net>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
	<1410193821-25109-6-git-send-email-jlayton@primarydata.com>
	<20140911195547.GA21296@fieldses.org>
	<20140911162836.70056390@tlielax.poochiereds.net>
	<20140912093600.50dfa9bc@tlielax.poochiereds.net>
	<20140912102153.09d58de7@tlielax.poochiereds.net>
	<20140912143621.GA28915@fieldses.org>
	<20140912152142.GB28915@fieldses.org>
	<CAABAsM7JoG1tQuyOZ1uU66jz9RKCoung8jdP1LXuDbExfqqWKg@mail.gmail.com>
	<20140912120737.385fdf6c@tlielax.poochiereds.net>
Date: Fri, 12 Sep 2014 12:29:01 -0400
Message-ID: <CAHQdGtSGaN0NL_NP45i-4Qw6GN9uFPRj=W+8yjBimqk3_7m_oA@mail.gmail.com>
Subject: Re: [PATCH v3 5/7] nfsdcltrack: update schema to v2
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 12, 2014 at 12:07 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> On Fri, 12 Sep 2014 11:54:17 -0400
> Trond Myklebust <trondmy@gmail.com> wrote:
>
>> On Fri, Sep 12, 2014 at 11:21 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Fri, Sep 12, 2014 at 10:36:21AM -0400, J. Bruce Fields wrote:
>> >> On Fri, Sep 12, 2014 at 10:21:53AM -0400, Jeff Layton wrote:
>> >> > Grace period
>> >> > eventually ends, and its record is purged from the DB.
>> >> >
>> >> > Now we have a client that has reclaimed some files but that has no
>> >> > record on stable storage.
>> >> >
>> >> > One possibility is to prematurely expire v4.1+ clients that have not
>> >> > sent a RECLAIM_COMPLETE when the grace period ends.
>> >> >
>> >> > That seems problematic though -- what about clients that just happen to
>> >> > do an EXCHANGE_ID just before the grace period is going to end, and
>> >> > that get expired before they can issue their RECLAIM_COMPLETE. Will
>> >> > that be a problem for them?
>> >>
>> >> In that case a client will send a reclaim, get back a NO_GRACE error,
>> >> mark the rest of its state as unrecoverable, send the RECLAIM_COMPLETE,
>> >> and continue normally.  (To the extent it can--signalling affected
>> >> processes or EIOing further attempts to use the unreclaimed state, or
>> >> whatever.)
>> >
>> > The one thing the server *could* do in this sort of case is extend the
>> > grace period by a little--I seem to recall the spec giving some leeway
>> > for this kind of thing.
>>
>>
>> Section 8.4.2.1.
>>
>> > So for example the server could have a heuristics like: extend the grace
>> > period by another second each time we notice there's been an EXCHANGE_ID
>> > or reclaim in the previous second, up to some maximum.  And I suppose it
>> > could also delay the grace period until someone actually attempts a
>> > non-reclaim open.
>> >
>> > In isolation a single client slipping in the end like that sounds like a
>> > freak event, but if there's a ton of state to reclaim perhaps it could
>> > become more likely.
>> >
>> > I don't think that's a priority, we might just want to make sure we know
>> > how to do that in the future.
>> >
>> > But now that I think about it I don't see the existing or proposed
>> > nfsdcltrack stuff tying our hands in any way here.  It just gives the
>> > kernel some extra information, and the kernel still has discretion about
>> > when exactly it wants to end the grace period.
>> >
>>
>> It is even allowed to grant reclaim lock attempts after the grace
>> period has ended _if_ and only if it can guarantee that no conflicting
>> locks were issued.
>>
>> However note that the NFSv4.1 client is not actually allowed to issue
>> non-reclaim lock requests before it has issued a RECLAIM_COMPLETE. I
>> dunno how religiously we stick to that in Linux (I think we do), but
>> the point is that the server can and should rely on the client
>> _always_ sending a RECLAIM_COMPLETE if it is going to establish new
>> locks.
>
> Yeah, I'm pretty sure that bit is enforced. The problem situation that
> I think Bruce was referring to is this:
>
> Server reboots. Client1 reclaims some of its locks (but not all) and
> never sends a RECLAIM_COMPLETE. Grace period ends and then server
> hands out a lock to client2 that was previously held by client1 but
> that didn't get reclaimed.
>
> Server reboots again, prior to the client1 expiring (so its record is
> still in the DB). Now client1 comes back and starts reclaiming again.
> This time it reclaims all of its locks and we have a conflict between
> it and client2.
>
> It's a solvable problem, but I'll need to work through how best to do
> so.
>
> --

That's the first edge condition described in section 8.4.3.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
