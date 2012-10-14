Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:42090 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343Ab2JNUz7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 16:55:59 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121014193905.GC32420@fieldses.org>
Date: Sun, 14 Oct 2012 16:55:44 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Larry McVoy <lm@bitmover.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2CAF58DA-E925-47F5-B1FD-DC86EF565125@oracle.com>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com> <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com> <20121014193905.GC32420@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 14, 2012, at 3:39 PM, Bruce Fields <bfields@fieldses.org> wrote:

> On Sat, Oct 13, 2012 at 02:28:39AM +0000, Myklebust, Trond wrote:
>> On Sat, 2012-10-13 at 10:02 +0900, Linus Torvalds wrote:
>>> On Sat, Oct 13, 2012 at 9:21 AM, Larry McVoy <lm@bitmover.com> wrote:
>>>> 
>>>> Ahh, I've been away from the kernel too long.  I miss that delicate
>>>> management touch.
>>> 
>>> "Delicate Management Touch" is my middle name.
>>> 
>>>> pics of the stack trace at http://www.mcvoy.com/lm/nfs-lock-crash
>>> 
>>> Ok, that's just the normal kind of random left-over oopses due to
>>> subsequent problems of a BUG_ON(). Looks like the watchdog timer ends
>>> up being unhappy, almost certainly simply because some core filesystem
>>> spinlock not being released.
>>> 
>>> It used to be (a long long time ago) that we'd recover fairly
>>> gracefully from BUG_ON()'s - back when the main shared lock we had was
>>> the kernel lock, and we had a single per-process kernel lock counter.
>>> So when we killed the process, we could clean that single lock up.
>>> 
>>> These days, if some process dies in random kernel code due to a
>>> BUG_ON() or a wild pointer or similar, and we kill it, we are seldom
>>> able to do so cleanly. So the best we can hope for is that it happened
>>> in some context where it held no (important) locks. Which is rare. So
>>> BUG_ON()'s are often fatal, and there are these kinds of downstream
>>> problems where they get flushed off the screen by subsequent issues...
>> 
>> If that code is being called under a lock, then we have other problems.
>> It is standard XDR code: it should always be called from an ordinary
>> process context with no special locks being held by the callers.
>> 
>>> Ho humm. Google doesn't seem to be finding any similar bug-reports, so
>>> unless Bruce or Trond go "Ahh, I know what it's about", I do think we
>>> would want to get as much more info as possible.
>> 
>> Never seen it before, and I see no reason why it should drag the entire
>> box down with it. It is part of the NLM server's callback code, so there
>> is no chance of it being called as part of a memory reclaim or anything
>> similarly sensitive to the rest of the box.
>> 
>> Are we sure that this BUG_ON() really is top of the chain of Oopses
>> here? All I can see it doing is crashing the lockd server process,
> 
> Can't it be called from the rpciod workqueue?  I'm not sure what happens
> when we hit a BUG there.
> 
> It looks like a bunch of BUG_ON's got added with an xdr rewrite in
> 2b061f9ef216b6d229b06267f188167fd6ab3d9b.  Maybe Chuck or someone should
> do a 'git grep BUG fs/lockd' and figure out what those should be
> instead?

In my own defense, I also removed a lot of BUG_ON's in that series.

This particular one was added because "getting the endianness of the reply status code wrong" turns out to be a fairly easy problem to introduce without noticing it when making changes to NFSD or lockd server.  There is a set of status codes that are already XDR-encoded, and a set that are not.  A person can easily choose the wrong one to use.

I expected that such problems would be caught quickly during development if we actually checked for it in the XDR layer and barked if it is incorrect.  I assumed therefore that these assertions would not be encountered by the time code gets in front of users.

I think range-check assertions in the XDR code are valuable.  Whether they are done via BUG_ON or WARN_ON_ONCE is a matter of priority: BUG_ON forces you to notice the problem and address it, while WARN_ON allows the system to continue operating with the bug, but the bug can be ignored (or the WARN_ON simply removed because it is annoying).


> And I need to do the same for nfsd; I've been sloppy about using them as
> asserts.
> 
> --b.
> 
>> which
>> will seriously inconvenience all the NFS clients trying to do locking,
>> but it shouldn't be affecting the swapper process as we're seeing in the
>> Oops screenshots.
>> If it really is the first thing to Oops, then the only thing I can think
>> of there that would trigger other Oopses would be a memory corruption
>> (use after free or some such thing?). Perhaps Larry could try turning on
>> some of the less intrusive slab debugging options?
>> 
>>> Doing a kernel compile really isn't that bad. The only nasty piece is
>>> getting the kernel configuration right, but you can just use the
>>> distro config. It's much too big and contains everything, but it will
>>> work, and gets you as similar a kernel as possible. Of course, Ubuntu
>>> has made installing your own kernel stupidly complicated (you have to
>>> build a package and install it using the package manager), but while
>>> it's an annoying extra step or two (compared to just doing a "make
>>> modules_install install"), it's not rocket surgery. There's a few help
>>> pages for it:
>>> 
>>>    https://help.ubuntu.com/community/Kernel/Compile
>>> 
>>> being the first one.
>>> 
>>>                Linus
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



