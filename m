Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53780 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbbL0Aim (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 19:38:42 -0500
Date: Sun, 27 Dec 2015 00:38:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Donald Buczek <buczek@molgen.mpg.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH] nfs: do not deny execute access based on outdated mode
 in inode
Message-ID: <20151227003837.GE20997@ZenIV.linux.org.uk>
References: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
 <CAHQdGtSCn4bbx4xiyE7FXmWk3SCY81mvWLJz_1VDow9YtB5VgA@mail.gmail.com>
 <567F29A7.2020906@molgen.mpg.de>
 <CAHQdGtSUmwVv0Do6Gu5=x+BonsoAi4afo_RzOo8KG+wp75t4aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSUmwVv0Do6Gu5=x+BonsoAi4afo_RzOo8KG+wp75t4aw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 26, 2015 at 07:11:16PM -0500, Trond Myklebust wrote:

> Ah... IOW: That so called "fast path" crap in do_last() is screwing us
> over by forcing us to to 2 ACCESS calls. The first being done for no
> good reason by the VFS, and the second being done in the OPEN call to
> the server in the NFS client.

Excuse me, but this is complete BS.  First of all, are you suggesting
that every filesystem out there must push the permission checks into
its ->open()?  This may_open() is where they normally happen...

Moreover, the things like "this mount is r/o, don't let anything to
be opened on it" are inherently client-side.  It's a property of
vfsmount; the same fs instance might be accessible r/w in another
place.  And things like opening a device node, etc. are not reaching
the server at all.

> > Merry Christmas
> 
> Suggestions Al?

Make nfs_permission() relax the checks when it sees MAY_OPEN, if you know
that things will be caught by server anyway?
