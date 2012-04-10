Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41527 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758941Ab2DJUWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 16:22:54 -0400
Date: Tue, 10 Apr 2012 16:22:51 -0400
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120410202251.GH18465@fieldses.org>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
 <4F841D2A.9020504@parallels.com>
 <20120410081612.65dd25fa@tlielax.poochiereds.net>
 <4F842BAE.2010804@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F842BAE.2010804@parallels.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 04:46:38PM +0400, Stanislav Kinsbursky wrote:
> 10.04.2012 16:16, Jeff Layton пишет:
> >On Tue, 10 Apr 2012 15:44:42 +0400
> >
> >(sorry about the earlier truncated reply, my MUA has a mind of its own
> >this morning)
> >
> 
> OK then. Previous letter confused me a bit.
> 
> >
> >TBH, I haven't considered that in depth. That is a valid situation, but
> >one that's discouraged. It's very difficult (and expensive) to
> >sequester off portions of a filesystem for serving.
> >
> >A filehandle is somewhat analogous to a device/inode combination. When
> >the server gets a filehandle, it has to determine "is this within a
> >path that's exported to this host"? That process is called subtree
> >checking. It's expensive and difficult to handle. It's always better to
> >export along filesystem boundaries.
> >
> >My suggestion would be to simply not deal with those cases in this
> >patch. Possibly we could force no_subtree_check when we export an fs
> >with a locks_in_grace option defined.
> >
> 
> Sorry, but without dealing with those cases your patch looks a bit... Useless.
> I.e. it changes nothing, it there will be no support from file
> systems, going to be exported.
> But how are you going to push developers to implement these calls?
> Or, even if you'll try to implement them by yourself, how they will
> looks like?
> Simple check only for superblock looks bad to me, because any other
> start of NFSd will lead to grace period for all other containers
> (which uses the same filesystem).

That's the correct behavior, and it sounds simple to implement.  Let's
just do that.

If somebody doesn't like the grace period from another container
intruding on their use of the same filesystem, they should either
arrange to export different filesystems (not just different subtrees)
from their containers, or arrange to start all their containers at the
same time so their grace periods overlap.

--b.
