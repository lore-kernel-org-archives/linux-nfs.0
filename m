Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:34329 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaHCRDP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:15 -0400
Received: by mail-qa0-f44.google.com with SMTP id f12so6068584qad.3
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/11] SUNRPC server scalability improvements
Date: Sun,  3 Aug 2014 13:03:02 -0400
Message-Id: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

When testing knfsd on 10GigE and 40GigE networks, we've been hitting a few
scalability issues that are seriously affecting performance. The main issue
was scalability of the pool->sp_lock, but we also hit a couple of things
like the use of ioctls in the receive fast path, as well as some issues
with heuristic tests being performed twice in the same path.

This is not urgent, and can definitely be delayed until the 3.18 merge
window, however since the performance gains were significant over NFSv3,
I thought I'd share now.

Cheers
  Trond

Trond Myklebust (11):
  SUNRPC: Reduce contention in svc_xprt_enqueue()
  SUNRPC: svc_tcp_write_space: don't clear SOCK_NOSPACE prematurely
  SUNRPC: Allow svc_reserve() to notify TCP socket that space has been
    freed
  SUNRPC: Do not override wspace tests in svc_handle_xprt
  lockd: Ensure that lockd_start_svc sets the server rq_task...
  nfs: Ensure that nfs_callback_start_svc sets the server rq_task...
  SUNRPC: Do not grab pool->sp_lock unnecessarily in svc_get_next_xprt
  SUNRPC: get rid of the request wait queue
  SUNRPC: Fix broken kthread_should_stop test in svc_get_next_xprt
  SUNRPC: More optimisations of svc_xprt_enqueue()
  SUNRPC: Optimise away svc_recv_available

 fs/lockd/svc.c                  |   2 +
 fs/nfs/callback.c               |   1 +
 include/linux/sunrpc/svc.h      |   1 -
 include/linux/sunrpc/svc_xprt.h |   1 +
 net/sunrpc/svc.c                |   2 -
 net/sunrpc/svc_xprt.c           | 112 ++++++++++++++++++++--------------------
 net/sunrpc/svcsock.c            |  71 ++++++++++++-------------
 7 files changed, 96 insertions(+), 94 deletions(-)

-- 
1.9.3

