Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbaIZSju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 14:39:50 -0400
Date: Fri, 26 Sep 2014 14:39:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140926183949.GC27412@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, I've seen the following *before* your patches, but in case
you're still looking at reboot recovery problems:

I'm getting sporadic failures in the REBT6 pynfs test--a reclaim open
succeeds after a previous boot (with full grace period) during which the
client had failed to reclaim.

I managed to catch one trace, the relevant parts looked like:

	SETCLIENTID client1
	OPEN
	LOCK

	(server restart here)

	SETCLIENTID client2
	OPEN
	LOCK (lock that conflicts with client1's)

	(server restart here)

	SETCLIENTID client1
	OPEN CLAIM_PREVIOUS

And all those ops (including the last reclaim open) succeeded.

So I didn't have a chance to review it more carefully, but it certainly
looks like a server bug, not a test bug.  (Well, technically the server
behavior above is correct since it's not required to refuse anything
till we actually attempt to reclaim the original lock, but we know our
server's not that smart.)

But I haven't gotten any further than that....

--b.

On Tue, Aug 19, 2014 at 02:38:24PM -0400, Jeff Layton wrote:
> v2:
> - move grace period handling into its own module
> 
> One of the huge annoyances in dealing with knfsd is the 90s grace period
> that's imposed when the server reboots. This is not just an annoyance,
> but means a siginificant amount of "downtime" in many production
> environments.
> 
> This patchset aimed at reducing this pain. It adds a couple of /proc
> knobs that tell the lockd and nfsd lock managers to lift the grace
> period.
> 
> It also changes the UMH upcalls to pass a little bit of extra info in
> the form of environment variables so that the upcall program can
> determine whether there are still any clients that may be in the process
> of reclaiming.
> 
> There are also a couple of cleanup patches in here that are not strictly
> required. In particular, making a separate grace.ko module doesn't have
> to be done, but I think it's a good idea.
> 
> Jeff Layton (5):
>   lockd: move lockd's grace period handling into its own module
>   lockd: add a /proc/fs/lockd/nlm_end_grace file
>   nfsd: add a v4_end_grace file to /proc/fs/nfsd
>   nfsd: remove redundant boot_time parm from grace_done client tracking
>     op
>   nfsd: pass extra info in env vars to upcalls to allow for early grace
>     period end
> 
>  fs/Kconfig                       |   6 ++-
>  fs/lockd/Makefile                |   3 +-
>  fs/lockd/netns.h                 |   1 -
>  fs/lockd/procfs.c                |  76 +++++++++++++++++++++++++++
>  fs/lockd/procfs.h                |  28 ++++++++++
>  fs/lockd/svc.c                   |  10 +++-
>  fs/nfs_common/Makefile           |   3 +-
>  fs/{lockd => nfs_common}/grace.c |  68 +++++++++++++++++++++----
>  fs/nfsd/Kconfig                  |   1 +
>  fs/nfsd/nfs4recover.c            | 107 +++++++++++++++++++++++++++++++--------
>  fs/nfsd/nfs4state.c              |   8 +--
>  fs/nfsd/nfsctl.c                 |  35 +++++++++++++
>  fs/nfsd/state.h                  |   5 +-
>  include/linux/proc_fs.h          |   2 +
>  14 files changed, 312 insertions(+), 41 deletions(-)
>  create mode 100644 fs/lockd/procfs.c
>  create mode 100644 fs/lockd/procfs.h
>  rename fs/{lockd => nfs_common}/grace.c (50%)
> 
> -- 
> 1.9.3
> 
