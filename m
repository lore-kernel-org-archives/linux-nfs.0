Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50125 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979Ab1I0D6U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 23:58:20 -0400
Received: by wyg34 with SMTP id 34so6679517wyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 20:58:19 -0700 (PDT)
In-Reply-To: <1317085155.21770.17.camel@lade.trondhjem.org>
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
 <1317013864.3187.81.camel@perseus.themaw.net> <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com>
 <1317071626.19951.8.camel@lade.trondhjem.org> <CA+55aFzWCZQjWMcxg16yMUoLr-mEPuXzAFgv49LU4hCn+=rbwQ@mail.gmail.com>
 <1317072718.19951.13.camel@lade.trondhjem.org> <CA+55aFzaScGiKmsSrgXivoUPw4xHjKobsB4VquuEu1fG=7R+wA@mail.gmail.com>
 <1317076424.19951.32.camel@lade.trondhjem.org> <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
 <1317078563.21770.8.camel@lade.trondhjem.org> <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
 <1317085155.21770.17.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2011 20:57:59 -0700
Message-ID: <CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 26, 2011 at 5:59 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> diff --git a/fs/namei.c b/fs/namei.c
> index f478836..5b1608f 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -724,25 +724,9 @@ static int follow_automount(struct path *path, unsigned flags,
>        /* We don't want to mount if someone supplied AT_NO_AUTOMOUNT
>         * and this is the terminal part of the path.
>         */
> -       if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
> +       if (!(flags & LOOKUP_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
>                return -EISDIR; /* we actually want to stop here */
>
> -       /* We don't want to mount if someone's just doing a stat -
> -        * unless they're stat'ing a directory and appended a '/' to
> -        * the name.
> -        *
> -        * We do, however, want to mount if someone wants to open or
> -        * create a file of any type under the mountpoint, wants to
> -        * traverse through the mountpoint or wants to open the
> -        * mounted directory.  Also, autofs may mark negative dentries
> -        * as being automount points.  These will need the attentions
> -        * of the daemon to instantiate them before they can be used.
> -        */
> -       if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
> -                    LOOKUP_OPEN | LOOKUP_CREATE)) &&
> -           path->dentry->d_inode)
> -               return -EISDIR;
> -
>        current->total_link_count++;
>        if (current->total_link_count >= 40)
>                return -ELOOP;

So I think that dropping the d_inode test is wrong, even if we were to
at some point decide that we want explicit LOOKUP_AUTOMOUNT
everywhere.

Of course, it may be that the comment is wrong. But assuming the
comment is correct, then it's really the test above that is
fundamentally wrong.

Ian may know the answer. Ian?

Regardless, I applied the minimal and obviously safe part of the
patch, so hopefully we have no actual regressions left in this area,
and it's just a discussion about possible future cleanups.

                    Linus
