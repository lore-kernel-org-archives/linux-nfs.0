Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:54662 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbeDFTkV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2018 15:40:21 -0400
MIME-Version: 1.0
In-Reply-To: <12717.1523042908@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
 <4034.1523025880@warthog.procyon.org.uk> <CA+55aFwKc1JzU6k=3R9n23HGXb5-BACT8pQ93rGTvgNjfa4ZHA@mail.gmail.com>
 <CA+55aFx_fs7C6JAX_ORJ9MoXEp25LcXS0CUnK4aO4p=hQw6xOg@mail.gmail.com> <12717.1523042908@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 6 Apr 2018 12:40:19 -0700
Message-ID: <CA+55aFxtYFbrt8=5tv5O8Ac-8JTcJMxUTZsOBsXcpoU-FBRVNA@mail.gmail.com>
Subject: Re: [PATCH net-next 00/12] fscache: Fixes, traces and development
To: David Howells <dhowells@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-afs@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 6, 2018 at 12:28 PM, David Howells <dhowells@redhat.com> wrote:
>
> That's okay with all the patches as follow up emails?

Actually, I generally just look at the git tree and don't need the
individual patches at all, at least as long as they are only to a
particular subsystem.

So if your git tree only touches fs/afs/ and fs/fscache/, just the
pull request email alone is sufficient.

It's only when people start touching core code or do cross-subsystem
things that I appreciate actually seeing the patches separated out.

In fact, even then it's generally fine to just point to the git tree
and just mention the patches that extend out of just the pure
subsystem (and why they do so).

Both your afs and fscache pulls looked fine to me, and didn't have
that issue (ok, the fscache one touches 9p and afs too, but those are
"afs and 9p use fscache", so it's not something that made me go
"Hmm..".

              Linus
