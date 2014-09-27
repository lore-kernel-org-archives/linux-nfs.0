Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35778 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbaI0U1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 16:27:16 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so1348597igd.10
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 13:27:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140927155045.76ce1149@synchrony.poochiereds.net>
References: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
	<20140927144056.2d303755@synchrony.poochiereds.net>
	<CAHQdGtQBNpBO+xv_uk+bkue6zoSKMhU72xjKaeOb2gEHY012Ew@mail.gmail.com>
	<20140927155045.76ce1149@synchrony.poochiereds.net>
Date: Sat, 27 Sep 2014 16:27:15 -0400
Message-ID: <CAHQdGtSc8+5k-U=5NB7gYEhh5Qd4jq2BqpzQ_0wA_YH637q97g@mail.gmail.com>
Subject: Re: [nfsv4] Could somebody please enlighten me as to what is supposed
 to happen in this situation?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 27, 2014 at 3:50 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> On Sat, 27 Sep 2014 15:25:12 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Sat, Sep 27, 2014 at 2:40 PM, Jeff Layton
>> <jeff.layton@primarydata.com> wrote:
>> > On Sat, 27 Sep 2014 11:22:29 -0400
>> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> >
>> >
>> > My take (quite possibly wrong, but...)
>> >
>> >> The scenario is this:
>> >>                                        Server
>> >>                                        ======
>> >>                                        boot (B1)
>> >> Client
>> >> ======
>> >> EXCHANGE_ID
>> >> CREATE_SESSION
>> >> OPEN(reclaim)
>> >> LOCK(reclaim)
>> >> RECLAIM_COMPLETE
>> >>                                        (lift GRACE period)
>> >
>> > At this point, we'd deny reclaim from any client that has not issued a
>> > RECLAIM_COMPLETE. In the case of the Linux server with nfsdcltrack, we
>> > clean out any client records that have not issued a RECLAIM_COMPLETE.
>> >
>> >>                                        reboot (B2)
>> >> EXCHANGE_ID
>> >> CREATE_SESSION
>> >> OPEN(reclaim)
>> >>                                         reboot (while GRACE period
>> >> still being enforced) (B3)
>> >> EXCHANGE_ID
>> >> CREATE_SESSION
>> >> OPEN(reclaim)
>> >>
>> >> What should be the server response to the above OPEN(reclaim) from the
>> >> client after reboot (B3)?
>> >>
>> >
>> > My expectation is that it would be granted. There was a
>> > RECLAIM_COMPLETE issued during the boot where the grace period was last
>> > lifted, and that should be enough to allow the client to issue reclaims
>> > on any subsequent reboot, until the grace period is lifted again.
>> >
>> > Doing anything else would be a pretty unfriendly way for the server to
>> > behave. In the face of rapid reboots (a not-uncommon occurrence when
>> > patching, etc), you'd lose state unless the client just happened to get
>> > in there quickly enough to issue a RECLAIM_COMPLETE between each reboot.

Where is the evidence that this is a problem for NFS and for NFS
client recovery?

>> > That was the situation with the legacy client tracker in knfsd. When
>> > testing, it was trivial to reboot the machine quickly twice and on the
>> > second reboot nothing could be reclaimed.
>>
>> So now, what if the following scenario:
>>
>>                                        Server
>>                                        ======
>>                                        boot (B1')
>> Client
>> ======
>> EXCHANGE_ID
>> CREATE_SESSION
>> OPEN(reclaim)
>> LOCK(reclaim)
>> RECLAIM_COMPLETE
>>                                        (lift GRACE period (G1))
>>                                        reboot (B2')
>> EXCHANGE_ID
>> CREATE_SESSION
>> OPEN(reclaim)
>>                                        (lift GRACE period (G2))
>>                                        reboot (B3')
>> EXCHANGE_ID
>> CREATE_SESSION
>> OPEN(reclaim)
>>
>> What should happen to the OPEN(reclaim) in (B3')?
>>
>
> (Let's call the lifting of grace periods 'G1' and 'G2'...)
>
> Denied.
>
> There was no RECLAIM_COMPLETE issued between B2 and G2. It's possible
> that client2 could creep in between G2 and B3 and acquire locks that
> conflict with ones that were not reclaimed by client1 between B2 and
> G2. So, we can't allow any reclaims for client1 after B3.

Why should the possibility that clients might steal locks that were
not reclaimed, affect reboot recovery of locks that were successfully
reclaimed? There is no way for client 2 to steal those unless the
lease expires, in which case client 1 will be blocked from recovering
state anyway.

So you are saying that the client should be able to reclaim all locks
or nothing? If this is really the case then, could we please fix the
spec?

> I should add a clarification here too. I'm assuming that the server in
> this case just tracks the minimum required to allow state to be
> reclaimed. If it (for instance) tracked on stable storage all of the
> locks that it ever granted such that it knows that there were no
> conflicts, then it could be more lenient about allowing client1 to
> reclaim after B3.

No. A server doesn't need to do all that in order to allow the client
to recover some of the locks.

All it needs to do is to be able to tell the client that it shouldn't
reclaim locks that were not reclaimed in (B2'). A simple SEQUENCE
status flag would suffice to let the client know that it failed to
reclaim all its locks in the last valid grace period.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
