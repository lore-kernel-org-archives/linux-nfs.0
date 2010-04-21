Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60335 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038Ab0DURm5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:42:57 -0400
Received: by pwj9 with SMTP id 9so5322309pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:42:56 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/9] For 2.6.35
To: linux-nfs@vger.kernel.org
Date: Wed, 21 Apr 2010 13:42:54 -0400
Message-ID: <20100421173628.2037.54635.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'd like these patches to be considered for 2.6.35.

The patches posted last week that add kobjects for the NLM host and
NSM handle caches are also candidates for 2.6.35.  However, I'd like
to have a clear plan for how statd will use this new API before they
are committed upstream, to avoid kernel-user space API churn down
the road.

The first patch in the present series is the previously posted fix for
NFSv4 rsize and wsize.  If this patch hasn't already been accepted for
2.6.34 and prior kernels, please consider it for 2.6.35.

The final four patches in this series are meant to improve the
precision of RPC RTTs used for RTT estimation and reported via
/proc/mountstats.

---

Chuck Lever (9):
      SUNRPC: Replace jiffies-based metrics with ktime-based metrics
      ktime: introduce ktime_to_ms()
      SUNRPC: RPC metrics and RTT estimator should use same RTT value
      NFS: Calldata for nfs4_renew_done()
      NFS: Squelch compiler warning in nfs_add_server_stats()
      NFS: Clean up fscache_uniq mount option
      NFS: Squelch compiler warning
      SUNRPC: Trivial cleanups in include/linux/sunrpc/xdr.h
      NFS: rsize and wsize settings ignored on v4 mounts


 fs/nfs/client.c                |    2 ++
 fs/nfs/fscache.c               |    3 ++-
 fs/nfs/iostat.h                |    6 +++---
 fs/nfs/nfs4proc.c              |   26 ++++++++++++++++++++------
 fs/nfs/super.c                 |   18 +++++++++---------
 include/linux/ktime.h          |   10 ++++++++--
 include/linux/sunrpc/metrics.h |    7 ++++---
 include/linux/sunrpc/sched.h   |    5 +++--
 include/linux/sunrpc/xdr.h     |    8 +++++---
 include/linux/sunrpc/xprt.h    |    4 ++--
 net/sunrpc/sched.c             |    2 +-
 net/sunrpc/stats.c             |   27 +++++++++------------------
 net/sunrpc/xprt.c              |   19 ++++++++-----------
 net/sunrpc/xprtsock.c          |    1 -
 14 files changed, 76 insertions(+), 62 deletions(-)

-- 
Chuck Lever
