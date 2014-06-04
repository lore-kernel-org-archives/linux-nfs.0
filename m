Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:62903 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbaFDMsC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 08:48:02 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so7183489iec.12
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 05:48:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140604173926.53918af3@notabene.brown>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
	<20140531081358.62ae69b3@notabene.brown>
	<20140604173926.53918af3@notabene.brown>
Date: Wed, 4 Jun 2014 08:48:02 -0400
Message-ID: <CAHQdGtR-YwT-nW-vcFhBFPsg3h=ZE6co08QB9KETGdiKrNNuUg@mail.gmail.com>
Subject: Re: Live lock in silly-rename.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 4, 2014 at 3:39 AM, NeilBrown <neilb@suse.de> wrote:
> On Sat, 31 May 2014 08:13:58 +1000 NeilBrown <neilb@suse.de> wrote:
>
>> On Fri, 30 May 2014 17:55:23 -0400 "J. Bruce Fields" <bfields@fieldses.org>
>> wrote:
>>
>> > On Fri, May 30, 2014 at 01:44:42PM +1000, NeilBrown wrote:
>> > > On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fieldses.org>
>> > > wrote:
>> > >
>> > > > Yes, it's a known server bug.
>> > > >
>> > > > As a first attempt I was thinking of just sticking a timestamp in struct
>> > > > inode to record the time of the most recent conflicting access and deny
>> > > > delegations if the timestamp is too recent, for some definition of too
>> > > > recent.
>> > > >
>> > >
>> > > Hmmm... I'll have a look next week and see what I can come up with.
>> >
>> > Thanks!
>> >
>> > If we didn't think it was worth another struct inode field, we could
>> > probably get away with global state.  Even just refusing to give out any
>> > delegations for a few seconds after any delegation break would be enough
>> > to fix this bug.
>> >
>> > Or you could make it a little less harsh with a small hash table: "don't
>> > give out a delegation on any inode whose inode number hashes to X for a
>> > few seconds."
>>
>> I was thinking of using a bloom filter - or possibly two.
>> - avoid handing out delegations if either bloom filter reports a match
>> - when reclaiming a delegation add the inode to the second bloom filter
>> - every so-often zero-out the older filter and swap them.
>>
>> Might be a bit of overkill, but I won't know until I implement it.
>>
>
> Below is my suggestion.  It seems easy enough.  It even works.
>
> However it does raise an issue with the NFS client.
>
> NFS performs a silly-rename as an 'asynchronous' operation.  One consequence
> of this is that NFS4ERR_DELAY always results in a delay of
> NFS4_POLL_RETRY_MAX (15*HZ), where as sync requests use an exponential scale
> from _MIN to _MAX.
>
> So in my test case there is always a 15second delay:
>   - try to silly-rename
>   - get NFS4ERR_DELAY
>   - server reclaim delegation
>   - 15 seconds passes
>   - retry silly-rename - it works.
>
> I hacked the NFS server to store a timeout in 'struct nfs_renamedata', and
> use the same exponential retry pattern and the 15 seconds (obviously)
> disappeared.
>
> Trond: would  you accept a patch which did that more generally?  e.g. pass a
> timeout pointer to nfs4_async_handle_error() and various *_done function pass
> a pointer to a field in their calldata?

It depends. If we're touching nfs4_async_handle_error, then I think we
should also convert nfs4_async_handle_error to use the same "struct
nfs4_exception" argument that we use for the synchronous case so that
we can share a bit more code.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
