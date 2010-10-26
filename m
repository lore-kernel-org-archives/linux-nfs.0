Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43290 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932558Ab0JZRkJ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 13:40:09 -0400
In-Reply-To: <20101026172250.GB526@fieldses.org>
References: <20101026164549.GD19445@fieldses.org> <20101026172250.GB526@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 26 Oct 2010 10:39:41 -0700
Message-ID: <AANLkTi=emsmLNFSV=j48d37JQxecQmNGZwY9OYdoKjeS@mail.gmail.com>
Subject: Re: nfsd changes for 2.6.37
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 10:22 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Oct 26, 2010 at 12:45:50PM -0400, J. Bruce Fields wrote:
>> Please pull the following nfsd updates from the for-2.6.37 branch at:
>>
>>       git://linux-nfs.org/~bfields/linux.git for-2.6.37
>
> By the way, apologies, I see there's a conflict with upstream--looks
> obvious (conflicting appends to
> Documentation/feature-removal-schedule.txt), but I'm happy to fix it up
> and add a merge commit on that branch if it saves you time.

No, as mentioned elsewhere in other similar threads, I actually prefer
people _not_ to pre-merge. It results in significantly uglier history
(especially since I tend to merge a lot during the merge window, so
your pre-merge will not obviate my later merge, because my tree will
have moved forward), since criss-crossing merges really end up making
the gitk graph rather harder to read.

But to me personally, the "uglier history" is actually the secondary
concern - I much prefer seeing the conflicts rather than have them
hidden from me by a pre-merge. Now, for something like
feature-removal-schedule.txt, the conflicts are usually not
interesting from a development angle, but on the other hand they are
also so trivial that they don't inconvenience me and I'd rather just
do them myself and avoid the history pollution of extra merges. But
then when the conflicts get more interesting and touching actual code,
I end up spending more time at them, but I _still_ want to see them,
because they inform me where different people ended up stepping on
each others code.

And those conflicts are interesting to me as a top-level maintainer,
because it either shows code organizational problems, or it shows
where people really were touching the same code for good reasons. And
regardless of the reason for the conflict, I like being aware of it,
because merges like that are often indicative of "this might cause
issues".

If the merge conflict ends up being so involved that I can't resolve
it, I'll push back an email saying so. It happens, but not very often
I'm happy to say. Our source organization is good enough that we
seldom have really complicated merges.

One thing that some maintainers do is to do a private pre-merge just
to see if there are problems (and because it can give a more accurate
diffstat in the presense of criss-cross merges or duplicate changes)
and then if that merge is complex, expose both an unmerged branch and
a "here, if you have issues, this is how I resolved the merge" branch.
What I usually end up doing in that case is actually to do the merge
myself anyway (because of all the issues above - I just want to know
what is going on), but then also compare my end result with the
maintainer pre-merge result, just to verify.

But even that kind of "both non-merged and pre-merged" pull requests
should be reserved just for cases where there really was a somewhat
involved conflict. For trivial conflicts like a feature removal doc
clash, don't even bother.  I do several trivial merges a day, it's
normal and it doesn't really take me any appreciable extra time. Git
command line of the day:

  git log --oneline v2.6.36.. --merges --author=Torvalds --grep=onflict

to see at least a partial list of the trivial conflicts I've done in
just this merge window. It's 3-4 per day, it's perfectly normal.

                                Linus
