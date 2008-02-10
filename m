From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.25
Date: Sun, 10 Feb 2008 18:24:48 -0500
Message-ID: <20080210232448.GB20829@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755748AbYBJXZG@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes are available from the for-linus branch of the git
repository at:

  git://linux-nfs.org/~bfields/linux.git for-linus

The four patches from Jeff Layton fix a bug that can allow an
unresponsive client to hang lockd.  The other two patches are minor
compile fixes.

--b.

J. Bruce Fields (1):
      nfsd: clean up svc_reserve_auth()

Jeff Layton (4):
      NLM: set RPC_CLNT_CREATE_NOPING for NLM RPC clients
      NLM: have server-side RPC clients default to soft RPC tasks
      NLM: don't reattempt GRANT_MSG when there is already an RPC in flight
      NLM: don't requeue block if it was invalidated while GRANT_MSG was in flight

Roland Dreier (1):
      SUNPRC: Fix printk format warning

 fs/lockd/host.c                       |   10 +++++++++-
 fs/lockd/svclock.c                    |   28 ++++++++++++++++++++++++----
 include/linux/sunrpc/svc.h            |   13 +++++--------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    3 ++-
 4 files changed, 40 insertions(+), 14 deletions(-)
