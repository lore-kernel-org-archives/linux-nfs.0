Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:35834 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755764AbbINPVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 11:21:24 -0400
Received: by ykdu9 with SMTP id u9so156702645ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 08:21:23 -0700 (PDT)
Date: Mon, 14 Sep 2015 11:21:20 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/4] fs: allow userland tasks to use delayed_fput
 infrastructure
Message-ID: <20150914112120.7d70afbe@tlielax.poochiereds.net>
In-Reply-To: <20150914144837.GA4332@fieldses.org>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
	<20150914144837.GA4332@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Sep 2015 10:48:37 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 14, 2015 at 09:45:51AM -0400, Jeff Layton wrote:
> > I'm breaking this piece out of the open file cache work for nfsd to see
> > if we can get this piece settled before I re-post the whole set. If this
> > looks like a reasonable approach we can sort out how it should be merged
> > (either by you directly, or via Bruce's tree with the rest of the open
> > file cache patches).
> > 
> > For those just joining in, some background:
> > 
> > We want to add an open file cache for nfsd to reduce the open/close
> > overhead on READ/WRITE RPCs, and so we can eliminate the raparm cache.
> > The basic idea is to keep a cache of open files, and close them down on
> > certain sorts of activity -- primarily, after an unlink that takes the
> > link count to 0, or before setting a lease.
> > 
> > The setlease part is problematic though. The plan is to have a notifier
> > callback into nfsd from vfs_setlease that will tell nfsd to close any
> > open files that are associated with the inode so we don't block lease
> > attempts solely due to cached but otherwise idle nfsd files. That means
> > that we need to be able to close out the files and ensure that the final
> > __fput runs before we try to set a lease.
> 
> I think I probably asked something similar before, but just to be sure I
> understand....  Do leases really need to be 100% reliable, or can we get
> away with saying "sorry, I don't feel like granting one right now".  An
> entry in the filehandle cache suggests we're likely to recall the thing
> soon anyway.  We use that option to get out of corner cases in the
> delegation case, but I don't know if it makes sense for oplocks.
> 


They don't need to be 100% reliable, but with the current design nfsd
will hold files open in the cache indefinitely, until one of the
following events occurs:

1) the exports cache is flushed (which is always done after unexporting)

2) an unlink event occurs that drops the i_nlink count to zero

3) userland attempts to set a lease

4) the shrinker kicks in

5) nfsd is shut down

So you could easily have a situation where a NFSv3 client does some
WRITE activity, and then an hour later samba comes along and asks for a
lease. I don't think we'd want to block the lease in that situation as
there's no reason to believe that we'd end up recalling it anytime
soon. The NFS client may be long gone at that point.

We could implement some heuristic that proactively closes out open
files that are idle for a certain amount of time. My first pass did
just that actually, but Christoph didn't much care for it, and I think
he was right. That's not as good a design as just keeping them open
until there's a real reason to close them.

-- 
Jeff Layton <jlayton@poochiereds.net>
