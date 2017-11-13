Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:40753 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdKMXyZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Nov 2017 18:54:25 -0500
MIME-Version: 1.0
In-Reply-To: <CA+55aFz4qA2RhjW5KtD+=jnbW-9hoRGgDQ5N6DkQ5LCTkO5idA@mail.gmail.com>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <87efp1zsww.fsf_-_@rasmusvillemoes.dk> <CA+55aFz4qA2RhjW5KtD+=jnbW-9hoRGgDQ5N6DkQ5LCTkO5idA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 13 Nov 2017 15:54:24 -0800
Message-ID: <CA+55aFwWt-hRSRqJRP6Wc67COZFZwpcMy4o06bRNBGnwW8QBFw@mail.gmail.com>
Subject: Re: bit tweaks [was: Re: [nfsd4] potentially hardware breaking
 regression in 4.14-rc and 4.13.11]
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 13, 2017 at 3:30 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So let's just rewrite that mnt_flags conversion that way, justr to get
> gcc to generate the obvious code.

Oh wow. I tried to do the same thing in fs/namespace.c where it does
the reverse bit translation, and gcc makes a _horrible_ mess of it and
actually makes the code much worse because for some reason the pattern
doesn't trigger.

So this gcc optimization is apparently pretty damn fragile in general.
It triggers for the trivial cases, but then other code around it can
confuse it badly.

So I don't think I'll touch this, it seems to not be really reliably
something that makes gcc generate what should be the obvious code..

               Linus
