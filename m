Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34781 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbcKQVxq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2016 16:53:46 -0500
Received: by mail-it0-f66.google.com with SMTP id o1so18140429ito.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 Nov 2016 13:53:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1479419127.33885.5.camel@primarydata.com>
References: <ufapovfc8m4.fsf@epithumia.math.uh.edu> <ufa1syb402e.fsf@epithumia.math.uh.edu>
 <20161117163101.GA19161@fieldses.org> <1479404750.33885.1.camel@primarydata.com>
 <20161117193239.GD20937@fieldses.org> <CAN-5tyFP8QapcfuG5pO2059ftf3wGhmaO=6RZAA+W_nYbVraPQ@mail.gmail.com>
 <20161117201753.GF20937@fieldses.org> <CAN-5tyHcaJCCdBaNbU4Mc=JuJXi9cDppuTVKKixrgVZMZS-DMg@mail.gmail.com>
 <20161117204618.GG20937@fieldses.org> <CAN-5tyHs1Xq4W2eJOMOW_Tv3=3hQLYhLdVwMDYixhGnaGsEH4Q@mail.gmail.com>
 <20161117212601.GA23130@fieldses.org> <1479419127.33885.5.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 17 Nov 2016 16:53:44 -0500
Message-ID: <CAN-5tyFChQ0S4hUwGyWjaJ73hBpTZjJXVK3jm_M_4v1vgzVSjA@mail.gmail.com>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2016 at 4:45 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2016-11-17 at 16:26 -0500, bfields@fieldses.org wrote:
>> On Thu, Nov 17, 2016 at 04:05:32PM -0500, Olga Kornievskaia wrote:
>> >
>> > On Thu, Nov 17, 2016 at 3:46 PM, bfields@fieldses.org
>> > <bfields@fieldses.org> wrote:
>> > >
>> > > On Thu, Nov 17, 2016 at 03:29:11PM -0500, Olga Kornievskaia
>> > > wrote:
>> > > >
>> > > > On Thu, Nov 17, 2016 at 3:17 PM, bfields@fieldses.org
>> > > > <bfields@fieldses.org> wrote:
>> > > > >
>> > > > > On Thu, Nov 17, 2016 at 02:58:12PM -0500, Olga Kornievskaia
>> > > > > wrote:
>> > > > > >
>> > > > > > On Thu, Nov 17, 2016 at 2:32 PM, bfields@fieldses.org
>> > > > > > <bfields@fieldses.org> wrote:
>> > > > > > >
>> > > > > > > On Thu, Nov 17, 2016 at 05:45:52PM +0000, Trond Myklebust
>> > > > > > > wrote:
>> > > > > > > >
>> > > > > > > > On Thu, 2016-11-17 at 11:31 -0500, J. Bruce Fields
>> > > > > > > > wrote:
>> > > > > > > > >
>> > > > > > > > > On Wed, Nov 16, 2016 at 02:55:05PM -0600, Jason L
>> > > > > > > > > Tibbitts III wrote:
>> > > > > > > > > >
>> > > > > > > > > >
>> > > > > > > > > > I'm replying to a rather old message, but the issue
>> > > > > > > > > > has just now
>> > > > > > > > > > popped
>> > > > > > > > > > back up again.
>> > > > > > > > > >
>> > > > > > > > > > To recap, a client stops being able to access _any_
>> > > > > > > > > > mount on a
>> > > > > > > > > > particular server, and "NFS:
>> > > > > > > > > > nfs4_reclaim_open_state: Lock reclaim
>> > > > > > > > > > failed!" appears several hundred times per second
>> > > > > > > > > > in the kernel
>> > > > > > > > > > log.
>> > > > > > > > > > The load goes up by one for ever process attempting
>> > > > > > > > > > to access any
>> > > > > > > > > > mount
>> > > > > > > > > > from that particular server.  Mounts to other
>> > > > > > > > > > servers are fine, and
>> > > > > > > > > > other clients can mount things from that one server
>> > > > > > > > > > without
>> > > > > > > > > > problems.
>> > > > > > > > > >
>> > > > > > > > > > When I kill every process keeping that particular
>> > > > > > > > > > mount active and
>> > > > > > > > > > then
>> > > > > > > > > > umount it, I see:
>> > > > > > > > > >
>> > > > > > > > > > NFS: nfs4_reclaim_open_state: unhandled error
>> > > > > > > > > > -10068
>> > > > > > > > >
>> > > > > > > > > NFS4ERR_RETRY_UNCACHED_REP.
>> > > > > > > > >
>> > > > > > > > > So, you're using NFSv4.1 or 4.2, and the server
>> > > > > > > > > thinks that the
>> > > > > > > > > client
>> > > > > > > > > has reused a (slot, sequence number) pair, but the
>> > > > > > > > > server doesn't
>> > > > > > > > > have a
>> > > > > > > > > cached response to return.
>> > > > > > > > >
>> > > > > > > > > Hard to know how that happened, and it's not shown in
>> > > > > > > > > the below.
>> > > > > > > > > Sounds like a bug, though.
>> > > > > > > >
>> > > > > > > > ...or a Ctrl-C....
>> > > > > > >
>> > > > > > > How does that happen?
>> > > > > > >
>> > > > > >
>> > > > > > If I may chime in...
>> > > > > >
>> > > > > > Bruce, when an application sends a Ctrl-C and clients's
>> > > > > > session slot
>> > > > > > has sent out an RPC but didn't process the reply, the
>> > > > > > client doesn't
>> > > > > > know if the server processed that sequence id or not. In
>> > > > > > that case,
>> > > > > > the client doesn't increment the sequence number. Normally
>> > > > > > the client
>> > > > > > would handle getting such an error by retrying again (and
>> > > > > > resetting
>> > > > > > the slots) but I think during recovery operation the client
>> > > > > > handles
>> > > > > > errors differently (by just erroring). I believe the
>> > > > > > reasoning that we
>> > > > > > don't want to be stuck trying to recover from the recovery
>> > > > > > from the
>> > > > > > recovery etc...
>> > > > >
>> > > > > So in that case the client can end up sending a different rpc
>> > > > > reusing
>> > > > > the old slot and sequence number?
>> > > >
>> > > > Correct.
>> > >
>> > > So that could get UNCACHED_REP as the response.  But if you're
>> > > very
>> > > unlucky, couldn't this also happen?:
>> > >
>> > >         1) the compound previously sent on that slot was
>> > > processed by
>> > >         the server and cached
>> > >         2) the compound you're sending now happens to have the
>> > > same set
>> > >         of operations
>> > >
>> > > with the result that the client doesn't detect that the reply was
>> > > actually to some other rpc, and instead it returns bad data to
>> > > the
>> > > application?
>> >
>> > If you are sending exactly the same operations and arguments, then
>> > why
>> > is a reply from the cache would lead to bad data?
>>
>> That would probably be fine, I was wondering what would happen if you
>> sent the same operation but different arguments.
>
>> So the original cancelled operation is something like
>> PUTFH(fh1)+OPEN("foo")+GETFH, and the new one is
>> PUTFH(fh2)+OPEN("bar")+GETFH.  In theory couldn't the second one
>> succeed
>> and leave the client thinking it had opened (fh2, bar) when the
>> filehandle it got back was really for (fh1, foo)?
>>
>
> The client would receive a filehandle for fh1/"foo", so it would apply
> any state it thought it had received to that file. However, normally,
> I'd expect to see a NFS4ERR_FALSE_RETRY in this case.

I see Bruce's point that if the server only looks up the cache based
on the seqid and slot# and doesn't have like a hash of the content
which I could see is expensive, then the client in this case would get
into trouble of thinking it opened "bar" but really it's "foo". Spec
says:

Section 18.46.3
If the client reuses a slot ID and sequence ID for a completely
   different request, the server MAY treat the request as if it is a
   retry of what it has already executed.  The server MAY however detect
   the client's illegal reuse and return NFS4ERR_SEQ_FALSE_RETRY.

What is "a completely different request". From the client's point of
view sending different args would constitute a different request. But
in any case it's a "MAY" so client can't depend on this being
implemented.
