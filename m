Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0210.hostedemail.com ([216.40.44.210]:46897 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751494AbdECSnw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 14:43:52 -0400
Message-ID: <1493837027.22125.17.camel@perches.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Joe Perches <joe@perches.com>
To: David Howells <dhowells@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Date: Wed, 03 May 2017 11:43:47 -0700
In-Reply-To: <4597.1493836661@warthog.procyon.org.uk>
References: <1493835998.22125.15.camel@perches.com>
         <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <1493835238.3180.7.camel@poochiereds.net>
         <4597.1493836661@warthog.procyon.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-03 at 19:37 +0100, David Howells wrote:
> Joe Perches <joe@perches.com> wrote:
> 
> > krealloc would probably be more efficient and possible
> > readable as likely there's already padding in the original
> > allocation.
> 
> The problem is if krealloc() fails: you've lost all those pointers to things
> you then need to free.

Huh?  How could that happen?

krealloc must always use a temporary.
If krealloc returns NULL, the original allocation is kept.

> > Are there no locking constraints?
> 
> Generally, no, not until you do the ->mount() op.  Also remounting needs a
> lock, but that's already done with the sb->s_umount lock.
> 
> However, that said, if you do:
> 
> 	fd = fsopen("foofs");
> 	write(fd, "o foo=bar", ...);
> 	fsmount(fd, "/foo");
> 
> then the fsmount() and write() calls have to lock against other fsmount() and
> write() calls.  I use the inode lock for this.  [Note that it probably should
> be interruptible rather than just killable, but there's no primitive for that
> as yet].
> 
> David
