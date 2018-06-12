Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32848 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753979AbeFLSGw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jun 2018 14:06:52 -0400
MIME-Version: 1.0
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com> <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
In-Reply-To: <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jun 2018 11:06:40 -0700
Message-ID: <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for 4.18
To: trondmy@hammerspace.com, NeilBrown <neilb@suse.com>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 12, 2018 at 10:42 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So could we please have a cursor entry for RCU walking, and actually
> have a agreed-upon way to do this? Maybe even using the low bit in the
> "next" field to mark a cursor entry generically - the same way we
> already do for the HEAD field in the bit-locked lists, just on the
> actual entries _on_ the list instead.

The real problem with a RCU cursor is that the lifetime of the cursor
is also RCU extended, so you can't do the traditional "just allocate
the cursor entry on the stack" that you can with synchronous locked
lists.

That makes it slightly more inconvenient to do simple cursors.

The dcache code has a fairly clean "dcache cursor", but it does use a
whole "struct dentry" for it (and it depends on "next_positive()" to
just skip them because dursors are never _positive_ dentries, so
there's some subtlety there).

But at least it's a very explicit cursor model, not that odd
delegation inode that seems to have a life as a real inode too.

So maybe a generic rcu-list cursor is too hard to do sanely, but can
we at least encourage that very explicit cursor model that is *only* a
cursor, and might not be touched/moved/reallocated by something else?

                Linus
