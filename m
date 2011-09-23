Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41972 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691Ab1IWOq6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 10:46:58 -0400
Received: by wwf22 with SMTP id 22so3762999wwf.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 07:46:57 -0700 (PDT)
In-Reply-To: <1316788444.14812.10.camel@lade.trondhjem.org>
References: <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 07:46:37 -0700
Message-ID: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 7:34 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> My objections are due to the other cases that I pointed out, where
> Miklos's patch introduced changes in behaviour that IMO are unnecessary
> and incorrect.

Guys, it wasn't Mikos' patch that introduced the changes!

What's so hard to understand here?

That's why I'm so upset. People talk stupid sh*t about "correct
behavior" when clearly no such thing *exists*. And people talk about
Miklos changes as if they were some radical change that changed
behavior, when they were only a revert to old behavior to begin with
(at least as far as autofs is concerned)!

Get a grip, people. Stop over-analyzing things. Stop bothering to
mention what Solaris does, when the *MUCH* bigger issue is what
*Linux* has done for years and years.

Stop saying "we'll revert Miklos patch" in the same sentence where you
then seem to not even understand that the *original* behavior was the
one that Miklos patch re-introduced.

Reverting Miklos patch isn't a revert. THAT is the "semantic change".
That's the one you need to explain why the heck it would be the right
thing to do, rather than imply that we'd be going back to some known
state.

                              Linus
