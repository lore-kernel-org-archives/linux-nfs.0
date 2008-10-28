From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/5] Fix rpcbind/rpcinfo build warnings
Date: Tue, 28 Oct 2008 10:15:40 -0400
Message-ID: <49071E8C.2040408@RedHat.com>
References: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46436 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbYJ1OWO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2008 10:22:14 -0400
In-Reply-To: <20081021220247.19488.82225.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Here's a handful of minor fix-ups for rpcbind that eliminate a bunch of
> warnings from autotool, make, and gcc.
> 
> ---
> 
> Chuck Lever (5):
>       rpcbind: Squelch autotool warning
>       rpcbind: Squelch make warnings
>       rpcbind: Squelch a compiler warning
>       rpcbind: Squelch a compiler warning
>       rpcbind: Squelch a compiler warning
> 
> 
>  configure.in    |    6 +++---
>  src/Makefile.am |    5 -----
>  src/rpcbind.c   |    1 +
>  src/rpcinfo.c   |    2 +-
>  src/warmstart.c |    1 -
>  5 files changed, 5 insertions(+), 10 deletions(-)
> 
All committed... thanks!

steved.
