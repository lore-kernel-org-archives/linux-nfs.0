Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36694 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965Ab1I0Ron (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 13:44:43 -0400
Date: Tue, 27 Sep 2011 10:38:22 -0700
From: Greg KH <gregkh@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ian Kent <raven@themaw.net>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Message-ID: <20110927173822.GC24197@suse.de>
References: <1317076424.19951.32.camel@lade.trondhjem.org>
 <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
 <1317078563.21770.8.camel@lade.trondhjem.org>
 <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
 <1317085155.21770.17.camel@lade.trondhjem.org>
 <CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com>
 <1317097001.3176.20.camel@perseus.themaw.net>
 <CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com>
 <1317099091.3176.31.camel@perseus.themaw.net>
 <CA+55aFwf8z+pi3okC2GmuYYKTN3hz+j5Y4XX4B=VrOP+YG0Qpw@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwf8z+pi3okC2GmuYYKTN3hz+j5Y4XX4B=VrOP+YG0Qpw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 27, 2011 at 08:22:24AM -0700, Linus Torvalds wrote:
> On Mon, Sep 26, 2011 at 9:51 PM, Ian Kent <raven@themaw.net> wrote:
> >
> > Yes, I also thought that AT_NO_AUTOMOUNT would need to be removed and
> > AT_AUTOMOUNT added as part of the change. But that can be done as a
> > follow up.
> 
> In fact, since reasonably automounting will always be an issue only
> for directories (yeah, in theory you could extend it to regular files,
> but why would you?) it's probably not even worth adding AT_AUTOMOUNT
> at all - you can do the same thing by just adding a '/' at the end of
> the filename instead, and suddenly it works for *all* the stat()
> family system calls, not just the odd statat() ones that almost nobody
> uses.
> 
> So it would be easy to add the AT_AUTOMOUNT flag, but whoever argues
> for it would have to be pretty convincing as to why it would be worth
> it.
> 
> I committed the patch I sent out with your and Trond's acks.

Does any of this make any sense for the 3.0-stable tree as well?

greg k-h
