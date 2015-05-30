Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37248 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757563AbbE3MDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 May 2015 08:03:32 -0400
Received: by wifw1 with SMTP id w1so52765329wif.0
        for <linux-nfs@vger.kernel.org>; Sat, 30 May 2015 05:03:31 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>,
        Jerome Marchand <jmarchan@redhat.com>
Subject: [PATCH 0/4] sunrpc: clean up "swapper" xprt handling
Date: Sat, 30 May 2015 08:03:09 -0400
Message-Id: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series is a (small) overhaul of the swap-over-NFS code. The main
impetus is to fix the problem reported by Jerome Marchand. We currently
hold the rcu_read_lock when calling xs_swapper and that's just plain
wrong. The first patch in this series should fix that problem, and also
clean up a bit of a layering violation.

The other focus of this set is to change how the swapper refcounting
works. Right now, it's only tracked in the rpc_xprt, and there seem to
be some gaps in its coverage -- places where we should taking or
dropping references but aren't. This changes it so that the clnt tracks
the number of swapfiles that it has, and the xprt tracks the number of
"swappable" clients.

It also ensures that we only call sk_set_memalloc once per socket. I
believe that's the correct thing to do as the main reason for the
memalloc_socks counter is to track whether we have _any_
memalloc-enabled sockets.

There is still some work to be done here as I think there remains some
potential for races between swapon/swapoff, and reconnect or migration
events. That will take some careful thought that I haven't the time to
spend on at the moment. I don't think this set will make those races
any worse though.

Jeff Layton (4):
  sunrpc: keep a count of swapfiles associated with the rpc_clnt
  sunrpc: make xprt->swapper an atomic_t
  sunrpc: if we're closing down a socket, clear memalloc on it first
  sunrpc: lock xprt before trying to set memalloc on the sockets

 fs/nfs/file.c                | 11 ++------
 include/linux/sunrpc/clnt.h  |  1 +
 include/linux/sunrpc/sched.h | 16 +++++++++++
 include/linux/sunrpc/xprt.h  |  5 ++--
 net/sunrpc/clnt.c            | 67 ++++++++++++++++++++++++++++++++++++++------
 net/sunrpc/xprtsock.c        | 59 +++++++++++++++++++++++++++++---------
 6 files changed, 125 insertions(+), 34 deletions(-)

-- 
2.4.1

