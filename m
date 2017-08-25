Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753891AbdHYAFU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 20:05:20 -0400
Subject: Re: Do we really need d_weak_revalidate???
To: mtk.manpages@gmail.com, NeilBrown <neilb@suse.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>
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
 <CAKgNAki1SYjr7-6g-i3shGjQRjwy81gS0QisfZRy-x-bHFtXmA@mail.gmail.com>
From: Ian Kent <ikent@redhat.com>
Message-ID: <9c4b3c7a-6b05-eb8e-72b9-d95a1cdc62ed@redhat.com>
Date: Fri, 25 Aug 2017 08:05:09 +0800
MIME-Version: 1.0
In-Reply-To: <CAKgNAki1SYjr7-6g-i3shGjQRjwy81gS0QisfZRy-x-bHFtXmA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24/08/17 19:03, Michael Kerrisk (man-pages) wrote:
> Hi Neil,
> 
> On 24 August 2017 at 06:07, NeilBrown <neilb@suse.com> wrote:
>> On Wed, Aug 23 2017, Ian Kent wrote:
>>
>>>
>>> That inconsistency has bothered me for quite a while now.
>>>
>>> It was carried over from the autofs module behavior when automounting
>>> support was added to the VFS. What's worse is it prevents the use of
>>> the AT_NO_AUTOMOUNT flag from working properly with fstatat(2) and with
>>> statx().
>>>
>>> There is some risk in changing that so it does work but it really does
>>> need to work to enable userspace to not trigger an automount by using
>>> this flag.
>>>
>>> So that's (hopefully) going to change soonish, see:
>>> http://ozlabs.org/~akpm/mmotm/broken-out/autofs-fix-at_no_automount-not-being-honored.patch
>>>
>>> The result should be that stat family calls don't trigger automounts except
>>> for fstatat(2) and statx() which will require the AT_NO_AUTOMOUNT flag.
>>>
>>
>> oooh, yes.  That's much better - thanks.
>>
>> We should make sure that change gets into the man pages...
>>
>> First however, we should probably correct the man page!
>> stat.2 says:
>>
>>
>>   NOTES
>>        On Linux, lstat() will generally not trigger  automounter
>>        action,  whereas  stat()  will  (but  see  the description of
>>        fstatat() AT_NO_AUTOMOUNT fag, above).
>>
>> which is wrong: lstat and stat treat automounts the same.
>> @Michael: do you recall why you inserted that text?  The commit message
>> in commit 1ef5b2805471 ("stat.2: Cosmetic reworking of timestamp
>> discussion in NOTES") is not very helpful.
> 
> That commit really was just cosmetic changes. The change that
> introduced the text was 82d2be3d9d66b7, based on a note from Peter
> Anvin:

Indeed, that was correct for autofs v3 but we're at autofs v5 now and
a lot has changed over time (the commit is from 2008).

All I can do is apologize for not also checking the man pages and trying
to keep them up to date.

Let's just work on making them accurate now.

> 
> [[
>     > > Additionally, you may want to make a note in the stat/lstat man page tha
> t on
>     > > Linux, lstat(2) will generally not trigger automounter action, whereas
>     > > stat(2) will.
>     >
>     > I don't understand this last piece.  Can you say some more.  (I'm not
>     > familiar with automounter details.)
> 
>     An automounter (either an explicit one, like autofs, or an implicit
>     one, such as are used by AFS or NFSv4) is something that triggers
>     a mount when something is touched.
> 
>     However, it's undesirable to automount, say, everyone's home
>     directory just because someone opened up /home in their GUI
>     browser or typed "ls -l /home".  The early automounters simply
>     didn't list the contents until you accessed it by name;
>     this is still the case when you can't enumerate a mapping
>     (say, all DNS names under /net).  However, this is extremely
>     inconvenient, too.
> 
>     The solution we ended up settling on is to create something
>     that looks like a directory (i.e. reports S_IFDIR in stat()),
>     but behaves somewhat like a symlink.  In particular, when it is
>     accessed in a way where a symlink would be dereferenced,
>     the automount triggers and the directory is mounted.  However,
>     system calls which do *not* cause a symlink to be dereferenced,
>     like lstat(), also do not cause the automounter to trigger.
>     This means that "ls -l", or a GUI file browser, can see a list
>     of directories without causing each one of them to be automounted.
> 
>             -hpa
> ]]
> 
> Cheers,
> 
> Michael
> 
>> I propose correcting to
>>
>>   NOTES:
>>       On Linux, lstat() nor stat() act as though AT_NO_AUTOMOUNT was set
>>       and will not trigger automounter action for direct automount
>>       points, though they may (prior to 4.14) for indirect automount
>>       points.
>>
>>
>> The more precise details, that automount action for indirect automount
>> points is not triggered when the 'browse' option is used, is probably
>> not necessary.
>>
>> Ian: if you agree with that text, and Michael doesn't provide alternate
>> evidence, I'll submit a formal patch for the man page.... or should we
>> just wait until the patch actually lands?
>>
>> Thanks,
>> NeilBrown
>>
> 
> 
> 

