Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59946 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751114AbdHXEr5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 00:47:57 -0400
Subject: Re: Do we really need d_weak_revalidate???
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name>
 <1502430944.3822.1.camel@primarydata.com>
 <1502449309.4950.2.camel@redhat.com>
 <87zib3niqn.fsf@notabene.neil.brown.name>
 <1502705432.4978.1.camel@redhat.com>
 <877ey4nsep.fsf@notabene.neil.brown.name>
 <1502883253.4847.6.camel@redhat.com>
 <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com>
 <878tihmora.fsf@notabene.neil.brown.name>
 <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
 <87h8x1l9qp.fsf@notabene.neil.brown.name>
 <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
 <87r2w3jdn5.fsf@notabene.neil.brown.name>
 <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
 <87inhdk3rq.fsf@notabene.neil.brown.name>
From: Ian Kent <ikent@redhat.com>
Message-ID: <6eea758c-1031-7e75-be05-a29ba8dc4620@redhat.com>
Date: Thu, 24 Aug 2017 12:47:46 +0800
MIME-Version: 1.0
In-Reply-To: <87inhdk3rq.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24/08/17 12:07, NeilBrown wrote:
> On Wed, Aug 23 2017, Ian Kent wrote:
> 
>>
>> That inconsistency has bothered me for quite a while now.
>>
>> It was carried over from the autofs module behavior when automounting
>> support was added to the VFS. What's worse is it prevents the use of
>> the AT_NO_AUTOMOUNT flag from working properly with fstatat(2) and with
>> statx().
>>
>> There is some risk in changing that so it does work but it really does
>> need to work to enable userspace to not trigger an automount by using
>> this flag.
>>
>> So that's (hopefully) going to change soonish, see:
>> http://ozlabs.org/~akpm/mmotm/broken-out/autofs-fix-at_no_automount-not-being-honored.patch
>>
>> The result should be that stat family calls don't trigger automounts except
>> for fstatat(2) and statx() which will require the AT_NO_AUTOMOUNT flag.
>>
> 
> oooh, yes.  That's much better - thanks.
> 
> We should make sure that change gets into the man pages...

Yes, I was wondering who to contact for that.

> 
> First however, we should probably correct the man page!
> stat.2 says:
> 
> 
>   NOTES
>        On Linux, lstat() will generally not trigger  automounter
>        action,  whereas  stat()  will  (but  see  the description of
>        fstatat() AT_NO_AUTOMOUNT fag, above).
> 
> which is wrong: lstat and stat treat automounts the same.
> @Michael: do you recall why you inserted that text?  The commit message
> in commit 1ef5b2805471 ("stat.2: Cosmetic reworking of timestamp
> discussion in NOTES") is not very helpful.
> 
> I propose correcting to
> 
>   NOTES:
>       On Linux, lstat() nor stat() act as though AT_NO_AUTOMOUNT was set
>       and will not trigger automounter action for direct automount
>       points, though they may (prior to 4.14) for indirect automount
>       points.

Shouldn't that be "lstat() and stat() act as though AT_NO_AUTOMOUNT is
set ..."

> 
> 
> The more precise details, that automount action for indirect automount
> points is not triggered when the 'browse' option is used, is probably
> not necessary.
> 
> Ian: if you agree with that text, and Michael doesn't provide alternate
> evidence, I'll submit a formal patch for the man page.... or should we
> just wait until the patch actually lands?

I thought the fstatat() description needed attention too, doubly so with
the AT_NO_AUTOMOUNT change.

The "The fstatat() system call operates in exactly the same way as stat()"
is wrong in the same way as the stat() description was wrong.

After the change fstatat() will trigger automounts if the AT_NO_AUTOMOUNT
flag is not given which is different from lstat() and stat().

The updated NOTE above probably needs to be referred to in order to clarify
what's meant by "in exactly the same way" since that probably refers to the
information returned rather than whether an automount will be done.

Ian
