Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59001 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754608Ab1IWA4h convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 20:56:37 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Thu, 22 Sep 2011 17:56:20 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Cc: "Jeff Layton" <jlayton@redhat.com>, "Ian Kent" <raven@themaw.net>,
        "David Howells" <dhowells@redhat.com>, <miklos@szeredi.hu>,
        <viro@zeniv.linux.org.uk>, <gregkh@suse.de>,
        <linux-nfs@vger.kernel.org>, <leonardo.lists@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Linus Torvalds [mailto:torvalds@linux-foundation.org]
> Sent: Thursday, September 22, 2011 6:57 PM
> To: Myklebust, Trond
> Cc: Jeff Layton; Ian Kent; David Howells; miklos@szeredi.hu;
> viro@zeniv.linux.org.uk; gregkh@suse.de; linux-nfs@vger.kernel.org;
> leonardo.lists@gmail.com
> Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr,
etc.
> 
> On Thu, Sep 22, 2011 at 12:20 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > We need to audit not only NFS, but a bunch of stuff in the VFS.
> 
> Why? What has *anything*else* got to do with fixing a NFSv4 bug?
> 
> IOW, why the hell would we hold up one bugfix just because you might
want
> to look at something else too?

Your LOOKUP_DIRECTORY solution assumes that any and all syscalls that
_might_ want to automount a directory that is the last path element can
always predict in advance that the last path element will be a
directory. I'm challenging that assumption.
So if I ask for quotactl(/foo), why am I suddenly required to know in
advance that /foo might be a directory, and so make that a /foo/ so that
the automounted case suddenly works?

Your assumption is that in the majority of cases, we do _not_ want to
automount the final directory unless we know that we are expecting a
directory. As far as I'm concerned, if doesn't matter if you are
expecting a directory or not: with only a few exceptions, your
application is not supposed to be able to access the directory that will
be automounted over at all. The only reason for allowing the 'stat()'
exception is to optimize away the automount in the common case of an 'ls
-l' where the application doesn't care about accuracy.

  Trond
