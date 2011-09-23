Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687Ab1IWQxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:53:54 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFwt96i3k_UJREQU18xq=tRqRZGP8NhRJfbOaipqiVKnGQ@mail.gmail.com>
References: <CA+55aFwt96i3k_UJREQU18xq=tRqRZGP8NhRJfbOaipqiVKnGQ@mail.gmail.com> <20110923162438.13574.52985.stgit@warthog.procyon.org.uk> <20110923162451.13574.33960.stgit@warthog.procyon.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, miklos@szeredi.hu, raven@themaw.net,
        viro@zeniv.linux.org.uk, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH 1/7] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
Date: Fri, 23 Sep 2011 17:53:07 +0100
Message-ID: <14116.1316796787@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> > The problem with this is that this breaks nfs_follow_remote_path() used by
> > NFS4 to find the root object to mount for the mount() syscall.
> 
> The above message is basically dishonest.
>
> That's not AT ALL the problem.

Dishonest?  In what way am I lying about it?  After I wrote that line I went
on to explain how to reproduce it and what was happening.

That was the problem addressed by that patch.  I was including it as a means
to fix the NFS regression and as I pointed out in the cover note, it can be
actually be dropped if one of the further patches is introduced.

> That problem could have been fixed with a one-liner patch that already exists.

Which is fragile.

> This whole patch-series looks like just excuses for doing stupid things.

I believe you to be wrong.

Anyway, if I'm going to be accused of dishonesty, I see no further reason to
continuing in this discussion.

Have a good weekend.

David
