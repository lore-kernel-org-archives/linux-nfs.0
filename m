From: Chuck Lever <chuck.lever-veTT2BtV2gDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] make capabilities support optional
Date: Mon, 26 Apr 2010 14:03:04 -0400
Message-ID: <4BD5D558.80509@oracle.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <201004240042.27705.vapier@gentoo.org> <4BD5AD68.6010200@oracle.com> <201004261246.59497.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57087 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab0DZSET (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Apr 2010 14:04:19 -0400
In-Reply-To: <201004261246.59497.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/26/2010 12:46 PM, Mike Frysinger wrote:
> On Monday 26 April 2010 11:12:40 Chuck Lever wrote:

>> However, as soon as a distributor sends patches (rather than, say,
>> > simply posting a bug report), you become a developer, and are thus
>> > obligated to act like one by reviewing the content of the local source
>> > management system before making changes, and by posting your patches to
>> > this list for us to review.
> expecting anyone who sends a patch to be fully versed in NFS internals and the
> full history is completely unreasonable.

I didn't say "anyone."  We were specifically discussing distributors, 
and specifically distributors that regularly send patches.

> i'm not saying people shouldnt do a
> little research here, but your position appears to be poor: if you want nfs-
> utils info, regardless of who you are, you must go to the scm source and dive
> through mounds of history and divine the answer yourself.

That's not my position at all.  After you claimed the ChangeLog is not 
kept updated, I merely observed that ChangeLog information is available 
in the git log, and on the web.  Asking the maintainer to copy the git 
log into the ChangeLog during every release for tarball users is 
perfectly reasonable.

>>> > > people attempting to package nfs-
>>> > > utils shouldnt need to crawl these backends to try and glean info
>>> > > themselves.
>> >
>> > As I pointed out, you don't need git on your local system to look at
>> > this metadata: it's already available on linux-nfs.org if you have a web
>> > browser.
> the interface is irrelevant -- you're still saying people have to dig through
> piles of information that is not relevant to packaging.

Have you looked at the output of git log?  It's basically the same 
content as the ChangeLog file, up to 2006.  It's exactly the information 
you were asking for.

>>>> > >> Patches are posted on this mailing list for review before they are
>>>> > >> committed.  Anyone has a chance to object, comment, or suggest a simpler
>>>> > >> way to do things.
>>> > >
>>> > > again, this isnt relevant to distro maintainers.
>> >
>> > How are nfs-utils developers supposed to know of a problem if distro
>> > maintainers don't tell us?
> you're saying distro maintainers are expected to subscribe to the development
> list and review patches ?  that's bunk.

Anyone who is a regular contributor should subscribe to the mailing list 
and review patches they care about to stay up to date.  If you happen to 
choose not to do that, then you really shouldn't be surprised when asked 
to provide more detail on a patch, or to follow the normal patch 
submission rules.

If you are a distro maintainer, you can either report problems to us, 
ask for new features, or post patches.  As a maintainer, if you want to 
post a lot of patches, you should follow the patch submission rules the 
rest of us are beholden to.  That's only fair to the rest of us, and it 
means we can do a better job reviewing everyone's changes.  How is that 
unreasonable?

>> I claim that "things" did not work.  When statd was shut down, it left a
>> dangling rpcbind registration, and that's a bug in all environments.
>
> perhaps, but some people are ok with that.  considering that has always been
> the behavior then, ive never seen one complaint about this via Gentoo.  clear
> documentation explaining the tradeoffs would be sufficient and there are
> plenty of systems where this bug is meaningless.  on my nfs servers, either
> everything is up, or everything is down.  there is no "in between" where some
> services are left running while others are not.

My point is that explanation should have been included in the patch 
description at the very beginning, because you should realize that not 
everyone else is served by your changes, either, and many of us don't 
run Gentoo and would not have known the details of your server 
configuration.

>>>> So, why do you want to make libcap optional?
>>>
>>> there are plenty of systems where privileges are meaningless (like
>>> embedded) and so libcap is pure cruft.
>>
>> In that case, your patch description should explain that so we can
>> understand why you've added another --enable switch.  These switches are
>> overused, so a clear rationalization is needed when adding yet another.
>>
>> By and large, those who participate on this list felt that "--enable"
>> flags are less desirable than automatic feature checking.  Your view is
>> novel, I think.
>
> the view of distro maintainers in this regard matters more than that of
> developers.  the configure script is designed for the end packagers to use,
> not developers.  my position here is not unique to me or something i pulled
> out of nowhere.

It may be true that maintainers care more about the configure script 
than developers, but none of those maintainers were here to express that 
opinion or comment on any patches that changed the configure script.

Basically, how are we supposed to know your opinions if you refuse to 
participate?

-- 
chuck[dot]lever[at]oracle[dot]com
