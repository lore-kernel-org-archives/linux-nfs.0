From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Mon, 9 Feb 2009 12:29:30 -0500
Message-ID: <9A7C762F-D2D4-4248-B18A-5FAB973D22A6@oracle.com>
References: <20090206.140714.201930500.davem@davemloft.net> <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com> <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi> <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi> <20090208052543.GA20689@fieldses.org>
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
Received: from rcsinet13.oracle.com ([148.87.113.125]:37911 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756848AbZBIRbI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 12:31:08 -0500
In-Reply-To: <20090208052543.GA20689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 8, 2009, at 12:25 AM, J. Bruce Fields wrote:
> On Sat, Feb 07, 2009 at 06:56:03PM +0200, Ilpo J=E4rvinen wrote:
>> I personally think that people were honestly just mislead to think =20
>> that
>> diff-funcs output is part of the patch
>
> Yes, exactly, in my case, that's all it was--the "diff" I thought I =20
> saw
> in my 2-second skim looked odd, and I figured a comment might have
> gotten dropped off in the process of replying and adding cc's--hence =
=20
> the
> original question.

I apologize if my request for "English" seemed Anglo-centric.  What I =20
intended was "non-machine-generated" and expressed in the natural =20
language that is usual for Linux kernel patch descriptions, which =20
appears to be English.

Not being a maintainer myself, I can't enforce any requirement here.  =20
I was simply suggesting ways to help the patch make its way =20
expediently to reviewers and people who can get it into the kernel.

I agree with you that the diff output in the patch description was =20
confusing, and yes, after Dave's first comment I understood what the =20
description meant.  I believe patch authors owe it to maintainers, who =
=20
have dozens of patches to review a day, to keep it as simple and easy =20
as possible.  I have tried to work with individual maintainers where =20
possible to improve the legibility of my patches, though at times I =20
have fallen short.

Although interesting, the tool output doesn't seem necessary to =20
justify the proposed change.  A single sentence, as Trond suggested, =20
would have been far more concise.  And Bruce's recommendations for =20
setting off machine-generated content in a patch description are cogent=
=2E

In addition to crafting a legible description, my suggestions were =20
about cc'ing the proper mailing list, and routing this patch directly =20
to the sunrpc kernel maintainers in the first place, all of which are =20
listed within easy reach in MAINTAINERS.  A handful of us on linux-nfs =
=20
happen to read netdev, but not all of us.  We do try to stick to a =20
fair review process here, which includes archiving the patch and =20
reviewer comments via linux-nfs-u79uwXL29TaiAVqoAR/hOA@public.gmane.org

J. Bruce Fields continues:
> Anyway, the patch looks obviously fine to me[.]

I don't have an immediate problem with the patch's content either, as =20
long as it has been tested and does not introduce any new sparse or =20
compiler warnings.  I'm all for the intelligent elimination of gotos =20
and duplicated code.

But I wonder how we ended up with these two copies of the same logic.  =
=20
It may be that at some point in the past we had more different logic =20
in the two write_space functions, but I suppose we can split it out =20
again if we ever need to.  Thinking aloud, at some point we may have =20
lost a little history here, or we may have perhaps lost any implicit =20
operational dependencies on other parts of xprtsock.c (like the TCP =20
state logic) that are not expressed in the source code or comments.

The newly shared code appears to be socket-specific, so it does not =20
belong in the shared function we already have, xprt_write_space(), =20
which is meant to be transport-generic.

Acked-by: Chuck Lever <chuck.lever@oracle.com>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com