Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51180 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1IZUtR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 16:49:17 -0400
Received: by eya28 with SMTP id 28so3981887eya.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 13:49:16 -0700 (PDT)
In-Reply-To: <1317013864.3187.81.camel@perseus.themaw.net>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
 <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
 <1316827854.3346.154.camel@perseus.themaw.net> <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
 <20110924073610.4b045189@tlielax.poochiereds.net> <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com>
 <1317013864.3187.81.camel@perseus.themaw.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2011 13:48:56 -0700
Message-ID: <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Ian Kent <raven@themaw.net>
Cc: Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Sep 25, 2011 at 10:11 PM, Ian Kent <raven@themaw.net> wrote:
> On Sat, 2011-09-24 at 08:56 -0700, Linus Torvalds wrote:
>>
>>    Now, if the auto-mounting actually have a whole different kind of
>> file type for an unmounted entry (not necessarily S_IFLNK - I could
>> well imagine a new implementation just saying "we'll return the new
>> S_IFAUTO marker"), then using lstat/stat the same way as for symlinks
>> would make sense. And maybe that would have been a good thing: then
>> "ls" could show those things nicely as "unmounted automount points".
>
> And that's the heart of it.
>
> We added VFS automounting but somehow we managed to retain the "second
> class VFS citizen" nature historic with automouning.

Well, realistically, we had to.

And we *still* have to.

There is absolutely no way in hell that we will teach user space about
a new "unmounted automount" inode type.

The is a metric sh*tload of programs that know about and use S_ISDIR()
and brethren. We realistically can't just break them because it would
be nice. The annoyance factor is too high, but more importantly, the
*advantage* is too low.

automounts just simply aren't important enough to warrant it. Most
people aren't aware of them, even if they are on a system where they
are in use. And that's relatively rare to begin with.

So I put it out as a "if this was a new design, and we didn't have any
existing code issues, it *should* possibly have been done that way".
But it was purely theoretical, because whil eI think it would be a
"clean solution", I seriously don't think it's a *realistic* solution
these days any more.

Sure, we could do it with a mount flag and let people try to migrate
if they wanted to, but realistically, simplicity is a bigger win than
"hey, give people the option to do it". Especially since there isn't
any real clamor from actual users for this - it's purely a theoretical
'wouldn't it have been nice if..' argument.

> OTOH, due to the fact we have such controversy, maybe that's a case for
> doing this from the outset. Thoughts? Dare I say, can we reach agreement
> on it?

Seriously, I have seen absolutely *zero* arguments for just trying to
go with the "keep it simple, stupid" approach.

What are the downsides of just adding the one or two
LOOKUP_DIRECTORY/LOOKUP_OPEN flags?

Nobody has even *mentioned* any downsides. So I don't think this is
controversial, and I don't understand why you consider it
controversial.

                     Linus
