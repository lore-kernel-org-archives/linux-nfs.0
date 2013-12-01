Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:39511 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab3LASNc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 13:13:32 -0500
Date: Sun, 1 Dec 2013 18:13:29 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Message-ID: <20131201181329.GC10323@ZenIV.linux.org.uk>
References: <20131201131441.790963326@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 01, 2013 at 05:14:41AM -0800, Christoph Hellwig wrote:
> This series tries to get rid of the damage created by sprinkling the
> network namespace cat poo all over rpc_pipefs and users.
> 
> Instead of getting lost in a maze of notifiers and infrastructure build
> around it a cargo cult manner we revert to a slightly nicer version of
> the pre-namespace API.
> 
> To do this we just have to create an in-kernel instance of rpc_pipefs
> that is mounted at network namespace creation so that all functions can
> operated on it.
> 
> As-is this has one major downside: because the initial mount already grabs
> a reference to the network namespace we'll create a cyclic reference and
> will never free the network namespace.

Making the series no-go in that form, obviously.

> To get around this we'd need
> some way to only grab it once user mounts show up / disapear in the VFS.

Hmm...  FWIW, there already is something of that sort; it _is_ ugly, but it
might be a food for thought...

AFAICS, pid_ns gets internal procfs instance and it pins the sucker down.
Which would cause exact same problems, obviously.  The trick done there
is more or less to introduce a "being shut down" state of pid_ns - from
the moment when we don't have any pids in it to actual destruction.
Entering that state schedules (yes, it is async and yes, it is ugly)
dropping the internal procfs vfsmount.

Additional headache, AFAICS, comes from /proc/self/ns/pid - it can be
opened, passed to somebody in ancestor pidns and then fed by it to
setns(2).  After that fork() by that somebody will trigger alloc_pid() in
that pid_ns.  What happens if it comes just before the (already scheduled)
pid_ns_release_proc()?  AFAICS, nothing good - there's no protection
against leaks, access to freed vfsmount, double-mntput, etc.  Eric, am
I missing something subtle and relevant in that code?
 
> Given that the namespace kraken has infected various internal filesystem
> and will get more soon I suspect this problem is or will become generic
> and will need a proper solution anyway.  Al, any good ideas how to deal
> with this?  Most straight forward way would be to add a counter of
> user vfsmount to the superblock and methods when it goes to 1 and 0,
> but that seems a bit ugly.

Folks, please, _please_, let's formulate the lifecycle rules first; we
already had way too much trouble from putting mechanism first only to
run into questions like the above ("what happens if somebody tries to
allocate a PID in pid_ns that is already scheduled for shutdown?").
Remember the (recurring) fun with kobject-related lifetime issues?
Or rpc_pipefs notifier ugliness, for that matter...
