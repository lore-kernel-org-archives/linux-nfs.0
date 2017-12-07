Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:42161 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdLGCHD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 21:07:03 -0500
MIME-Version: 1.0
In-Reply-To: <87po7zv62h.fsf@notabene.neil.brown.name>
References: <87po7zv62h.fsf@notabene.neil.brown.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 6 Dec 2017 18:07:01 -0800
Message-ID: <CA+55aFxHmVi-PuAWWrZqQzrich1QS9NR35DbdGpMts=y9uMAVA@mail.gmail.com>
Subject: Re: [PATCH] NFS: allow name_to_handle_at() to work for Amazon EFS.
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 30, 2017 at 12:56 PM, NeilBrown <neilb@suse.com> wrote:
>
> -/* limit the handle size to NFSv4 handle size now */
> -#define MAX_HANDLE_SZ 128
> +/* Must be larger than NFSv4 file handle, but small
> + * enough for an on-stack allocation. overlayfs doesn't
> + * want this too close to 255.
> + */
> +#define MAX_HANDLE_SZ 200

This really smells for so many reasons.

Also, that really is starting to be a fairly big stack allocation, and
it seems to be used in exactly one place (show_mark_fhandle), which
makes me go "why is that on the stack anyway?".

Could we just allocate a buffer at open time or something?

               Linus
