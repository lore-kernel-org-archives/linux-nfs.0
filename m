Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:42732 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933244AbeFLRnK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jun 2018 13:43:10 -0400
MIME-Version: 1.0
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com>
In-Reply-To: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jun 2018 10:42:58 -0700
Message-ID: <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for 4.18
To: trondmy@hammerspace.com, NeilBrown <neilb@suse.com>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 12, 2018 at 6:39 AM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> NeilBrown (4):
>       rculist: add list_for_each_entry_from_rcu()

Oh christ, people. Not another one of these.

We need to start having a real rule in place where people DO NOT PLAY
GAMES WITH RCU LISTS.

Adding Paul McKenney to the list, since he clearly wasn't for the
actual development, and the commit has no sign that it was sanity
checked.

This whole "let's re-start RCU walking in the middle after we've
dropped the RCU read lock" needs a hell of a lot more thought than
people seem to actually be giving it.

Maybe the code is actually correct - it looks ok to me. But every time
I see it I just shudder.

What people actually want is to just have a cursor entry in an RCU
list. I'd much rather have *that*, than have people make up these
insane ad-hoc cursor entries that are insane and have horrible
semantics.

For example, looking at that commit e04bbf6b1bbe ("NFS: Avoid
quadratic search when freeing delegations"), it even talks about the
ad-hoc cursor entry not actually being reliable, and how that's ok
because the code doesn't care. No, random odd behavior that is
basically never ever going to be testable is *NOT* ok.

So could we please have a cursor entry for RCU walking, and actually
have a agreed-upon way to do this? Maybe even using the low bit in the
"next" field to mark a cursor entry generically - the same way we
already do for the HEAD field in the bit-locked lists, just on the
actual entries _on_ the list instead.

Because we now have *two* of these odd special "restart the loop in
the middle" come in during the same merge window. That really implies
to me that we should have a _proper_ solution for the problem, not
this horribly nasty case where people make up their own pseudo-cursors
that have odd and questionable semantics.

Paul, comments?

                 Linus
