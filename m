Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46522 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab1IVW5e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 18:57:34 -0400
Received: by wwf22 with SMTP id 22so2800390wwf.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:57:33 -0700 (PDT)
In-Reply-To: <1316719228.3968.14.camel@lade.trondhjem.org>
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Sep 2011 15:57:13 -0700
Message-ID: <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, Ian Kent <raven@themaw.net>,
        David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 12:20 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> We need to audit not only NFS, but a bunch of stuff in the VFS.

Why? What has *anything*else* got to do with fixing a NFSv4 bug?

IOW, why the hell would we hold up one bugfix just because you might
want to look at something else too?

> For instance, what is the correct behaviour if I do a bind mount with
> the source being an automount directory? Currently, that doesn't set
> LOOKUP_DIRECTORY (they cant, since file may also be a mountpoint) and so
> the current behaviour means that they will fail to automount.

Umm. If there is any question at all what the correct behavior might
be, then pretty clearly the correct behavior is to let the user
decide.

And as pointed out, that's one of the *advantages* of
LOOKUP_DIRECTORY. Because it lets users decide.

Exatly because it gets automatically set for the 'slash at end of
name' case. So suddenly you can literally let the user say one or the
other by just letting the user add or remove the slash: "/mountpoint"
is not automount-followed, while "/mountpoint/" is. Nice, obvious, and
consistent interface. Which is exactly what we'd be looking for.

                 Linus
