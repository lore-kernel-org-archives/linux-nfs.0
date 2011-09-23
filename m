Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64426 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab1IWQ0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 12:26:30 -0400
Received: by wwf22 with SMTP id 22so3882474wwf.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:26:29 -0700 (PDT)
In-Reply-To: <CA+55aFx03u51bbAPe_o=4PeyE0dFnuL1KyqRdTJCFUD-vM6V-w@mail.gmail.com>
References: <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
 <1316792468.3346.144.camel@perseus.themaw.net> <CA+55aFx03u51bbAPe_o=4PeyE0dFnuL1KyqRdTJCFUD-vM6V-w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 09:26:09 -0700
Message-ID: <CA+55aFwRQW_UVAE2-QukXBPT0UJiQhTio2ktPtn_EW5JjrFZ5w@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Ian Kent <raven@themaw.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 9:21 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> For example, I think the whole "let's consider lstat different from
> stat" model is broken.

Just to expand on that: I think it's also extra broken to then say "..
but we can randomly fix up user space" for it.

It's like saying "we have introduced a totally broken model, and now
we're going to make old applications change because we changed.

That's very much against the kernel philosophy. I realize other
projects work that way, but we really *really* don't work that way in
the kernel. We don't break old workflow unless there is some seriously
overriding reason, and I don't think "we have a new crazy model" is a
good reason.

If the lstat/stat difference made any sense, we could at least argue
for it. But it just doesn't.

                        Linus
