Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707Ab2DJMQQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2012 08:16:16 -0400
Date: Tue, 10 Apr 2012 08:16:12 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120410081612.65dd25fa@tlielax.poochiereds.net>
In-Reply-To: <4F841D2A.9020504@parallels.com>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
	<4F841D2A.9020504@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Apr 2012 15:44:42 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 03.04.2012 16:14, Jeff Layton пишет:
> > The main reason for the grace period is to prevent the server from
> > allowing an operation that might otherwise be denied once the client has
> > reclaimed all of its stateful objects.
> >
> > Currently, the grace period handling in the nfsd/lockd server code is
> > very simple. When the lock managers start, they stick an entry on a list
> > and set a timer. When the timers pop, then they remove the entry from
> > the list. The locks_in_grace check just looks to see if the list is
> > empty. If it is, then the grace period is considered to be over.
> >
> > This is insufficient for a clustered filesystem that is being served
> > from multiple nodes at the same time. In such a configuration, the grace
> > period must be coordinated in some fashion, or else one node might hand
> > out stateful objects that conflict with those that have not yet been
> > reclaimed.
> >
> > This patch paves the way for fixing this by adding a new export
> > operation called locks_in_grace that takes a superblock argument. The
> > existing locks_in_grace function is renamed to generic_locks_in_grace,
> > and a new locks_in_grace function that takes a superblock arg is added.
> > If a filesystem does not have a locks_in_grace export operation then the
> > generic version will be used.
> >
> > Care has also been taken to reorder calls such that locks_in_grace is
> > called last in compound conditional statements. Handling this for
> > clustered filesystems may involve upcalls, so we don't want to call it
> > unnecessarily.
> >
> > For now, this patch is just an RFC as I do not yet have any code that
> > overrides this function and am still specing out what that code should
> > look like.
> >
> 

(sorry about the earlier truncated reply, my MUA has a mind of its own
this morning)

> Oops, I've noticed your patch after I replied in "Grace period" thread.
> This patch looks good, but doesn't explain, how this per-filesystem logic will 
> work in case of sharing non-nested subdirectories with the same superblock.
> This is a valid situation. But how to handle grace period in this case?

TBH, I haven't considered that in depth. That is a valid situation, but
one that's discouraged. It's very difficult (and expensive) to
sequester off portions of a filesystem for serving.

A filehandle is somewhat analogous to a device/inode combination. When
the server gets a filehandle, it has to determine "is this within a
path that's exported to this host"? That process is called subtree
checking. It's expensive and difficult to handle. It's always better to
export along filesystem boundaries.

My suggestion would be to simply not deal with those cases in this
patch. Possibly we could force no_subtree_check when we export an fs
with a locks_in_grace option defined.

> Also, don't we need to prevent of exporting the same file system parts but 
> different servers always, but not only for grace period?
> 

I'm not sure I understand what you're asking here. Were you referring
to my suggestion earlier of not allowing the export of the same
filesystem from more than one container? If so, then yes that would
apply before and after the grace period ends.

-- 
Jeff Layton <jlayton@redhat.com>
