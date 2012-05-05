Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:35541 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757317Ab2EERXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 May 2012 13:23:33 -0400
Subject: [PATCH RFC 00/13] Lockd: grace period containerization
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Sat, 05 May 2012 21:21:30 +0400
Message-ID: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set is marked with RFC, because I'm still not quite sure, that this
implementation will satisfy other interested people.
So, would be appreciated for any comments.

This patch set makes grace period and hosts reclaiming network namespace
aware.

Main ideas:
1)  moving of 

	unsigned long next_gc;
	unsigned long nrhosts;

	struct delayed_work grace_period_end;
	struct lock_manager lockd_manager;
	struct list_head grace_list;

to per-net Lockd data.

2) moving of 

	struct lock_manager nfsd4_manager;

to per-net NFSd data.

3) shutdown + gc of NLM hosts done now network namespace aware.

4) restart_grace() now works only for init_net.

The following series implements...

---

Stanislav Kinsbursky (13):
      LockD: mark host per network namespace on garbage collect
      LockD: make garbage collector network namespace aware.
      LockD: manage garbage collection timeout per networks namespace
      LockD: manage used host count per networks namespace
      Lockd: host complaining function introduced
      Lockd: add more debug to host shutdown functions
      LockD: manage grace period per network namespace
      LockD: make lockd manager allocated per network namespace
      NFSd: make nfsd4_manager allocated per network namespace context.
      SUNRPC: service request network namespace helper introduced
      LockD: manage grace list per network namespace
      LockD: pass actual network namespace to grace period management functions
      Lockd: move grace period management from lockd() to per-net functions


 fs/lockd/grace.c            |   16 +++++--
 fs/lockd/host.c             |   92 +++++++++++++++++++++++++++++--------------
 fs/lockd/netns.h            |    7 +++
 fs/lockd/svc.c              |   43 ++++++++++++--------
 fs/lockd/svc4proc.c         |   13 +++---
 fs/lockd/svclock.c          |   16 ++++---
 fs/lockd/svcproc.c          |   15 ++++---
 fs/lockd/svcsubs.c          |   19 ++++++---
 fs/nfs/callback_xdr.c       |    4 +-
 fs/nfsd/export.c            |    4 +-
 fs/nfsd/netns.h             |    2 +
 fs/nfsd/nfs4idmap.c         |    4 +-
 fs/nfsd/nfs4proc.c          |   18 +++++---
 fs/nfsd/nfs4state.c         |   60 ++++++++++++++++------------
 fs/nfsd/state.h             |    3 +
 include/linux/fs.h          |    5 +-
 include/linux/lockd/lockd.h |    6 +--
 include/linux/sunrpc/svc.h  |    2 +
 18 files changed, 204 insertions(+), 125 deletions(-)

