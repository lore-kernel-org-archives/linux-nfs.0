Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52714 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756100AbaDWDsM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2014 23:48:12 -0400
From: NeilBrown <neilb@suse.de>
To: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 23 Apr 2014 12:40:58 +1000
Subject: [PATCH/RFC 0/5] Support loop-back NFS mounts - take 2
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-ID: <20140423022441.4725.89693.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a somewhat shorter patchset for loop-back NFS support than
last time, thanks to the excellent feedback and particularly to Dave
Chinner.  Thanks.

Avoiding the wait-for-congestion which can trigger a livelock is much
the same, though I've reduced the cases in which the wait is
by-passed.
I did this using current->backing_dev_info which is otherwise serving
no purpose on the current kernel.

Avoiding the deadlocks has been turned on its head.
Instead of nfsd checking if it is a loop-back mount and setting
PF_FSTRANS, which then needs lots of changes too PF_FSTRANS and
__GFP_FS handling, it is now NFS which checks for a loop-back
filesystem.

There is more verbosity in that patch (Fifth of Five) but the essence
is that nfs_release_page will now not wait indefinitely for a COMMIT
request to complete when sent to the local host.  It still waits a
little while as some delay can be important. But it won't wait
forever.
The duration of "a little while" is currently 100ms, though I do
wonder if a bigger number would serve just as well.

Unlike the previous series, this set should remove deadlocks that
could happen during the actual fail-over process.  This is achieved by
having nfs_release_page monitor the connection and if it changes from
a remote to a local connection, or just disconnects, then it will
timeout.  It currently polls every second, though this probably could
be longer too.  It only needs to be the same order of magnitude as the
time it takes node failure to be detected and failover to happen, and
I suspect that is closer to 1 minute.  So maybe a 10 or 20 second poll
interval would be just as good.

Implementing this timeout requires some horrible code as the
wait_on_bit functions don't support timeouts.  If the general approach
is found acceptable I'll explore ways to improve the timeout code.

Comments, criticism, etc very welcome as always,

Thanks,
NeilBrown


---

NeilBrown (5):
      MM: avoid throttling reclaim for loop-back nfsd threads.
      SUNRPC: track whether a request is coming from a loop-back interface.
      nfsd: Only set PF_LESS_THROTTLE when really needed.
      SUNRPC: track when a client connection is routed to the local host.
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.


 fs/nfs/file.c                   |    2 +
 fs/nfs/write.c                  |   73 +++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfssvc.c                |    6 ---
 fs/nfsd/vfs.c                   |   12 ++++++
 include/linux/freezer.h         |   10 +++++
 include/linux/sunrpc/clnt.h     |    1 +
 include/linux/sunrpc/svc.h      |    1 +
 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/xprt.h     |    1 +
 include/uapi/linux/nfs_fs.h     |    3 ++
 mm/vmscan.c                     |   18 +++++++++-
 net/sunrpc/clnt.c               |   25 +++++++++++++
 net/sunrpc/svcsock.c            |   10 +++++
 net/sunrpc/xprtsock.c           |   17 +++++++++
 14 files changed, 163 insertions(+), 17 deletions(-)

-- 
Signature

