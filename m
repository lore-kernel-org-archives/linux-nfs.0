Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:55599 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751174AbdKIUGm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 15:06:42 -0500
MIME-Version: 1.0
In-Reply-To: <151021202428.22743.11071460838655377498.stgit@noble>
References: <151021179901.22743.15252956909042161062.stgit@noble> <151021202428.22743.11071460838655377498.stgit@noble>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 9 Nov 2017 12:06:41 -0800
Message-ID: <CA+55aFx=-BeJbptHctGF1TrDYV9q7Oc2a_7ALsJ6dAHpWffT9A@mail.gmail.com>
Subject: Re: [PATCH 3/3] VFS / autofs4: remove kern_path_mountpoint()
To: NeilBrown <neilb@suse.com>
Cc: Ian Kent <ikent@redhat.com>, Latchesar Ionkov <lucho@ionkov.net>,
        Jeff Layton <jlayton@redhat.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        autofs mailing list <autofs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        V9FS Developers <v9fs-developer@lists.sourceforge.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 8, 2017 at 11:20 PM, NeilBrown <neilb@suse.com> wrote:
> ---
>  fs/autofs4/dev-ioctl.c |    5 +-
>  fs/namei.c             |  129 ------------------------------------------------
>  include/linux/namei.h  |    1
>  3 files changed, 2 insertions(+), 133 deletions(-)

This one certainly looks lovely, and the rationale all looks solid.

Al, mind taking a look?

             Linus
