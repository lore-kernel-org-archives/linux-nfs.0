Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756619Ab2EHUCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 May 2012 16:02:38 -0400
Date: Tue, 8 May 2012 16:03:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsdcld: add support for dropping capabilities
Message-ID: <20120508160343.1114f01c@corrin.poochiereds.net>
In-Reply-To: <20120508193429.GA17669@fieldses.org>
References: <1336491712-29445-1-git-send-email-jlayton@redhat.com>
	<20120508193429.GA17669@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 May 2012 15:34:29 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, May 08, 2012 at 11:41:52AM -0400, Jeff Layton wrote:
> > As a long running daemon, we need to be security-conscious with nfsdcld,
> > so let's prune what it can do down to nearly nothing.
> > 
> > We want the daemon to run as root so that it has access to open and
> > reopen the rpc_pipefs pipe, but we don't actually need any of the
> > superuser caps that come with it. Have it drop all capabilities early
> > on. We don't need any of them as long as the fsuid continues to be 0.
> 
> Makes sense to me.
> 
> (In practice, though, surely fsuid=0 is often enough to get everything?)
> 
> --b.
> 

With this, root is basically a user like any other. He has to have
explicit permissions to access anything. If another user owns a file
and it's not world readable (or group readable by a group to which root
is a member), then the process won't be able to read it. Granted, a lot
of files are owned by root on a typical machine, but this should still
prevent access to any that aren't.

This also trims out all of the other extraneous stuff we don't need --
being able to bind to low sockets, traverse directories in which root
has no explicit access, chown ability, etc...

There are a couple of other approaches we could take here instead:

1) we could run as an unprivileged user and keep CAP_DAC_OVERRIDE.
I think that's less safe than what I'm doing here though...

2) we could teach the kernel to create the pipe with a different owner
and then run the daemon as a non-root user. That means we'd need some
mechanism to tell the kernel what we want that owner to be. I'm not
sure how that would work in practice -- maybe a new file
in /proc/fs/nfsd ?

In any case, I think this is probably good enough for now. This daemon
doesn't listen on a socket or anything so any compromise of it would
be a local one. Users also don't generally interact with it directly,
so you'd need to jump through some hoops in order to break it I'd
think.

-- 
Jeff Layton <jlayton@redhat.com>
