Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299Ab2AEVsY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 16:48:24 -0500
Message-ID: <4F061AA5.6020808@RedHat.com>
Date: Thu, 05 Jan 2012 16:48:21 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] Bug fixes and NFS junction support
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
In-Reply-To: <20120104194136.21904.36616.stgit@degas.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/04/2012 02:56 PM, Chuck Lever wrote:
> Four minor bug fix patches, for what they're worth, then...
> 
> The fifth patch adds support in mountd for loading a plug-in to
> resolve NFS junctions.  The plug-in will be provided by fedfs-utils.
> Source code will be posted very soon for review.
> 
> We'd like to see this in Fedora 17, if convenient.  Meantime, let's
> review what I've got.
> 
> ---
> 
> Chuck Lever (5):
>       mountd: Support junction management plug-ins
>       mountd: remove newline from xlog() format specifier strings
>       mountd: Plug v4root memory leak
>       configure.ac: Don't check for AI_ADDRCONFIG
>       configure.ac: Clean up help string for --with-statdpath
All 5 patches have been committed...

I went ahead and fixed the snprintf length issue that was
brought up with the 5th patch... I neglected of fix the 
other issues that were pointed out... I will leave them
on my todo list but as always patches are welcome! 8-)

steved.

> 
> 
>  aclocal/ipv6.m4          |   11 --
>  configure.ac             |   10 +-
>  utils/mountd/Makefile.am |    2 
>  utils/mountd/cache.c     |  225 ++++++++++++++++++++++++++++++++++++++++++++++
>  utils/mountd/fsloc.c     |   10 +-
>  utils/mountd/v4root.c    |    2 
>  6 files changed, 237 insertions(+), 23 deletions(-)
> 
