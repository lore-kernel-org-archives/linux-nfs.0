Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f195.google.com ([209.85.213.195]:42736 "EHLO
        mail-yb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdLKGrm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 01:47:42 -0500
MIME-Version: 1.0
In-Reply-To: <151297224516.7818.4371883364929399006.stgit@noble>
References: <151297214390.7818.7216826079527521005.stgit@noble> <151297224516.7818.4371883364929399006.stgit@noble>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 11 Dec 2017 08:47:40 +0200
Message-ID: <CAOQ4uxhT_=Ot8tuCr6wAOTOZGhyR52CsqoCgJJ2Za_WUGRauvg@mail.gmail.com>
Subject: Re: [PATCH 2/4] fs/notify: don't put file handle buffer on stack.
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>,
        Pavel Emelyanov <xemul@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 8:04 AM, NeilBrown <neilb@suse.com> wrote:
> A file handle buffer is not tiny, and could need to be larger in future,
> so it isn't safe to allocate one on the stack.  Instead, we need to
> kmalloc().
>
> There is no way to return an error status from a ->show_fdinfo()
> function, so if the kmalloc fails, we silently exclude the filehandle
> from the output.  As it is at the end of line, this shouldn't
> upset parsing too much.

I think that is a bold assumption to make about parsers ;)
Anyway, the second reasoning is stronger, so may as well drop this one.
There is probably a single userspace user for this which is CRIU,
for which this fdinfo file handle was added, so you could possibly say
that this change does not upset this user (?).

> In any case, it can only fail when the
> process is being killed by the OOM killer, so the file will never
> be parsed anyway.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
