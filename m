Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751233AbdECSlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 14:41:44 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1493836633.3180.9.camel@poochiereds.net>
References: <1493836633.3180.9.camel@poochiereds.net> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 May 2017 19:41:40 +0100
Message-ID: <4652.1493836900@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@poochiereds.net> wrote:

> I think one of the neat things here is that we can now error out as
> soon as a bogus mount option is passed in.

It means that the 'sloppy' option can also now be implemented in userspace.

> > Once fsmount() has been called, further write() calls will incur EBUSY,
> > even if the fsmount() fails.  read() is still possible to retrieve error
> > information.
> > 
> 
> What's the rationale for the above behavior?
> 
> A failed attempt to graft it into the tree doesn't seem like it would
> have any real effect on the mount_context. While I can't think of a use
> case for being able to try fsmount() again, I don't quite understand
> why we'd prohibit someone from doing it.

The mount procedure is allowed to preallocate resources and attach them to the
mount context and ->mount() is allowed to use them up, say by transferring
them to the superblock.  The mount context is then in a degraded state and
cannot necessarily be reused.

David

