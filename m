Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53379 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757045AbaKSVh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Nov 2014 16:37:59 -0500
Date: Wed, 19 Nov 2014 16:37:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] sunrpc: fixes and cleanups for svc creation and
 thread handling
Message-ID: <20141119213758.GE14207@fieldses.org>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 19, 2014 at 07:51:12AM -0500, Jeff Layton wrote:
> Patch #1 in this series is a bugfix, but probably isn't worth sending to
> stable. The rest are just cleanups in preparation for some other patches
> that I have queued up. Can you consider these for 3.19?

Sure, I've read through them, they look fine.

When I tried to apply them to my for-3.19 there were rejects due to
tracing stuff in include/trace/events/sunrpc.h.  I haven't tried to
investigate yet.

--b.

> 
> The main one that I'm hoping to send soon for v3.19 is the one to help
> reduce the pool->sp_lock contention on busy servers. I have some
> preliminary numbers that look pretty good, but one of our QA folks is
> working on getting some better ones from a more rigorous test. I'll
> send those along in a few days once I have those numbers.
> 
> Jeff Layton (10):
>   sunrpc: release svc_pool_map reference when serv allocation fails
>   sunrpc: add a generic rq_flags field to svc_rqst and move rq_secure to
>     it
>   sunrpc: move rq_local field to rq_flags
>   sunrpc: move rq_usedeferral flag to rq_flags
>   sunrpc: move rq_dropme flag into rq_flags
>   sunrpc: move rq_splice_ok flag into rq_flags
>   sunrpc: move rq_cachetype field to better optimize space
>   sunrpc: convert sp_task_pending flag to use atomic bitops
>   sunrpc: have svc_wake_up only deal with pool 0
>   sunrpc: require svc_create callers to pass in meaningful shutdown
>     routine
> 
>  fs/lockd/svc.c                    |  2 +-
>  fs/nfsd/nfs4proc.c                |  6 ++---
>  fs/nfsd/nfs4xdr.c                 |  8 +++---
>  fs/nfsd/nfscache.c                |  4 +--
>  fs/nfsd/nfsfh.c                   |  2 +-
>  fs/nfsd/nfssvc.c                  |  2 +-
>  fs/nfsd/vfs.c                     |  6 ++---
>  include/linux/sunrpc/svc.h        | 22 +++++++++--------
>  include/trace/events/sunrpc.h     | 24 +++++++++++++-----
>  net/sunrpc/auth_gss/svcauth_gss.c |  2 +-
>  net/sunrpc/svc.c                  | 23 +++++++++---------
>  net/sunrpc/svc_xprt.c             | 51 ++++++++++++++++++---------------------
>  net/sunrpc/svcsock.c              |  5 +++-
>  13 files changed, 85 insertions(+), 72 deletions(-)
> 
> -- 
> 2.1.0
> 
