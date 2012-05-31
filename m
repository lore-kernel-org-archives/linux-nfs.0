Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34400 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab2EaWPT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 18:15:19 -0400
MIME-Version: 1.0
In-Reply-To: <20120531205300.GG25955@fieldses.org>
References: <20120531182457.GB25955@fieldses.org> <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
 <20120531200138.GD25955@fieldses.org> <CA+55aFyuHz5Vn8G_kpKgnSStX0s125gwwQij2KXmnhfwaajhkg@mail.gmail.com>
 <20120531205300.GG25955@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 May 2012 15:14:57 -0700
Message-ID: <CA+55aFxY+WJmMu=1Wvdh24kK0JWEuQ1vwcqZdaNDbp1_wUsZ4A@mail.gmail.com>
Subject: Re: nfsd changes for 3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 1:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, May 31, 2012 at 01:17:26PM -0700, Linus Torvalds wrote:
>
> Uh, that means ditching some work in my public git tree.  Which I
> haven't rebased in years.  So, a stupid process question; would you
> rather I:
>
>        - continue to be strict about rebasing and apply a bunch of
>          reverts?
>        - ditch it and start over?

I think in this case rebasing is the right thing to do.

I hate rebasing, but what I hate about it is how people who use it as
a development model cause problems for anybody else. I don't think it
will cause problems in this particular case, but if somebody hollers,
let me know.

>>  Making
>> it an rwsem might help readdir a tiny amount, but I suspect people
>> actually depend on the mutex in readdir right now.
>
> Al called this all "highly non-trivial":
>
>        http://marc.info/?l=linux-fsdevel&m=132726495726326&w=2
>
> I don't know who'd have the cycles.

I agree, it's a rats nest.

Doing lookups in particular is ridiculously single-threaded for almost
no good reason, though (and create is just a special case of that). It
*should* be possible that push the i_mutex down into the filesystem,
if we just created some fake dentry (with the appropriate support for
lookup to stall on it) to make sure that lookups of the same *name*
are serialized.

At that point, each filesystem could decide that they don't need the
i_mutex for the whole thing.

Maybe.

And readdir() could be done mostly mechanically by changing i_mutex
into an rwsem, making all lockers use a write lock, and pushing the
locking down from the caller into the filesystem for ->readdir().
Again, at that point, I suspect many filesystems could do with much
less locking.

But yeah, it's all nasty. Even the purely mechanical part of changing
i_mutex to an rwsem would not only be a *huge* and painful patch, it
would hit things like lockdep issues too (we don't support the nesting
thing for rwsem annotations, afaik).

So nobody has really done it, and it's so painful that maybe nobody
will. There are loads that hit this serialization point, but they are
*fairly* rare and specialized.

                Linus
