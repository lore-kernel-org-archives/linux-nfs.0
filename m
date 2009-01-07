From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] Three more nfs-utils clean ups
Date: Wed, 07 Jan 2009 12:54:20 -0500
Message-ID: <4964EC4C.6000908@RedHat.com>
References: <20090106231909.24661.92964.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33976 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbZAGR4i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2009 12:56:38 -0500
In-Reply-To: <20090106231909.24661.92964.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> While digging through the last set of bugs in 2008, I constructed
> these three fairly simple patches.  The middle one is probably the
> most interesting, as it provides a little more flexibility about
> how nfs-utils is built when libtirpc is present on the build system.
> 
> ---
> 
> Chuck Lever (3):
>       showmount command: Quiesce warning when TI-RPC is disabled
>       configure: Add new build option "--enable-tirpc"
>       configure: Remove inet_ntop(3) check from configure.ac
> 
> 
>  configure.ac                |   34 +++++++++++++++++++++++-----------
>  utils/showmount/showmount.c |   14 +++++++-------
>  2 files changed, 30 insertions(+), 18 deletions(-)
> 
Committed...

steved.
