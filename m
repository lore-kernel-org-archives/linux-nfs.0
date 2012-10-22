Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888Ab2JVR16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Oct 2012 13:27:58 -0400
Message-ID: <5085821C.4020500@RedHat.com>
Date: Mon, 22 Oct 2012 13:27:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] nfs-utils compiler warning clean ups
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/10/12 12:05, Chuck Lever wrote:
> Hi-
> 
> These address compiler warnings in mountd and gssd that I've found
> during recent sojourns in that code base.  I've done some light
> testing, but more critical review and testing would be appreciated.
> 
> I think these are appropriate for your next release of nfs-utils.
What CFLAGS do you use to see these warnings? Every time I do a build
I check for warnings and if I would have seen these I would have
fixed them immediately...   

BTW, I'm using gcc version 4.7.2 20120921 (Red Hat 4.7.2-2) (GCC)
to do my builds these days...

steved.

> 
> ---
> 
> Chuck Lever (10):
>       rpc.gssd: Squelch compiler error
>       rpc.gssd: Squelch compiler warning
>       rpc.gssd: Squelch compiler warning
>       mountd: Avoid unnecessary type conversions
>       mountd: Avoid unnecessary type conversions
>       mountd: Avoid unnecessary type conversions
>       mountd: Make local functions static
>       mountd: Eliminate unnecessary type conversions
>       mountd: Avoid unnecessary type conversions
>       nfs-utils: Eliminate dereferencing type punned pointers
> 
> 
>  support/include/nfslib.h   |    1 +
>  support/include/sockaddr.h |   10 ++++------
>  support/nfs/cacheio.c      |    5 +++++
>  utils/gssd/gss_util.c      |    2 +-
>  utils/gssd/gssd_proc.c     |   13 +++++++------
>  utils/mountd/cache.c       |   34 ++++++++++++++++++----------------
>  6 files changed, 36 insertions(+), 29 deletions(-)
> 
