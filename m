From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Tue, 10 Feb 2009 12:12:32 -0500
Message-ID: <C1261653-18B9-4E6F-A2A1-A1BEC957324B@oracle.com>
References: <20090206.140714.201930500.davem@davemloft.net> <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com> <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi> <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi> <20090208052543.GA20689@fieldses.org> <9A7C762F-D2D4-4248-B18A-5FAB973D22A6@oracle.com> <Pine.LNX.4.64.0902101417550.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Trond Myklebust <trond@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:16652 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbZBJRNO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2009 12:13:14 -0500
In-Reply-To: <Pine.LNX.4.64.0902101417550.31742-x/A8LOkYjdVsRR2hCrRKtT03IgOmwywn@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ilpo-

On Feb 10, 2009, at 8:12 AM, Ilpo J=E4rvinen wrote:
> On Mon, 9 Feb 2009, Chuck Lever wrote:
>
>> On Feb 8, 2009, at 12:25 AM, J. Bruce Fields wrote:
>>> On Sat, Feb 07, 2009 at 06:56:03PM +0200, Ilpo J=E4rvinen wrote:
>>>> I personally think that people were honestly just mislead to =20
>>>> think that
>>>> diff-funcs output is part of the patch
>>>
>>> Yes, exactly, in my case, that's all it was--the "diff" I thought =20
>>> I saw
>>> in my 2-second skim looked odd, and I figured a comment might have
>>> gotten dropped off in the process of replying and adding cc's--=20
>>> hence the
>>> original question.
>>
>> I apologize if my request for "English" seemed Anglo-centric.  What =
=20
>> I intended
>> was "non-machine-generated" and expressed in the natural language =20
>> that is
>> usual for Linux kernel patch descriptions, which appears to be =20
>> English.
>
> ...I still argue that if title gives the same information as that
> sentence would, the sentence is optional.

I'm OK with that.  In the original patch, I think both were somewhat =20
difficult to parse.  My request is to try harder next time to make =20
them clear.  It sounds like we agree here.

> Some patches don't even have
> patch description beyond title and there's very little problem with =20
> that.
> As I admitted earlier the title wasn't as good as it should have =20
> (and I
> even sent a followup to please all including even the in body sentenc=
e
> plus the fixed title). Not that I find the title really a problem to =
=20
> sane
> people who understand that code-duplication is bad and getting rid =20
> of it
> is what one should do in general, as long as it's possible without =20
> making
> a mess out of it.

Like all things software, absolute statements are usually always =20
proven incorrect (eg "goto is spawn of the devil and should never be =20
used").  Code duplication is _usually_ bad.  Sometimes there is a =20
reason for it.  We want to avoid a knee-jerk response of eliminating =20
it wherever we find it, without another thought.

>> I agree with you that the diff output in the patch description was =20
>> confusing,
>> and yes, after Dave's first comment I understood what the =20
>> description meant.
>> I believe patch authors owe it to maintainers, who have dozens of =20
>> patches to
>> review a day, to keep it as simple and easy as possible.  I have =20
>> tried to work
>> with individual maintainers where possible to improve the =20
>> legibility of my
>> patches, though at times I have fallen short.
>>
>> Although interesting, the tool output doesn't seem necessary to =20
>> justify the
>> proposed change.
>
> I don't understand why a tool output cannot "say" the same as some =20
> English
> sentence...

It can.  But it's interesting to observe that the point of your =20
proposed change was to reduce lines of code and code obscurity.  Your =20
description, however, was much longer and more obscure than it needed =20
to be.  :-)

I was too harsh to ask for no machine-generated patch descriptions.  =20
The point is, is the description meaningful and concise?

> And if a proof that the code blocks that were merged were
> infact identical (instead of having some hard to spot difference) =20
> doesn't
> seem like useful information to reviewer I don't really know what to =
=20
> say.

Verification of your patch is different than justification.  But =20
that's a minor point.

>> In addition to crafting a legible description, my suggestions were =20
>> about
>> cc'ing the proper mailing list, and routing this patch directly to =20
>> the sunrpc
>> kernel maintainers in the first place, all of which are listed =20
>> within easy
>> reach in MAINTAINERS.
>
> Please note that I couldn't guess that I'd have to look for another =20
> entry
> after first SUNRPC entry in the MAINTAINERS. So asking outsider to =20
> know
> who is who in sunrpc realm is not very likely to be a practical
> requirement either. And even to add into confusion the latest commits
> in that particular directory had the last S-o-B line as Bruce's. How =
=20
> could
> I have guessed? Forgetting to lookup the address from MAINTAINERS =20
> into the
> first mail is something which just happened and I'm certainly guilty =
=20
> to
> that :-).

Yes, we should fix the SUNRPC entries in MAINTAINERS.

> ...I've had enough down turning experiences with random dev lists =20
> listed
> in the MAINTAINERS (mostly spammy subsriber only ones, nearly infinit=
e
> response time, etc things) that I mostly ignore them nowadays though =
=20
> this
> time it would have been vger list so no subscription required madness=
=2E
> Instead I either select lkml or netdev, this time netdev because of
> the obvious presence under net/ hierarcy.

My experience is usually the opposite.  I post a patch directly to a =20
maintainer and get a "please use such-and-such list" response.  The =20
exception is usually very specific device drivers.

But you're right, it would be nice to have some consistency here =20
across the kernel.

>> But I wonder how we ended up with these two copies of the same =20
>> logic.  It may
>> be that at some point in the past we had more different logic in =20
>> the two
>> write_space functions, but I suppose we can split it out again if =20
>> we ever need
>> to.  Thinking aloud, at some point we may have lost a little =20
>> history here, or
>> we may have perhaps lost any implicit operational dependencies on =20
>> other parts
>> of xprtsock.c (like the TCP state logic) that are not expressed in =20
>> the source
>> code or comments.
>
> Well, this kind of thinking is beyond me and requires more knowledge =
=20
> about
> internals of the code.

My concern with immediately accepting a patch that appears to be =20
solely machine-generated is exactly this.  The submission didn't leave =
=20
me with the impression that there was a human who had taken the time =20
to understand history (git log/annotate) and how the code works, what =20
the source code was attempting to express, or whether the resulting =20
patch was even tested.  Usually you can glean a bit of this from a =20
lengthier patch description.

Yes, yours was a simple and proper change in the end, but still.  =20
Given the long "dialog" just had on lkml about compiler (machine-=20
generated) optimizations, I think we would all be just a little =20
skeptical (or perhaps careful) about such automated transformations.

> IMHO, this kind of speculation changes nothing
> really, and besides the functions _were_ different to begin with as =20
> was
> proven in the patch description :-). ...Would they have been fully
> identical you would have seen a bit different patch ;-).
>
> If you think there's something wrong, please fix, you're free to do =20
> so,
> I don't understand enough. But we don't keep all those #if 0 blocks
> around either just because somebody thinks that something will get
> implemented one day (not that you directly made such assertion, =20
> probably
> saying mildy the opposite instead). Ironically, you would have been
> perfectly happy with the particular functions unless a cleanup patch
> against them gets made... :-)

You are correct, the analysis doesn't change anything, but the =20
analysis is worth at least noting during review.  It helps us =20
understand where we have to make the code more clear.

The question is whether the code itself documents dependencies on =20
other parts of the code, whether such dependencies are only documented =
=20
by comments, or whether it is entirely implicit and up to the folks =20
who work on it to understand and remember. This is usually only an =20
issue when someone who has never worked on the code submits a patch.

The goal of open source code is to facilitate other folks modifying =20
our code.  For open source especially it is a larger issue than simple =
=20
code maintenance.  It is not enough for open source code simply to =20
work.  If people outside our team (or outside the larger Linux =20
community) can't easily understand the important features of our open =20
source code, then we've still failed, even if the legal barriers have =20
been lifted by the GPL.

Thus I'm especially sensitive to areas where our source code does not =20
express itself well to folks who are not familiar.  We want to invite =20
wider review, and that's simply not possible if nobody understands =20
this code base but ourselves.

>> The newly shared code appears to be socket-specific, so it does not
>> belong in the shared function we already have, xprt_write_space(), =20
>> which
>> is meant to be transport-generic.
>
> IMHO, this is the most useful response so far! :-) Usually the hardes=
t
> obstacles I face with non-familiar code is its structure and naming.


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com