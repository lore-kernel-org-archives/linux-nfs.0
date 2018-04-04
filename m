Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:40359 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752318AbeDDWxE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Apr 2018 18:53:04 -0400
MIME-Version: 1.0
In-Reply-To: <152287964415.14760.2996398134900556495.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
 <152287964415.14760.2996398134900556495.stgit@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 Apr 2018 15:53:02 -0700
Message-ID: <CA+55aFymk0Na_eBp1FSoDgNhyBAnS7X_ZwgG6++LsvjpcUfuxw@mail.gmail.com>
Subject: Re: [PATCH 06/12] fscache: Detect multiple relinquishment of a cookie
To: David Howells <dhowells@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-afs@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 4, 2018 at 3:07 PM, David Howells <dhowells@redhat.com> wrote:
> Report if an fscache cookie is relinquished multiple times by the netfs.
>
> -       set_bit(FSCACHE_COOKIE_RELINQUISHED, &cookie->flags);
> +       if (test_and_set_bit(FSCACHE_COOKIE_RELINQUISHED, &cookie->flags))
> +               BUG();

Ugh. Please try to avoid adding BUG() calls for reporting. They can
often cause the machine to be basically dead.

This one seem fairly ok, simply because it looks like the only caller
doesn't really hold a lot of locks (the superblock s_umount lock, but
that may be all).

So I'll pull this change, I just wanted people to realize that if this
is a "help make sure we notice if things go wrong", then
"WARN_ON_ONCE()" or something is usually a better choice than
"potentially kill the machine and make it harder to actually see the
error".

                 Linus
