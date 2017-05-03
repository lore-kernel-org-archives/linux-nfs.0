Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751813AbdECShn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 14:37:43 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1493835998.22125.15.camel@perches.com>
References: <1493835998.22125.15.camel@perches.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <1493835238.3180.7.camel@poochiereds.net>
To: Joe Perches <joe@perches.com>
Cc: dhowells@redhat.com, Jeff Layton <jlayton@poochiereds.net>,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 May 2017 19:37:41 +0100
Message-ID: <4597.1493836661@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> krealloc would probably be more efficient and possible
> readable as likely there's already padding in the original
> allocation.

The problem is if krealloc() fails: you've lost all those pointers to things
you then need to free.

> Are there no locking constraints?

Generally, no, not until you do the ->mount() op.  Also remounting needs a
lock, but that's already done with the sb->s_umount lock.

However, that said, if you do:

	fd = fsopen("foofs");
	write(fd, "o foo=bar", ...);
	fsmount(fd, "/foo");

then the fsmount() and write() calls have to lock against other fsmount() and
write() calls.  I use the inode lock for this.  [Note that it probably should
be interruptible rather than just killable, but there's no primitive for that
as yet].

David
