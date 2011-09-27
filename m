Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:34749 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752466Ab1I0Evj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 00:51:39 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com>
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
	 <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
	 <1316827854.3346.154.camel@perseus.themaw.net>
	 <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
	 <20110924073610.4b045189@tlielax.poochiereds.net>
	 <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com>
	 <1317013864.3187.81.camel@perseus.themaw.net>
	 <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com>
	 <1317071626.19951.8.camel@lade.trondhjem.org>
	 <CA+55aFzWCZQjWMcxg16yMUoLr-mEPuXzAFgv49LU4hCn+=rbwQ@mail.gmail.com>
	 <1317072718.19951.13.camel@lade.trondhjem.org>
	 <CA+55aFzaScGiKmsSrgXivoUPw4xHjKobsB4VquuEu1fG=7R+wA@mail.gmail.com>
	 <1317076424.19951.32.camel@lade.trondhjem.org>
	 <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
	 <1317078563.21770.8.camel@lade.trondhjem.org>
	 <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
	 <1317085155.21770.17.camel@lade.trondhjem.org>
	 <CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com>
	 <1317097001.3176.20.camel@perseus.themaw.net>
	 <CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Sep 2011 12:51:31 +0800
Message-ID: <1317099091.3176.31.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-26 at 21:35 -0700, Linus Torvalds wrote:
> On Mon, Sep 26, 2011 at 9:16 PM, Ian Kent <raven@themaw.net> wrote:
> >
> > This case is the one were there is no existing directory yet for the
> > automount (it's the age old original automount case where mount point
> > directories never existed within the automount managed directory before
> > being automounted). In this case we always want to automount regardless
> > of the lookup flags. So returning -EISDIR should be conditional on also
> > having a positive dentry.
> 
> Ok. This all just makes me more conviced that the LOOKUP_NO_AUTOMOUNT
> code is not even worth trying to salvage (ie not play any games with
> the existing AT_NO_AUTOMOUNT flag and perhaps turning
> !AT_SYMLINK_NOFOLLOW + !AT_NOAUTOMOUNT -> LOOKUP_AUTOMOUNT). That's
> the case that never tested for d_inode being NULL, so it got the
> autofs case wrong.

Agreed.

> 
> At some point we might want to expose an AT_AUTOMOUNT flag to user
> space _if_ it turns out that glibc or somebody wants really wants it,
> but the old flag clearly actually had a buggy implementation and
> almost certainly isn't worth worrying about.

Yes, I also thought that AT_NO_AUTOMOUNT would need to be removed and
AT_AUTOMOUNT added as part of the change. But that can be done as a
follow up.

> 
> Of course, we'll have to see if there are any actual regression
> reports in this area.. If something actually breaks, we may not have
> all that many choices. But at least tentatively, I think we can plan
> on applying the attached cleanup to just rip that out (it's already
> effectively dead code apart from the buggy lack of d_inode testing,
> since apart from d_inode, it never triggers unless the subsequent test
> triggers)..

Is there a source tree somewhere, I'm not sure now exactly what has been
changed. I can run tests if I can get accurate source.

Ian




