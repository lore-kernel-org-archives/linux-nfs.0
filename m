Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:47410 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964860Ab2EaURs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 16:17:48 -0400
MIME-Version: 1.0
In-Reply-To: <20120531200138.GD25955@fieldses.org>
References: <20120531182457.GB25955@fieldses.org> <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
 <20120531200138.GD25955@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 May 2012 13:17:26 -0700
Message-ID: <CA+55aFyuHz5Vn8G_kpKgnSStX0s125gwwQij2KXmnhfwaajhkg@mail.gmail.com>
Subject: Re: nfsd changes for 3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 1:01 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Right.  By default it's 90 seconds before we'll give up on the client.

So a slightly buggy client can basically DoS the server by getting a
delegation and then crashing or something. Everybody else that tries
to read that directory (not that file) will be dead in the water.
Definitely not good.

> I hate that too, and originally tried to avoid it with something like:
>
>        retry:
>                acquire locks
>                lookup inode
>                ret = try_to_break_deleg(inode);
>                if (ret)
>                        drop locks
>                        really_break_deleg(inode);
>                        goto retry;
>                ... do the real work ...
>                drop locks
>
> I felt like I was making already complicated code logic like rename's
> even harder to follow.

I do think it's the only thing we can reasonably do. I'd love to have
some kind of per-dentry lock for unlink/rename, but we don't.
Long-term, we really do need to do something about the directory
locking, though, because it's also a huge problem for readdir()
concurrency. Or at least it used to be (samba in particular). Making
it an rwsem might help readdir a tiny amount, but I suspect people
actually depend on the mutex in readdir right now.

> And those operations don't really know the inode till they acquire the
> locks, so in pathological cases that could continue forever.

I suspect at some point you just have to say "screw it".

               Linus
