Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53768 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750883AbdEIJc2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 May 2017 05:32:28 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
References: <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com> <10943.1494284264@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 09 May 2017 10:32:25 +0100
Message-ID: <15607.1494322345@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> Forget remount, it's a historical remnant.

I don't think it can't be set aside so lightly.  Within the kernel, the option
parsing should share as much code as possible between new superblock config,
old new mount and old remount.

The 'trickiest' function we need to support is MS_RDONLY flipping.  That one
affects both the mount and the superblock.  I think all the rest only affect
one side or the other.

Given that a superblock can be mounted in multiple places, do we need to count
the number of read-only mounts that are holding a particular superblock and
only flip the superblock when they're all read-only?

Or do you advocate replacing "mount -o remount,[ro|rw]" with a pair of
operations - one to flip the mount and the other to flip the superblock?

Further, "emergency remount r/o" needs to be supported - though it might make
sense to add a special op just for that.

David
