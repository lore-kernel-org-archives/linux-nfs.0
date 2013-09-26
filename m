Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab3IZPVe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 11:21:34 -0400
Date: Thu, 26 Sep 2013 11:21:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Howells <dhowells@redhat.com>
Cc: Trond.Myklebust@netapp.com, olof@lixom.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC][PATCH 0/4] SunRPC/NFS: Use no_printk() in
Message-ID: <20130926152125.GD704@fieldses.org>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 03:45:02PM +0100, David Howells wrote:
> 
> 
> Here's a series of patches to make SunRPC/NFS use no_printk() to implement its
> null dfprintk() macro (ie. when RPC_DEBUG is disabled).  This prevents 'unused
> variable' errors from occurring when a variable is set only for use in
> debugging statements and renders RPC/NFS_IFDEBUG unnecessary.

Does this patch series fix any actual warnings?  Or does it just change
the way that we prevent the warnings?

Whatever, I've got no opinion--ACK for any parts that touch code I
maintain....

--b.

> 
> David
> ---
> David Howells (4):
>       SunRPC: Use the standard varargs macro method for dfprintk() and co.
>       SunRPC: Declare and use rpc_task_pid() to wrap task->tk_pid
>       SunRPC: Use no_printk() for the null dprintk() and dfprintk()
>       SunRPC: Kill RPC_IFDEBUG() and NFS_IFDEBUG()
> 
> 
>  fs/lockd/clntproc.c            |    2 +
>  fs/lockd/svc.c                 |    6 ++-
>  fs/lockd/svc4proc.c            |    2 +
>  fs/lockd/svclock.c             |    6 ++-
>  fs/lockd/svcproc.c             |    2 +
>  fs/nfs/direct.c                |    6 ++-
>  fs/nfs/fscache.c               |    2 +
>  fs/nfs/nfs4filelayout.c        |    8 ++--
>  fs/nfs/nfs4proc.c              |    2 +
>  fs/nfs/read.c                  |    4 +-
>  fs/nfs/write.c                 |    8 ++--
>  fs/nfsd/nfs4proc.c             |    6 +--
>  fs/nfsd/nfsfh.c                |   10 +++---
>  include/linux/nfs_fs.h         |    2 -
>  include/linux/sunrpc/debug.h   |   39 ++++++++++------------
>  include/linux/sunrpc/sched.h   |   20 ++++++++---
>  include/trace/events/sunrpc.h  |    8 ++--
>  net/sunrpc/auth.c              |   18 +++++-----
>  net/sunrpc/auth_gss/auth_gss.c |   20 ++++++-----
>  net/sunrpc/clnt.c              |   72 ++++++++++++++++++++--------------------
>  net/sunrpc/rpcb_clnt.c         |   34 +++++++++----------
>  net/sunrpc/sched.c             |   39 +++++++++-------------
>  net/sunrpc/svcsock.c           |   33 +++++++++++-------
>  net/sunrpc/xprt.c              |   30 ++++++++---------
>  net/sunrpc/xprtsock.c          |    2 +
>  25 files changed, 194 insertions(+), 187 deletions(-)
> 
