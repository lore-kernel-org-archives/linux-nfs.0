Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34681 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbbKISjj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 13:39:39 -0500
Date: Mon, 9 Nov 2015 13:39:38 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH] Using pthreads to handle upcalls.
Message-ID: <20151109183938.GD8738@fieldses.org>
References: <1447074308-15823-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447074308-15823-1-git-send-email-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 09, 2015 at 08:05:07AM -0500, Steve Dickson wrote:
> Recently a bug was found that was causing a
> TGT fetch for every mount upcall. The bug was
> caused when forking for every mount was introduce.
> The global memory for the TGT cache was being
> freed when the forked process existed. 
> 
> The fix we came up with was to only fork on non-root
> upcalls, basically mount upcalls would no longer fork.
> In debugging the patch it became apparent that if the
> process hung, all NFS mounts on that client would be blocked.
> So at this point rpc.gssd is a single point of failure.
> 
> This patch replaces the forking/non-forking with creating
> pthreads for every upcall which I think is a better 
> solution to the original problem since pthreads can share
> global data. 

I seem to recall the reason for the fork is to allow dropping some
privileges while processing the upcall, is that right?  But looking at
pthreads(7), it looks like those are probably shared (e.g., it says user
and group IDs are process-wide).

> I was also hoping using pthread would bring more asynchronous
> to rpc.gssd. I was thinking rpc.gssd could take an upcall,
> fire off a thread to handle it, the go back and listen
> for more upcalls. 
> 
> Unfortunately this is not the case. It seems, maybe due to
> my lack of my pthreads understanding, that after each 
> pthread_create() call, a pthread_join() call, which waits for 
> the created to stop, is needed. Similar to fork/wait..

Actually making gssd thread-safe would be a significant effort.

> This means if an upcall pthread gets hung the daemon
> is also hung... The same single point of failure... 
> 
> I do believe using threads is a better solution than
> the non-fork solution, but rpc.gssd is still a single 
> point of failure. Plus I'm hoping moving to pthread will 
> allow us to solve that problem.

So this doesn't actually fix anything right now?

--b.

> 
> Steve Dickson (1):
>   gssd: use pthreads to handle upcalls
> 
>  aclocal/libpthread.m4  | 13 +++++++++++++
>  configure.ac           |  3 +++
>  utils/gssd/Makefile.am |  3 ++-
>  utils/gssd/gssd.c      | 18 ++++++++++++++++--
>  utils/gssd/gssd.h      |  2 ++
>  utils/gssd/gssd_proc.c | 30 ------------------------------
>  utils/gssd/krb5_util.c |  3 +++
>  7 files changed, 39 insertions(+), 33 deletions(-)
>  create mode 100644 aclocal/libpthread.m4
> 
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
