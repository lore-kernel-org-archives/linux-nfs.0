Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58548 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab1IXBpW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 21:45:22 -0400
Received: by wyg34 with SMTP id 34so4460039wyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 18:45:20 -0700 (PDT)
In-Reply-To: <1316827854.3346.154.camel@perseus.themaw.net>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
 <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu> <1316827854.3346.154.camel@perseus.themaw.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 18:44:59 -0700
Message-ID: <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Ian Kent <raven@themaw.net>
Cc: Miklos Szeredi <miklos@szeredi.hu>, David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 6:30 PM, Ian Kent <raven@themaw.net> wrote:
>
> Perhaps, but that allows modules to circumvent VFS policy which is what
> allowed this situation to come up in the first place.

So, realistically, what's the downside of just adding LOOKUP_DIRECTORY
(or LOOKUP_OPEN) to the nfs_follow_remote_path() case?

And if we decide that we really *really* must never bind-mount a
automount point, we could certainly add LOOKUP_OPEN to that case too,
but my gut feel is that's a "doctor, doctor, it hurts when I put a
nail in my eye" kind of case - do we really care?  Is it a sane
operation to do to begin with?

My gut feel is that either of (or both) of
LOOKUP_OPEN/LOOKUP_DIRECTORY is a saner flag to check for than
LOOKUP_FOLLOW ever was. Let's keep LOOKUP_FOLLOW as being the "acts on
symlink or the thing it points to", and nothing else.

                  Linus
