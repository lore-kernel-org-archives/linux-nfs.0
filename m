Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002Ab1IXLgp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Sep 2011 07:36:45 -0400
Date: Sat, 24 Sep 2011 07:36:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ian Kent <raven@themaw.net>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Message-ID: <20110924073610.4b045189@tlielax.poochiereds.net>
In-Reply-To: <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
 <1316747758.3346.89.camel@perseus.themaw.net>
 <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net>
 <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net>
 <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com>
 <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com>
 <1316788444.14812.10.camel@lade.trondhjem.org>
 <29743.1316791138@redhat.com>
 <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
 <1316827854.3346.154.camel@perseus.themaw.net>
 <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 23 Sep 2011 18:44:59 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, Sep 23, 2011 at 6:30 PM, Ian Kent <raven@themaw.net> wrote:
> >
> > Perhaps, but that allows modules to circumvent VFS policy which is what
> > allowed this situation to come up in the first place.
> 
> So, realistically, what's the downside of just adding LOOKUP_DIRECTORY
> (or LOOKUP_OPEN) to the nfs_follow_remote_path() case?
> 

There's certainly no danger in adding LOOKUP_DIRECTORY to that call. We
are, after all, looking for a directory there.

The problem is that that does not fully fix the NFS regression. NFS
(and CIFS) has always allowed the automounting of submounts to trigger
on stat() -- this is both before and after the d_automount patches went
in. Miklos' patch changes this.

The problem really boils down to this:

The d_automount patches changed autofs' automount trigger behavior to
be like that of NFS and CIFS. Miklos' patch reverts the behavior of
autofs to pre-2.6.38 behavior, but it also changes NFS and CIFS in the
same way, which is also a regression.

If you want to go back to pre-2.6.38 behavior, then you really have no
choice but to do re-introduce filesystem-specific behavior for
automounting. The behavior of autofs was different from that of
NFS and CIFS in earlier kernels.

-- 
Jeff Layton <jlayton@redhat.com>
