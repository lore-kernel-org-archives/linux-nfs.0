Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34765 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752454AbeDFScN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2018 14:32:13 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFwKc1JzU6k=3R9n23HGXb5-BACT8pQ93rGTvgNjfa4ZHA@mail.gmail.com>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
 <4034.1523025880@warthog.procyon.org.uk> <CA+55aFwKc1JzU6k=3R9n23HGXb5-BACT8pQ93rGTvgNjfa4ZHA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 6 Apr 2018 11:32:11 -0700
Message-ID: <CA+55aFx_fs7C6JAX_ORJ9MoXEp25LcXS0CUnK4aO4p=hQw6xOg@mail.gmail.com>
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

On Fri, Apr 6, 2018 at 11:21 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> No, but if you can redo the pull request part so that the diffstat I
> get will match the diffstat I see in the pull request, that would be
> good.

Oh, and can you please make sure there is a "[GIT PULL]" in the
subject line for your pull requests?

Particularly during the merge window (not so much later) I end up
having a separate filtered list of emails that I look at that mention
"git pull".

Your pull requests don't seem to match that, so your pull requests
don't actually even show up in my list of pending pull requests.

That doesn't mean that they get lost - it just tends to mean that I
don't necessarily see them during my busiest days of pulling. I
usually start my days off looking at emails in general, so I see
discussions and I see your emails, but then when I start actually
pulling I go to that list of pending pull requests, and never actually
pull your stuff.

That all changes the second week of the merge window when I generally
don't have a separate list of pull requests at all (because I've
gotten through the big pile of pending stuff), so the pull *does*
eventually happen, but it kind of gets delayed.

For example, yesterday when I was doing filesystem pulls (I try to
often group "similar areas" together), I did nfsd and f2fs. I would
have done your afs and fscache pulls while at it, but they didn't show
up in my pull request list, so I didn't..

So if you have that [GIT PULL] in the subject line, the pulls will
often be a bit timelier.

(Again, this is mainly just an issue for the merge window, but it
certainly doesn't hurt at other times).

                 Linus
