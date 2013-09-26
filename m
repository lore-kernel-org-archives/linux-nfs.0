Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab3IZOpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:45:15 -0400
Subject: [RFC][PATCH 0/4] SunRPC/NFS: Use no_printk() in 
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: David Howells <dhowells@redhat.com>
Cc: olof@lixom.net, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Sep 2013 15:45:02 +0100
Message-ID: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Here's a series of patches to make SunRPC/NFS use no_printk() to implement its
null dfprintk() macro (ie. when RPC_DEBUG is disabled).  This prevents 'unused
variable' errors from occurring when a variable is set only for use in
debugging statements and renders RPC/NFS_IFDEBUG unnecessary.

David
---
David Howells (4):
      SunRPC: Use the standard varargs macro method for dfprintk() and co.
      SunRPC: Declare and use rpc_task_pid() to wrap task->tk_pid
      SunRPC: Use no_printk() for the null dprintk() and dfprintk()
      SunRPC: Kill RPC_IFDEBUG() and NFS_IFDEBUG()


 fs/lockd/clntproc.c            |    2 +
 fs/lockd/svc.c                 |    6 ++-
 fs/lockd/svc4proc.c            |    2 +
 fs/lockd/svclock.c             |    6 ++-
 fs/lockd/svcproc.c             |    2 +
 fs/nfs/direct.c                |    6 ++-
 fs/nfs/fscache.c               |    2 +
 fs/nfs/nfs4filelayout.c        |    8 ++--
 fs/nfs/nfs4proc.c              |    2 +
 fs/nfs/read.c                  |    4 +-
 fs/nfs/write.c                 |    8 ++--
 fs/nfsd/nfs4proc.c             |    6 +--
 fs/nfsd/nfsfh.c                |   10 +++---
 include/linux/nfs_fs.h         |    2 -
 include/linux/sunrpc/debug.h   |   39 ++++++++++------------
 include/linux/sunrpc/sched.h   |   20 ++++++++---
 include/trace/events/sunrpc.h  |    8 ++--
 net/sunrpc/auth.c              |   18 +++++-----
 net/sunrpc/auth_gss/auth_gss.c |   20 ++++++-----
 net/sunrpc/clnt.c              |   72 ++++++++++++++++++++--------------------
 net/sunrpc/rpcb_clnt.c         |   34 +++++++++----------
 net/sunrpc/sched.c             |   39 +++++++++-------------
 net/sunrpc/svcsock.c           |   33 +++++++++++-------
 net/sunrpc/xprt.c              |   30 ++++++++---------
 net/sunrpc/xprtsock.c          |    2 +
 25 files changed, 194 insertions(+), 187 deletions(-)

