Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:61348 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbaKUTTj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2014 14:19:39 -0500
Received: by mail-qa0-f41.google.com with SMTP id f12so3956814qad.28
        for <linux-nfs@vger.kernel.org>; Fri, 21 Nov 2014 11:19:38 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] sunrpc: reduce pool->sp_lock contention when queueing a xprt for servicing
Date: Fri, 21 Nov 2014 14:19:27 -0500
Message-Id: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce!

Here are the patches that I had mentioned earlier that reduce the
contention for the pool->sp_lock when the server is heavily loaded.

The basic problem is that whenever a svc_xprt needs to be queued up for
servicing, we have to take the pool->sp_lock to try and find an idle
thread to service it.  On a busy server, that lock becomes highly
contended and that limits the throughput.

This patchset fixes this by changing how we search for an idle thread.
First, we convert svc_rqst and the sp_all_threads list to be
RCU-managed. Then we change the search for an idle thread to use the
sp_all_threads list, which now can be done under the rcu_read_lock.
When there is an available thread, queueing an xprt to it can now be
done without any spinlocking.

With this, we see a pretty substantial increase in performance on a
larger-scale server that is heavily loaded. Chris has some preliminary
numbers, but they need to be cleaned up a bit before we can present
them. I'm hoping to have those by early next week.

Jeff Layton (4):
  sunrpc: add a rcu_head to svc_rqst and use kfree_rcu to free it
  sunrpc: fix potential races in pool_stats collection
  sunrpc: convert to lockless lookup of queued server threads
  sunrpc: add some tracepoints around enqueue and dequeue of svc_xprt

 include/linux/sunrpc/svc.h    |  12 +-
 include/trace/events/sunrpc.h |  98 +++++++++++++++-
 net/sunrpc/svc.c              |  17 +--
 net/sunrpc/svc_xprt.c         | 252 ++++++++++++++++++++++++------------------
 4 files changed, 258 insertions(+), 121 deletions(-)

-- 
2.1.0

